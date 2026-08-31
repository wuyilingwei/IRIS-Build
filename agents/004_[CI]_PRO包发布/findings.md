# 调研记录

- [现有发布结构] -> Core 在行为门禁之后发布 Open Core，Shell 在 `shell-check` 生成共享材料并由矩阵构建安装包 -> PRO 包必须在这些边界之前由各入口各上传一次。
- [源仓接口] -> `npm run pro:pack` 需要版本、最小 Core 版本、签名私钥和 32-byte base64url 包密钥；上传脚本以相同密钥向私有许可服务上传 -> 密钥不能写入 job 输出或 artifact。
