# 调研记录

- worktree 仅包含 `.github/workflows/build.yml`，无现成 `/test` 或 Build 测试。
- workflow 在 shell-check、签名准备、签名身份校验、构建及产物校验处多次引用旧的 macOS-specific secrets；运行时变量已经是 `IRIS_SIGNING_CERT_BASE64/PASSWORD`。
- 替换后全 workflow 不再出现 `IRIS_MACOS_SIGNING_*`；Windows/macOS 的非 Ubuntu 构建步骤共用通用 secrets。
