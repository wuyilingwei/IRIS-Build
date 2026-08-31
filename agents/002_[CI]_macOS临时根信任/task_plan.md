# macOS 临时根信任计划

- [x] 检查 shell-build matrix、签名步骤和现有静态检查。
- [x] 在 macOS job 中加入受限时、无交互的 System.keychain root 安装。
- [x] 在 always 清理中按固定 SHA-1 删除该 root，并补充静态测试。
- [x] 运行 actionlint 与测试，复核 diff、完成审计记录并提交 Build 改动。
