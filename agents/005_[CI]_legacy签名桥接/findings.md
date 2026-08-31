# Findings

- 旧公开根的 SHA-1 是 `7dbbec289bce316a2163ee3d4f4292836733bd78`；当前源码跟踪其公开 PEM，私钥不再由 workflow 从历史读取。
- 真实 CI 已证明历史 P12 不可由现行密码解锁，因此 bridge 必须使用独立、用户保留的 P12 与密码 secrets。
- `legacy-bridge` 与 `current` 是版本化 workflow phase，不允许 dispatch 输入或 fallback 覆盖；每个 phase 在 shell-check 先验证对应的 secret 对。
- shell-release 继续只依赖完整 shell-build 成功，保持 payload → assets → tags → GitHub Release 的原有提交顺序。
