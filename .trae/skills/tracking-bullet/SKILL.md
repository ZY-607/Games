# 追踪弹技能

## 技能概述

追踪弹是一种可以自动跟踪敌人的投射物技能，具有以下特点：
- **自动追踪**：弹头会自动寻找并追踪最近的敌人
- **拖尾效果**：弹头后方有动态拖尾，增强视觉效果
- **高命中率**：由于追踪特性，几乎不会打空

## 技能参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| 基础伤害 | 玩家攻击力 | 每次攻击的基础伤害 |
| 弹道速度 | 10 | 投射物移动速度（受投射物速度加成影响） |
| 冷却时间 | 攻速决定 | 攻击间隔 |
| 穿透次数 | 1 | 可穿透的敌人数量（受穿透加成影响） |
| 追踪范围 | 400px | 自动追踪的目标范围 |
| 拖尾长度 | 8 | 拖尾粒子数量 |

## 视觉效果

### 弹头
- 图片资源：`assets/effects/tracking-bullet-head.png`
- 图片尺寸：64×32（右头左尾）
- 根据移动方向自动旋转朝向
- 降级方案：金色圆形（#FFD700）+ 光晕

### 拖尾
- 图片资源：`assets/effects/tracking-bullet-trail.png`
- 渐变透明度（60% → 0%）
- 逐渐缩小效果
- 降级方案：金色圆形粒子

## 美术素材

| 素材 | 路径 | 尺寸 | 说明 |
|------|------|------|------|
| 弹头 | `assets/effects/tracking-bullet-head.png` | 64×32 | 右边是头部，左边是尾部 |
| 拖尾 | `assets/effects/tracking-bullet-trail.png` | - | 拖尾粒子 |

## 技术实现

### 追踪逻辑
```javascript
// 在updateProjectiles中更新追踪弹位置
if (proj.type === 'guided' && proj.target && enemies.includes(proj.target)) {
    const dx = proj.target.x - proj.x;
    const dy = proj.target.y - proj.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    if (dist > 0.001) {
        proj.vx = (dx / dist) * proj.speed;
        proj.vy = (dy / dist) * proj.speed;
    }
}
```

### 拖尾实现
```javascript
// 使用轨迹数组记录历史位置
if (!proj.trail) proj.trail = [];
proj.trail.unshift({ x: proj.x, y: proj.y });
if (proj.trail.length > 8) proj.trail.pop();
```

### 图片渲染（带旋转）
```javascript
// 图片尺寸：64×32，右边是头部，左边是尾部
const angle = Math.atan2(proj.vy, proj.vx);
const imgWidth = 64;
const imgHeight = 32;
const scale = proj.size * 2 / imgHeight;

ctx.save();
ctx.translate(proj.x, proj.y);
ctx.rotate(angle);
ctx.scale(scale, scale);
ctx.drawImage(trackingBulletHeadImage, -imgWidth/2, -imgHeight/2, imgWidth, imgHeight);
ctx.restore();
```

## 版本历史

- v1.12.0：追踪弹系统正式版，弹头朝向修复
- v1.11.1-dev：初始实现，替换默认普攻
