---
name: "unity-ai-design"
description: "提供Unity引擎肉鸽类型游戏的AI设计支持，包括敌人AI行为树、路径finding、决策系统等核心功能。当用户需要设计游戏AI时调用。"
---

# Unity肉鸽游戏AI设计专家

## 技能概述

本技能专注于为使用Unity引擎开发肉鸽类型游戏的开发者提供AI设计支持。肉鸽游戏中的AI设计对于游戏体验至关重要，本技能将帮助开发者实现智能、有趣且具有挑战性的敌人AI系统。

## 适用场景

- 设计Unity肉鸽游戏中的敌人AI行为
- 实现敌人的路径finding和导航系统
- 创建敌人的决策系统和行为树
- 设计不同难度级别的AI行为
- 优化AI性能，确保游戏流畅运行
- 解决AI设计中的技术难题

## 核心功能支持

### 1. AI行为系统

- 使用Unity的行为树实现复杂AI行为
- 状态机设计和实现
- 敌人的巡逻、追逐、攻击行为
- 基于环境的动态行为调整
- 敌人之间的协作行为

### 2. 路径finding

- 使用Unity的NavMesh系统实现路径finding
- 动态障碍物回避
- 寻路算法优化
- 不同类型敌人的移动策略
- 考虑地形和环境因素的路径规划

### 3. 决策系统

- 敌人的目标选择机制
- 基于玩家状态的动态决策
- 资源管理和优先级决策
- 随机决策因素，增加游戏变化性
- 基于难度级别的决策调整

### 4. AI平衡

- 不同难度级别的AI配置
- 渐进式AI挑战设计
- 玩家技能与AI能力的平衡
- 动态难度调整系统
- AI行为模式的多样性

### 5. 性能优化

- AI计算的性能优化
- 大量敌人的AI管理
- 远距离敌人的AI简化
- 使用Unity的Job System和Burst Compiler优化AI计算
- 异步AI决策处理

## 使用指南

当您需要以下支持时，可以调用本技能：

1. **AI设计咨询**：讨论敌人AI的设计思路和行为模式
2. **技术实现**：获取AI系统的代码实现示例
3. **性能优化**：解决AI系统的性能问题
4. **平衡调整**：优化AI难度和游戏体验

## 示例用法

### 示例1：基本行为树实现

```csharp
// Unity C# 示例：使用行为树实现敌人AI
using UnityEngine;
using UnityEngine.AI;

public class EnemyAI : MonoBehaviour
{
    public Transform player;
    public NavMeshAgent agent;
    public float chaseDistance = 10f;
    public float attackDistance = 2f;
    public float patrolSpeed = 3f;
    public float chaseSpeed = 6f;
    public float attackCooldown = 1f;

    private enum AIState { Patrol, Chase, Attack }
    private AIState currentState;
    private Vector3 patrolDestination;
    private float lastAttackTime;

    private void Start()
    {
        currentState = AIState.Patrol;
        SetRandomPatrolDestination();
    }

    private void Update()
    {
        float distanceToPlayer = Vector3.Distance(transform.position, player.position);

        switch (currentState)
        {
            case AIState.Patrol:
                HandlePatrol(distanceToPlayer);
                break;
            case AIState.Chase:
                HandleChase(distanceToPlayer);
                break;
            case AIState.Attack:
                HandleAttack(distanceToPlayer);
                break;
        }
    }

    private void HandlePatrol(float distanceToPlayer)
    {
        agent.speed = patrolSpeed;

        // 检查是否到达巡逻点
        if (Vector3.Distance(transform.position, patrolDestination) < 1f)
        {
            SetRandomPatrolDestination();
        }

        // 检查是否发现玩家
        if (distanceToPlayer < chaseDistance)
        {
            currentState = AIState.Chase;
        }
    }

    private void HandleChase(float distanceToPlayer)
    {
        agent.speed = chaseSpeed;
        agent.SetDestination(player.position);

        // 检查是否可以攻击
        if (distanceToPlayer < attackDistance)
        {
            currentState = AIState.Attack;
        }
        // 检查是否失去玩家
        else if (distanceToPlayer > chaseDistance * 1.5f)
        {
            currentState = AIState.Patrol;
            SetRandomPatrolDestination();
        }
    }

    private void HandleAttack(float distanceToPlayer)
    {
        agent.SetDestination(transform.position); // 停止移动

        // 检查是否可以攻击
        if (Time.time - lastAttackTime > attackCooldown)
        {
            AttackPlayer();
            lastAttackTime = Time.time;
        }

        // 检查玩家是否离开攻击范围
        if (distanceToPlayer > attackDistance * 1.5f)
        {
            currentState = AIState.Chase;
        }
        // 检查是否失去玩家
        else if (distanceToPlayer > chaseDistance * 1.5f)
        {
            currentState = AIState.Patrol;
            SetRandomPatrolDestination();
        }
    }

    private void SetRandomPatrolDestination()
    {
        float radius = 10f;
        Vector3 randomDirection = Random.insideUnitSphere * radius;
        randomDirection += transform.position;
        NavMeshHit hit;
        if (NavMesh.SamplePosition(randomDirection, out hit, radius, 1))
        {
            patrolDestination = hit.position;
            agent.SetDestination(patrolDestination);
        }
    }

    private void AttackPlayer()
    {
        // 实现攻击逻辑
        Debug.Log("Enemy attacks player!");
        // 这里可以添加伤害计算、动画触发等
    }
}
```

