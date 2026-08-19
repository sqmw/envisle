# 当前真相

- 更新日期：2026-08-19
- 当前主线：`T-005 v2 全局漂移审查与最终产品方案定稿` 正在执行；用户已把方向校正为 Android-first 跨平台 Environment 系统，macOS 仅为 reference profile。
- 当前状态：`T-001 v1`、`T-004 v1`、`T-002 v2` 与 `T-003 v3` 已关闭；现有 Swift Package 是 macOS reference contract 证据，正式 Android/macOS App、Provider 和 guest agent 均未开始。

## 当前有效结论

1. 产品路径是 Android-first 的跨平台 `Managed Runtime Platform`：产品统一管理 Environment、实例与授权，不把平台专用 Runtime 暴露为全局语义。
2. Apple ARM64 Linux VM Provider 为条件性 Go：一台 Apple M2/macOS 26.5.1 已通过真实生命周期、独立磁盘、默认无共享和显式只读共享探针。
3. Android 是最高产品优先级；Public APK、Enterprise 与 OEM/AOSP 是不同交付 Profile。AVF/pKVM 需要平台签名/OEM 权限，不属于普通第三方 APK 的已得能力。
4. QEMU 的 HVF/WHPX 只为同 ISA 提供硬件虚拟化；跨 ISA 使用 TCG，必须显式标记兼容模式。
5. 标准产品名为 `Envisle`、repository slug 为 `envisle`；`OSDeck` / `osdesk` 只作历史旧称。
6. `D-007` 的 Swift 进程边界只适用于 macOS reference profile；全局 UI/Core/Provider 语言尚未冻结，跨平台领域契约不得依赖 Apple API。
7. Environment 只有在 Runtime `running`，且同一 Environment、当前 RuntimeInstanceID 的 Network/Share applied evidence 均与 desired policy 的 schema/revision/digest 一致并保持新鲜、网络租约仍有效时才 `ready`。

## 当前待验证

- Android 最高优先：分别 Probe 普通 APK、Device Owner/Enterprise、平台签名/AOSP 与 OEM 路径；区分 Linux/Microdroid workload 和完整 Android App/System Environment。
- Guest Policy v1 目前只有 JSON/状态/租约契约测试；受认证传输、真实 guest firewall、端口 allow/revoke、失联 watchdog 和恢复仍需独立 Probe。
- Apple Provider 仍只有外部 Probe，尚未在产品源码实现；Share 动态撤销没有证据，契约允许明确返回需重启。
- `Envisle` 只完成工程冲突初筛；正式商标检索不属于当前工程结论。

## 当前风险

- macOS guest 的许可用途和最多两个额外副本限制必须进入产品策略；这不是框架技术上限。
- Apple `container` 的 OCI 兼容不等于 Docker Engine、Compose 或 `docker.sock` 兼容。
- VM、容器和 AVD 的镜像/快照/网络语义不能统一承诺。
- VZNAT 环境间 TCP 在当前双实例探针中不可达，但宿主可直接连接 guest；端口默认拒绝必须由 guest firewall 实施并证明。
- 本项目位于可能同步到 Windows 的工作区，运行数据必须置于仓库和同步目录外。
- T-003 的独立工程 review 已 PASS，但项目尚无冻结的安全审核计划/plan hash/资格矩阵，不能把它称为正式安全认证。
- 若 Environment 内工具可获得 guest root，Guest Agent 可停止自身或修改 firewall，不能作为最终网络隔离权威；强隔离产品定位需要宿主控制的数据面，相关 D-005/D-007 变更尚未获用户明确解冻。
- AVF/pVM 权限与启动镜像受平台签名/OEM 信任链控制，普通第三方 APK 不能被写成完整 Runtime 已可用；Microdroid 也不能冒充完整 Android guest。

## 验证与导航

- 最低验证：`make check`
- 主 TODO：[`../TODO.md`](../TODO.md)
- 主 STEPS：[`../STEPS.md`](../STEPS.md)
- 产品路径：[`../architecture/product-options.md`](../architecture/product-options.md)
- 最终产品方向：[`../product/final-product-proposal.md`](../product/final-product-proposal.md)
- macOS reference 基线：[`../architecture/mvp-baseline.md`](../architecture/mvp-baseline.md)
- Environment 契约：[`../architecture/environment-contracts.md`](../architecture/environment-contracts.md)
- Runtime Probe：[`../research/macos-runtime-probe.md`](../research/macos-runtime-probe.md)
- 研究证据：[`../research/breadth-scan.md`](../research/breadth-scan.md)
