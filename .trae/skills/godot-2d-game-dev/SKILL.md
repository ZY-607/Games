---
name: godot-2d-game-dev
description: 专注于Godot 2D游戏开发，包括TileMap地图编辑、2D光照系统、视差背景、精灵动画、物理碰撞、摄像机控制、屏幕震动、粒子效果等。适用于2D游戏项目的场景构建、角色控制、平台跳跃、俯视角游戏等开发需求。
---

# Godot 2D 游戏开发

## 概述

本技能专注于Godot引擎的2D游戏开发，提供TileMap地图编辑、2D光照系统、视差背景、精灵动画、物理碰撞检测、摄像机控制等核心技术指南。涵盖平台跳跃游戏、俯视角游戏、卷轴游戏等多种2D游戏类型的最佳实践。

## TileMap 地图系统

### TileSet 创建与配置

TileMap是2D游戏地图构建的核心工具。通过创建TileSet来定义可放置的图块，然后使用TileMap节点在场景中绘制地图。TileSet支持自动图块绘制、碰撞形状定义、动画图块和自定义数据图层等功能。

### 图块碰撞设置

```gdscript
extends TileMap

@export var tile_size: Vector2i = Vector2i(16, 16)

func _ready():
    # 设置图块大小
    tile_set.tile_size = tile_size
    
    # 配置碰撞层
    set_collision_layer_value(1, true)  # 墙壁
    set_collision_layer_value(2, true)  # 平台
    set_collision_layer_value(3, true)  # 危险区域

# 检测特定位置的碰撞
func can_move_to(world_pos: Vector2) -> bool:
    var tile_pos = local_to_map(world_pos)
    var tile_data = get_tile_tile_data(tile_pos)
    
    if tile_data:
        return not tile_data.get_collision_polygon(0)  # 假设0号多边形为障碍
    return false
```

### 自动图块绘制

TileMap支持自动图块功能，可以自动处理图块之间的连接和过渡。在TileSet编辑器中配置自动图块时，需要为每种图块类型定义正确的邻居关系。这样在绘制地图时，图块会自动选择合适的外观。

### 动画图块

```gdscript
extends TileMap

func _ready():
    # 获取动画图块数据
    var tile_set = self.tile_set
    var source_id = 0  # TileSetAtlasSource
    var animated_tiles = tile_set.get_tiles_ids_for_source_id(source_id)
    
    for tile_id in animated_tiles:
        var tile_data = tile_set.get_tile_data(tile_id, source_id)
        if tile_data.tile_mode == TileData.TILE_MODE_ANIMATED:
            print("动画图块: ", tile_id)
            print("帧数: ", tile_data.get_animation_frames_count())
```

### 地形笔刷

使用地形笔刷可以快速绘制连续的地形，通过配置地形连接规则来自动处理不同地形之间的过渡。地形笔刷支持多种形状包括直线、拐角、十字路口等。

## 2D 光照系统

### WorldEnvironment 光照配置

```gdscript
extends Node2D

func _ready():
    var env = WorldEnvironment.new()
    var environment = Environment.new()
    
    # 配置2D光照
    environment.background_mode = Environment.BG_CANVAS
    environment.canvas_lights_enabled = true
    environment.canvas_lights_modulate_luminance = true
    environment.canvas_lights_blend_mode = Environment.CANVAS_LIGHT_BLEND_MODE_ADD
    
    env.environment = environment
    add_child(env)
```

### Light2D 节点

```gdscript
extends Node2D

@export var light_color: Color = Color(1, 0.8, 0.5)
@export var energy: float = 1.0
@export var range_layer: int = 0

func setup_light():
    var light = Light2D.new()
    light.position = Vector2(400, 300)
    light.color = light_color
    light.energy = energy
    light.range_layer = range_layer
    
    # 设置遮罩纹理
    var texture = load("res://assets/light_mask.png")
    light.texture = texture
    
    # 配置阴影
    light.shadow_enabled = true
    light.shadow_filter = Light2D.SHADOW_FILTER_PCF13
    
    add_child(light)

func update_light_position(target: Vector2):
    position = position.lerp(target, 0.1)
```

### 阴影投射

