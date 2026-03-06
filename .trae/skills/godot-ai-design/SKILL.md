---
name: "godot-ai-design"
description: "提供Godot引擎肉鸽类型游戏的AI设计支持，包括敌人AI行为树、路径finding、决策系统等核心功能。当用户需要设计游戏AI时调用。"
---

# Godot肉鸽游戏AI设计师

## 技能概述

本技能专注于为使用Godot引擎开发肉鸽(Roguelike/Roguelite)类型游戏的开发者提供AI设计专业支持。肉鸽游戏的AI需要兼顾挑战性、多样性和性能，本技能将帮助开发者实现智能且有趣的游戏AI系统。

## 适用场景

- 设计基于Godot引擎的肉鸽游戏敌人AI
- 实现路径finding和寻路算法
- 创建复杂的决策系统和行为模式
- 设计难度自适应AI
- 实现群体AI和协同行为
- 优化AI性能和行为
- 解决肉鸽游戏AI设计中的技术难题

## 核心功能支持

### 1. 敌人AI行为设计

- 行为树和状态机实现
- 巡逻和警戒行为
- 战斗和攻击模式
- 躲避和防御行为
- 特殊能力和技能使用
- 死亡和撤退行为

### 2. 路径finding和导航

- A*寻路算法实现
- 网格和导航网格设置
- 动态障碍物避让
- 地形适应性导航
- 路径优化和平滑
- 多人和群体导航

### 3. 决策系统

- 基于规则的决策
- 优先级系统
- 环境感知和反应
- 目标选择和评估
- 资源管理和权衡
- 学习和适应能力

### 4. 难度和挑战性

- 难度等级设计
- 自适应难度系统
- 敌人强度平衡
- 行为多样性
- 组合和协同行为
- 玩家技能匹配

### 5. 性能优化

- AI更新频率控制
- 视野和感知优化
- 计算复杂度管理
- 多线程和异步处理
- 内存使用优化
- 大型群体AI优化

## 使用指南

当您需要以下支持时，可以调用本技能：

1. **AI设计咨询**：讨论游戏AI的整体设计思路和策略
2. **行为实现**：获取具体AI行为的代码实现示例
3. **路径finding**：实现敌人的寻路和导航功能
4. **决策系统**：创建智能的AI决策机制
5. **性能优化**：解决AI相关的性能问题

## 示例用法

### 示例1：行为树实现

```gdscript
# Godot GDScript 示例：基本行为树
class_name BasicBehaviorTree

# 行为节点基类
class BehaviorNode:
    var status = "READY"
    
    func tick() -> String:
        if status != "RUNNING":
            on_enter()
        
        status = update()
        
        if status != "RUNNING":
            on_exit()
        
        return status
    
    func on_enter():
        pass
    
    func update() -> String:
        return "SUCCESS"
    
    func on_exit():
        pass

# 选择节点（OR逻辑）
class SelectorNode extends BehaviorNode:
    var children = []
    var current_child = -1
    
    func _init():
        children = []
    
    func add_child(child):
        children.append(child)
    
    func on_enter():
        current_child = 0
    
    func update() -> String:
        while current_child < children.size():
            var child_status = children[current_child].tick()
            if child_status != "FAILURE":
                return child_status
            current_child += 1
        return "FAILURE"

# 序列节点（AND逻辑）
class SequenceNode extends BehaviorNode:
    var children = []
    var current_child = -1
    
    func _init():
        children = []
    
    func add_child(child):
        children.append(child)
    
    func on_enter():
        current_child = 0
    
    func update() -> String:
        while current_child < children.size():
            var child_status = children[current_child].tick()
            if child_status != "SUCCESS":
                return child_status
            current_child += 1
        return "SUCCESS"

# 敌人AI行为树
class EnemyAI extends Node:
    var behavior_tree
    var target = null
    var vision_range = 100
    var attack_range = 50
    
    func _ready():
        # 创建行为树
        behavior_tree = create_behavior_tree()
    
    func _process(delta):
        # 更新目标
        update_target()
        # 执行行为树
        behavior_tree.tick()
    
    func create_behavior_tree():
        var root = SelectorNode.new()
        
        # 攻击序列
        var attack_sequence = SequenceNode.new()
        attack_sequence.add_child(CanAttackCondition.new(self))
        attack_sequence.add_child(AttackAction.new(self))
        root.add_child(attack_sequence)
        
        # 追逐序列
        var chase_sequence = SequenceNode.new()
        chase_sequence.add_child(HasTargetCondition.new(self))
        chase_sequence.add_child(ChaseAction.new(self))
        root.add_child(chase_sequence)
        
        # 巡逻行为
        root.add_child(PatrolAction.new(self))
        
        return root
    
    func update_target():
        # 寻找玩家作为目标
        var players = get_tree().get_nodes_in_group("players")
        if players.size() > 0:
            target = players[0]
        else:
            target = null

# 条件节点：是否可以攻击
class CanAttackCondition extends BehaviorNode:
    var ai
    
    func _init(ai_instance):
        ai = ai_instance
    
    func update() -> String:
        if ai.target and ai.global_position.distance_to(ai.target.global_position) <= ai.attack_range:
            return "SUCCESS"
        return "FAILURE"

# 动作节点：攻击
class AttackAction extends BehaviorNode:
    var ai
    
    func _init(ai_instance):
        ai = ai_instance
    
    func update() -> String:
        # 执行攻击逻辑
        ai.attack(ai.target)
        return "SUCCESS"

# 条件节点：是否有目标
class HasTargetCondition extends BehaviorNode:
    var ai
    
    func _init(ai_instance):
        ai = ai_instance
    
    func update() -> String:
        if ai.target and ai.global_position.distance_to(ai.target.global_position) <= ai.vision_range:
            return "SUCCESS"
        return "FAILURE"

# 动作节点：追逐
class ChaseAction extends BehaviorNode:
    var ai
    
    func _init(ai_instance):
        ai = ai_instance
    
    func update() -> String:
        # 执行追逐逻辑
        ai.chase(ai.target)
        return "SUCCESS"

# 动作节点：巡逻
class PatrolAction extends BehaviorNode:
    var ai
    
    func _init(ai_instance):
        ai = ai_instance
    
    func update() -> String:
        # 执行巡逻逻辑
        ai.patrol()
        return "SUCCESS"
```

