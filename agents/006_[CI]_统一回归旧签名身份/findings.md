# Findings

- 用户决定 Windows 与 macOS 统一使用既有 `IRIS_SIGNING_P12_BASE64`、`IRIS_SIGNING_PASSWORD`，不新增 bridge 专用 secret。
- shell-build 仍应先由 shell-check 验证统一 secret 对，再进入任何平台构建。
- macOS 临时信任应只使用源码跟踪的公开 PEM，并按固定旧根 SHA-1 `7dbbec289bce316a2163ee3d4f4292836733bd78` 清理。
- shell-release 的原子顺序保持 payload、shell assets、source tags、GitHub Release；本任务不触发发布。
- 源码提交 `19b54ec827c92a194453b9cca14a0058f20cd480` 已将 `iris-internal-signing-100y.cert.pem` 恢复为 SHA-1 `7dbbec289bce316a2163ee3d4f4292836733bd78`，并删除 signing profile 与双身份验证路径；与本 workflow 的单一映射一致。
