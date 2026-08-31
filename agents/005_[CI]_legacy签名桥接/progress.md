# Progress

- 2026-08-31：建立 legacy-bridge workflow 审计与实施计划。
- 2026-08-31：shell-build 对固定 `9308241a` 的 non-Linux 构建提取 legacy P12 和公开 PEM 到 RUNNER_TEMP，以既有签名密码验证并设置 legacy-bridge profile；现行签名阶段仅在其他源提交运行。
- 2026-08-31：为 macOS 增加旧根 `7dbbec289bce316a2163ee3d4f4292836733bd78` 的临时 trust/finally cleanup；通用 cleanup 删除 legacy PEM，shell-release 未增加 bridge 前提。
- 2026-08-31：migration phase 默认 legacy-bridge，并保留 current 显式分支。旧 P12 预检先尝试 OpenSSL normal，再无输出地回退 legacy provider；静态映射检查、actionlint 与 YAML 解析通过。
