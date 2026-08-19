# 当前真相

- 更新日期：2026-08-19
- 当前主线：`T-003 v3 Environment 领域模型与 Provider 契约基线` 正在执行架构测试与文档收口。
- 当前状态：`T-001 v1`、`T-004 v1` 与 `T-002 v2` 已关闭；纯领域 Swift Package 已建立，正式 App/Provider/guest agent 尚未开始。

## 当前有效结论

1. 产品路径已冻结为 `Managed Runtime Platform`：一实例一受管 VM 是默认安全边界，共享和入站网络默认关闭并由产品显式授权。
2. Apple ARM64 Linux VM Provider 为条件性 Go：一台 Apple M2/macOS 26.5.1 已通过真实生命周期、独立磁盘、默认无共享和显式只读共享探针。
3. Android host 上的 AVF/pKVM 需要平台签名/OEM 权限，不属于普通第三方 APK 路径。
4. QEMU 的 HVF/WHPX 只为同 ISA 提供硬件虚拟化；跨 ISA 使用 TCG，必须显式标记兼容模式。
5. 标准产品名为 `Envisle`、repository slug 为 `envisle`；`OSDeck` / `osdesk` 只作历史旧称。
6. macOS MVP 宿主采用单一签名 Swift 进程；纯领域层不依赖 Apple API，guest policy agent 经版本化语言无关协议连接，Agent 实现语言尚未冻结。
7. Environment 只有在 Runtime `running`，且同一 Environment、当前 RuntimeInstanceID 的 Network/Share applied evidence 均与 desired policy 的 schema/revision/digest 一致并保持新鲜、网络租约仍有效时才 `ready`。

## 当前待验证

- Guest Policy v1 目前只有 JSON/状态/租约契约测试；受认证传输、真实 guest firewall、端口 allow/revoke、失联 watchdog 和恢复仍需独立 Probe。
- Apple Provider 仍只有外部 Probe，尚未在产品源码实现；Share 动态撤销没有证据，契约允许明确返回需重启。
- `Envisle` 只完成工程冲突初筛；正式商标检索不属于当前工程结论。

## 当前风险

- macOS guest 的许可用途和最多两个额外副本限制必须进入产品策略；这不是框架技术上限。
- Apple `container` 的 OCI 兼容不等于 Docker Engine、Compose 或 `docker.sock` 兼容。
- VM、容器和 AVD 的镜像/快照/网络语义不能统一承诺。
- VZNAT 环境间 TCP 在当前双实例探针中不可达，但宿主可直接连接 guest；端口默认拒绝必须由 guest firewall 实施并证明。
- 本项目位于可能同步到 Windows 的工作区，运行数据必须置于仓库和同步目录外。

## 验证与导航

- 最低验证：`make check`
- 主 TODO：[`../TODO.md`](../TODO.md)
- 主 STEPS：[`../STEPS.md`](../STEPS.md)
- 产品路径：[`../architecture/product-options.md`](../architecture/product-options.md)
- MVP 冻结基线：[`../architecture/mvp-baseline.md`](../architecture/mvp-baseline.md)
- Environment 契约：[`../architecture/environment-contracts.md`](../architecture/environment-contracts.md)
- Runtime Probe：[`../research/macos-runtime-probe.md`](../research/macos-runtime-probe.md)
- 研究证据：[`../research/breadth-scan.md`](../research/breadth-scan.md)
