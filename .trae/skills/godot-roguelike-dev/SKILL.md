---
name: godot-roguelike-dev
description: 专注Godot肉鸽游戏开发，提供关卡程序化生成、永久死亡机制、房间系统、道具系统、属性成长、敌人AI、回合制战斗、Boss战设计等核心架构。适用于开发类似Hades、Slay the Spire、Dead Cells等类型的肉鸽类游戏。
---

# Godot 肉鸽游戏开发

## 概述

本技能专注于肉鸽类（Roguelike/Roguelite）游戏的Godot引擎开发，涵盖程序化关卡生成、永久死亡机制、道具与装备系统、角色成长树、敌人AI、回合制与即时战斗系统、Boss战设计等核心内容。适用于开发地牢探索、卡牌构建、动作平台等多种类型的肉鸽游戏。

## 肉鸽游戏核心机制

### 永久死亡系统

永久死亡是肉鸽游戏的核心特征。每次角色死亡后，角色数据被重置，但部分永久进度（如解锁内容、能力解锁）会被保留。这种设计创造了挑战与成长并存的游戏体验，激励玩家不断尝试新的build和策略组合。

```gdscript
class_name PermadeathSystem
extends Node

# 永久进度存储
var permanent_progress: Dictionary = {
    "unlocks": [],
    "mastery_levels": {},
    "meta_currency": 0,
    "statistics": {}
}

# 会话数据（死亡时清除）
var session_data: Dictionary = {
    "current_run": {},
    "inventory": [],
    "stats": {}
}

func _ready():
    load_permanent_progress()

func save_permanent_progress():
    var save_file = SaveSystem.get_save_path("permanent_progress")
    var json = JSON.stringify(permanent_progress)
    FileAccess.save_string_to_file(save_file, json)

func load_permanent_progress():
    var save_file = SaveSystem.get_save_path("permanent_progress")
    if FileAccess.file_exists(save_file):
        var json = FileAccess.get_file_as_string(save_file)
        permanent_progress = JSON.parse_string(json)

func start_new_run():
    session_data.clear()
    session_data["current_run"] = {
        "floor": 1,
        "gold": 0,
        "kills": 0,
        "time_alive": 0.0
    }

func add_permanent_unlock(unlock_id: String):
    if not unlock_id in permanent_progress["unlocks"]:
        permanent_progress["unlocks"].append(unlock_id)
        save_permanent_progress()
        ShowUnlockPopup(unlock_id)

func on_player_died():
    # 保存本次运行统计
    save_run_statistics()
    
    # 处理永久进度
    permanent_progress["meta_currency"] += calculate_meta_currency()
    
    # 清除会话数据
    session_data.clear()
    
    # 保存永久进度
    save_permanent_progress()

func calculate_meta_currency() -> int:
    var base_currency = session_data["current_run"].get("gold", 0) / 10
    var bonus_currency = session_data["current_run"].get("kills", 0) * 2
    return int(base_currency + bonus_currency)

func has_unlock(unlock_id: String) -> bool:
    return unlock_id in permanent_progress["unlocks"]

func get_mastery_level(skill_id: String) -> int:
    return permanent_progress["mastery_levels"].get(skill_id, 0)
```

### 进程与回滚

肉鸽游戏通常使用进程系统来保存玩家进度，但要注意平衡永久进度与临时挑战之间的关系。设计时要考虑玩家的挫败感管理，通过有意义的失败奖励来缓解负面情绪。

## 程序化关卡生成

### 房间生成器

房间是肉鸽游戏关卡的基本单元。通过预定义的房间模板和随机组合，可以创造出丰富多样的关卡布局。房间设计需要考虑连接点、敌人配置、道具分布和挑战难度等因素。

