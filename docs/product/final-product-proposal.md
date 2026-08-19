# Envisle 最终产品方向

## 当前状态

- 状态：`accepted-direction / platform-profile-pending-probe`
- 日期：2026-08-19
- 适用 Task：`T-005 v2`
- 决策来源：用户明确指出 Android 是当前最高优先级，macOS 只是当前方便实现且同样需要支持的平台，禁止把 Envisle 收窄为 macOS 产品。

## 产品定义

> Envisle 是跨平台的权限化 Environment 系统。它在 Android、macOS、Windows 等宿主上创建彼此独立的 Environment Instance，并由 Envisle 统一控制文件、网络、凭据、设备和应用能力如何跨越实例边界。

用户面对的是 `Environment`、`Instance`、`Data`、`Permissions` 与实际状态；Virtualization.framework、AVF/pKVM、Hyper-V、Container、VM 或 Emulator 都是平台内部实现，不是全局产品定义。

## 产品优先级与工程顺序

| 维度 | 当前结论 |
| --- | --- |
| 最高产品优先级 | Android host |
| 当前最成熟参考实现 | Apple silicon + macOS 26 + ARM64 Linux VM |
| 后续宿主 | Windows |
| 全局核心 | 平台无关的 Environment、Instance、授权、证据、生命周期与 Provider capability |
| 禁止推断 | macOS 先实现不等于 macOS 是产品边界；Android 第一也不等于普通 APK 已具备 AVF/OEM 权限 |

Android 的平台可达性 Probe 必须排在新产品实现之前；macOS reference implementation 可以并行验证平台无关语义，不能替 Android 做权限结论。

## Android 目标必须分成两条轴

“Android 平台”至少包含两个不同目标，不能混成一句支持声明：

1. **Android 作为 host**：Envisle 安装在 Android 设备上，创建、运行和管理独立 Environment。
2. **Android 作为 Environment/guest**：实例内部提供可安装 Android App、拥有独立数据与系统空间的 Android 环境。

AVF 的 Microdroid/Linux payload 与完整 Android UI/SystemServer guest 不是同一能力；完成前者不能宣称已经完成后者。

## Android 交付 Profiles

### A. OEM / AOSP Platform Profile — 完整愿景主路线

- 形态：平台签名、privileged/system app、定制 AOSP 产品或 OEM 合作版本。
- Runtime 候选：AVF/pKVM、VirtualizationService、厂商批准的启动镜像与平台服务。
- 目标：每个 Environment 具有独立执行边界、数据、身份与产品控制的共享桥梁；进一步验证完整 Android Environment 的 SystemServer、应用安装、图形与设备能力。
- 当前证据：AVF 只在 ARM64；pVM 创建/交互权限与启动镜像受平台签名和 Google/OEM 信任链约束。
- 当前状态：`target / not yet available`。未取得 OEM、平台签名、产品镜像或分发授权。

### B. Public Android App Profile — 普通 APK 能力验证路线

- 形态：普通第三方 APK / Play 可分发应用。
- 可验证范围：Android app sandbox 内的 Package/Instance UI、受控数据 Broker、显式导入导出、逻辑实例和受限进程隔离。
- 禁止承诺：普通 APK 可任意创建 pVM、携带自定义 kernel、创建完整 Android guest，或用同 UID/普通进程隔离等价替代 AVF。
- 价值：验证用户工作流、授权模型和数据桥梁；如果不能达到独立 Environment 的最低隔离标准，只作为体验原型，不提升为正式 Runtime Profile。
- 当前状态：`probe required`。

### C. Android Enterprise / Device-owner Profile — 条件路线

- 形态：受管设备、Device Policy Controller、work profile 或企业专用部署。
- 待验证：能否满足实例数量、应用安装、数据边界、用户可见控制和分发要求；work profile 不能未经实测就等价为任意多 Environment。
- 当前状态：`research candidate`，不与 OEM/AVF 路线混写。

## macOS Reference Profile

macOS 是首个已取得真实 Runtime 证据的平台 Profile，不是最终产品边界：

