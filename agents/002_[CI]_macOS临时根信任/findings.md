# 调研记录

- [安装包构建超过九分钟] -> source custom signer 在签名期间写入信任根 -> GitHub macOS runner 应在构建前一次性安装 tracked public root，避免签名回调进入授权路径。
- [清理范围] -> root SHA-1 为 `8601bb53dfc44d12d26f0e513ced84673b874cea` -> cleanup 使用该固定指纹删除，不按名称或宽泛匹配删除证书。
