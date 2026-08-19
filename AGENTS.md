# Envisle 项目级 Agent 入口

## 适用范围

1. 本文件只记录 Envisle 项目长期有效的边界和首读入口；全局规则仍以 `$CODEX_HOME/AGENTS.md` 与其路由文档为准。
2. 标准产品名为 `Envisle`，GitHub repository slug 为 `envisle`；历史旧称只在来源与迁移记录中保留。

## 项目事实

1. 当前阶段：`T-005 v2` 正在把产品方向校正为 Android-first 的跨平台 Environment 系统；`T-003 v3` 仍是已关闭的首个 macOS reference contract 证据。
2. 当前产品优先级：Android host 第一，macOS 是首个已取得 Runtime 证据的 reference platform，Windows 后续；禁止把实现顺序解释成产品范围。
3. 当前技术状态：全局 UI/Core/Provider 语言未冻结。仅 macOS reference profile 的 host Control Plane、Broker 编排和 Apple Provider 由 `D-007` 冻结为 Swift 分层；尚无正式 App、Provider 或 agent。
4. 当前平台证据：Apple M2/macOS 26.5.1 的 ARM64 Linux VM 已通过生命周期、独立磁盘和只读共享探针；Android AVF/pVM 仍受平台签名/OEM 权限约束，尚无 Envisle Android Runtime Probe。
5. 冻结基线：`D-008` 定义跨平台产品范围和 Android 第一优先级；`docs/architecture/mvp-baseline.md`、`D-002`、`D-005`、`D-007` 只作为 macOS reference profile 基线。改变默认隔离或产品受控共享仍需用户明确决策。
6. 主 TODO：`docs/TODO.md`；主 STEPS：`docs/STEPS.md`；主 DECISIONS：`docs/DECISIONS.md`。
7. 运行数据边界：VM 磁盘、镜像、缓存、日志、数据库、快照、凭据与下载包一律置于仓库和同步目录之外。

## 首读顺序

1. `AGENTS.md`
2. `README.md`
3. `docs/agent-context/current.md`
4. `docs/README.md`
5. 根据任务只读一到两个命中的 P2 文档，再用 `rg` 定向定位文件。

## 架构硬边界

1. 上层使用 `Environment`；底层 Provider 必须显式声明 `kind`、宿主/来宾架构与 capability set。
2. Container、VM、Emulator 保持独立 Provider 类型；不得为统一 UI 而伪造统一镜像、快照、网络或设备语义。
3. 不允许把硬件加速失败静默降级为 TCG；实际 accelerator 必须可观察。
4. 平台 API、外部 CLI 和第三方集成都在独立 adapter 内；核心领域不直接依赖其命令格式或 SDK 类型。
5. 产品路径已冻结为 Managed Runtime Platform；不得退化为只管理用户现有 Runtime 的 Local Control Plane，也不得在无用户显式解冻时弱化默认 VM 隔离与项目受控共享。
6. 在当前 macOS reference profile 中，VZNAT 不等于 host-to-guest 防火墙；Network Broker 必须通过 guest policy agent 证明 default deny、allow 与 revoke，未证明时 fail closed。该实现不得外推为 Android 全局网络模型。
7. Android、macOS、Windows 是宿主 Platform Profile；平台专用 API、权限、语言和安全证据不得提升为全局 Environment 语义。Android 普通 APK、Enterprise 与 OEM/AOSP Profile 必须分开声明能力。

## 常用命令

- 项目检查：`make check`
- 文档检索：`rg "<关键词>" README.md AGENTS.md docs`
- 文件导航：`rg --files`

## 文档同步

改变产品边界、Provider 责任、公共契约、运行数据目录、验证入口或模块导航时，必须同步更新 `README.md`、`docs/agent-context/current.md` 和对应 P2/代码地图。
