# 产品路径决策与平台范围

## 核心缺口

用户已明确首要目的：安装产品后由产品创建独立实例，数据共享由产品本身控制；并进一步明确 Android 是当前最高产品优先级，macOS 只是参考实现平台。因此 Runtime Platform 与 Local Control Plane 的比较已经关闭；跨平台范围见 [`D-008`](../DECISIONS.md#d-008)，macOS Profile 见 [`mvp-baseline.md`](mvp-baseline.md)。

## Option A — Runtime Platform

- 决策：**采用，并收敛为 Managed Runtime Platform。**

- 解决：用户无需预装后端，Envisle 自己提供环境创建和运行。
- 已验证后端：macOS Virtualization.framework 上的 ARM64 Linux 受管 VM。当前最高优先级改为 Android Profile capability Probe；Apple `container`、QEMU 与 Windows Provider 保留为独立评估对象。
- 优点：产品体验可控，长期形成真正统一的环境平台。
- 成本：需要承担镜像、网络、磁盘、快照、guest integration、安全更新与许可策略。
- 已完成参考验收：Apple silicon + macOS 26 的 ARM64 Linux VM 生命周期、独立系统盘、默认无共享与错误证据。下一个产品验收必须来自 Android capability matrix，不能由 macOS 结果替代。
- 触发条件：愿意把首期重点放在底层 Runtime 工程，而不是先验证统一控制面需求。

## Option B — Local Control Plane

- 决策：不作为首个 MVP；未来可作为导入/兼容能力。

- 解决：统一发现并控制用户已安装的 VM、container 与 Linux machine 后端。
- 候选 adapter：UTM、Docker context、Lima/Colima。
- 优点：更快验证跨 Provider inventory、capability UI 和生命周期体验，不先承担 hypervisor 全栈。
- 成本：依赖外部安装，能力受 Provider 版本影响；长期差异化需要持续扩展 adapter。
- 首个验收：同一 macOS 主机同时发现至少一种 VM 和一种 container/machine 后端，完成幂等刷新、状态映射及 capability-aware 启停。
- 触发条件：优先验证用户需求与统一体验，接受首版不是“一键获得任意 OS”。

## 共同基线

两条路径都需要：

- Environment 身份与状态模型；
- Provider/adapter 隔离；
- capability negotiation；
- 宿主与架构探测；
- 可解释失败、日志和回退句柄；
- 仓库外运行数据策略。

共同基线继续有效；全局产品以 [`最终产品方向`](../product/final-product-proposal.md) 为准。`mvp-baseline.md` 只约束 macOS reference profile，不把“一实例一 Apple VM”外推为所有平台的固定实现。