```gdscript
extends StaticBody2D

func _ready():
    # 确保阴影层与光照层匹配
    collision_layer = 1
    collision_mask = 0
    
    # 设置阴影投射
    set_collision_layer_value(1, true)  # 物理层
    set_collision_layer_value(2, true)  # 阴影投射层

# 自定义阴影形状
func _draw():
    var shape = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 32
    shape.shape = circle
```

## 视差背景

### ParallaxLayer 实现

```gdscript
extends ParallaxLayer

@export var scroll_offset: Vector2 = Vector2.ZERO
@export var scroll_base_scale: Vector2 = Vector2(1, 1)
@export var mirror_texture: bool = false

func _process(_delta):
    var viewport_size = get_viewport_rect().size
    var camera = get_parent().get_camera()
    
    if camera:
        var scroll_motion = calculate_scroll_motion(camera)
        motion_offset = scroll_motion

func calculate_scroll_motion(camera: Camera2D) -> Vector2:
    var parallax_factor = scroll_base_scale - Vector2(1, 1)
    var camera_motion = camera.get_screen_center_position()
    return camera_motion * parallax_factor + scroll_offset
```

### 背景分层系统

```gdscript
extends Node2D

@export var background_layers: Array[PackedScene] = []

func _ready():
    setup_background_layers()

func setup_background_layers():
    var camera = $Camera2D
    
    # 创建视差滚动父节点
    var parallax = ParallaxBackground.new()
    add_child(parallax)
    
    # 添加远景背景（移动最慢）
    var far_layer = ParallaxLayer.new()
    far_layer.scroll_base_scale = Vector2(0.1, 0.1)
    far_layer.add_child(create_background_sprite("far_bg.png"))
    parallax.add_child(far_layer)
    
    # 添加中景背景
    var mid_layer = ParallaxLayer.new()
    mid_layer.scroll_base_scale = Vector2(0.5, 0.5)
    mid_layer.add_child(create_background_sprite("mid_bg.png"))
    parallax.add_child(mid_layer)
    
    # 添加近景背景（移动最快）
    var near_layer = ParallaxLayer.new()
    near_layer.scroll_base_scale = Vector2(0.8, 0.8)
    near_layer.add_child(create_background_sprite("near_bg.png"))
    parallax.add_child(near_layer)

func create_background_sprite(texture_path: String) -> Sprite2D:
    var sprite = Sprite2D.new()
    var texture = load(texture_path)
    sprite.texture = texture
    sprite.scale = Vector2(2, 2)  # 根据需要调整
    return sprite
```

## 精灵与动画

### Sprite2D 管理

```gdscript
extends Node2D

@export var sprite_texture: Texture2D
@export var frame_size: Vector2 = Vector2(32, 32)
@export var current_frame: int = 0
@export var animation_speed: float = 10.0

var animation_timer: float = 0.0
var is_animating: bool = true
var animation_frames: Array[int] = []

func _ready():
    sprite_texture = load("res://assets/spritesheet.png")
    animation_frames = [0, 1, 2, 3, 4, 5]  # 动画帧索引

func _process(delta):
    if is_animating:
        animation_timer += delta * animation_speed
        if animation_timer >= 1.0:
            animation_timer = 0.0
            current_frame = (current_frame + 1) % animation_frames.size()
            update_frame()

func update_frame():
    var frame_x = animation_frames[current_frame] * int(frame_size.x)
    var frame_rect = Rect2(frame_x, 0, frame_size.x, frame_size.y)
    $Sprite2D.region_enabled = true
    $Sprite2D.region_rect = frame_rect

func play_animation(frames: Array[int], speed: float):
    animation_frames = frames
    animation_speed = speed
    is_animating = true
    current_frame = 0

func stop_animation():
    is_animating = false

func set_frame(frame_index: int):
    current_frame = frame_index
    is_animating = false
    update_frame()
```

### 动画状态机