### 示例2：使用Unity的行为树插件

```csharp
// Unity C# 示例：使用行为树资产实现复杂AI
using UnityEngine;
using BehaviorDesigner.Runtime;
using BehaviorDesigner.Runtime.Tasks;

[TaskCategory("EnemyAI")]
public class ChasePlayer : Action
{
    public SharedTransform playerTransform;
    public SharedNavMeshAgent agent;
    public SharedFloat chaseSpeed = 6f;
    public SharedFloat chaseDistance = 10f;

    public override void OnStart()
    {
        if (agent.Value != null)
        {
            agent.Value.speed = chaseSpeed.Value;
        }
    }

    public override TaskStatus OnUpdate()
    {
        if (playerTransform.Value == null || agent.Value == null)
        {
            return TaskStatus.Failure;
        }

        float distance = Vector3.Distance(transform.position, playerTransform.Value.position);
        if (distance > chaseDistance.Value)
        {
            return TaskStatus.Failure;
        }

        agent.Value.SetDestination(playerTransform.Value.position);
        return TaskStatus.Running;
    }
}

[TaskCategory("EnemyAI")]
public class AttackPlayer : Action
{
    public SharedTransform playerTransform;
    public SharedFloat attackDistance = 2f;
    public SharedFloat attackCooldown = 1f;
    public SharedFloat lastAttackTime;

    public override TaskStatus OnUpdate()
    {
        if (playerTransform.Value == null)
        {
            return TaskStatus.Failure;
        }

        float distance = Vector3.Distance(transform.position, playerTransform.Value.position);
        if (distance > attackDistance.Value)
        {
            return TaskStatus.Failure;
        }

        if (Time.time - lastAttackTime.Value > attackCooldown.Value)
        {
            // 执行攻击
            Debug.Log("Enemy attacks player!");
            lastAttackTime.Value = Time.time;
            return TaskStatus.Success;
        }

        return TaskStatus.Running;
    }
}
```

## 最佳实践

1. **模块化设计**：将AI系统分解为独立的组件，如感知、决策、行为执行
2. **数据驱动**：使用ScriptableObject定义AI参数，便于调整和平衡
3. **性能考虑**：对于大量敌人，使用简化的AI行为和LOD系统
4. **多样性**：设计不同类型的敌人AI，增加游戏的变化性和挑战性
5. **可扩展性**：构建灵活的AI架构，便于添加新的敌人类型和行为
6. **测试和迭代**：通过游戏测试不断调整AI行为，确保游戏体验平衡

## 常见问题

### Q: 如何处理大量敌人的AI性能问题？

A: 可以使用以下方法：
- 实现AI LOD系统，根据距离简化AI计算
- 使用Unity的Job System和Burst Compiler优化AI计算
- 对远距离敌人使用更简单的行为模式
- 实现AI更新频率的动态调整
- 使用对象池管理敌人实例

### Q: 如何设计具有挑战性但又公平的AI？

A: 建议：
- 实现渐进式难度曲线，随着游戏进程增加AI挑战
- 给玩家提供足够的反馈和提示，让AI行为可预测但不单调
- 设计不同类型的敌人AI，有些注重速度，有些注重防御，有些注重策略
- 实现动态难度调整系统，根据玩家表现调整AI行为
- 确保AI有明确的弱点，让玩家可以制定策略

### Q: 如何实现敌人之间的协作行为？

A: 实现方法：
- 使用简单的通信系统，让敌人共享玩家位置信息
- 设计基于目标的协作行为，如包围玩家
- 实现敌人的分工协作，如坦克、 DPS、辅助角色
- 使用事件系统触发敌人的协作行为
- 考虑敌人类型和能力的互补性

## 版本信息

- **版本**：1.0.0
- **创建日期**：2026-02-01
- **更新记录**：
  - 2026-02-01：初始版本，提供Unity肉鸽游戏AI设计核心功能支持

## 调用示例

当用户提出以下需求时，系统将自动调用本技能：

- "如何在Unity中设计敌人AI？"
- "Unity肉鸽游戏的AI行为树怎么实现？"
- "如何优化大量敌人的AI性能？"
- "Unity中的路径finding怎么实现？"
- "如何设计敌人之间的协作行为？"

本技能将为开发者提供专业、实用的AI设计建议和代码示例，帮助他们创建智能、有趣且具有挑战性的肉鸽游戏体验。