```gdscript
class_name RoomGenerator
extends Node

@export var room_width: int = 10
@export var room_height: int = 8
@export var room_templates: Array[PackedScene] = []

var grid_size: Vector2i = Vector2i(10, 8)
var placed_rooms: Array[Dictionary] = []
var room_connections: Dictionary = {}

func generate_dungeon(num_rooms: int = 10) -> Array[Dictionary]:
    placed_rooms.clear()
    room_connections.clear()
    
    # 放置初始房间
    var start_room = PlaceStartRoom()
    placed_rooms.append(start_room)
    
    # 递归放置其他房间
    for i in range(1, num_rooms):
        var new_room = try_place_room()
        if new_room:
            placed_rooms.append(new_room)
    
    # 创建房间之间的连接
    connect_rooms()
    
    # 返回生成的关卡数据
    return placed_rooms

func PlaceStartRoom() -> Dictionary:
    var room = create_room_data()
    room["type"] = "start"
    room["position"] = Vector2i(0, 0)
    room["connections"] = []
    return room

func try_place_room() -> Dictionary:
    var max_attempts = 100
    var attempts = 0
    
    while attempts < max_attempts:
        var pos = Vector2i(
            randi_range(-20, 20),
            randi_range(-20, 20)
        )
        
        if can_place_room_at(pos):
            var room = create_room_data()
            room["position"] = pos
            room["connections"] = []
            
            # 确保与现有房间有连接
            connect_to_existing_room(room, pos)
            
            return room
        
        attempts += 1
    
    return {}

func can_place_room_at(pos: Vector2i) -> bool:
    for room in placed_rooms:
        var room_pos = room["position"]
        var distance = pos.distance_to(room_pos)
        if distance < grid_size.x * 2:
            return false
    return true

func connect_to_existing_room(new_room: Dictionary, pos: Vector2i):
    var nearest_room = find_nearest_room(pos)
    if nearest_room:
        var direction = (nearest_room["position"] - pos).sign()
        new_room["connections"].append({
            "to": nearest_room,
            "direction": direction,
            "door_position": calculate_door_position(direction)
        })
        nearest_room["connections"].append({
            "to": new_room,
            "direction": -direction,
            "door_position": calculate_door_position(-direction)
        })

func find_nearest_room(pos: Vector2i) -> Dictionary:
    var nearest = null
    var nearest_dist = INF
    
    for room in placed_rooms:
        var dist = pos.distance_to(room["position"])
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = room
    
    return nearest

func calculate_door_position(direction: Vector2i) -> Vector2i:
    match direction:
        Vector2i.UP:
            return Vector2i(room_width / 2, 0)
        Vector2i.DOWN:
            return Vector2i(room_width / 2, room_height - 1)
        Vector2i.LEFT:
            return Vector2i(0, room_height / 2)
        Vector2i.RIGHT:
            return Vector2i(room_width - 1, room_height / 2)
    return Vector2i(room_width / 2, room_height / 2)

func create_room_data() -> Dictionary:
    var template = room_templates.pick_random() if room_templates.size() > 0 else null
    
    return {
        "type": "normal",
        "position": Vector2i.ZERO,
        "connections": [],
        "enemies": [],
        "items": [],
        "traps": [],
        "template": template,
        "difficulty_modifier": 1.0
    }

func connect_rooms():
    # 确保所有房间都连通
    pass
```

### BSP 房间分割

二叉空间分割（BSP）是一种高效的关卡生成算法，特别适合生成地牢风格的游戏地图。该算法将地图递归分割为更小的区域，然后在每个区域中生成房间，通过走廊连接各个房间。

```gdscript
class_name BSPLevelGenerator
extends Node

@export var map_width: int = 80
@export var map_height: int = 50
@export var min_room_size: int = 6
@export var max_room_size: int = 15

var root_leaf: Leaf
var rooms: Array[Dictionary] = []
var corridors: Array[Dictionary] = []

class Leaf:
    var x: int
    var y: int
    var width: int
    var height: int
    var left_child: Leaf = null
    var right_child: Leaf = null
    var room_rect: Rect2i = Rect2i.ZERO

func _ready():
    generate_level()

func generate_level() -> Dictionary:
    rooms.clear()
    corridors.clear()
    
    # 创建根节点
    root_leaf = Leaf.new()
    root_leaf.x = 0
    root_leaf.y = 0
    root_leaf.width = map_width
    root_leaf.height = map_height
    
    # 递归分割空间
    split_space(root_leaf, 10)
    
    # 在每个叶子节点创建房间
    create_rooms(root_leaf)
    
    # 创建走廊连接房间
    create_corridors()
    
    return {
        "rooms": rooms,
        "corridors": corridors
    }

func split_space(leaf: Leaf, depth: int):
    if depth <= 0:
        return
    
    var split_horizontal = randf() > 0.5
    var max_split = if split_horizontal then leaf.height else leaf.width
    max_split -= min_room_size * 2
    
    if max_split <= min_room_size:
        return
    
    var split_pos = randi_range(min_room_size, max_split)
    
    if split_horizontal:
        leaf.left_child = create_leaf(leaf.x, leaf.y, leaf.width, split_pos)
        leaf.right_child = create_leaf(leaf.x, leaf.y + split_pos, leaf.width, leaf.height - split_pos)
    else:
        leaf.left_child = create_leaf(leaf.x, leaf.y, split_pos, leaf.height)
        leaf.right_child = create_leaf(leaf.x + split_pos, leaf.y, leaf.width - split_pos, leaf.height)
    
    split_space(leaf.left_child, depth - 1)
    split_space(leaf.right_child, depth - 1)

func create_leaf(x: int, y: int, width: int, height: int) -> Leaf:
    var leaf = Leaf.new()
    leaf.x = x
    leaf.y = y
    leaf.width = width
    leaf.height = height
    return leaf

func create_rooms(leaf: Leaf):
    if leaf.left_child or leaf.right_child:
        if leaf.left_child:
            create_rooms(leaf.left_child)
        if leaf.right_child:
            create_rooms(leaf.right_child)
        
        # 在子节点之间创建连接
        connect_child_leafs(leaf)
    else:
        # 尝试在当前空间创建房间
        var room_width = randi_range(min_room_size, min(leaf.width - 2, max_room_size))
        var room_height = randi_range(min_room_size, min(leaf.height - 2, max_room_size))
        var room_x = randi_range(leaf.x + 1, leaf.x + leaf.width - room_width - 1)
        var room_y = randi_range(leaf.y + 1, leaf.y + leaf.height - room_height - 1)
        
        leaf.room_rect = Rect2i(room_x, room_y, room_width, room_height)
        
        rooms.append({
            "rect": leaf.room_rect,
            "center": Vector2i(room_x + room_width / 2, room_y + room_height / 2)
        })

func connect_child_leafs(leaf: Leaf):
    if not leaf.left_child or not leaf.right_child:
        return
    
    var left_center = get_leaf_center(leaf.left_child)
    var right_center = get_leaf_center(leaf.right_child)
    
    var corridor = {
        "points": generate_corridor_points(left_center, right_center)
    }
    corridors.append(corridor)

func get_leaf_center(leaf: Leaf) -> Vector2i:
    if leaf.room_rect != Rect2i.ZERO:
        return Vector2i(
            leaf.room_rect.position.x + leaf.room_rect.size.x / 2,
            leaf.room_rect.position.y + leaf.room_rect.size.y / 2
        )
    else:
        return Vector2i(
            leaf.x + leaf.width / 2,
            leaf.y + leaf.height / 2
        )

func generate_corridor_points(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
    var points: Array[Vector2i] = []
    var current = from
    
    # L型走廊
    if randf() > 0.5:
        while current.x != to.x:
            points.append(current)
            current.x += 1 if to.x > current.x else -1
        while current.y != to.y:
            points.append(current)
            current.y += 1 if to.y > current.y else -1
    else:
        while current.y != to.y:
            points.append(current)
            current.y += 1 if to.y > current.y else -1
        while current.x != to.x:
            points.append(current)
            current.x += 1 if to.x > current.x else -1
    
    points.append(to)
    return points
```

