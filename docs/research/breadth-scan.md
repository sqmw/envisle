# 广度调研结论

## 证据边界

- 截止日期：2026-08-19。本文件是初始化阶段研究快照；后续 Decision 已取代的产品假设保留用于溯源，不代表当前建议。
- 证据以 Apple、Microsoft、Android、QEMU 和竞品官方文档/官方仓库为主。
- 本轮完成静态资料核验与本机工具链检查；没有实际启动 VM、container、WSL、AVF 或 Android Emulator。
- 许可归纳不是法律意见；公开品牌仍需正式商标检索。

## 结论地图

| 领域 | 已核验事实 | 初始化约束 |
| --- | --- | --- |
| Apple VM | Virtualization.framework 支持 Apple silicon 上 macOS guest 与同架构 Linux guest；Rosetta 只翻译 ARM Linux 内的 x86_64 用户态程序 | v0 不承诺 x86_64 guest OS、Linux 3D/GPU、任意 IPSW 或跨主机恢复 |
| Apple container | `container` 1.2.2 在 Apple silicon + macOS 26 上以每容器轻量 VM 运行 OCI Linux 镜像 | 作为可替换 CLI adapter；OCI 兼容不等于 Docker API/Compose 兼容 |
| macOS 许可 | Tahoe SLA 对合规 Apple Mac 上额外 macOS 副本/实例及用途设限 | macOS guest 在实现前必须建立许可策略和法律复核门 |
| Windows | Hyper-V、WHP、WSL2 分别适合完整 VM、VMM 执行底座、Linux 开发环境 | 先做 capability probe；不可把 Windows Home/Pro、启用状态和重启要求隐藏 |
| Windows container | Windows Containers 不支持 GUI/桌面型应用，镜像与宿主版本/许可有约束 | 不能代替完整 Windows Environment |
| Android desktop | Android Emulator 可被 CLI 编排，但官方定位是应用开发/测试 | 商业嵌入与再分发前需专项许可；不进首个 MVP |
| Android host | AVF/pKVM 的 pVM 权限限平台签名应用；Microdroid 无完整 Android UI/SystemServer | 普通 Play APK 路线禁用；仅 OEM/系统镜像合作时重开 |
| QEMU | HVF/WHPX 同 ISA 加速；跨 ISA 依赖 TCG | 运行时必须报告实际 accelerator，禁止静默性能降级 |
| 竞争扫描推断 | 初始化时提出“跨独立 VM + container provider 的 capability-aware 控制面”假设；已由 `D-002` 的 VM-first Managed Runtime MVP 取代 | 仅作历史假设，不再指导首验 |
| 名称 | GitHub 已有 `OSDeck` 组织、Client/Host/Emulator 等软件仓库 | 已由 `D-003` 取代：标准名称和 repository slug 均为 `Envisle/envisle` |

## Apple 证据

- [Virtualization.framework](https://developer.apple.com/documentation/virtualization)
- [安装 macOS VM](https://developer.apple.com/documentation/virtualization/installing-macos-on-a-virtual-machine)
- [Linux x86_64 用户态翻译](https://developer.apple.com/documentation/virtualization/running-intel-binaries-in-linux-vms)
- [`container` 1.2.2](https://github.com/apple/container/releases/tag/1.2.2)
- [`container` 技术概览](https://github.com/apple/container/blob/1.2.2/docs/technical-overview.md)
- [macOS Tahoe 26 SLA](https://www.apple.com/legal/sla/docs/macOSTahoe.pdf)

关键边界：完整 VM 与 OCI container 必须是不同 Provider；桥接网络需受限 entitlement；macOS 27 的 USB/provisioning 等仍属 Beta，不进入稳定首发基线。

## Windows 与 Android 证据

- [Microsoft 虚拟化 API 分层](https://learn.microsoft.com/en-us/virtualization/api/)
- [Hyper-V 安装与版本限制](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/install-hyper-v)
- [WSL2 架构](https://learn.microsoft.com/en-us/windows/wsl/compare-versions)
- [Windows container GUI 限制](https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/lift-shift-to-containers)
- [Android Emulator 加速要求](https://developer.android.com/studio/run/emulator-acceleration)
- [AVF 安全模型](https://source.android.com/docs/core/virtualization/security)
- [Microdroid 能力边界](https://source.android.com/docs/core/virtualization/microdroid)

关键边界：Windows 后端可由普通桌面软件接入，但宿主 SKU、可选功能、权限与重启都必须显式呈现；AVF 的平台签名权限是产品硬边界，不是运行时权限弹窗能够解决的问题。

## QEMU 证据

- [QEMU accelerators](https://www.qemu.org/docs/master/system/introduction.html#virtualisation-accelerators)
- [WHPX 支持与已知问题](https://www.qemu.org/docs/master/system/whpx.html)
- [QMP accelerator 查询](https://www.qemu.org/docs/master/interop/qemu-qmp-ref.html#command-query-accelerators)
- [accelerator/target 构建映射](https://github.com/qemu/qemu/blob/fa19879df1658f96ac07365fca8835b7decd6995/meson.build#L292-L318)

关键边界：QEMU 可以提供跨平台的设备模型与 QMP 控制，但是否作为统一主后端仍需和原生 Provider 路线对比；无论哪种方案，TCG 都只能作为显式兼容 profile。

## 竞品证据与待验证产品假设

- [UTM](https://docs.getutm.app/)：通用 VM GUI，统一 Apple Virtualization 与 QEMU。
- [OrbStack](https://docs.orbstack.dev/)：macOS 上自有容器与 Linux machine 体验。
- [Podman Desktop](https://podman-desktop.io/docs/discover-podman-desktop)：多容器 provider 与扩展模型。
- [Lima](https://lima-vm.io/docs/usage/) / [Colima](https://github.com/abiosoft/colima)：Linux VM 与容器底座。
- [Tart](https://tart.run/)：Apple silicon 上可自动化、可进 OCI registry 的 macOS/Linux VM 镜像。
- [Multipass](https://canonical.com/multipass/docs/latest/)：跨平台 Ubuntu instance，能力受 driver 影响。
- [Android Emulator](https://developer.android.com/studio/run/managing-avds)：专用 device/AVD 模型。

本轮定向覆盖上述产品的官方资料，不是完整市场普查。初始化时提出的“同时连接 VM 与 container/machine Provider”产品假设已经被 `D-002` 的 VM-first Managed Runtime MVP 取代，不再是当前首验方向；其未获得用户访谈、安装基数或付费数据支持的证据边界继续保留。

## 名称冲突初筛

- [GitHub OSDeck organization](https://github.com/OSDeck) 已包含 `OSDeck-Host`、`OSDeck-Client` 与 `Emulator` 等软件仓库。
- 另有 [Painfull-Community/osdeck](https://github.com/Painfull-Community/osdeck)。
- npm 与 crates.io 精确包名初筛未命中；PyPI 未完成可靠核验。
- 未获得可引用的注册商标结论。

因此 `OSDeck` 不是“已证实可用”的公开品牌；该结论后来触发 `D-003`，项目已选择 `Envisle` 作为新标准名称。

## 后续探针的最低证据

- Host probe：芯片、系统版本、硬件虚拟化、可选功能、entitlement、实际 runtime 版本。
- Provider probe：明确的 `available / enablement_required / unsupported / license_review_required` 原因。
- QEMU probe：QMP 的实际 accelerator，禁止仅以进程存活判定成功。
- 生命周期 probe：连续启动、优雅停止、异常回收、原始错误码与可重复日志。
- 数据 probe：仓库外状态目录、崩溃恢复和清理边界。
