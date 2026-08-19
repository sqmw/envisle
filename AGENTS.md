# Envisle 项目级 Agent 入口

## 适用范围

1. 本文件只记录 Envisle 项目长期有效的边界和首读入口；全局规则仍以 `$CODEX_HOME/AGENTS.md` 与其路由文档为准。
2. 标准产品名为 `Envisle`，GitHub repository slug 为 `envisle`；历史旧称只在来源与迁移记录中保留。

## 项目事实

1. 当前阶段：macOS Runtime Probe 已形成条件性 Go，等待 `T-003 v3` 冻结 Environment/Provider/Broker 契约。
2. 当前技术状态：尚未冻结 UI、Core 或 Provider 的实现语言；讨论中的 Flutter、Rust、Swift 是候选，不是已批准基线。
3. 当前首发目标宿主：Apple silicon + macOS 26，首个 guest 为 ARM64 Linux；`P-ENVI-001` 已在一台 Apple M2/macOS 26.5.1 上通过生命周期、独立磁盘和只读共享探针，但正式支持仍需契约与产品级验证。
4. 冻结基线：`docs/architecture/mvp-baseline.md` 与 `D-002`；任何改变默认 VM 隔离、默认关闭共享/入站网络或产品受管生命周期的方案都需用户明确解冻。
5. 主 TODO：`docs/TODO.md`；主 STEPS：`docs/STEPS.md`；主 DECISIONS：`docs/DECISIONS.md`。
6. 运行数据边界：VM 磁盘、镜像、缓存、日志、数据库、快照、凭据与下载包一律置于仓库和同步目录之外。

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
6. VZNAT 不等于 host-to-guest 防火墙；Network Broker 必须通过 guest policy agent 证明 default deny、allow 与 revoke，未证明时 fail closed。

## 常用命令

- 项目检查：`make check`
- 文档检索：`rg "<关键词>" README.md AGENTS.md docs`
- 文件导航：`rg --files`

## 文档同步

改变产品边界、Provider 责任、公共契约、运行数据目录、验证入口或模块导航时，必须同步更新 `README.md`、`docs/agent-context/current.md` 和对应 P2/代码地图。
