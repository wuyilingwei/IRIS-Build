# 操作记录

- 2026-08-31：确认目标目录不存在；克隆 `wuyilingwei/IRIS-Build` 到隔离 worktree，并创建 `codex/pro-package-release`。
- 2026-08-31：读取 agent-mode 规范、现有工作流、签名约束测试，以及 IRIS 源仓的 PRO 打包与上传接口。
- 2026-08-31：在 Core 与 `shell-check` 行为门禁后加入单步 PRO 包打包/上传；每步在内存中生成一次性 32-byte base64url 密钥，退出时撤销变量并清理私有构建材料。
- 2026-08-31：为 Shell 矩阵构建加入同一 PRO 公钥配置，未向 artifact、job 输出或公开 release 添加 PRO 材料。
- 2026-08-31：在 Core 与 `shell-check` 中各增加独立的静态契约检查；保留真实的 Electron/GUI 行为门禁作为后续步骤。
- 2026-08-31：`bash test/test-signing-secrets.sh`、`bash test/test-pro-package-release.sh` 和 workflow YAML 解析通过；`git diff --check` 无输出。
- 2026-08-31：复审发现 Core payload 的两个打包步骤未接收 PRO 公钥；开始补充信任锚和密钥对一致性检查。
- 2026-08-31：`Pack core payload`、`Decrypt and pack core payload` 与 Shell installer 均使用同一配置公钥；两个私有上传步骤在上传前从私钥导出 Ed25519 原始公钥并恒定时间比较。
- 2026-08-31：补充测试后，签名约束测试、PRO 工作流解析/行为测试、`actionlint` 与 `git diff --check` 全部通过。
- 2026-08-31：复审发现标签部署密钥直到 PRO 上传后的 tag checkout 才会使用；开始将其纳入 Core 与 Shell 的入口预检。
- 2026-08-31：Core 与 `shell-check` 的入口均已验证标签部署密钥非空；两项 shell 测试、`actionlint`、YAML 解析与 `git diff --check` 通过。
