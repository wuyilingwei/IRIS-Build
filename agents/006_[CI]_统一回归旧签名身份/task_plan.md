# 任务计划

- [x] 审计 migration phase、签名 secret、P12 来源与 macOS 根信任路径
- [x] 将 shell-check 固定为既有统一 signing secret 对的前置验证
- [x] 将 Windows/macOS 签名与校验固定为旧身份，并只信任当前源码的旧公开 PEM
- [x] 移除 migration phase、专用 legacy secret、历史 P12 与新根分支
- [x] 更新静态契约测试并运行 YAML、actionlint 与静态验证
- [x] 审阅差异、提交隔离分支且不发布