### 迷宫生成算法

```gdscript
class_name MazeGenerator
extends Node

@export var width: int = 21
@export var height: int = 21

var grid: Array[Array] = []
const WALL = 0
const PATH = 1

func generate_maze() -> Array[Array]:
    # 初始化网格
    grid.clear()
    for y in range(height):
        var row: Array[Array] = []
        for x in range(width):
            row.append(WALL)
        grid.append(row)
    
    # 深度优先搜索生成迷宫
    var start_x = 1
    var start_y = 1
    
    carve_maze(start_x, start_y)
    
    return grid

func carve_maze(x: int, y: int):
    grid[y][x] = PATH
    
    var directions = [Vector2i(0, -2), Vector2i(2, 0), Vector2i(0, 2), Vector2i(-2, 0)]
    directions.shuffle()
    
    for dir in directions:
        var new_x = x + dir.x
        var new_y = y + dir.y
        
        if is_in_bounds(new_x, new_y) and grid[new_y][new_x] == WALL:
            # 在墙中间打通
            grid[y + dir.y / 2][x + dir.x / 2] = PATH
            carve_maze(new_x, new_y)

func is_in_bounds(x: int, y: int) -> bool:
    return x > 0 and x < width - 1 and y > 0 and y < height - 1
```

## 道具系统

### 道具数据

```gdscript
class_name ItemData
extends Resource

enum ItemType {
    WEAPON,
    ARMOR,
    ACCESSORY,
    CONSUMABLE,
    MATERIAL,
    KEY
}

@export var item_id: String
@export var item_name: String
@export var item_description: String
@export var item_type: ItemType
@export var icon: Texture2D
@export var max_stack: int = 1
@export var rarity: int = 1  # 1-5 星

@export_group("Combat")
@export var damage: int = 0
@export var defense: int = 0
@export var speed_modifier: float = 1.0
@export var crit_chance: float = 0.0
@export var crit_damage: float = 0.0

@export_group("Stats")
@export var health_bonus: int = 0
@export var mana_bonus: int = 0
@export var strength_bonus: int = 0
@export var agility_bonus: int = 0
@export var intelligence_bonus: int = 0

@export_group("Special")
@export var special_effects: Array[String] = []
@export var set_id: String = ""

func get_full_name() -> String:
    var prefix = get_rarity_prefix()
    return prefix + item_name

func get_rarity_prefix() -> String:
    match rarity:
        1:
            return "普通 "
        2:
            return "优秀 "
        3:
            return "精良 "
        4:
            return "史诗 "
        5:
            return "传说 "
    return ""

func can_equip(character_class: String) -> bool:
    return true  # 可根据类型添加限制

func get_stat_bonuses() -> Dictionary:
    return {
        "health": health_bonus,
        "mana": mana_bonus,
        "strength": strength_bonus,
        "agility": agility_bonus,
        "intelligence": intelligence_bonus,
        "damage": damage,
        "defense": defense,
        "speed": speed_modifier,
        "crit_chance": crit_chance,
        "crit_damage": crit_damage
    }
```

### 装备系统