### 示例2：A*寻路算法

```gdscript
# Godot GDScript 示例：A*寻路算法
class_name AStarPathfinding

# 节点类
class Node:
    var x = 0
    var y = 0
    var g = 0
    var h = 0
    var parent = null
    
    func _init(x_pos, y_pos):
        x = x_pos
        y = y_pos
    
    func get_f():
        return g + h

# 网格类
class Grid:
    var width = 0
    var height = 0
    var grid = []
    
    func _init(width_size, height_size):
        width = width_size
        height = height_size
        # 初始化网格
        for y in range(height):
            grid.append([])
            for x in range(width):
                grid[y].append(0)  # 0 = 可通行, 1 = 障碍物
    
    func is_walkable(x, y):
        if x < 0 or x >= width or y < 0 or y >= height:
            return false
        return grid[y][x] == 0
    
    func get_neighbors(node):
        var neighbors = []
        var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
                        Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
        
        for dir in directions:
            var new_x = node.x + int(dir.x)
            var new_y = node.y + int(dir.y)
            if is_walkable(new_x, new_y):
                neighbors.append(Node.new(new_x, new_y))
        
        return neighbors

# A*算法
func find_path(grid, start_x, start_y, end_x, end_y):
    var open_set = []
    var closed_set = []
    
    var start_node = Node.new(start_x, start_y)
    var end_node = Node.new(end_x, end_y)
    
    open_set.append(start_node)
    
    while open_set.size() > 0:
        # 找到f值最小的节点
        var current_node = open_set[0]
        var current_index = 0
        for i in range(open_set.size()):
            if open_set[i].get_f() < current_node.get_f():
                current_node = open_set[i]
                current_index = i
        
        # 从开放集移除，添加到关闭集
        open_set.erase(current_node)
        closed_set.append(current_node)
        
        # 到达目标
        if current_node.x == end_node.x and current_node.y == end_node.y:
            return reconstruct_path(current_node)
        
        # 获取邻居
        var neighbors = grid.get_neighbors(current_node)
        for neighbor in neighbors:
            # 检查是否在关闭集
            var in_closed = false
            for closed_node in closed_set:
                if neighbor.x == closed_node.x and neighbor.y == closed_node.y:
                    in_closed = true
                    break
            if in_closed:
                continue
            
            # 计算g和h
            var tentative_g = current_node.g + 1
            var tentative_h = abs(neighbor.x - end_node.x) + abs(neighbor.y - end_node.y)
            
            # 检查是否在开放集
            var in_open = false
            var open_index = -1
            for i in range(open_set.size()):
                if neighbor.x == open_set[i].x and neighbor.y == open_set[i].y:
                    in_open = true
                    open_index = i
                    break
            
            if not in_open or tentative_g < open_set[open_index].g:
                neighbor.g = tentative_g
                neighbor.h = tentative_h
                neighbor.parent = current_node
                
                if not in_open:
                    open_set.append(neighbor)
                else:
                    open_set[open_index] = neighbor
    
    # 没有找到路径
    return []

func reconstruct_path(node):
    var path = []
    var current = node
    
    while current != null:
        path.append(Vector2(current.x, current.y))
        current = current.parent
    
    # 反转路径，使其从起点到终点
    path.invert()
    return path
```

