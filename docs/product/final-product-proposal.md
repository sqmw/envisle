# 最终产品方案提案

## 状态与决策门

- 状态：`recommended / awaiting-explicit-thaw`
- 日期：2026-08-19
- 适用 Task：`T-005 v1`
- 不变基线：一 Environment 一受管 VM、独立系统盘、默认无宿主共享、所有桥梁由 Envisle 授权。
- 待解冻点：`D-005` / `D-007` 与 `mvp-baseline` 当前把 VZNAT + guest firewall / Guest Agent 作为网络默认拒绝的实施与证明者，且 D-007 冻结单一宿主进程；若产品要隔离拥有 guest root 的不可信工具，最终网络权威必须迁移到宿主数据面，每 Runtime 的不可信 Guest I/O 必须隔离到最小 worker，并由一个新的 Contract v2 Task 取代 T-003 v3 的网络子契约。T-003 v3 继续作为已关闭的 v1 历史证据，不重开、不改写。冻结决策和公共契约在用户明确批准前不修改。

## 推荐定位

> Envisle 是 macOS 上的权限化本地软件运行平台。用户安装带权限声明的 Environment Package；每个实例运行在独立 Linux VM 和私有数据域中，只有用户经 Envisle 授权的文件、网络、凭据与服务才能跨越边界。

首个 wedge 是本地 AI 工具、第三方自动化程序和来源尚未充分信任的开发工具，而不是通用 VM 管理、Docker 替代或单一 Coding Agent Sandbox。

## 为什么不是原来的三个方向

| 候选 | 结论 | 关键原因 | 重评触发条件 |
| --- | --- | --- | --- |
| 多 OS 个人实验室 | 否决首发，保留长期 Provider 愿景 | UTM、VMware、Parallels 已有深功能；许可、GUI/GPU、设备与镜像供应链同时扩张 | 第二种 guest 已有明确重复用户需求与许可/图形闭环 |
| 受控开发工作区 | 作为 Package Platform 的通用 Shell 模板保留 | 比 VM 管理器更贴近任务，但 OrbStack 与 Docker Sandboxes 已直接覆盖开发/Agent sandbox | 用户研究证明只需工作区，不需要安装包权限模型 |
| 权限化本地软件运行平台 | **推荐** | 最贴近“手机式独立实例 + 产品决定共享”；差异点是 Package 权限声明、实例私有数据和可撤销桥梁 | 宿主网络权威 Probe 失败，或目标用户不接受 Copy-in/Export 与受限网络 |

## 目标用户与核心任务

首批用户：在 Apple silicon Mac 上运行本地 AI 工具、GitHub 项目、npm/PyPI 工具或自动化脚本，同时不愿直接暴露整个 Home、SSH Agent、云凭据和私有仓库的安全敏感型开发者与技术型个人。

核心闭环：

1. 用户选择一个已签名或本地导入的 Environment Package；安装页展示发布者、内容摘要、资源和权限请求。
2. Envisle 创建独立 Environment Instance、系统盘和私有数据域。
3. 用户从内置终端进入；默认没有宿主目录、真实凭据、入站端口或直接网络接口。
4. 文件通过 Copy-in / 只读授权进入，结果通过 Review / Export 返回；授权可查看、撤销并审计。
5. 网络只通过宿主 Broker 的受限能力开放；任何证据缺失或不一致时 Instance 不进入 Ready，并隔离或停止。
6. 用户可 Clone、Reset 或 Delete Instance；删除不等于安全擦除，APFS 快照或备份可能残留，Reset/Clone/Delete 的保留范围必须分别显示。

## 产品对象与最小数据表示

`EnvironmentPackage` 是用户安装对象，至少声明：

- 发布者、签名、格式版本与内容摘要；
- Envisle allowlist 中的基础镜像/Bootstrap/Guest Agent 兼容性 ID，以及 Package 自身入口；Package 发布者不能替换 Envisle 启动信任根；
- CPU、内存、磁盘与私有持久化数据需求；
- 请求的文件导入/导出、域名、凭据代理和本机服务能力；
- 更新通道、最低安全版本、SBOM 与许可证信息。

`EnvironmentInstance` 是一次独立安装，拥有 EnvironmentID、每次启动唯一的 RuntimeInstanceID、独立系统盘/数据、desired policy、applied evidence、授权与审计记录。用户界面不暴露 Provider 作为首要概念；Provider 只出现在诊断信息中。

## macOS 首发架构

