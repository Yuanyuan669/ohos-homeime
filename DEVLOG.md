# 沐界输入法开发记录

## 2026-11-24 候选长句核实 + 词典重建工具链

### 结论：中文候选长句引擎层已支持，待办过期
- 用设备端探针（加载 `dict_pinyin.dat` → `im_search` → `im_get_candidate`）实测：
  - `woxiangchifan` → 候选[0]「我想吃饭」，`im_choose(0)` 一次固定全部 4 音节并整句返回；
  - `jintiantianqihenhao` → 「今天天气很好」；`zhongguoren` → 「中国人」；`nihaoma` → 「你好吗」。
- ETS 链路完整：`worker.chooseAndUpdate` 在 `canDoPrediction()`（全部音节已固定）时把整句经
  `PinyinResultMessage` 提交 `insertText`；候选 0 号即整句（`imGetChoiceList` 已剥掉 fixed 前缀）。
- 即：**长句解码与整句上屏现在就能用**，之前待办「中文候选长句仍未做」不成立（英文联想仍未做）。

### 词典溯源（重要，2026-11-25 更正）
- 运行时 `rawfile/dict_pinyin.dat` **就是由仓内 `cpp/data/rawdict_utf16_65105_freq.txt` 构建的**：
  用仓内 share/ 源码 + 仓内 rawdict 重建出的 dat 与 shipped **md5 完全一致**（53e5e643…，1068442 字节）。
- 更正：此前记录「rawdict 全部为单字条目（0 条词组）」是错的——当时的 iconv 检测在本机根本没生效（无 iconv），结论无效。
  用 node 按 UTF-16LE 重新解码核实（**空格分隔，不是 tab**）：65105 条 = 17037 单字 + 48068 词组
  （2 字 34070 / 3 字 7372 / 4 字 6626，如「爸爸」「八百」「欧洲市场」），rawdict 本身含词组，与 md5 一致自洽。
- 另核实：用 rime `pinyin_simp` 派生 rawdict（61595 条，OpenCC TSCharacters 过滤繁体）也能重建出可加载词典，
  长句候选与 shipped 一致——可作为替代词典源。
- 重建工具链留在 `tools/dict-rebuild/`（convert.js 生成 rawdict，构建/探针二进制在设备端跑）。

### 设备端跑原生工具的坑（LHT16）
- OHOS SDK llvm 交叉编译 aarch64-linux-ohos **动态**二进制可在 `/data/local/tmp` 直接运行
  （`LD_LIBRARY_PATH=/system/lib64`）；**静态**链接的二进制一律 Signal 11，不要用 `-static`。
- 该设备无 32 位运行环境（armv7 二进制报 No such file or directory），只能 aarch64。
- `DictList::save_list` 用 `sizeof(size_t)` 写、`load_list` 用 `sizeof(uint32)` 读：
  在 64 位主机/工具里构建词典必须把 save 端改成 uint32（tools 里已带补丁版 dictlist_save32.cpp），
  否则产出的 dat 加载时 trie 段错位（读出的节点数是 ASCII 乱码值）。
- hdc 坑：`hdc file send 本地文件 /目标/不存在路径` 会把目标建成**目录**（文件落在目录内、沿用源文件名）；
  要发送成文件需先 `mkdir -p` 后 send 到 `目录/文件名`，或利用该目录语义 send 到 `目录/`。

### 待办（修订）
- 符号页：底排 `<` `>` `.` 在中文态已经由 PunctuationAdapter 适配为全角 `《` `》` `。`（显示与上屏一致），
  剩余是可选优化：把常用中文符号（、；：？！…—）直接排进符号网格，减少翻页。
- 空格滑动灵敏度可做成设置项。
- 英文联想仍未做。
- 导航栏：`resolveScreenBottom()` 现已尝试 `getLastWindow` + 避让区并有 displayHeight 兜底，
  待在目标机型核对日志确认生效后再关闭此条。

## 2026-11-18 布局与交互改进

### 本次改动
- 九键：字母键增加按压反馈；数字移到左上角，字母放大（19fp），标点键显示 `，。？`。
- 九键：长按 `1`（450ms）直接进入符号键盘；短按仍循环 `，。？`。
- 工具栏：高度 26→36vp，左侧显示 `拼音 · 九键/全键`，设置入口改为文字「设置」，图标点击区 40x40。
- 候选栏：高度 26→30vp，候选字号 19fp，增加上下细分隔线。
- 面板：竖屏高度 660→680px（272vp），横屏 700→740px（296vp）。
- 空格键：左右滑动移动光标（每 18vp 一步），滑动后不插入空格。
- 回车键：按 `enterKeyType` 显示 前往/搜索/发送/下一项/完成/上一项；其余显示 ↵。
  - **枚举坑**：SDK `EnterKeyType` 是 `UNSPECIFIED=0, NONE=1, GO=2, SEARCH=3, SEND=4, NEXT=5, DONE=6, PREVIOUS=7`，不是从 GO=1 开始。
- 符号页：第三行由 `Row` 改为 `Flex SpaceBetween`，修复删除键被挤出屏幕。
- 底部功能键统一 `height('100%')`，避免 48vp 行高内出现 50vp 键导致的裁切。

### 导航栏避让（三键导航）
- 系统设置：设置 → 系统 → 系统导航方式 → 关闭「手势导航开关」，即可恢复底部 ◁ ○ □。
- 实测 WindowManager 会整体上移 IME 面板：
  - 导航栏 `SystemUi_NavigationB` 矩形 `[0,2300,1080,108]`
  - 键盘 `softKeyboard1` 矩形 `[0,1620,1080,680]`（底部 2300，正好让开）
- `getLastWindow()` 在输入法扩展里会报 `1300002`，拿不到窗口/避让区；不要依赖它做精确 inset。当前做法是保留 `displayHeight` 兜底，由系统完成避让；竖屏下若系统不上移，再按 `displayHeight*0.045` 兜底减掉导航栏。
- 结论：三键导航开启后，九键/26 键底排都在导航栏上方，无需在 UI 里额外加 padding（否则会二次上移留白）。

### 构建/安装
```bash
cd /d/ohos-homeime
. scripts/env.sh
"$OHOS_NODE" "$HVIGOR_CLI" --mode module -p product=default -p buildMode=debug assembleHap
cp entry/build/default/outputs/default/entry-default-unsigned.hap build-artifacts/entry-unsigned.hap
bash scripts/sign.sh
hdc install -r build-artifacts/entry-signed.hap
```
安装后 IME 会重置为 Kika，需重新启用/切换 homeime。