```gdscript
class_name AnimationStateMachine
extends Node

signal state_changed(new_state, old_state)
signal animation_finished(anim_name)

@export var default_state: String = "idle"

var current_state: String = ""
var animation_player: AnimationPlayer

func _ready():
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    current_state = default_state

func change_state(new_state: String):
    if current_state == new_state:
        return
    
    var old_state = current_state
    current_state = new_state
    
    # 播放新状态动画
    animation_player.play(new_state)
    
    state_changed.emit(new_state, old_state)
    
    # 监听动画结束
    animation_player.animation_finished.connect(
        func(_anim): animation_finished.emit(new_state)
    )

func is_playing(anim_name: String) -> bool:
    return animation_player.current_animation == anim_name
```

## 2D 物理系统

### 碰撞层与遮罩

```gdscript
extends CharacterBody2D

# 碰撞层定义
enum CollisionLayer {
    PLAYER = 1,
    ENEMY = 2,
    WALLS = 4,
    ITEMS = 8,
    HAZARDS = 16
}

# 碰撞遮罩
@export var collision_mask: int = CollisionLayer.WALLS

func _ready():
    # 设置碰撞层
    collision_layer = CollisionLayer.PLAYER
    
    # 设置碰撞遮罩
    collision_mask = CollisionLayer.WALLS | CollisionLayer.ENEMY
    
    # 动态更新碰撞层
    set_collision_layer_value(1, true)
    set_collision_mask_value(1, true)
    set_collision_mask_value(2, true)

func check_collision():
    # 检测碰撞对象
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        
        if collider.is_in_group("enemies"):
            take_damage(10)
        elif collider.is_in_group("items"):
            collect_item(collider)
```

### 区域检测

```gdscript
extends Area2D

signal player_entered(player)
signal player_exited(player)

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    area_entered.connect(_on_area_entered)

func _on_body_entered(body):
    if body.is_in_group("player"):
        player_entered.emit(body)
        highlight_area(true)

func _on_body_exited(body):
    if body.is_in_group("player"):
        player_exited.emit(body)
        highlight_area(false)

func highlight_area(active: bool):
    var tween = create_tween()
    var target_color = Color.GREEN if active else Color.WHITE
    tween.tween_property(self, "modulate", target_color, 0.2)
```

## 摄像机系统

### 基础摄像机控制

```gdscript
extends Camera2D

@export var follow_target: Node2D
@export var dead_zone: Vector2 = Vector2(100, 100)
@export var smoothing_speed: float = 5.0
@export var zoom_speed: float = 0.5
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0

var current_zoom: float = 1.0

func _ready():
    if follow_target:
        position = follow_target.position

func _process(delta):
    if follow_target:
        update_camera_position(delta)

func update_camera_position(delta: Vector2):
    var target_pos = follow_target.position
    
    # 死区检测
    if position.distance_to(target_pos) > dead_zone.x:
        position = position.lerp(target_pos, smoothing_speed * delta)

func zoom_in():
    current_zoom = clamp(current_zoom + zoom_speed, min_zoom, max_zoom)
    zoom = Vector2(current_zoom, current_zoom)

func zoom_out():
    current_zoom = clamp(current_zoom - zoom_speed, min_zoom, max_zoom)
    zoom = Vector2(current_zoom, current_zoom)
```

### 摄像机震动效果

```gdscript
extends Camera2D

signal shake_finished

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var shake_decay: float = 5.0

func _process(delta):
    if shake_intensity > 0:
        shake_timer -= delta
        apply_shake()
        
        if shake_timer <= 0:
            shake_intensity = 0
            shake_finished.emit()

func apply_shake():
    var random_offset = Vector2(
        randf_range(-1, 1),
        randf_range(-1, 1)
    ) * shake_intensity
    
    offset = offset.lerp(random_offset, 0.3)

func start_shake(intensity: float, duration: float):
    shake_intensity = intensity
    shake_duration = duration
    shake_timer = duration

func add_shake(intensity: float):
    shake_intensity = clamp(shake_intensity + intensity, 0, 20)
```

## 屏幕震动效果

```gdscript
extends Node2D

var camera: Camera2D
var screenshake_intensity: float = 0.0

func _ready():
    camera = $Camera2D
    camera.shake_finished.connect(_on_shake_finished)

func apply_screenshake(intensity: float, duration: float):
    camera.start_shake(intensity, duration)

func trauma_shake(trauma: float, decay: float = 2.0):
    var intensity = trauma * trauma
    camera.start_shake(intensity, 0.3)
```

