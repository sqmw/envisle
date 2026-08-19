# 首个 MVP 产品路径

## 核心缺口

讨论确定了长期愿景，但没有决定首个可验证产品是“自建 Runtime”还是“聚合已有 Runtime”。这会改变工程量、差异化证据和首批用户价值，当前不能由初始化骨架替用户静默锁定。

## Option A — Runtime Platform

- 解决：用户无需预装后端，OSDeck 自己提供环境创建和运行。
- 候选后端：Virtualization.framework、Apple `container`、QEMU；Windows 后续接 Hyper-V/WHP/WSL2。
- 优点：产品体验可控，长期形成真正统一的环境平台。
- 成本：需要承担镜像、网络、磁盘、快照、guest integration、安全更新与许可策略。
- 首个验收：Apple silicon + macOS 26 上至少一条 VM 和一条 container 路径完成创建、启停、删除及错误回收。
- 触发条件：愿意把首期重点放在底层 Runtime 工程，而不是先验证统一控制面需求。

## Option B — Local Control Plane

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

因此当前初始化只创建共同基线。选择任一路径前，不创建另一条路径难以复用的大规模代码。
