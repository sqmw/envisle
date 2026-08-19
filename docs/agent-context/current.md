# 当前真相

- 更新日期：2026-08-19
- 当前主线：等待执行 `T-002 v2 macOS Runtime Provider 探针`。
- 当前状态：`T-001 v1` 与 `T-004 v1` 已关闭；产品代码尚未开始。

## 当前有效结论

1. 产品路径已冻结为 `Managed Runtime Platform`：一实例一受管 VM 是默认安全边界，共享和入站网络默认关闭并由产品显式授权。
2. MVP 产品范围以 Apple silicon + macOS 26 host、项目提供的 ARM64 Linux guest 为冻结目标；Runtime 可行性与实现方式尚未通过探针。
3. Android host 上的 AVF/pKVM 需要平台签名/OEM 权限，不属于普通第三方 APK 路径。
4. QEMU 的 HVF/WHPX 只为同 ISA 提供硬件虚拟化；跨 ISA 使用 TCG，必须显式标记兼容模式。
5. 标准产品名为 `Envisle`、repository slug 为 `envisle`；`OSDeck` / `osdesk` 只作历史旧称。

## 当前待验证

- `T-002 v2` 需验证受管 VM 生命周期、默认隔离、显式共享/端口和失败边界。
- UI/Core/Provider 语言栈在探针前不冻结。
- `Envisle` 只完成工程冲突初筛；正式商标检索不属于当前工程结论。

## 当前风险

- macOS guest 的许可用途和最多两个额外副本限制必须进入产品策略；这不是框架技术上限。
- Apple `container` 的 OCI 兼容不等于 Docker Engine、Compose 或 `docker.sock` 兼容。
- VM、容器和 AVD 的镜像/快照/网络语义不能统一承诺。
- 本项目位于可能同步到 Windows 的工作区，运行数据必须置于仓库和同步目录外。

## 验证与导航

- 最低验证：`make check`
- 主 TODO：[`../TODO.md`](../TODO.md)
- 主 STEPS：[`../STEPS.md`](../STEPS.md)
- 产品路径：[`../architecture/product-options.md`](../architecture/product-options.md)
- MVP 冻结基线：[`../architecture/mvp-baseline.md`](../architecture/mvp-baseline.md)
- 研究证据：[`../research/breadth-scan.md`](../research/breadth-scan.md)
