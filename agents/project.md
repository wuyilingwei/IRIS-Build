# IRIS-Build 项目索引
> 最后更新：2026-08-31

## 项目目标
维护 IRIS 发布构建 workflow，生成并发布跨平台安装包及核心构建产物。

## 技术栈
GitHub Actions YAML、Node.js 脚本、shell。

## 模块结构
- `.github/workflows/build.yml`：构建、签名校验与发布流程。
- `/test`：本地静态行为检查。
