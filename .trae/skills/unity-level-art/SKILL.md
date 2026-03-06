---
name: "unity-level-art"
description: "提供Unity引擎肉鸽类型游戏的关卡美术设计支持，包括程序化美术生成、环境氛围营造、视觉风格统一等核心功能。当用户需要设计肉鸽游戏关卡美术时调用。"
---

# Unity肉鸽游戏关卡美术设计专家

## 技能概述

本技能专注于为使用Unity引擎开发肉鸽类型游戏的开发者提供关卡美术设计支持。关卡美术对于肉鸽游戏的氛围营造和玩家体验至关重要，本技能将帮助开发者实现视觉上引人入胜的游戏环境。

## 适用场景

- 设计Unity肉鸽游戏中的关卡美术风格
- 实现程序化美术生成和关卡布局
- 创建游戏环境和氛围效果
- 优化美术资源和性能
- 解决关卡美术设计中的技术难题

## 核心功能支持

### 1. 关卡设计系统

- 使用Unity的场景编辑器创建关卡
- 程序化关卡生成算法
- 关卡布局和流程设计
- 不同区域和主题的关卡设计
- 使用ScriptableObject管理关卡数据

### 2. 美术资源管理

- 3D模型和纹理资源管理
- 使用Unity的Asset Pipeline优化资源
- 资源压缩和LOD系统
- 精灵和2D资源管理
- 使用Addressables系统管理大型资源

### 3. 环境氛围

- 光照系统设计和实现
- 粒子效果和视觉特效
- 环境纹理和材质
- 天气和时间系统
- 环境互动元素

### 4. 程序化美术

- 使用Unity的Procedural Generation工具
- 程序化纹理和材质生成
- 程序化地形和环境
- 使用Houdini Engine等外部工具集成
- 基于规则的美术生成系统

### 5. 视觉风格统一

- 游戏整体视觉风格设计
- 色彩方案和调色板
- 材质和纹理风格统一
- 光照和阴影风格
- 特效和粒子效果风格

## 使用指南

当您需要以下支持时，可以调用本技能：

1. **美术设计咨询**：讨论游戏关卡的美术风格和设计思路
2. **技术实现**：获取关卡美术系统的代码实现示例
3. **性能优化**：解决美术资源的性能问题
4. **风格统一**：确保游戏整体视觉风格的一致性

## 示例用法

### 示例1：程序化关卡生成

