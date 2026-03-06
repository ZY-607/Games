---
name: "roguelike-upgrade-system"
description: "提供肉鸽游戏升级系统设计支持，包括三选一BD构建机制、技能组合和流派形成。当用户需要设计或实现游戏升级系统时调用。"
---

# 肉鸽游戏升级系统设计助手

## 功能说明

本技能专注于肉鸽游戏升级系统的设计和实现，提供以下核心功能：

1. **三选一升级机制**：设计平衡的三选一升级选项系统
2. **BD构建系统**：支持技能组合和流派形成的深度设计
3. **平衡系统**：确保升级选项的平衡性和游戏体验
4. **随机性设计**：基于玩家进度和当前构建的智能随机生成
5. **数据管理**：提供升级系统的数据结构和管理方案

## 适用场景

- 设计肉鸽游戏的升级系统
- 实现三选一BD构建机制
- 平衡游戏升级选项
- 优化升级系统的随机性和深度

## 核心设计原则

### 三选一升级机制

1. **选项生成**：
   - 基于玩家当前等级和进度生成合适的选项
   - 考虑玩家当前的BD构建，提供相关和互补的选项
   - 确保每个选项都有明确的价值和独特性

2. **选项类型**：
   - **主动技能**：需要玩家触发的技能，如招式、法术等
   - **被动技能**：持续生效的技能，如属性提升、特殊效果等
   - **装备/道具**：提供临时或永久增益的物品
   - **流派核心**：定义玩家构建方向的关键技能

3. **视觉反馈**：
   - 清晰的技能图标和描述
   - 升级动画和特效
   - 技能组合效果的视觉提示

### BD构建系统

1. **流派设计**：
   - **剑术流**：专注于近战攻击速度和连击
   - **拳法流**：注重攻击力和击退效果
   - **内功流**：强调持续伤害和范围效果
   - **暗器流**：专注于远程攻击和控制效果
   - **混合流**：不同流派技能的组合

2. **技能互动**：
   - **协同效果**：多个技能组合产生额外效果
   - **强化效果**：某些技能增强其他技能
   - **转化效果**：改变技能的基础属性或机制

3. **平衡性考虑**：
   - 确保每个流派都有优缺点
   - 避免单一最优解
   - 鼓励实验和多样化构建

### 随机性设计

1. **种子系统**：
   - 使用种子随机确保游戏的可重复性
   - 基于种子生成升级选项池

2. **智能筛选**：
   - 根据玩家当前构建筛选相关选项
   - 确保每个游戏都能体验不同的构建可能性

3. **难度曲线**：
   - 随着游戏进度，升级选项的强度和复杂度增加
   - 后期提供更强大的组合选项

## 数据结构

### 升级选项数据结构

```javascript
const upgradeOption = {
  id: "skill_sword_mastery",
  name: "剑术精通",
  description: "提升剑类技能伤害20%",
  type: "passive", // passive, active, equipment, core
  rarity: "common", // common, rare, epic, legendary
  levelRequirement: 1,
  stats: {
    damage: 20,
    // 其他属性
  },
  synergies: ["skill_sword_combos", "skill_quick_strike"],
  category: "sword", // 流派分类
  icon: "assets/ui/icons/sword_mastery.png"
};
```

### 玩家构建数据结构

```javascript
const playerBuild = {
  level: 5,
  skills: ["skill_sword_mastery", "skill_quick_strike"],
  equipment: ["weapon_iron_sword"],
  stats: {
    damage: 100,
    speed: 80,
    defense: 50,
    // 其他属性
  },
  buildScore: 75, // 构建强度评分
  dominantCategory: "sword" // 主要流派
};
```

## 实现方案

### 升级选项生成算法

```javascript
function generateUpgradeOptions(playerBuild) {
  const options = [];
  const level = playerBuild.level;
  
  // 1. 基于等级筛选可选技能池
  const availableSkills = allSkills.filter(skill => 
    skill.levelRequirement <= level && 
    !playerBuild.skills.includes(skill.id)
  );
  
  // 2. 智能筛选，优先相关流派
  const categoryWeights = calculateCategoryWeights(playerBuild);
  
  // 3. 随机选择三个平衡的选项
  for (let i = 0; i < 3; i++) {
    const weightedPool = weightSkillsByCategory(availableSkills, categoryWeights);
    const selectedSkill = selectRandomSkill(weightedPool);
    options.push(selectedSkill);
    // 从池中移除已选择的技能
    availableSkills.splice(availableSkills.indexOf(selectedSkill), 1);
  }
  
  return options;
}
```

