#!/usr/bin/env bash
# Build the HAP with hvigor. Produces build-artifacts/entry-unsigned.hap.
#   bash scripts/build.sh [--release]
#
# No IDE needed: uses the era-matching hvigor 3.2.4 plus the OpenHarmony SDK
# located by env.sh / common.sh. hvigorfile.ts requires the plugin by bare
# name, so NODE_PATH must point at the hvigor node_modules (env.sh sets it).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

MODE="$OHOS_BUILD_MODE"
[ "${1:-}" = "--release" ] && MODE="release"

step "检查构建前置条件"
[ -d "$OHOS_BASE_SDK_HOME/openharmony/toolchains" ] \
  || fail "OpenHarmony SDK 未就位：$OHOS_BASE_SDK_HOME/openharmony 不存在"
ok "SDK base: $OHOS_BASE_SDK_HOME"
NODE="$(resolve_node || true)"
[ -n "$NODE" ] || fail "找不到 node（设置 OHOS_NODE 或把 node 放进 PATH）"
[ -f "$HVIGOR_CLI" ] || fail "找不到 hvigor CLI：$HVIGOR_CLI"
[ -d "$NODE_PATH" ] || fail "NODE_PATH 指向的目录不存在：$NODE_PATH"
ok "hvigor -> $NODE $HVIGOR_CLI"
ok "module: $OHOS_MODULE   product: $OHOS_PRODUCT   mode: $MODE"

step "assembleHap (mode=$MODE)"
mkdir -p "$OHOS_OUT_DIR"
( cd "$OHOS_PROJECT_ROOT" && "$NODE" "$HVIGOR_CLI" assembleHap --mode module \
    -p "product=$OHOS_PRODUCT" \
    -p "buildMode=$MODE" \
    --no-daemon ) || fail "hvigor 构建失败。常见原因：
     1) Unable to find SDK -> export OHOS_BASE_SDK_HOME=<SDK 根>
     2) Unable to find components: toolchains:<api> -> SDK 根下缺 <api>/ 版本号目录
     3) spawn java ENOENT -> JDK 未进 PATH / JAVA_HOME 不对
     4) ArkTS 报错 -> 看上面第一条 ERROR 的文件与行号"

step "收集产物"
HAP=$(find "$OHOS_PROJECT_ROOT/$OHOS_MODULE/build" -name '*.hap' -not -path '*/node_modules/*' 2>/dev/null | sort | tail -1)
[ -n "$HAP" ] || fail "没找到 .hap 产物（$OHOS_PROJECT_ROOT/$OHOS_MODULE/build）"
ok "产物: $HAP ($(wc -c < "$HAP") bytes)"
case "$(basename "$HAP")" in
  *unsigned*) cp "$HAP" "$OHOS_UNSIGNED_HAP"; ok "未签名 -> $OHOS_UNSIGNED_HAP（下一步 sign.sh）" ;;
  *)          cp "$HAP" "$OHOS_SIGNED_HAP";   ok "已带签名 -> $OHOS_SIGNED_HAP" ;;
esac
ls -l "$OHOS_OUT_DIR"