```csharp
// Unity C# 示例：程序化关卡生成
using UnityEngine;
using System.Collections.Generic;

public class ProceduralLevelGenerator : MonoBehaviour
{
    [Header("Level Generation Settings")]
    public int width = 50;
    public int height = 50;
    public int roomCount = 15;
    public int minRoomSize = 4;
    public int maxRoomSize = 8;

    [Header("Visual Settings")]
    public GameObject floorPrefab;
    public GameObject wallPrefab;
    public GameObject corridorPrefab;
    public GameObject[] decorationPrefabs;

    [Header("Generation")]
    public bool generateOnStart = true;

    private int[,] levelGrid;
    private List<Room> rooms = new List<Room>();

    [System.Serializable]
    public class Room
    {
        public int x, y, width, height;
        public Vector2 center {
            get { return new Vector2(x + width / 2, y + height / 2); }
        }
    }

    private void Start()
    {
        if (generateOnStart)
        {
            GenerateLevel();
        }
    }

    public void GenerateLevel()
    {
        // 初始化网格
        levelGrid = new int[width, height];
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                levelGrid[x, y] = 0; // 0 = 墙壁
            }
        }

        // 生成房间
        GenerateRooms();

        // 连接房间
        ConnectRooms();

        // 生成视觉元素
        GenerateVisuals();

        // 添加装饰
        AddDecorations();
    }

    private void GenerateRooms()
    {
        rooms.Clear();

        for (int i = 0; i < roomCount; i++)
        {
            int roomWidth = Random.Range(minRoomSize, maxRoomSize + 1);
            int roomHeight = Random.Range(minRoomSize, maxRoomSize + 1);
            int roomX = Random.Range(1, width - roomWidth - 1);
            int roomY = Random.Range(1, height - roomHeight - 1);

            Room newRoom = new Room { x = roomX, y = roomY, width = roomWidth, height = roomHeight };

            // 检查房间是否重叠
            bool overlaps = false;
            foreach (Room room in rooms)
            {
                if (IsOverlapping(newRoom, room))
                {
                    overlaps = true;
                    break;
                }
            }

            if (!overlaps)
            {
                // 创建房间
                CreateRoom(newRoom);
                rooms.Add(newRoom);
            }
        }
    }

    private bool IsOverlapping(Room room1, Room room2)
    {
        return room1.x < room2.x + room2.width && room1.x + room1.width > room2.x &&
               room1.y < room2.y + room2.height && room1.y + room1.height > room2.y;
    }

    private void CreateRoom(Room room)
    {
        for (int x = room.x; x < room.x + room.width; x++)
        {
            for (int y = room.y; y < room.y + room.height; y++)
            {
                levelGrid[x, y] = 1; // 1 = 空地
            }
        }
    }

    private void ConnectRooms()
    {
        for (int i = 1; i < rooms.Count; i++)
        {
            Room prevRoom = rooms[i - 1];
            Room currRoom = rooms[i];

            // 水平通道
            for (int x = Mathf.Min((int)prevRoom.center.x, (int)currRoom.center.x); x <= Mathf.Max((int)prevRoom.center.x, (int)currRoom.center.x); x++)
            {
                levelGrid[x, (int)prevRoom.center.y] = 1;
            }

            // 垂直通道
            for (int y = Mathf.Min((int)prevRoom.center.y, (int)currRoom.center.y); y <= Mathf.Max((int)prevRoom.center.y, (int)currRoom.center.y); y++)
            {
                levelGrid[(int)currRoom.center.x, y] = 1;
            }
        }
    }

    private void GenerateVisuals()
    {
        // 清空现有物体
        foreach (Transform child in transform)
        {
            Destroy(child.gameObject);
        }

        // 生成地板和墙壁
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                Vector3 position = new Vector3(x, 0, y);

                if (levelGrid[x, y] == 1)
                {
                    // 生成地板
                    Instantiate(floorPrefab, position, Quaternion.identity, transform);

                    // 检查是否需要生成墙壁
                    CheckAndGenerateWalls(x, y);
                }
            }
        }
    }

    private void CheckAndGenerateWalls(int x, int y)
    {
        // 检查四个方向是否需要墙壁
        if (x > 0 && levelGrid[x - 1, y] == 0)
        {
            Vector3 position = new Vector3(x - 0.5f, 0, y);
            Instantiate(wallPrefab, position, Quaternion.identity, transform);
        }

        if (x < width - 1 && levelGrid[x + 1, y] == 0)
        {
            Vector3 position = new Vector3(x + 0.5f, 0, y);
            Instantiate(wallPrefab, position, Quaternion.identity, transform);
        }

        if (y > 0 && levelGrid[x, y - 1] == 0)
        {
            Vector3 position = new Vector3(x, 0, y - 0.5f);
            Instantiate(wallPrefab, position, Quaternion.identity, transform);
        }

        if (y < height - 1 && levelGrid[x, y + 1] == 0)
        {
            Vector3 position = new Vector3(x, 0, y + 0.5f);
            Instantiate(wallPrefab, position, Quaternion.identity, transform);
        }
    }

    private void AddDecorations()
    {
        foreach (Room room in rooms)
        {
            // 在房间中添加一些装饰
            int decorationCount = Random.Range(1, 5);
            for (int i = 0; i < decorationCount; i++)
            {
                int decorX = Random.Range(room.x + 1, room.x + room.width - 1);
                int decorY = Random.Range(room.y + 1, room.y + room.height - 1);
                
                if (levelGrid[decorX, decorY] == 1 && decorationPrefabs.Length > 0)
                {
                    Vector3 position = new Vector3(decorX, 0, decorY);
                    GameObject decorationPrefab = decorationPrefabs[Random.Range(0, decorationPrefabs.Length)];
                    Instantiate(decorationPrefab, position, Quaternion.identity, transform);
                }
            }
        }
    }
}
```

### 示例2：程序化材质生成

