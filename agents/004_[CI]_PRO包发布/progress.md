# 操作记录

- 2026-08-31：确认目标目录不存在；克隆 `wuyilingwei/IRIS-Build` 到隔离 worktree，并创建 `codex/pro-package-release`。
- 2026-08-31：读取 agent-mode 规范、现有工作流、签名约束测试，以及 IRIS 源仓的 PRO 打包与上传接口。
- 2026-08-31：在 Core 与 `shell-check` 行为门禁后加入单步 PRO 包打包/上传；每步在内存中生成一次性 32-byte base64url 密钥，退出时撤销变量并清理私有构建材料。
- 2026-08-31：为 Shell 矩阵构建加入同一 PRO 公钥配置，未向 artifact、job 输出或公开 release 添加 PRO 材料。
- 2026-08-31：在 Core 与 `shell-check` 中各增加独立的静态契约检查；保留真实的 Electron/GUI 行为门禁作为后续步骤。
- 2026-08-31：`bash test/test-signing-secrets.sh`、`bash test/test-pro-package-release.sh` 和 workflow YAML 解析通过；`git diff --check` 无输出。
