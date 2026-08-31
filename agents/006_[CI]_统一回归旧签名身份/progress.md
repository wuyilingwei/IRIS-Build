# Progress

- 2026-08-31：创建隔离分支 `codex/revert-to-legacy-build`，从 IRIS-Build 当前 main 审计签名与发布链。
- 2026-08-31：确认现行 workflow 仍包含 migration phase、legacy 专用 secret 和新根分支，开始按用户决定统一回退。
- 2026-08-31：shell-check 改为在 source checkout 前校验既有统一 P12/password；Windows 与 macOS 的签名准备、身份校验、安装包构建和产物复核均只映射该对 secret。
- 2026-08-31：macOS 临时信任与 always cleanup 固定为旧根 `7dbbec289bce316a2163ee3d4f4292836733bd78` 和 `certificates/iris-internal-signing-100y.cert.pem`；删除 migration phase、专用 secret、profile 传递和新根路径。
- 2026-08-31：`bash test/test-signing-secrets.sh`、`bash test/test-pro-package-release.sh`、Ruby YAML 解析、`actionlint` 与 `git diff --check` 均通过。
- 2026-08-31：隔离分支提交完成，未推送、未触发 workflow、未发布。
- 2026-08-31：跨仓复核源码提交 `19b54ec827c92a194453b9cca14a0058f20cd480`：旧公开 PEM 的 SHA-1 为 `7dbbec289bce316a2163ee3d4f4292836733bd78`，源码已无 profile/new-root 分支；在其隔离 worktree 运行 12 个签名、更新与 Windows 校验测试全部通过。
