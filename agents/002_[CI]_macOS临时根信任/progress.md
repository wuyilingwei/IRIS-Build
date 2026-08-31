# 操作日志

- 2026-08-31：加载 Agent Mode，检查 Build worktree、shell-build workflow 和现有静态测试。
- 2026-08-31：在 macOS matrix job 中加入公开 root SHA-1 预检、30 秒 `sudo -n security add-trusted-cert`，并在 always cleanup 中按固定 SHA-1 删除。
- 2026-08-31：运行 `test/test-signing-secrets.sh` 和 `actionlint .github/workflows/build.yml`，均通过；完成 diff 检查和提交内容关键词自检。
- 2026-08-31：修正 cleanup `always()` 条件的静态测试匹配方式，并重新运行静态测试与 actionlint。