```gdscript
class_name EquipmentSystem
extends Node

@export var max_equipment_slots: int = 8

var equipped_items: Dictionary = {
    "main_hand": null,
    "off_hand": null,
    "head": null,
    "body": null,
    "legs": null,
    "feet": null,
    "accessory_1": null,
    "accessory_2": null
}

var item_bonuses: Dictionary = {}
var active_effects: Array[Dictionary] = []

func _ready():
    recalculate_bonuses()

func equip_item(slot: String, item: ItemData) -> ItemData:
    var old_item = equipped_items.get(slot)
    
    if old_item:
        unequip_item(slot)
    
    if item:
        equipped_items[slot] = item
        apply_item_effects(item, true)
        recalculate_bonuses()
    
    return old_item

func unequip_item(slot: String) -> ItemData:
    var item = equipped_items.get(slot)
    if item:
        apply_item_effects(item, false)
        equipped_items[slot] = null
        recalculate_bonuses()
    return item

func apply_item_effects(item: ItemData, is_equipping: bool):
    var multiplier = 1 if is_equipping else -1
    
    for stat in item.get_stat_bonuses():
        var value = item.get_stat_bonuses()[stat]
        if not stat in item_bonuses:
            item_bonuses[stat] = 0
        item_bonuses[stat] += value * multiplier

func recalculate_bonuses():
    item_bonuses.clear()
    active_effects.clear()
    
    for slot in equipped_items:
        var item = equipped_items[slot]
        if item:
            apply_item_effects(item, true)

func get_total_bonus(stat: String) -> float:
    return item_bonuses.get(stat, 0)

func get_all_bonuses() -> Dictionary:
    return item_bonuses.duplicate()

func check_set_bonuses() -> Dictionary:
    var set_bonuses: Dictionary = {}
    var set_items: Dictionary = {}
    
    for slot in equipped_items:
        var item = equipped_items[slot]
        if item and item.set_id != "":
            if not item.set_id in set_items:
                set_items[item.set_id] = []
            set_items[item.set_id].append(item)
    
    for set_id in set_items:
        var items = set_items[set_id]
        var count = items.size()
        
        # 检查套装效果
        var set_data = get_set_data(set_id)
        if set_data and count >= 2:
            if not set_id in set_bonuses:
                set_bonuses[set_id] = {
                    "name": set_data["name"],
                    "equipped": count,
                    "bonuses": []
                }
            set_bonuses[set_id]["equipped"] = count
    
    return set_bonuses

func get_set_data(set_id: String) -> Dictionary:
    # 从配置数据获取套装信息
    return {}
```

### 消耗品系统

```gdscript
class_name ConsumableSystem
extends Node

@export var potion_heal_percent: float = 0.25
@export var potion_cooldown: float = 5.0

var last_use_time: Dictionary = {}

func use_consumable(item: ItemData, target: Node) -> bool:
    var current_time = Time.get_ticks_msec()
    var cooldown_key = item.item_id + "_" + target.name
    
    if current_time - last_use_time.get(cooldown_key, 0) < potion_cooldown * 1000:
        return false
    
    apply_consumable_effect(item, target)
    last_use_time[cooldown_key] = current_time
    return true

func apply_consumable_effect(item: ItemData, target: Node):
    var bonuses = item.get_stat_bonuses()
    
    if bonuses.has("health"):
        var heal_amount = bonuses["health"]
        if bonuses["health"] < 1:
            heal_amount = target.max_health * bonuses["health"]
        target.heal(heal_amount)
    
    if bonuses.has("mana"):
        var mana_amount = bonuses["mana"]
        if bonuses["mana"] < 1:
            mana_amount = target.max_mana * bonuses["mana"]
        target.restore_mana(mana_amount)
    
    # 播放使用效果
    show_consumable_effect(target, item)

func show_consumable_effect(target: Node, item: ItemData):
    var effect = load("res://prefabs/consumable_effect.tscn").instantiate()
    effect.texture = item.icon
    target.add_child(effect)
    
    var tween = create_tween()
    tween.tween_property(effect, "position", Vector2(0, -50), 1.0)
    tween.tween_callback(effect.queue_free)
```

## 角色属性与成长

### 属性系统