## 2D 粒子系统

### GPUParticles2D

```gdscript
extends GPUParticles2D

@export var particle_lifetime: float = 1.0
@export var particle_count: int = 50
@export var emission_shape: int = ParticleTypes.SHAPE_POINT

enum ParticleTypes {
    SHAPE_POINT,
    SHAPE_BOX,
    SHAPE_CIRCLE,
    SHAPE_SPHERE
}

func _ready():
    configure_particles()

func configure_particles():
    lifetime = particle_lifetime
    amount = particle_count
    
    # 配置发射形状
    emission_shape = ParticleTypes.SHAPE_CIRCLE
    emission_points = 10
    
    # 配置颜色渐变
    var gradient = Gradient.new()
    gradient.set_color(0, Color(1, 1, 1, 1))
    gradient.set_color(1, Color(1, 1, 1, 0))
    color_ramp = gradient
    
    # 配置缩放曲线
    var scale_curve = CurveTexture.new()
    scale_curve.curve = Curve.new()
    scale_curve.curve.add_point(Vector2(0, 1))
    scale_curve.curve.add_point(Vector2(1, 0))
    scale_control = scale_curve

func emit_particles_once():
    emitting = false
    one_shot = true
    emitting = true

func set_particle_color(color: Color):
    modulate = color

func set_particle_speed(speed: float):
    initial_velocity_min = speed * 0.5
    initial_velocity_max = speed
```

### 粒子发射器模式

```gdscript
extends Node2D

@export var particle_scene: PackedScene

func _ready():
    particle_scene = load("res://prefabs/particle_emitter.tscn")

func spawn_particle_at(pos: Vector2, color: Color):
    var emitter = particle_scene.instantiate()
    emitter.position = pos
    emitter.set_particle_color(color)
    add_child(emitter)

func spawn_burst(pos: Vector2, count: int, color: Color):
    for i in count:
        await get_tree().create_timer(i * 0.05).timeout
        spawn_particle_at(pos + Vector2(randf_range(-10, 10), randf_range(-10, 10)), color)
```

## 平台跳跃游戏

### 角色控制器

```gdscript
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_force: float = 500.0
@export var gravity: float = 980.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

var is_on_floor_only: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_jumping: bool = false

func _physics_process(delta):
    apply_gravity(delta)
    handle_movement()
    handle_jump()
    move_and_slide()
    update_animations()

func apply_gravity(delta):
    if not is_on_floor():
        velocity.y += gravity * delta

func handle_movement():
    var direction = Input.get_axis("ui_left", "ui_right")
    velocity.x = direction * speed
    
    if direction != 0:
        flip_sprite(direction)

func handle_jump():
    # 土狼时间
    if is_on_floor():
        coyote_timer = coyote_time
    else:
        coyote_timer -= get_physics_process_delta_time()
    
    # 跳跃缓冲
    if Input.is_action_just_pressed("ui_accept"):
        jump_buffer_timer = jump_buffer_time
    
    # 执行跳跃
    if coyote_timer > 0 and jump_buffer_timer > 0:
        velocity.y = -jump_force
        coyote_timer = 0
        jump_buffer_timer = 0
        is_jumping = true
        create_jump_effect()

func update_animations():
    if velocity.y < 0:
        play_animation("jump")
    elif velocity.y > 0:
        play_animation("fall")
    elif abs(velocity.x) > 0:
        play_animation("run")
    else:
        play_animation("idle")

func flip_sprite(direction: float):
    $Sprite2D.flip_h = direction < 0
```

### 地面检测

```gdscript
extends RayCast2D

@export var ground_layer: int = 1
@export var check_distance: float = 20.0

func _ready():
    target_position = Vector2(0, check_distance)
    collision_mask = ground_layer

func is_ground_below() -> bool:
    return is_colliding()

func get_ground_normal() -> Vector2:
    if is_colliding():
        return get_collision_normal()
    return Vector2.UP
```

### 移动平台