```csharp
// Unity C# 示例：程序化材质生成
using UnityEngine;

[CreateAssetMenu(fileName = "ProceduralMaterialGenerator", menuName = "LevelArt/ProceduralMaterialGenerator")]
public class ProceduralMaterialGenerator : ScriptableObject
{
    [Header("Base Settings")]
    public Shader baseShader;
    public Color baseColor = Color.gray;

    [Header("Noise Settings")]
    public float noiseScale = 1.0f;
    public float noiseIntensity = 0.2f;
    public int noiseOctaves = 3;
    public float noiseLacunarity = 2.0f;
    public float noiseGain = 0.5f;

    [Header("Color Variation")]
    public Color colorVariation1 = Color.white;
    public Color colorVariation2 = Color.black;
    public float colorBlend = 0.5f;

    public Material GenerateMaterial(string materialName)
    {
        Material material = new Material(baseShader);
        material.name = materialName;

        // 设置基础颜色
        material.color = baseColor;

        // 生成噪波纹理
        Texture2D noiseTexture = GenerateNoiseTexture(256, 256);
        material.SetTexture("_NoiseTexture", noiseTexture);
        material.SetFloat("_NoiseScale", noiseScale);
        material.SetFloat("_NoiseIntensity", noiseIntensity);

        // 设置颜色变化
        material.SetColor("_ColorVariation1", colorVariation1);
        material.SetColor("_ColorVariation2", colorVariation2);
        material.SetFloat("_ColorBlend", colorBlend);

        return material;
    }

    private Texture2D GenerateNoiseTexture(int width, int height)
    {
        Texture2D texture = new Texture2D(width, height);
        Vector2[] octaveOffsets = new Vector2[noiseOctaves];

        // 生成八度偏移
        for (int i = 0; i < noiseOctaves; i++)
        {
            float offsetX = Random.Range(-10000f, 10000f);
            float offsetY = Random.Range(-10000f, 10000f);
            octaveOffsets[i] = new Vector2(offsetX, offsetY);
        }

        // 生成噪声
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                float amplitude = 1.0f;
                float frequency = 1.0f;
                float noiseValue = 0.0f;

                for (int i = 0; i < noiseOctaves; i++)
                {
                    float sampleX = (x / (float)width) * frequency + octaveOffsets[i].x;
                    float sampleY = (y / (float)height) * frequency + octaveOffsets[i].y;

                    float perlinValue = Mathf.PerlinNoise(sampleX, sampleY) * 2 - 1;
                    noiseValue += perlinValue * amplitude;

                    amplitude *= noiseGain;
                    frequency *= noiseLacunarity;
                }

                // 归一化并设置像素
                float normalizedValue = (noiseValue + 1) / 2;
                Color pixelColor = new Color(normalizedValue, normalizedValue, normalizedValue);
                texture.SetPixel(x, y, pixelColor);
            }
        }

        texture.Apply();
        return texture;
    }
}

public class MaterialGeneratorExample : MonoBehaviour
{
    public ProceduralMaterialGenerator materialGenerator;
    public MeshRenderer targetRenderer;

    private void Start()
    {
        if (materialGenerator != null && targetRenderer != null)
        {
            Material generatedMaterial = materialGenerator.GenerateMaterial("ProceduralMaterial");
            targetRenderer.material = generatedMaterial;
        }
    }
}
```

## 最佳实践

1. **模块化设计**：将关卡美术系统分解为独立的模块，如地形、环境、装饰等
2. **资源管理**：合理组织和优化美术资源，使用Addressables系统管理大型资源
3. **性能优化**：使用LOD系统、纹理压缩和GPU instancing等技术
4. **视觉一致性**：确保游戏整体视觉风格的一致性和统一性
5. **程序化生成**：结合程序化生成和手动设计，平衡随机性和可控性
6. **光照设计**：充分利用Unity的光照系统，创建有氛围的环境

## 常见问题

### Q: 如何优化大量美术资源的性能？

A: 可以使用以下方法：
- 实现LOD系统，根据距离显示不同细节的模型
- 使用纹理压缩和图集
- 合理使用GPU instancing渲染重复物体
- 使用Unity的静态批处理和动态批处理
- 考虑使用SRP (Scriptable Render Pipeline)优化渲染

### Q: 如何创建统一的视觉风格？

A: 建议：
- 制定详细的美术风格指南
- 使用统一的色彩方案和调色板
- 为所有材质使用一致的 shader设置
- 保持光照和阴影风格的一致性
- 定期审查和调整美术资源，确保风格统一

### Q: 如何平衡程序化生成和手动设计？

A: 实现方法：
- 使用程序化生成创建基础布局和结构
- 手动设计关键区域和重要场景
- 为程序化生成设置合理的约束和规则
- 使用混合方法，让程序化元素遵循手动设计的指导
- 保留人工调整的空间，确保游戏体验质量

## 版本信息

- **版本**：1.0.0
- **创建日期**：2026-02-01
- **更新记录**：
  - 2026-02-01：初始版本，提供Unity肉鸽游戏关卡美术设计核心功能支持

## 调用示例

当用户提出以下需求时，系统将自动调用本技能：

- "如何在Unity中设计肉鸽游戏的关卡美术？"
- "Unity肉鸽游戏的程序化关卡生成怎么实现？"
- "如何优化Unity游戏的美术资源性能？"
- "如何创建统一的游戏视觉风格？"

本技能将为开发者提供专业、实用的关卡美术设计建议和代码示例，帮助他们创建视觉上引人入胜的肉鸽游戏环境。