### 技能协同效果计算

```javascript
function calculateSynergyEffects(playerBuild) {
  const synergies = [];
  
  // 检查所有技能组合
  for (let i = 0; i < playerBuild.skills.length; i++) {
    for (let j = i + 1; j < playerBuild.skills.length; j++) {
      const skill1 = getSkillById(playerBuild.skills[i]);
      const skill2 = getSkillById(playerBuild.skills[j]);
      
      // 检查是否有协同效果
      if (skill1.synergies.includes(skill2.id)) {
        synergies.push({
          skills: [skill1.id, skill2.id],
          effect: getSynergyEffect(skill1.id, skill2.id)
        });
      }
    }
  }
  
  return synergies;
}
```

## 平衡系统

### 数值平衡

1. **基准值设定**：
   - 定义每个等级的预期强度增长
   - 基于游戏总时长和升级次数计算

2. **选项价值评估**：
   - 为每个升级选项分配价值评分
   - 确保三个选项的价值相近
   - 考虑技能的长期价值和组合潜力

3. **难度调整**：
   - 基于玩家构建强度调整敌人难度
   - 动态平衡游戏体验

### 多样化鼓励

1. **流派奖励**：
   - 为专注于单一流派的玩家提供额外奖励
   - 为混合流派玩家提供独特的组合效果

2. **成就系统**：
   - 设计与不同流派相关的成就
   - 鼓励玩家尝试不同的构建

3. **新游戏+**：
   - 提供更高难度的游戏模式
   - 解锁新的升级选项和流派

## 最佳实践

1. **迭代设计**：
   - 从简单的升级系统开始
   - 通过测试和反馈不断扩展和平衡

2. **数据驱动**：
   - 使用配置文件定义升级选项
   - 便于调整和扩展

3. **玩家反馈**：
   - 收集玩家对升级系统的反馈
   - 分析玩家构建数据，识别强势和弱势流派

4. **文档化**：
   - 记录升级系统的设计决策
   - 为每个升级选项创建详细文档

## 常见问题

### 平衡问题
- **解决方案**：定期测试和调整，使用数据分析识别问题

### 选择困难
- **解决方案**：提供清晰的技能描述和视觉提示，考虑添加预览功能

### 流派单一
- **解决方案**：确保每个流派都有独特的优势，设计交叉流派的协同效果

### 后期疲软
- **解决方案**：设计后期强力的升级选项，确保游戏体验的持续提升

## 示例实现

### 升级系统核心代码

```javascript
class UpgradeSystem {
  constructor(skillDatabase) {
    this.skillDatabase = skillDatabase;
  }
  
  generateOptions(playerBuild) {
    // 实现升级选项生成逻辑
  }
  
  applyUpgrade(player, upgradeId) {
    // 实现应用升级的逻辑
  }
  
  calculateSynergies(playerBuild) {
    // 实现技能协同效果计算
  }
}
```

### 中国武侠风格升级选项示例

```javascript
const wuxiaSkills = [
  {
    id: "skill_sword_heart",
    name: "剑心通明",
    description: "剑术伤害提升30%，有几率触发剑气追踪目标",
    type: "passive",
    rarity: "rare",
    levelRequirement: 3,
    stats: {
      damage: 30
    },
    synergies: ["skill_sword_rain", "skill_quick_strike"],
    category: "sword",
    icon: "assets/ui/icons/sword_heart.png"
  },
  {
    id: "skill_qigong_mastery",
    name: "内功 mastery",
    description: "内功伤害提升25%，持续时间延长",
    type: "passive",
    rarity: "common",
    levelRequirement: 1,
    stats: {
      damage: 25,
      duration: 20
    },
    synergies: ["skill_qi_explosion"],
    category: "qigong",
    icon: "assets/ui/icons/qigong_mastery.png"
  }
  // 更多技能...
];
```