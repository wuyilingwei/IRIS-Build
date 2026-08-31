# 调研记录

- `shell-build` 当前的 `upload-artifact` 仅在前一步成功时执行，因此 `Verify signed installers` 失败会丢失已经生成的安装包；后续 `shell-release` 仍由 job 级成功状态门控，不会发布失败 job 的产物。
- 需要使用步骤级 `if: always() && hashFiles('staged-installers/**') != ''`，以便目录/文件不存在时跳过上传；`if-no-files-found: error` 保持不变，避免空目录被误判为诊断证据。
