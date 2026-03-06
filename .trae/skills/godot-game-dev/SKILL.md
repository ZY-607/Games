---
name: godot-game-dev
description: 通用Godot游戏开发能力，支持2D/3D游戏项目创建、节点系统、场景管理、脚本编写、资源处理等。适用于使用Godot引擎开发任何类型的游戏，包括新项目初始化、代码重构、性能优化和跨平台发布等场景。
---

# Godot 游戏开发

## 概述

本技能提供完整的Godot游戏开发工作流程指导，涵盖从项目初始化到发布的全流程。支持Godot 4.x版本的所有核心功能，包括GDScript脚本编写、节点与场景系统、资源管理、信号机制、动画系统、物理引擎和UI设计等。

## 项目结构规范

### 推荐目录结构

```
project/
├── assets/               # 原始资源文件
│   ├── art/             # 美术资源
│   ├── audio/           # 音效和音乐
│   └── fonts/           # 字体文件
├── resources/           # 导入后的资源
├── scenes/              # 游戏场景
├── scripts/             # 脚本文件
├── prefabs/             # 可复用场景模板
├── config/             # 配置文件
└── addons/             # 插件和扩展
```

### 资源组织原则

- 使用语义化的文件夹命名
- 将原始资源与导入资源分开管理
- 为不同类型的资源创建专用子目录
- 避免在根目录直接存放文件

## 节点系统

### 节点类型选择

**基础节点：**
- `Node` - 所有节点的基类，适合作为脚本挂载点
- `Node2D` - 2D游戏的基础节点，支持位置、旋转、缩放
- `CharacterBody2D/3D` - 角色控制器专用节点
- `Area2D/3D` - 区域检测和碰撞触发
- `StaticBody2D/3D` - 静态碰撞体
- `RigidBody2D/3D` - 物理模拟物体
- `Control` - UI控件基类
- `CanvasLayer` - UI分层渲染

**容器节点：**
- `Node` - 通用容器
- `HBoxContainer/VBoxContainer` - 水平/垂直布局
- `GridContainer` - 网格布局
- `CenterContainer` - 居中容器

### 节点组合模式

```gdscript
# 典型角色节点结构
CharacterBody2D (根节点)
├── CollisionShape2D (碰撞体)
├── Sprite2D (角色外观)
├── AnimationPlayer (动画播放)
├── RayCast2D (方向检测，可选)
└── Timer (技能冷却，可选)
```

## 场景系统

### 场景创建流程

1. 创建新场景并选择根节点类型
2. 添加必要的子节点构建场景结构
3. 为节点添加碰撞体和碰撞形状
4. 配置节点属性和信号连接
5. 保存场景文件（.tscn格式）

### 场景实例化

```gdscript
# 预加载场景并实例化
var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready():
    var enemy = enemy_scene.instantiate()
    add_child(enemy)
    enemy.position = Vector2(100, 200)

# 实例化并配置
func spawn_enemy():
    var enemy = enemy_scene.instantiate()
    enemy.set_meta("difficulty", 2)
    add_child(enemy)
```

## GDScript 脚本

### 基础语法

```gdscript
extends Node

# 变量声明
@export var speed: float = 300.0
@export var health: int = 100

# 生命周期方法
func _ready():
    print("场景加载完成")

func _process(delta):
    move_player(delta)

func _physics_process(delta):
    handle_physics(delta)

# 自定义方法
func move_player(delta):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    position += direction * speed * delta
```

### 信号机制

```gdscript
# 定义信号
signal health_changed(new_value)
signal died()

# 发送信号
func take_damage(amount):
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        died.emit()

# 连接信号（编辑器方式）
# 在节点面板中选择节点 -> 节点 -> 信号 -> 连接

# 代码连接信号
func _ready():
    $Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
    print("计时器触发")
```

### 属性导出

```gdscript
# 基本导出
@export var damage: int = 10
@export var attack_speed: float = 1.0

# 分组导出
@export_group("Attack Settings")
@export var critical_chance: float = 0.2
@export var critical_multiplier: float = 2.0

# 资源类型导出
@export var weapon_scene: PackedScene
@export var attack_sound: AudioStream
@export var drop_table: Dictionary

# 枚举导出
enum ItemType { WEAPON, ARMOR, CONSUMABLE }
@export var item_type: ItemType = ItemType.WEAPON
```

## 物理系统

### 碰撞检测

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * speed
    
    if direction != Vector2.ZERO:
        move_and_slide()
        
        # 检测碰撞
        for i in get_slide_collision_count():
            var collision = get_slide_collision(i)
            var collider = collision.get_collider()
            print("碰撞对象: ", collider.name)
```

### 区域检测

```gdscript
extends Area2D

func _ready():
    body_entered.connect(_on_body_entered)
    area_entered.connect(_on_area_entered)

func _on_body_entered(body):
    if body.is_in_group("player"):
        print("玩家进入区域")

func _on_area_entered(area):
    print("区域碰撞: ", area.name)
```

## 动画系统

### AnimationPlayer

```gdscript
extends AnimationPlayer

func _ready():
    play("idle")

func attack():
    play("attack")
    await animation_finished
    play("idle")

func is_playing_animation(anim_name: String) -> bool:
    return current_animation == anim_name
```

### AnimationTree（高级）

```gdscript
extends AnimationTree

func _ready():
    active = true

func set_blend_position(blend_pos: Vector2):
    animation_tree.set("parameters/Move/blend_position", blend_pos)
```

## 用户界面

### 控件布局

```gdscript
extends Control

func _ready():
    # 使用锚点布局
    anchor_left = 0.5
    anchor_right = 0.5
    offset_left = -100
    offset_right = 100
    
    # 使用容器
    var vbox = VBoxContainer.new()
    vbox.add_child(create_label("标题"))
    vbox.add_child(create_button("确定"))
    add_child(vbox)