```gdscript
class_name CharacterStats
extends Node

@export var base_health: float = 100.0
@export var base_mana: float = 50.0
@export var base_damage: float = 10.0
@export var base_defense: float = 5.0
@export var base_speed: float = 100.0

var current_health: float
var current_mana: float

var stat_bonuses: Dictionary = {}

# 派生属性计算
var health_multiplier: float = 1.0
var mana_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var defense_multiplier: float = 1.0
var speed_multiplier: float = 1.0

func _ready():
    current_health = max_health
    current_mana = max_mana

func get_max_health() -> float:
    var base = base_health
    var bonus = get_stat_bonus("health")
    return (base + bonus) * health_multiplier

func get_max_mana() -> float:
    var base = base_mana
    var bonus = get_stat_bonus("mana")
    return (base + bonus) * mana_multiplier

func get_damage() -> float:
    var base = base_damage
    var bonus = get_stat_bonus("damage")
    return (base + bonus) * damage_multiplier

func get_defense() -> float:
    var base = base_defense
    var bonus = get_stat_bonus("defense")
    return (base + bonus) * defense_multiplier

func get_speed() -> float:
    var base = base_speed
    var bonus = get_stat_bonus("speed")
    return (base + bonus) * speed_multiplier

func get_stat_bonus(stat_name: String) -> float:
    return stat_bonuses.get(stat_name, 0.0)

func add_stat_bonus(stat_name: String, value: float):
    if not stat_name in stat_bonuses:
        stat_bonuses[stat_name] = 0.0
    stat_bonuses[stat_name] += value

func remove_stat_bonus(stat_name: String, value: float):
    if stat_name in stat_bonuses:
        stat_bonuses[stat_name] -= value
        if stat_bonuses[stat_name] <= 0:
            stat_bonuses.erase(stat_name)

func take_damage(amount: float, damage_type: String = "physical"):
    var damage = amount
    
    # 伤害减免
    if damage_type == "physical":
        damage -= get_defense()
    
    damage = max(damage, 1)  # 至少造成1点伤害
    
    current_health -= damage
    
    if current_health <= 0:
        current_health = 0
        on_death()
    
    return damage

func heal(amount: float):
    current_health = min(current_health + amount, max_health)

func restore_mana(amount: float):
    current_mana = min(current_mana + amount, max_mana)

func on_death():
    pass  # 子类实现死亡逻辑
```

### 天赋系统

```gdscript
class_name TalentSystem
extends Node

@export var talent_tree_layout: Dictionary = {}

var unlocked_talents: Array[String] = []
var talent_points: int = 0
var talent_cap: int = 20

var talent_data: Dictionary = {}

func _ready():
    load_talent_data()
    load_progress()

func load_talent_data():
    talent_data = {
        "strength_1": {
            "name": "力量入门",
            "description": "力量+5",
            "prerequisite": null,
            "max_rank": 3,
            "effect": {"strength": 5},
            "position": Vector2i(0, 0)
        },
        "strength_2": {
            "name": "力量精通",
            "description": "力量+10",
            "prerequisite": "strength_1",
            "max_rank": 3,
            "effect": {"strength": 10},
            "position": Vector2i(0, 1)
        },
        # 更多天赋...
    }

func unlock_talent(talent_id: String, rank: int = 1) -> bool:
    if not can_unlock(talent_id):
        return false
    
    var talent = talent_data.get(talent_id)
    if talent:
        for i in range(rank):
            if talent_points > 0:
                unlocked_talents.append(talent_id + "_" + str(i + 1))
                talent_points -= 1
    
    save_progress()
    return true

func can_unlock(talent_id: String) -> bool:
    var talent = talent_data.get(talent_id)
    if not talent:
        return false
    
    # 检查是否有前置天赋
    if talent["prerequisite"]:
        if not has_talent(talent["prerequisite"]):
            return false
    
    # 检查是否已满级
    var current_rank = get_talent_rank(talent_id)
    if current_rank >= talent["max_rank"]:
        return false
    
    # 检查是否有足够点数
    if talent_points <= 0:
        return false
    
    return true

func has_talent(talent_id: String) -> bool:
    for unlocked in unlocked_talents:
        if unlocked.begins_with(talent_id):
            return true
    return false

func get_talent_rank(talent_id: String) -> int:
    var rank = 0
    for unlocked in unlocked_talents:
        if unlocked.begins_with(talent_id):
            rank += 1
    return rank

func get_talent_effects() -> Dictionary:
    var effects: Dictionary = {}
    
    for unlocked in unlocked_talents:
        var parts = unlocked.split("_")
        if parts.size() >= 2:
            var talent_id = parts[0] + "_" + parts[1]
            var talent = talent_data.get(talent_id)
            if talent and talent.has("effect"):
                for stat in talent["effect"]:
                    var value = talent["effect"][stat]
                    if not stat in effects:
                        effects[stat] = 0.0
                    effects[stat] += value
    
    return effects

func reset_talents():
    unlocked_talents.clear()
    talent_points = talent_cap
    save_progress()

func save_progress():
    var save_data = {
        "unlocked_talents": unlocked_talents,
        "talent_points": talent_points
    }
    SaveSystem.save_json("talent_progress", save_data)

func load_progress():
    var data = SaveSystem.load_json("talent_progress")
    if data:
        unlocked_talents = data.get("unlocked_talents", [])
        talent_points = data.get("talent_points", talent_cap)
```

## 敌人AI系统

### 状态机AI

