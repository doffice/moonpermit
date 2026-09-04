# MoonPermit：AI Agent 可证明效果计划与最小权限引擎

- 参赛者：doffice
- 仓库：https://github.com/doffice/moonpermit
- 项目基础：2026 年 9 月从空仓库原创开发，无赛前既有代码
- 许可证：Apache-2.0

## 项目目标

AI Agent 通常获得整组工具权限，或者要求用户逐次确认调用；两者都无法准确表达“用户只批准完成这项任务所必需的外部效果”。MoonPermit 使用 MoonBit 实现效果计划编译器与运行时门禁：把结构化计划编译为最小权限 Permit，并验证每个真实工具调用都是已批准效果的子集。

## 本期核心工作

1. 为文件、进程、网络、密钥和资源预算建立类型化效果模型。
2. 实现范围包含、交集、规范化和不可扩权委托算法。
3. 从计划合成最小 Permit，并生成人类可读的授权差异。
4. 在运行时输出 Allow、Deny 或 NeedsApproval 决策及确定性收据。
5. 提供 `compile`、`check`、`delegate`、`diff`、`audit` CLI 和完整演示。

## 技术路线与验收

核心库采用纯 MoonBit，实现 `actual_effect <= approved_effect` 与 `child_permit <= parent_permit` 两条不变量；通过黑盒、边界、性质和回归测试覆盖路径逃逸、命令约束、过期、预算耗尽、重放和子 Agent 扩权。项目将提供 CI、可运行示例、架构与威胁模型文档，并发布至 mooncakes.io。

## 原创与参考边界

项目参考对象能力安全、MCP 安全边界和 IETF attenuating agent token 草案的公开思想，但不移植或复制现有实现。MoonPermit 的原创重点是效果计划编译、最小权限合成、计划差异授权、线性预算消费与可验证执行收据。详细来源和非目标见 `docs/prior-art.md` 与 `docs/threat-model.md`。

## AI 使用说明

AI 将辅助需求分析、接口设计、代码、测试和文档；参赛者负责目标、技术取舍、来源核验、运行验证和最终质量。所有关键设计均以规范、测试和可复现命令固化。