- 支持面：Apple silicon + macOS 26；首个 guest 仅项目验证的 ARM64 Linux；不承诺 Intel Mac、旧 macOS、Rosetta 等价 x86 VM、GPU、USB、快照或休眠。
- UI/Control：SwiftUI + Swift；纯 `EnvisleDomain`、Application/Supervisor、Broker 与 Virtualization.framework adapter 分层。提案要求解冻“永久单进程”：每个 Runtime 的所有 guest-originated vsock bytes（network、terminal、Agent、挂载/复制、遥测和导出 framing）必须先进入独立、最小 entitlement 的 Guest I/O worker，主进程只接收规范化、有界、类型化事件。worker 不持有 App Group、bookmark、Keychain、发布密钥或其他 Environment 状态；worker 退出即因 VM 无直接 NIC 而 fail closed。是否一个聚合 worker 或多个更小 worker、XPC/helper/file-handle attachment 的跨进程边界和签名方式必须由 Probe 决定。
- Runtime：一个 Instance 一台 Virtualization.framework VM。Apple Containerization 只作后续可替换 Provider 候选，不把 OCI container 偷换成当前持久 Environment。
- 入口：内置终端经 virtio-vsock 连接，不用入站 TCP；Guest Agent 负责启动协作、挂载/复制和遥测，不作为对抗 guest root 的最终网络权威。
- 网络提案：VM 默认不附加可直接路由的 NIC；HTTP/HTTPS 与 DNS 通过 vsock → 每 Runtime Host Gateway 提供，按 Package 和用户授权限制域名/端口，不能声称可仅凭 CONNECT 强制“用途”。Gateway 必须固定解析结果并拒绝 DNS rebinding，以及 loopback、link-local、RFC1918、ULA、宿主和其他 Environment 地址；raw CONNECT 看不到加密的 HTTP 重定向，因此规则是每个新连接都重新校验目标域/IP/端口且绝不继承前一连接权限。任意 TCP/UDP、LAN 暴露和公开入站不进首发。vsock 连接只能绑定 Runtime，不能证明 guest 内 Agent 可信，因为 guest root 可以冒充它。该路径必须先做性能、兼容性、解析器隔离和 guest-root 绕过 Probe。
- 凭据：长期原始 secret 永不进入 guest、network worker 或主进程的通用网络解析路径；主进程只编译用户授权。代发/签名操作由独立最小权限 Credential Broker 或一次性受限 worker 完成，优先不返回 secret。确需下发的短期 token 必须显示 expiry；撤销只保证阻止新 token，旧 token 在到期前仍可能有效，该有界残余权限必须进入契约和测试。
- 数据：正式发行候选优先使用带验证 entitlement 的 App Group container，但它是否足以阻止各类同用户进程必须由对手能力矩阵和真实 Probe 证明，不能从存放路径直接推出安全承诺；开发/测试才允许环境变量覆盖。文件默认 Copy-in 或只读，Live RW Mount 不进首发；bookmark、文件身份、symlink/TOCTOU 与撤销必须 fail closed。
- 分发：Developer ID 直发，App Sandbox、Hardened Runtime、notarization/stapling；Mac App Store 只作未来独立审核。Guest image/agent 使用签名 manifest、摘要、最低安全版本、SBOM 与原子更新/回滚。
- 镜像与 Bootstrap：首发从发行方直下固定版本的未修改 Debian ARM64 raw cloud base artifact并校验上游签名/摘要；Envisle 另维护签名、版本锁定、可回滚的 bootstrap layer，在首次启动前通过受验证 seed/initrd 机制安装 Agent、vsock 终端与 Broker 客户端。Bootstrap 失败时不得 Ready，并回滚或销毁未完成实例。定制镜像和离线内置镜像必须另做许可证与对应源码义务审计。

Package 发布者签名与 Envisle 镜像/Bootstrap 签名是两个独立信任域。Package 只能引用 Envisle compatibility catalog 中的 image/agent ID；本地未验证 Package 必须持续标记为未验证，默认不能请求凭据代理、本机服务或其他高风险能力，除非用户经过单独的高风险授权流程。

Host 永不执行 Package 内的程序、安装脚本或动态库。Package archive、manifest、签名、图标与 SBOM 的解析在资源受限的隔离解析器中完成，限制大小、深度、文件数、路径穿越、symlink/hardlink、设备节点、覆盖与压缩炸弹；canonical manifest 与签名覆盖范围必须唯一，验证后只把规范化 manifest 和内容摘要交给 Control Plane。发布者签名只证明身份，不自动代表可信。

## 威胁模型与承诺边界

目标纳入普通未授权宿主应用、其他 Environment、guest 内不可信程序（包括 guest root）、远程网络以及崩溃/重放/降级。排除宿主 root/内核/hypervisor/固件失陷、用户主动授权、资源耗尽和已合法披露数据的撤回。App Group 也不覆盖 root、用户批准、获得同一 Group entitlement 的同 Team 代码、宿主进程漏洞或 DoS。

