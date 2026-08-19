# 讨论来源基线

## 来源

- 标题：`pure-Multi-OS Environment Runtime`
- 公开快照：[chat2api share](https://sunqin.ipyingshe.net/18083/share/KDlew3o-MufuLfpAKUOwjMPT3GAEbOBcFVmfqfqquZY)
- 创建时间：`2026-08-19T08:55:24.888789+00:00`
- 消息数：`4`
- 核验日期：`2026-08-19`

可复现元数据读取：

```bash
curl -fsSL --compressed \
  'https://sunqin.ipyingshe.net/18083/api/public/chat-shares/KDlew3o-MufuLfpAKUOwjMPT3GAEbOBcFVmfqfqquZY' \
  | jq '.item | {title, created_at, message_count: (.messages | length)}'
```

该链接是创建时的文本快照，不包含原回答引用的真实 URL、附件或检索产物。因此快照只证明讨论内容，不证明其中技术事实；技术事实重新记录在 [`breadth-scan.md`](breadth-scan.md)。

## 讨论提出的问题

用户希望安装一个软件后获得多种隔离环境：同宿主系统环境是基础能力，跨操作系统环境是提升能力，目标宿主包含 macOS、Windows 与 Android。

## 讨论形成的候选方向

- 不把产品局限为“容器软件”，而定义为 Multi-OS Environment Runtime。
- 用户只理解 `Environment`；底层按宿主、来宾和架构选择 Container / VM / Emulator。
- 引入 Environment Manager、Runtime Router 与 Provider 架构。
- 第一阶段候选为 Apple silicon macOS，覆盖 macOS、Linux、Android；Windows 与 Android host 后置。
- 候选技术栈是 Flutter UI、Rust Core、Swift/Kotlin/Windows 原生 adapter。
- 工作名称是 `OSDeck`，标语为 `Every OS. One Deck.`。

## 初始化时的修正

- “macOS + Linux + Android”不能直接视为首发承诺；许可、图形集成、镜像分发和真实运行体验均需逐项探针。
- Android AVF 不能作为普通第三方 APK 后端。
- QEMU 不能把跨 ISA guest 宣传为硬件加速主路径。
- `OSDeck` 已存在软件组织/仓库命名冲突，只保留为工作代号。
- Flutter/Rust/Swift 是候选组合；初始化不通过目录结构将其冻结。