```gdscript
class_name EnemyAI
extends Node

enum State {
    IDLE,
    PATROL,
    CHASE,
    ATTACK,
    FLEE,
    DEAD
}

@export var aggro_range: float = 200.0
@export var attack_range: float = 50.0
@export var patrol_range: float = 100.0
@export var flee_threshold: float = 0.3

var current_state: State = State.IDLE
var target: Node2D = null
var patrol_point: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

@onready var enemy: CharacterBody2D = get_parent()

func _physics_process(delta):
    update_state(delta)
    execute_state(delta)

func update_state(delta):
    state_timer -= delta
    
    if state_timer > 0:
        return
    
    # 状态转换逻辑
    var dist_to_target = INF
    if target:
        dist_to_target = enemy.global_position.distance_to(target.global_position)
    
    match current_state:
        State.IDLE:
            if target and dist_to_target < aggro_range:
                change_state(State.CHASE)
            elif state_timer <= 0:
                change_state(State.PATROL)
        
        State.PATROL:
            if target and dist_to_target < aggro_range:
                change_state(State.CHASE)
            elif enemy.global_position.distance_to(patrol_point) < 10:
                change_state(State.IDLE)
        
        State.CHASE:
            if not target:
                change_state(State.PATROL)
            elif dist_to_target > aggro_range * 1.5:
                change_state(State.PATROL)
            elif dist_to_target < attack_range:
                change_state(State.ATTACK)
            elif enemy.health / enemy.max_health < flee_threshold:
                change_state(State.FLEE)
        
        State.ATTACK:
            if dist_to_target > attack_range * 1.5:
                change_state(State.CHASE)
        
        State.FLEE:
            if enemy.health / enemy.max_health > flee_threshold * 1.5:
                change_state(State.CHASE)

func execute_state(delta):
    match current_state:
        State.IDLE:
            pass
        
        State.PATROL:
            move_to(patrol_point, delta * 0.5)
            if enemy.global_position.distance_to(patrol_point) > 10:
                patrol_point = enemy.global_position + Vector2(
                    randf_range(-patrol_range, patrol_range),
                    randf_range(-patrol_range, patrol_range)
                )
        
        State.CHASE:
            if target:
                move_to(target.global_position, delta)
        
        State.ATTACK:
            if target:
                enemy.look_at(target.global_position)
                perform_attack()
        
        State.FLEE:
            var flee_dir = (enemy.global_position - target.global_position).normalized()
            enemy.velocity = flee_dir * enemy.speed * 1.5

func change_state(new_state: State):
    current_state = new_state
    state_timer = get_state_duration(new_state)
    
    # 进入状态时的初始化
    match new_state:
        State.PATROL:
            patrol_point = enemy.global_position + Vector2(
                randf_range(-patrol_range, patrol_range),
                randf_range(-patrol_range, patrol_range)
            )

func get_state_duration(state: State) -> float:
    match state:
        State.IDLE:
            return randf_range(1.0, 3.0)
        State.PATROL:
            return randf_range(2.0, 5.0)
    return 0.0

func move_to(target_pos: Vector2, speed_modifier: float = 1.0):
    var direction = (target_pos - enemy.global_position).normalized()
    enemy.velocity = direction * enemy.speed * speed_modifier
    enemy.move_and_slide()

func perform_attack():
    enemy.attack()
```

### 敌人生成器

```gdscript
class_name EnemySpawner
extends Node

@export var enemy_database: Dictionary = {}
@export var spawn_points: Array[Vector2] = []

var active_enemies: Array[Node] = []
var spawn_queue: Array[Dictionary] = []

func spawn_enemy(enemy_type: String, position: Vector2) -> Node:
    var enemy_data = enemy_database.get(enemy_type)
    if not enemy_data:
        return null
    
    var enemy = enemy_data["scene"].instantiate()
    enemy.global_position = position
    
    # 应用难度修正
    var difficulty = GameState.get_current_difficulty()
    apply_difficulty_scaling(enemy, difficulty)
    
    add_child(enemy)
    active_enemies.append(enemy)
    
    return enemy

func apply_difficulty_scaling(enemy: Node, difficulty: float):
    enemy.health *= difficulty
    enemy.damage *= difficulty
    enemy.speed *= difficulty * 0.5 + 0.75  # 限制速度加成

func spawn_wave(wave_config: Dictionary):
    var enemies = wave_config["enemies"]
    
    for enemy_type in enemies:
        var count = enemies[enemy_type]
        for i in range(count):
            var spawn_pos = get_random_spawn_point()
            spawn_enemy(enemy_type, spawn_pos)

func get_random_spawn_point() -> Vector2:
    if spawn_points.size() > 0:
        return spawn_points.pick_random()
    
    # 在玩家周围随机生成
    var player = GameState.get_player()
    if player:
        return player.global_position + Vector2(
            randf_range(200, 400),
            randf_range(200, 400)
        )
    
    return Vector2.ZERO

func clear_dead_enemies():
    for enemy in active_enemies:
        if not is_instance_valid(enemy) or enemy.is_dead():
            active_enemies.erase(enemy)
```

## Boss战设计

### Boss行为模式