产品只有在真实发行构建对明确的宿主对手能力矩阵通过验证后，才可承诺矩阵覆盖的未授权应用不能静默读取或修改 Envisle 受保护状态；不能把 App Sandbox、App Group 路径或一次测试 App 结果单独当作证明。其余可验证承诺包括每个 Instance 独立 VM/磁盘、默认无宿主目录与网络桥梁、显式授权可见可撤销、证据不足即 fail closed。

不能承诺“任何外部应用绝对无法干扰”、防宿主管理员、撤回 guest 已读取的数据、仅凭 FileVault 实现每实例密码学加密/安全删除，或未经安全评审即称零信任/安全认证。

## 发布门与退出条件

1. **宿主网络权威与 worker 隔离 Probe（当前阻塞）**：guest root 停 Agent、冒充 Agent、改 firewall 后仍无法绕过默认拒绝；HTTP/HTTPS 常见工具兼容性和性能可接受；畸形帧、network/terminal/agent/file-export framing fuzz、DNS rebinding、SSRF 和单 worker crash 不触达主进程或其他实例。通过后新建独立的 `Host Network Authority Contract v2` Task 与 Decision：`HostNetworkEvidence` 取代 guest firewall evidence 成为 Ready 权威，Guest Agent evidence 仅保留健康/纵深防御；Router capability、quarantine、policy digest、worker identity、测试和迁移文档同步升级，禁止并存两个安全真相源。失败则缩小为 trusted-guest 工作区，不得保留强隔离措辞。
2. **受保护数据 Probe（当前阻塞）**：先冻结宿主对手能力矩阵，至少覆盖 sandboxed/unsandboxed、同 Team/异 Team、签名/未签名普通同用户进程，并逐项标明 App Group/SIP/TCC/ACL/加密或 Broker 中真正执行拒绝的机制；使用真实 Developer ID、production provisioning 和发行 entitlement 的 Release build 逐项读写 VM、策略、bookmark 和审计，并验证拒绝系统提示后仍不可访问。Network Gateway 不加入 App Group，Release build 禁止状态目录环境变量覆盖；未覆盖或失败的类型不得进入承诺。
3. **Package 需求验证（商业阻塞，非工程安全门）**：10–15 名目标用户能理解权限安装页，愿意以 Copy-in/Review/Export 代替 Live RW Mount，并能说出重复使用场景。失败则退回受控开发工作区定位。
4. **产品竖切**：Package 安装、镜像校验、创建、终端、启停、文件授权/撤销、网络 Broker、Reset/Delete 与崩溃恢复在真实发行构建闭环。
5. **安全发布审查**：固定构建/镜像 hash，完成故障注入、Package/archive/parser 与协议 fuzz、guest-root 绕过、供应链与独立渗透测试；未通过不得发布安全承诺。

## 明确解冻范围

如果用户批准推荐方案，下一 Decision 必须一次性替换以下边界，不能只改产品文案：

| 现有基线 | 替换内容 | 保留内容 |
| --- | --- | --- |
| `D-005` | VZNAT + guest firewall 实施端口策略 → 无直接 NIC + Host Network Gateway 实施受限能力；首发取消通用端口发布 | Apple VM 生命周期 conditional Go；VZNAT 不是防火墙的证据 |
| `D-007` | Guest Agent 网络 evidence、Agent 网络租约、所有 Broker 单进程 → Host Gateway evidence、worker fail-closed、每 Runtime 最小 Guest I/O worker与独立最小 Credential Broker | Swift 领域层/Control Plane/Apple Provider、一实例一 VM、版本化授权与 RuntimeInstance 防重放 |
| `mvp-baseline` | NAT 出站/单端口发布/guest firewall → 无 NIC、受限 HTTP(S)/DNS 与 typed capability | 默认无共享、无直接入站、证据缺失即隔离或停止 |
| `T-003 v3` 领域契约 | 保持关闭历史不变；批准后新建 Contract v2 Task，只取代 Network baseline、capability、quarantine、evidence 来源和 lease；Guest health 不再证明网络隔离 | Environment/Provider/Share/生命周期既有契约与 T-003 v3 证据 |

迁移必须删除旧网络权威的公共绕过入口，不能让 Host 与 Guest 同时成为安全真相源；回退只允许整体恢复到明确标记 `trusted-guest` 的旧 profile，不能在强隔离 profile 中静默降级。

## 交给 AI 承担与验收句柄

AI/Agent 负责 Provider、Supervisor、Broker、Package/镜像供应链、Guest Agent、签名分发、测试、日志和安全证据；用户负责产品定位、冻结边界、优先级与验收标准。

- 做对了：用户不需要理解 VM/Provider，只看到 Package 权限、Instance 私有数据和当前授权；guest root 与 App crash 都不能让旧网络权限继续生效。
- 典型失败：首页变成 VM/QEMU/Container 选择器；默认挂载 Home 或注入真实凭据；Guest Agent 自报被当作对抗 guest root 的安全证明；安全能力只在单元测试中成立而真实发行构建未验证。
