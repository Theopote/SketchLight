# SketchLight

一个 Iris 光影包骨架，目标是把 Minecraft 渲染成 SketchUp / 建筑草图风格：
清晰的黑色轮廓线、平面化的明暗色阶（cel shading）、低饱和度配色和淡淡的纸张颗粒感。

## 目录结构

```
SketchLight/
└─ shaders/
   ├─ shaders.properties      # 缓冲区配置 + 可调选项声明
   ├─ gbuffers_basic.vsh/.fsh # 兜底 pass（粒子/杂项实体等）
   ├─ gbuffers_terrain.vsh/.fsh # 方块几何体：写入 albedo + 视空间法线
   ├─ gbuffers_water.vsh/.fsh   # 半透明几何体（水/彩色玻璃/冰）
   ├─ composite.vsh/.fsh      # 核心：基于深度+法线的 Sobel 边缘检测，画轮廓线
   └─ final.vsh/.fsh          # 输出前处理，目前只有占位的纸张颗粒噪声
```

## 渲染管线现状

1. `gbuffers_terrain` / `gbuffers_water` / `gbuffers_basic` 渲染场景时，
   把颜色写到 `colortex0`，把视空间法线编码写到 `colortex1`。
2. `composite` 读取 `colortex0`、`colortex1`、`depthtex0`，做两种 Sobel 边缘检测
   （深度突变 = 物体轮廓，法线突变 = 同一物体上的棱角折线），叠加黑色描边。
3. `final` 目前只加了一层程序化噪点模拟纸张质感，是占位实现。

这是**能跑起来但风格未完成**的骨架 —— 轮廓线有了，但还没有 cel shading
（明暗量化成色阶）、没有手绘线条的抖动感、没有真正的纸张贴图。这些留给
下一步开发（见 `CURSOR_PROMPT.md`）。

## 如何测试

1. 安装 Fabric Loader + Fabric API。
2. 安装 [Iris](https://irisshaders.dev/)（Fabric 版本）。
3. 把 `SketchLight` 这个文件夹（或打包成 zip）放进
   `.minecraft/shaderpacks/`。
4. 游戏内 视频设置 → 光影包 → 选择 SketchLight。
5. 修改 `.fsh`/`.vsh` 后，光影选项界面里有一个"重新加载光影包"的按钮
   （或者退出重进世界），不需要重启游戏。

## 已知限制 / 下一步

- 轮廓线颜色是固定的纯黑，没有根据环境光/材质变化。
- 没有 cel shading，光照仍是原版的连续渐变。
- 纸张纹理是伪随机噪声，不是真实贴图。
- 没有处理 GUI/手持物品的轮廓线（可能需要单独的 `gbuffers_hand` pass）。
- 没有做"手绘线条抖动"效果。

详细的开发任务拆解见同目录下的 `CURSOR_PROMPT.md`。
