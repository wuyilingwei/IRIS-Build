# Findings

- 固定源提交 `9308241a` 含 legacy P12 与同名公开 PEM；公开 PEM 的 SHA-1 是 `7dbbec289bce316a2163ee3d4f4292836733bd78`。
- 当前 shell-build 已先 checkout `iris-source`，所以 bridge material 可从该 clone 的固定 Git object 写入 RUNNER_TEMP，不需要新 secret。
- 旧证书仅在固定旧提交构建时替代现行签名准备；shell-release 继续依赖 shell-build，不需要单独阻断条件。
- bridge phase 只提取历史 P12；profile、file-input 支持和 legacy PEM 必须已随当前 dispatch 源码合入，避免 CI 覆盖构建源码的辅助文件。