```gdscript
extends StaticBody2D

@export var move_range: float = 100.0
@export var move_speed: float = 50.0
@export var wait_time: float = 1.0

var start_pos: Vector2
var direction: int = 1
var timer: float = 0.0

func _ready():
    start_pos = position

func _physics_process(delta):
    if timer > 0:
        timer -= delta
        return
    
    position.x += direction * move_speed * delta
    
    if abs(position.x - start_pos.x) >= move_range:
        direction *= -1
        timer = wait_time
```

## 俯视角游戏

### 俯视角移动

```gdscript
extends CharacterBody2D

@export var move_speed: float = 200.0
@export var diagonal_multiplier: float = 0.707  # 1/sqrt(2)

func _physics_process(_delta):
    var direction = Vector2.ZERO
    
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    
    # 归一化并应用对角线修正
    direction = direction.normalized()
    if direction.x != 0 and direction.y != 0:
        direction *= diagonal_multiplier
    
    velocity = direction * move_speed
    move_and_slide()

func look_at_mouse():
    var mouse_pos = get_global_mouse_position()
    look_at(mouse_pos)
```

### 2.5D 视角效果

```gdscript
extends Node2D

@export var camera_tilt_angle: float = 15.0
@export var perspective_offset: Vector2 = Vector2(0, 50)

func apply_tilt_effect(target_pos: Vector2):
    var tilt = Vector3.ZERO
    
    # 基于鼠标位置计算倾斜
    var viewport_center = get_viewport_rect().size / 2
    var mouse_offset = target_pos - viewport_center
    tilt.x = -mouse_offset.x / viewport_center.x * camera_tilt_angle
    tilt.y = mouse_offset.y / viewport_center.y * camera_tilt_angle
    
    return tilt
```

## 2D 优化技巧

### 视锥剔除

```gdscript
extends Node2D

func optimize_visible_area():
    var visible_rect = get_viewport_rect()
    
    for sprite in get_children():
        if sprite is Sprite2D:
            var sprite_rect = Rect2(
                sprite.global_position - sprite.texture.get_size() * sprite.scale / 2,
                sprite.texture.get_size() * sprite.scale
            )
            
            if not visible_rect.intersects(sprite_rect):
                sprite.visible = false
            else:
                sprite.visible = true
```

### 图集合并

将多个小图合并为精灵图集，减少绘制调用次数。在项目设置中配置资源导入选项，将小图合并为精灵图集并生成对应的元数据文件。

### 遮挡剔除

使用 VisibilityNotifier2D 或自定义遮挡系统，在对象离开屏幕时禁用其处理逻辑和渲染。这可以显著提高游戏性能，特别是对于包含大量对象的场景。

```gdscript
extends Node2D

func _ready():
    $VisibilityNotifier2D.visibility_notifier_2d_screen_entered.connect(
        _on_screen_entered
    )
    $VisibilityNotifier2D.visibility_notifier_2d_screen_exited.connect(
        _on_screen_exited
    )

func _on_screen_entered():
    set_process(true)
    visible = true

func _on_screen_exited():
    set_process(false)
    visible = false
```

## 2D 游戏最佳实践

### 精灵管理

保持精灵的纹理尺寸为2的幂次方，这样可以利用GPU的压缩功能。使用SpriteFrames或AnimatedSprite2D来管理动画，并为不同分辨率的设备准备多套资源以支持自适应缩放。

### 碰撞体优化

使用简化的碰撞体形状而非精确的多边形。CharacterBody2D主要用于玩家控制，RigidBody2D用于需要物理模拟的物体，StaticBody2D用于墙壁等静态障碍。合理设置碰撞层和遮罩可以减少不必要的碰撞检测计算。

### 性能监控

使用Godot内置的性能分析器监控游戏的帧率、内存使用和绘制调用次数。关注Draw Calls、Sprite Count、Physics Objects等关键指标，针对性地进行优化。

## 相关资源

### 官方文档

- 2D 游戏文档：https://docs.godotengine.org/en/stable/tutorials/2d/index.html
- TileMap 参考：https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html
- 2D 光照文档：https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html

### 社区资源

- Godot 2D 示例项目：https://github.com/godotengine/godot-demo-projects
- itch.io 2D 资源：https://itch.io/game-assets/tag-2d