- Host：Apple silicon + macOS 26。
- Guest：ARM64 Linux。
- Runtime：Virtualization.framework，一 Environment 一独立 VM/系统盘。
- Host：Swift 领域层、Control Plane 与 Apple Provider；当前 D-005/D-007 契约仅约束该 reference profile。
- 已实测：生命周期、独立磁盘、默认无共享、显式只读共享和 VZNAT 行为。
- 未完成：正式 App、Provider、Guest Agent、宿主网络权威、发行签名与产品安全验证。
- 用途：验证跨平台 Environment 语义、Provider observation、Broker、授权、fail-closed、镜像与恢复；不得把 Swift、XPC、App Group 或 Virtualization.framework 写进全局领域契约。

上一版“macOS 权限化本地软件运行平台”定位已被用户否决。其 Package、Host Gateway、per-Runtime worker 和 Credential Broker 设计只能作为 macOS Profile 的候选安全设计，须另立 Task/Probe 后才能冻结。

## 平台无关核心

全局契约必须稳定表达：

- `Environment` 与一次安装/创建形成的 `EnvironmentInstance`；
- host/guest OS、architecture、runtime kind 与实际 capability/accelerator；
- lifecycle、desired policy、applied evidence、RuntimeInstanceID 与 fail-closed；
- Storage、Share、Network、Credential、Device Broker 的授权与撤销；
- Provider 能力差异、许可/权限 admission、不可用原因和禁止静默降级；
- 每个平台 Profile 的威胁模型、支持级别与证据来源。

全局模型统一身份、意图和证据，不伪造平台能力：Android work profile、AVF pVM、macOS VM、Windows VM 与 Container/Emulator 可以共享上层概念，但不得声称具有相同镜像、网络、快照、设备或安全语义。

## 当前推进顺序

1. **Android Platform Capability Probe — 当前第一阻塞项。**核验普通 APK、Device Owner、平台签名/AOSP 与 OEM 路径分别能创建何种隔离实例、运行何种 payload、使用何种镜像和共享通道。做对时输出可复现 capability matrix；典型失败是以 AOSP 源码存在某 API 推断 Play APK 可调用。
2. **Android Product Target Probe。**分别验证“Android host 上的 Linux/Microdroid workload”和“独立 Android App/System Environment”；做对时两条路径有不同验收和 No-Go，不用 Microdroid 成功冒充完整 Android guest。
3. **Cross-platform Contract v2。**在保留 T-003 v3 历史证据的前提下，新建独立 Task，把平台无关 core 与 Android/macOS adapter/profile 分离；做对时核心领域不依赖 SwiftUI、AVF 或 Virtualization.framework 类型。
4. **macOS Reference Implementation — 可并行。**原因是已有真实 VM 证据，可提前验证共同模型；触发条件是不得挤占 Android capability Probe 的最高优先级，也不得把 macOS-only 设计提升为全局基线。
5. **Android 竖切。**只有在 Profile 权限可达后，才实现安装、创建实例、进入环境、授权数据、撤销和删除的产品闭环。

## 当前不作出的承诺

- 不承诺普通 Android APK 已能创建 AVF pVM 或完整 Android guest。
- 不承诺 Microdroid 是完整 Android 环境。
- 不承诺 Android、macOS、Windows 使用同一种 Runtime 或实现语言。
- 不承诺 Container、VM、work profile、AVF pVM 和 Emulator 具有相同隔离强度。
- 不承诺 macOS reference profile 的安全网络提案已经实现。
- 不承诺 Android OEM/系统权限合作已经取得。

## 交给 AI 承担与验收句柄

AI/Agent 负责 Android 能力探针、平台 adapter、领域契约、实现、测试、日志和证据；用户负责产品优先级、平台目标与重大权限/合作路线。

- 做对了：任何项目入口都首先把 Envisle 描述为跨平台 Environment 系统，并把 Android 标成最高产品优先级；macOS 明确只是 reference profile；Android 每项能力都能指向 Public APK、Enterprise 或 OEM/AOSP Profile 及真实证据。
- 典型失败：README 再次把 Envisle 定义成 macOS 产品；因为 macOS 已跑通就把 Android 后置；因为 AVF 存在就宣称普通 APK 可创建 pVM；用 Microdroid/Linux workload 代替完整 Android Environment 的验收。
