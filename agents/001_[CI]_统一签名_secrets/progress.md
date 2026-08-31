# 操作日志

- 2026-08-31：读取 `agent-mode` 规范，检查 worktree、workflow 和 git 状态。
- 2026-08-31：将 workflow 中所有旧 signing secret 引用替换为 `IRIS_SIGNING_P12_BASE64` / `IRIS_SIGNING_PASSWORD`，保留 `IRIS_SIGNING_CERT_BASE64/PASSWORD` 运行时 env。
- 2026-08-31：新增并运行 `test/test-signing-secrets.sh`；静态检查通过。
- 2026-08-31：运行 `actionlint .github/workflows/build.yml`，无输出即通过。
- 2026-08-31：已提交分支；提交前 `git diff --cached --check` 通过。
