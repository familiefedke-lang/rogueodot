# 🎮 Grid-Based Inventory System - Godot Plugin

[![Godot 4.x](https://img.shields.io/badge/Godot-4.x-%23478cbf)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A foundational inventory framework for Godot  

Designed with an MVC-like architecture that separates presentation layer from data layer, offering high extensibility  

Simple integration with minimal intrusion into existing projects  

Supports independent data saving and loading  

## 🖼️ Sample Screenshots  

![Inventory System Example](GBIS_demos/assets/screenshots/Snipaste_2025-07-06_16-32-34.png)  
![Inventory System Example](GBIS_demos/assets/screenshots/Snipaste_2025-07-06_16-33-31.png)  
![Inventory System Example](GBIS_demos/assets/screenshots/Snipaste_2025-07-06_16-33-52.png)  

## 🚀 Quick Start  

### Usage  

1. Copy the `addons/grid_base_inventory_system` folder to your Godot project  
2. Configure `addons/grid_base_inventory_system/core/grid_base_inventory_system.gd` as a global script named GBIS  
3. Refer to the input configuration below for Input settings  
4. Select appropriate classes from `addons/grid_base_inventory_system/model/item/` to inherit, implement required methods, and define your item rules  
5. (Optional) Configure quick transfer relationships between inventories  
6. (Optional) Listen to signals to display item information  

**Input Configuration**  

Configure these four inputs in project settings (defaults shown):  
* inv_click: Left mouse click  
* inv_quick_move: Shift + Right mouse click  
* inv_use: Right mouse click  
* inv_split: Middle mouse click  

If input names differ from defaults, update these GBIS properties during initialization:  

```gdscript
GBIS.input_click = "your_input_name"
GBIS.input_quick_move = "your_input_name"
GBIS.input_use = "your_input_name"
GBIS.input_split = "your_input_name"
```

**Inventory Relationship Configuration**

```gdscript
# Add quick transfer relationship between inventories
GBIS.add_quick_move_relation("InventoryA", "InventoryB")
```

**Display Hovered Item Information**

```gdscript
GBIS.sig_item_focused.connect(your_display_method)
GBIS.sig_item_focus_lost.connect(your_clear_method)
```

**Add Items to Inventory**

```gdscript
var my_item = preload("res://path/to/your_item.tres")
GBIS.add_item("target_inventory_name", my_item)
```

## 🙏 Author
- [bilibili: Java已死游戏当立](https://space.bilibili.com/3546831153793300)

# 🎮 网格基础物品系统 - Godot插件

[![Godot 4.x](https://img.shields.io/badge/Godot-4.x-%23478cbf)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Godot基础背包框架

采用类MVC设计，展示层和数据层分离，具有较高的可扩展性

集成简单，对现有项目侵入低

可独立保存读取数据

## 🖼️ 示例截图
 
![架构示意图](GBIS_demos/assets/screenshots/GBIS架构.drawio.png)  

## 🚀 快速开始

### 使用方式

1. 将`addons/grid_base_inventory_system`文件夹复制到您的Godot项目中
2. 将`addons/grid_base_inventory_system/core/grid_base_inventory_system.gd`配置到全局，名称设置为GBIS
3. 参考下方输入配置，进行Input设置
4. 在`addons/grid_base_inventory_system/model/item/`中选择合适的类进行继承，实现必要方法并书写自己的物品规则
5. （可选）配置背包间的快速移动关系
6. （可选）监听信号显示物品信息

**输入配置**

项目输入中需要配置四个输入，默认为：
* inv_click：鼠标左键点击
* inv_quick_move：shift + 鼠标右键
* inv_use：鼠标右键
* inv_split：鼠标中键

如果输入的名字和默认不一致，请在启动时更新GBIS中的以下属性

```gdscript
GBIS.input_click = "你的输入名字"
GBIS.input_quick_move = "你的输入名字"
GBIS.input_use = "你的输入名字"
GBIS.input_split = "你的输入名字"
```
**背包关系配置**

```gdscript
# 添加背包间快速移动关系
GBIS.add_quick_move_relation("背包A", "背包B")
```

**监听显示鼠标下的物品信息**

```gdscript
GBIS.sig_item_focused.connect(显示物品信息的方法)
GBIS.sig_item_focus_lost.connect(清除物品信息的方法)
```

**添加物品到背包**

```gdscript
var my_item = preload("res://path/to/your_item.tres")
GBIS.add_item("目标背包名称", my_item)
```

## 🙏 作者（请关注）
- [B站: Java已死游戏当立](https://space.bilibili.com/3546831153793300)

## 📜 许可证

MIT License

Copyright (c) 2025 Cabbage0211

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