```gdscript
class_name BossAI
extends EnemyAI

enum Phase {
    PHASE_1,
    PHASE_2,
    PHASE_3
}

@export var phase_transition_health: Array[float] = [0.66, 0.33]

var current_phase: Phase = Phase.PHASE_1
var attack_patterns: Dictionary = {}
var special_attack_cooldown: float = 0.0

func _ready():
    super._ready()
    load_attack_patterns()

func load_attack_patterns():
    attack_patterns = {
        Phase.PHASE_1: ["basic_attack", "dash_attack"],
        Phase.PHASE_2: ["basic_attack", "dash_attack", "area_attack"],
        Phase.PHASE_3: ["basic_attack", "dash_attarea_attack", "special_attack"]
    }

func take_damage(amount: float) -> float:
    var damage_taken = super.take_damage(amount)
    
    # 检测阶段转换
    var health_percent = enemy.health / enemy.max_health
    if health_percent <= phase_transition_health[0] and current_phase == Phase.PHASE_1:
        enter_phase(Phase.PHASE_2)
    elif health_percent <= phase_transition_health[1] and current_phase == Phase.PHASE_2:
        enter_phase(Phase.PHASE_3)
    
    return damage_taken

func enter_phase(new_phase: Phase):
    current_phase = new_phase
    
    # 阶段转换效果
    enemy.play_animation("phase_transition")
    show_phase_announcement(new_phase)
    
    # 增强敌人属性
    enemy.damage *= 1.5
    enemy.speed *= 1.2
    
    # 清空攻击冷却
    special_attack_cooldown = 0.0

func show_phase_announcement(phase: Phase):
    var phase_name = ""
    match phase:
        Phase.PHASE_1:
            phase_name = "第一阶段"
        Phase.PHASE_2:
            phase_name = "第二阶段"
        Phase.PHASE_3:
            phase_name = "最终阶段"
    
    UI.show_announcement(phase_name, 3.0)

func execute_state(delta):
    match current_state:
        State.ATTACK:
            var patterns = attack_patterns.get(current_phase, [])
            if patterns.size() > 0:
                var attack = patterns.pick_random()
                perform_attack_pattern(attack)
```

### Boss技能系统

```gdscript
class_name BossSkillSystem
extends Node

@export var skill_database: Dictionary = {}

var available_skills: Array[Dictionary] = []
var current_skill: Dictionary = null

func _ready():
    load_skills()

func load_skills():
    skill_database = {
        "ground_slam": {
            "name": "重击",
            "damage": 30,
            "radius": 100,
            "delay": 1.0,
            "animation": "ground_slam"
        },
        "laser_beam": {
            "name": "激光",
            "damage": 20,
            "length": 300,
            "duration": 2.0,
            "animation": "laser_charge"
        },
        "summon_minions": {
            "name": "召唤",
            "count": 4,
            "enemy_type": "minion",
            "animation": "summon"
        }
    }

func use_skill(skill_name: String, target_pos: Vector2) -> bool:
    var skill = skill_database.get(skill_name)
    if not skill:
        return false
    
    # 创建技能效果
    var effect = create_skill_effect(skill, target_pos)
    
    # 应用伤害
    apply_skill_damage(skill, target_pos)
    
    return true

func create_skill_effect(skill: Dictionary, target_pos: Vector2) -> Node:
    var effect = load("res://prefabs/boss_skills/" + skill["animation"] + ".tscn").instantiate()
    effect.global_position = target_pos
    
    if skill.has("radius"):
        effect.radius = skill["radius"]
    if skill.has("length"):
        effect.length = skill["length"]
    if skill.has("duration"):
        effect.duration = skill["duration"]
    
    get_parent().add_child(effect)
    return effect

func apply_skill_damage(skill: Dictionary, target_pos: Vector2):
    var affected_area = Rect2(
        target_pos - Vector2(skill.get("radius", 50), skill.get("radius", 50)),
        Vector2(skill.get("radius", 100), skill.get("radius", 100))
    )
    
    var enemies = get_tree().get_nodes_in_group("player")
    for player in enemies:
        if affected_area.has_point(player.global_position):
            player.take_damage(skill["damage"])
```

## 回合制战斗系统

