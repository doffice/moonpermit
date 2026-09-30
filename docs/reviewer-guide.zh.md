# MoonPermit 中文审阅与演示指南

## 一句话定位

MoonPermit 是位于 AI Agent 与工具执行器之间的纯 MoonBit 最小权限引擎：
它把结构化任务计划编译成可执行授权，在每次真实工具调用前检查范围、额度和
有效期，并生成可以机器读取的结构化决策证明和可离线重放验证的确定性收据。

```text
realized effect <= approved effect
child permit    <= parent permit
```

它解决的不是“模型说得是否可信”，而是一个更小、可测试的问题：宿主准备执行的
具体文件、命令、网络或密钥效果，是否仍在用户已经批准的权限以内。

## 与常见方案的区别

| 常见做法 | MoonPermit 的处理 |
| --- | --- |
| 一次授予整个工具 | 授权具体路径、命令参数、主机、HTTP 方法和数据级别 |
| 每次调用弹窗确认 | 先批准规范化 Permit，只在权限扩张时要求重新批准 |
| 子 Agent 复制父权限 | 子 Permit 必须收窄权限，并从父级剩余额度中事务性预留 |
| 只记录 Allow/Deny 文本 | 同一次原子判断生成收据和逐项证明，可定位范围、到期、调用、字节或重放失败 |
| 依赖自然语言解释 | 核心判断使用可判定的类型化范围和预算代数 |

## 三分钟演示

环境需要 moonc 0.10.14 或更新版本，CI 固定为 `0.10.14+7d59c7ec9`。
示例不需要 API Key、网络服务或付费依赖。本分支准备发布 v0.2.0，已完成严格
检查、构建和 87 项 native 测试；PR #10 的 CI 36737771009 已通过
Ubuntu、macOS、Windows 默认后端验证和质量任务。主分支合并验证与发布仍待完成。
当前已发布版本为 v0.1.1。

### 1. 运行综合场景

```bash
moon run cmd/main
```

重点观察：

1. `docs/**` 授权允许读取 `docs/guide.md`。
2. 一次调用额度耗尽后，第二次调用被拒绝。
3. 到期的密钥读取授权被拒绝。
4. 父级没有网络权限时，网络子授权创建失败。
5. 新增 `.env` 读取被标记为 `NEEDS_APPROVAL`。
6. 一次成功委托与三次授权检查组成的四条事件通过离线重放审计。

综合演示的第一条允许结果会依次输出兼容收据和结构化证明。

### 2. 单独展示最小授权和额度

```bash
moon run cmd/main -- compile docs-reader --calls 2 \
  read-tree:docs exec:moon,test,--deny-warn

moon run cmd/main -- check --calls 1 --repeat 2 \
  read-tree:docs read:docs/guide.md
```

第一条命令生成排序稳定的 Permit。第二条命令输出两行 JSONL：第一次为
`Allow`，第二次为 `CallBudgetExhausted`。拒绝不会继续消耗任何额度。

再执行一次可解释检查：

```bash
moon run cmd/main -- explain --calls 2 --bytes 10 --expires 20 \
  --cost 4 --now 5 read-tree:docs read:docs/guide.md
```

输出中的 `checks` 依次记录调用标识防重放、范围包含、有效期、调用额度和
字节额度；`decision_grant_id` 与同一 JSON 中收据的 `grant_id` 一致。证明和
收据来自一次状态变更，不会重复扣减额度。

### 3. 展示不可扩权委托和权限差异

```bash
moon run cmd/main -- delegate --parent-calls 2 --child-calls 1 \
  read-tree:docs read:docs/guide.md

moon run cmd/main -- diff read-tree:docs read:.env
```

子授权只能从父运行时的剩余权限中预留，不能恢复已经消耗的额度。Diff 只把
新增或扩大的权限标为 `NEEDS_APPROVAL`，删除或收窄权限不会制造额外确认。

### 4. 运行验收门禁

```bash
moon check --deny-warn
moon test --deny-warn
moon fmt
moon info
moon fmt --check
moon build
moon run cmd/main -- audit
moon run examples/basic
moon run examples/guarded_host
```

`guarded_host` 使用内存假执行器展示真实集成边界：所有已识别工具调用先经过
`check_with_proof`，仅 `Allow` 执行一次；越权、过期、额度耗尽、重复标识和未知
工具均不产生执行器副作用。它不读取真实文件，也不执行命令或网络请求。

历史基线为 65 项测试通过，旧 CI 在 Ubuntu、macOS、Windows 运行成功，但使用的
moonc 0.10.12 低于验收要求。本轮已在 moonc 0.10.14 完成生成接口审阅、87 项
native 测试、全部 CLI、两个示例与基准。核心覆盖率为 565/583（96.9%），
全源码为 821/939（87.4%）。本地 Wasm 运行器崩溃，三平台默认后端 CI 与
发布后消费安装仍待完成；证据状态见 `docs/quality.md`。

## 建议重点阅读

- `moonpermit_spec.mbt`：公共行为契约，使用当前 MoonBit `declare` 语法。
- `effect_scope.mbt` 与各 scope 文件：效果范围和包含关系。
- `planner.mbt`：确定性的最小 Permit 编译。
- `runtime.mbt`：最窄授权优先、原子预算消费、收据和结构化证明生成。
- `delegation.mbt`：对子授权的事务性额度预留。
- `audit.mbt`：从初始 Permit 重放完整执行证据。
- `examples/guarded_host`：宿主完整中介、拒绝零副作用的参考集成。
- `docs/quality.md`：测试、覆盖率、基准和源代码规模的可复现证据。
- `docs/threat-model.md`：安全声明成立所需的宿主假设与明确非目标。

## 评委常见问题

### 这是操作系统沙箱吗？

不是。MoonPermit 是应用层参考监控器。宿主必须确保所有受保护操作都经过检查，
并提供真实的类型化请求和逻辑时间。操作系统隔离仍应由容器、沙箱或权限系统完成。

### “Proof-carrying” 是否表示密码学签名？

“证明”指绑定一次运行时状态变更的结构化决策证据，不声称密码学真实性，
也不能作为可重用授权。重放能发现不一致的证据，但一致地重写日志或截断一个有效
前缀仍可能通过。持久化、签名、可信时间和预期事件数量属于宿主的责任。

### 包含委托的运行如何审计？

使用 `Runtime::events()` 保存授权检查与成功委托，交给 `audit_events` 顺序重放。
委托事件包含子 Permit、时间及预留后的父预算。失败委托不改变预算或事件流。
旧 `audit_receipts` 保留用于只做检查的运行，无法从收据推断缺失的委托预留。

### 为什么编译器不删除被宽范围覆盖的窄授权？

两个范围即使存在包含关系，也可能携带不同额度。直接删除窄授权会把它的额度
错误转移到宽范围的其他资源。v0.1 只合并完全相同的范围；运行时则优先消耗最窄
的可用授权，从而为真正需要宽范围的请求保留额度。

### AI 辅助开发如何验收？

AI 辅助范围、人工责任、参考来源和非复制边界均已公开记录。公共行为必须通过
黑盒、边界、性质或状态机测试，不能仅凭生成代码看起来合理而接受。

## 当前发布边界

已发布的 v0.1.1 覆盖效果代数、Permit 编译、运行时门禁、不可扩权委托、权限 Diff、
JSON 收据、结构化授权证明和检查流审计。v0.2.0 增加委托事件审计，并修复命令参数
边界造成的标识冲突；旧日志应保留原版本重放。通用配置加载、操作系统执行、分布式状态、
持久化以及密码学签名不在本期承诺内，避免把原型包装成未经验证的生产安全产品。
