# 首个 MVP 产品路径（已决策）

## 核心缺口

用户已明确首要目的：安装产品后由产品创建独立实例，外部应用默认不可干扰，数据共享由产品本身控制。因此本文件中的比较已经关闭，当前冻结结论见 [`mvp-baseline.md`](mvp-baseline.md)。

## Option A — Runtime Platform

- 决策：**采用，并收敛为 Managed Runtime Platform。**

- 解决：用户无需预装后端，Envisle 自己提供环境创建和运行。
- 候选后端：Virtualization.framework、Apple `container`、QEMU；Windows 后续接 Hyper-V/WHP/WSL2。
- 优点：产品体验可控，长期形成真正统一的环境平台。
- 成本：需要承担镜像、网络、磁盘、快照、guest integration、安全更新与许可策略。
- 首个验收：Apple silicon + macOS 26 上至少一条 VM 和一条 container 路径完成创建、启停、删除及错误回收。
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

共同基线继续有效；正式实现以 [`mvp-baseline.md`](mvp-baseline.md) 的 VM 默认隔离、项目介导共享和明确威胁模型为准。