## 最佳实践

1. **模块化设计**：将AI系统分解为独立的模块，如感知、决策、行为执行等
2. **性能优先**：在设计复杂AI时，始终考虑性能影响
3. **多样性**：为不同类型的敌人设计不同的AI行为，增加游戏趣味性
4. **可扩展性**：设计灵活的AI架构，便于添加新行为和调整现有行为
5. **测试迭代**：通过大量测试调整AI参数，找到最佳平衡点
6. **玩家体验**：AI行为应提供挑战性但公平的游戏体验
7. **视觉反馈**：为AI行为提供清晰的视觉反馈，帮助玩家理解敌人意图
8. **资源管理**：合理管理AI使用的计算和内存资源

## 常见问题

### Q: 如何设计既具有挑战性又公平的AI？

A: 可以使用以下方法：
- 实现不同难度级别的AI行为
- 为AI添加可预测的模式，让玩家可以学习和应对
- 避免AI使用作弊手段获取信息
- 设计AI的弱点和优势，创造战术深度
- 平衡AI的反应速度和决策时间

### Q: 如何优化大量敌人AI的性能？

A: 优化策略：
- 实现AI更新频率控制，远处敌人更新频率降低
- 使用空间分区，只处理玩家附近的敌人AI
- 实现视野系统，敌人只在视野内活跃
- 使用群体行为简化大量敌人的AI计算
- 考虑使用多线程处理AI计算

### Q: 如何实现智能的敌人协同行为？

A: 实现方法：
- 创建简单的通信系统，让敌人能够共享信息
- 设计基于角色的AI系统，不同敌人有不同职责
- 使用目标分配算法，避免多个敌人同时攻击同一目标
- 实现基本的战术行为，如侧翼包抄、前后夹击等
- 考虑使用状态共享，让敌人能够协调行动

### Q: 如何设计适应不同玩家技能水平的AI？

A: 设计建议：
- 实现难度调整系统，根据玩家表现自动调整
- 创建多个难度预设，让玩家选择适合自己的挑战
- 设计AI行为的动态调整机制
- 考虑添加辅助功能，帮助新手玩家
- 为高级玩家提供更具挑战性的AI行为

### Q: 如何处理AI在复杂地形中的导航？

A: 解决方案：
- 使用导航网格(NavigationMesh)系统
- 实现动态路径finding，适应变化的地形
- 为不同类型的地形设计不同的移动行为
- 考虑添加地形适应性，如爬梯、开门等特殊移动
- 优化路径finding算法，减少计算复杂度

## 工具推荐

1. **Godot内置工具**：
   - Navigation2D/Navigation3D节点
   - 行为树插件
   - 状态机编辑器
   - 定时器和信号系统

2. **外部工具**：
   - BehaviorTree.js：行为树可视化工具
   - A* Pathfinding Project：寻路算法参考
   - AI Game Programming Wisdom：AI设计参考书籍

3. **插件推荐**：
   - Godot Behavior Tree：行为树实现
   - Godot State Machine：状态机工具
   - Godot Navigation Utils：导航辅助工具

## 工作流程建议

1. **需求分析**：
   - 确定游戏AI的核心功能和挑战
   - 分析目标玩家群体的技能水平
   - 研究同类游戏的AI设计

2. **架构设计**：
   - 选择合适的AI架构（行为树、状态机等）
   - 设计AI系统的模块和组件
   - 规划AI与游戏其他系统的交互

3. **原型实现**：
   - 创建基础AI行为
   - 实现核心导航和决策系统
   - 测试基本AI功能

4. **功能完善**：
   - 添加复杂的AI行为和决策
   - 实现敌人之间的协同
   - 调整AI难度和平衡性

5. **测试优化**：
   - 测试AI在不同场景下的表现
   - 优化AI性能
   - 收集玩家反馈并调整

## 版本信息

- **版本**：1.0.0
- **创建日期**：2026-02-01
- **更新记录**：
  - 2026-02-01：初始版本，提供Godot肉鸽游戏AI设计核心功能支持

## 调用示例

当用户提出以下需求时，系统将自动调用本技能：

- "我想设计Godot肉鸽游戏的敌人AI"
- "如何实现敌人的路径finding？"
- "肉鸽游戏的AI行为树怎么设计？"
- "Godot里如何实现群体AI？"
- "AI导致游戏性能下降怎么办？"

本技能将为开发者提供专业、实用的AI设计建议和代码示例，帮助他们创建智能且有趣的肉鸽游戏AI系统。