```gdscript
class_name TurnBasedCombatSystem
extends Node

enum TurnPhase {
    PLAYER_TURN,
    ENEMY_TURN,
    RESOLUTION
}

@export var max_actions_per_turn: int = 2

var current_phase: TurnPhase = TurnPhase.PLAYER_TURN
var action_points: int = 0
var current_actor: Node = null

var combat_participants: Array[Node] = []
var action_queue: Array[Dictionary] = []

signal turn_started(actor)
signal turn_ended(actor)
signal combat_phase_changed(phase)

func start_combat(participants: Array[Node]):
    combat_participants = participants
    action_points = max_actions_per_turn
    current_phase = TurnPhase.PLAYER_TURN
    
    for participant in combat_participants:
        participant.turn_start()
    
    begin_turn()

func begin_turn():
    if current_phase == TurnPhase.PLAYER_TURN:
        action_points = max_actions_per_turn
        emit_signal("turn_started", get_current_actor())

func get_current_actor() -> Node:
    if current_phase == TurnPhase.PLAYER_TURN:
        return GameState.get_player()
    elif current_phase == TurnPhase.ENEMY_TURN:
        return combat_participants.filter(func(p): return p.is_in_group("enemies")).pick_random()
    return null

func queue_action(actor: Node, action: Dictionary):
    action_queue.append({
        "actor": actor,
        "action": action,
        "priority": action.get("priority", 0)
    })

func execute_action(action_data: Dictionary):
    var actor = action_data["actor"]
    var action = action_data["action"]
    
    match action["type"]:
        "attack":
            perform_attack(actor, action["target"], action["damage"])
        "defend":
            perform_defend(actor)
        "item":
            perform_use_item(actor, action["item"])
        "skill":
            perform_skill(actor, action["skill"])

func perform_attack(attacker: Node, target: Node, base_damage: float):
    var damage = calculate_damage(attacker, target, base_damage)
    target.take_damage(damage)
    
    show_damage_number(target, damage)
    
    action_points -= 1

func calculate_damage(attacker: Node, target: Node, base_damage: float) -> float:
    var damage = base_damage
    
    # 伤害加成
    damage += attacker.get_damage() * 0.5
    
    # 防御减免
    damage -= target.get_defense() * 0.3
    
    # 暴击判定
    if randf() < attacker.get_crit_chance():
        damage *= attacker.get_crit_damage()
        show_crit_indicator(target)
    
    return max(damage, 1.0)

func end_turn():
    emit_signal("turn_ended", current_actor)
    
    # 切换回合
    if current_phase == TurnPhase.PLAYER_TURN:
        current_phase = TurnPhase.ENEMY_TURN
    else:
        current_phase = TurnPhase.PLAYER_TURN
    
    combat_participants_changed.emit()
    begin_turn()
```

## 进度保存系统

```gdscript
class_name SaveSystem
extends Node

static func get_save_path(save_name: String) -> String:
    var save_dir = "user://saves/"
    DirAccess.make_dir_recursive_absolute(save_dir)
    return save_dir + save_name + ".json"

static func save_json(save_name: String, data: Dictionary):
    var path = get_save_path(save_name)
    var json = JSON.stringify(data, "\t")
    FileAccess.save_string_to_file(path, json)

static func load_json(save_name: String) -> Dictionary:
    var path = get_save_path(save_name)
    if FileAccess.file_exists(path):
        var json = FileAccess.get_file_as_string(path)
        return JSON.parse_string(json)
    return {}

static func delete_save(save_name: String):
    var path = get_save_path(save_name)
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(path)

static func get_all_saves() -> Array[String]:
    var saves: Array[String] = []
    var dir = DirAccess.open("user://saves/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".json"):
                saves.append(file_name.replace(".json", ""))
            file_name = dir.get_next()
    return saves

static func save_full_run(save_name: String, game_state: Dictionary):
    var data = {
        "timestamp": Time.get_unix_time_from_system(),
        "game_version": "1.0.0",
        "player_data": serialize_player(game_state.player),
        "room_progress": game_state.room_progress,
        "inventory": serialize_inventory(game_state.inventory),
        "statistics": game_state.statistics
    }
    save_json(save_name, data)

func serialize_player(player: Node) -> Dictionary:
    return {
        "health": player.current_health,
        "mana": player.current_mana,
        "level": player.level,
        "experience": player.experience,
        "equipment": serialize_equipment(player.equipment),
        "talents": player.talent_system.unlocked_talents
    }
```

## 肉鸽游戏最佳实践

### 难度曲线设计

肉鸽游戏的难度曲线需要在挑战性与成就感之间取得平衡。早期楼层应该相对简单，让玩家能够熟悉游戏机制和建立初始build。随着楼层的深入，敌人属性逐渐增强，房间配置变得更加复杂。Boss战需要设计独特的阶段转换和攻击模式，为玩家提供难忘的战斗体验。

### 构建多样性

为了保持游戏的重玩价值，需要设计多种可行的build路径。确保不同类型的武器、装备和技能能够形成有效的组合。避免设计出过于强大的必选物品，同时确保没有完全无用的选项。加入一些有趣的combo效果，鼓励玩家尝试不同的组合方式。

### 进度反馈

设计清晰的进度反馈系统，让玩家感受到每一次尝试都在积累有价值的东西。显示本次运行的统计信息、解锁的新内容、以及下次可用的永久加成。小型成就可以作为短期目标，激励玩家不断挑战更高难度。

## 相关资源

### 肉鸽游戏设计参考

- 经典Roguelike：《Rogue》、《NetHack》、《ADOM》
- 现代Roguelike：《Hades》、《Slay the Spire》、《Dead Cells》、《Enter the Gungeon》
- 设计理念：柏林诠释（Berlin Interpretation）的Roguelike核心要素

### Godot 相关资源

- Godot 程序化生成示例：https://github.com/godotengine/godot-demo-projects
- 2D 游戏开发文档：https://docs.godotengine.org/en/stable/tutorials/2d/index.html
