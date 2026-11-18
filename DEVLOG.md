# 沐界输入法开发记录

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

### 待办
- 符号页底部 `《》` 与 `。` 的键位语义再梳理（当前可用但不够直观）。
- 空格滑动灵敏度可做成设置项。
- 中文候选长句、英文联想仍未做。
- 导航栏：如果目标机型不自动上移，需要按 `displayHeight - navBarHeight` 显式定位（目前 getLastWindow 在此扩展不可用，需另找 API）。