func create_label(text: String) -> Label:
    var label = Label.new()
    label.text = text
    return label

func create_button(text: String) -> Button:
    var button = Button.new()
    button.text = text
    button.pressed.connect(_on_button_pressed)
    return button

func _on_button_pressed():
    print("按钮点击")
```

### 主题定制

```gdscript
extends Control

func _ready():
    var theme = Theme.new()
    theme.set_font_size("font_size", 16)
    theme.set_color("font_color", Color.WHITE, "Label")
    theme.set_constant("separation", 4, "VBoxContainer")
    
    theme.default_font_size = 16
    theme.default_font = load("res://fonts/default.ttf")
```

## 资源管理

### 资源加载

```gdscript
# 预加载（编译时加载）
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

# 动态加载（运行时加载）
func load_level(level_number: int):
    var level_path = "res://levels/level_%d.tscn" % level_number
    var level = load(level_path)
    return level.instantiate()

# 资源变换
func load_and_modify_texture():
    var texture = load("res://assets/image.png")
    var image = texture.get_image()
    image.resize(64, 64)
    var new_texture = ImageTexture.create_from_image(image)
    return new_texture
```

### 资源打包

- 纹理：使用.webp格式减少文件大小
- 音频：使用 Vorbis 或 PCM 格式
- 场景：保存为.tscn格式
- 脚本：保存为.gd格式

## 输入处理

### 输入映射

在项目设置 -> 输入映射中配置输入动作：

```gdscript
func _process(_delta):
    # 检测按键
    if Input.is_action_just_pressed("ui_accept"):
        print("确认键按下")
    
    if Input.is_action_just_released("jump"):
        print("跳跃释放")
    
    # 获取轴值
    var axis = Input.get_axis("ui_left", "ui_right")
    
    # 获取鼠标位置
    var mouse_pos = get_global_mouse_position()
```

### 虚拟摇杆（移动端）

```gdscript
extends CanvasLayer

var joystick_active = false
var joystick_center = Vector2.ZERO
var joystick_vector = Vector2.ZERO

func _input(event):
    if event is InputEventTouch:
        if event.pressed:
            if not joystick_active and event.position.x < 200:
                joystick_active = true
                joystick_center = event.position
        elif event.index == 0:
            joystick_active = false
            joystick_vector = Vector2.ZERO
```

## 性能优化

### 优化策略

- 使用对象池管理频繁创建销毁的对象
- 使用 `visible` 而非 `process_mode` 控制节点处理
- 合理使用 `freeze` 和 `freeze_mode` 优化物理
- 减少 `_process` 中的复杂计算
- 使用 `await` 处理耗时操作
- 利用 `call_deferred` 延迟执行

### 对象池实现

```gdscript
class_name ObjectPool
extends Node

var pool: Array[Node] = []
@export var scene: PackedScene
@export var initial_size: int = 10

func _ready():
    for i in initial_size:
        var obj = scene.instantiate()
        obj.set_process(false)
        obj.set_physics_process(false)
        obj.visible = false
        pool.append(obj)
        add_child(obj)

func acquire() -> Node:
    var obj
    if pool.size() > 0:
        obj = pool.pop_back()
    else:
        obj = scene.instantiate()
        add_child(obj)
    
    obj.set_process(true)
    obj.set_physics_process(true)
    obj.visible = true
    obj.released.disconnect(_on_object_released)
    return obj

func release(obj: Node):
    obj.set_process(false)
    obj.set_physics_process(false)
    obj.visible = false
    obj.released.connect(_on_object_released.bind(obj))
    pool.append(obj)

func _on_object_released(obj):
    pool.append(obj)
```

## 跨平台发布

### 发布配置

```gdscript
# 检测运行平台
func _ready():
    if OS.get_name() == "Windows":
        print("Windows平台")
    elif OS.get_name() == "Android":
        print("Android平台")
    elif OS.get_name() == "iOS":
        print("iOS平台")

# 适配不同屏幕
func _ready():
    var viewport_size = get_viewport_rect().size
    print("视口大小: ", viewport_size)
```

### 导出预设

- Windows: .exe + 依赖库
- macOS: .dmg 或 .app
- Linux: 可执行文件
- Web: HTML5 + WebAssembly
- Android: .apk 或 .aab
- iOS: .ipa（需要Xcode）

## 调试技巧

### 日志输出

```gdscript
func _process(_delta):
    # 使用 print 输出信息
    print("当前位置: ", position)
    
    # 使用 push_warning 输出警告
    if health < 0:
        push_warning("生命值异常")
    
    # 使用 push_error 输出错误
    if weapon == null:
        push_error("武器未装备")
```

### 断点调试

- 使用 Godot 编辑器内置调试器
- 设置断点检查变量值
- 使用监视窗口跟踪对象
- 分析性能分析器数据

## 最佳实践

### 代码规范

- 使用语义化的变量和函数命名
- 添加适当的注释说明复杂逻辑
- 保持函数短小，职责单一
- 使用 `class_name` 定义自定义类
- 利用 `@tool` 注解在编辑器中运行脚本

### 场景设计

- 保持场景层次结构清晰
- 为节点设置有意义的名字
- 使用组（Group）管理相关对象
- 合理利用可复用场景
- 避免过深的节点嵌套

## 相关资源

### 官方文档

- Godot 官方文档：https://docs.godotengine.org
- GDScript 参考：https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html
- API 参考：https://docs.godotengine.org/en/stable/classes/index.html

### 社区资源

- Godot 商店：https://godotengine.org/asset-library
- Reddit 社区：r/godot
- Discord 服务器：Godot Engine
