# wheat-grain-analysis

[English](README.md) | 中文

[![CI](https://github.com/smiler488/wheat-grain-analysis/actions/workflows/test.yml/badge.svg)](https://github.com/smiler488/wheat-grain-analysis/actions/workflows/test.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) ![MATLAB R2019b+](https://img.shields.io/badge/MATLAB_R2019b%2B-informational)
一个 MATLAB 脚本：从一批照片中测量每粒小麦的长、宽、面积、周长和朝向，每个样品保存一张标注图，测量结果导出到 Excel 和 CSV。

这是我在一个处理试验里用的。每个小区的籽粒铺在浅色背景上，用手机拍照。我需要逐粒的数据和小区均值放在一起看，也想快速检查分割效果，不想为此专门搭一套种子成像平台。`reference/grainscan/` 里保留了部分相同图片的 GrainScan 结果，方便对照。

## 运行环境

MATLAB R2019b 或更高版本，需要 Image Processing Toolbox。

## 使用

1. 把图片放进 `RAW/`，按 `<处理>-<重复>.jpg` 命名，例如 `CK-1.jpg`、`T2-3.jpg`。支持 JPG、PNG 和 TIFF。
2. 按需修改 `wheat_grain_analysis.m` 开头的参数。
3. 在 MATLAB 中运行 `wheat_grain_analysis`。

| 参数 | 默认值 | 说明 |
|---|---|---|
| `pixelsPerMm` | `[]` | 比例尺；留空则以像素为单位。可以在照片里放一把尺子或一枚硬币来换算 |
| `opts.threshold` | `'global'` | 全局 Otsu 阈值；光照不均匀的照片改用 `'adaptive'` |
| `opts.minArea` | 50 | 小于这个像素数的目标会被去掉 |
| `opts.splitTouching` | `false` | 基于距离变换的分水岭，用来分开粘连的籽粒 |
| `opts.clearBorder` | `true` | 去掉被图像边缘截断的籽粒 |

分割和测量的代码在 `analyze_grains.m` 里，也可以单独调用：

```matlab
grains = analyze_grains(imread('RAW/CK-1.jpg'), struct('splitTouching', true));
```

## 输出（`result/`）

- `<图片名>_result.jpg`：外接框（红）、长轴（红）、短轴（绿）、籽粒编号和长宽。
- `result.xlsx`：每张图一个工作表，包含 `Grain, Length, Width, AspectRatio, Area, Perimeter, Orientation_deg`。
- `grains_all.csv`：所有图片的全部籽粒，带 `Image, Treatment, Replicate` 列，可以直接用 R 或 Python 分析。
- 命令窗口会显示各处理的长、宽、面积的均值和标准差。

长和宽取的是与籽粒二阶矩相同的椭圆的长轴和短轴，和 GrainScan 的 `majellipse` / `minellipse` 定义一致。

## 拍摄建议

- 籽粒尽量铺开，不要相互接触。分水岭能分开两两粘连的籽粒，但有时会把细长或腹沟明显的籽粒切成两半。
- 背景哑光、光照均匀，比分辨率更重要。籽粒宽度方向有 20 个像素左右，就够测长和宽了。
- 用全局阈值时，籽粒旁边的阴影会被算进籽粒。顶部用漫射光，或者底下垫一个灯箱，可以避免这个问题。

## 本次修订

- 标注图里的长轴之前上下镜像了（图像 y 轴朝下，符号写反了）。表格里的数值不受影响。
- 自动读取文件夹里的所有图片，不再只循环写死的 `CK/T1/T2/T3 × 1–5` 文件名。
- 新增可选的像素–毫米换算、周长、长宽比、汇总 CSV 和按处理的统计。
- 新增可选的分水岭分割和去除边缘籽粒，分割代码独立到 `analyze_grains.m`。
- 绘图在后台完成，批量处理时不会再一个个弹窗。
- GrainScan 对照结果移到 `reference/grainscan/`，代码注释改为英文。

## 引用

```bibtex
@software{deng_wheat_grain_analysis,
  author = {Deng, Liangchao},
  title  = {wheat-grain-analysis: grain size and shape from photographs in MATLAB},
  year   = {2025},
  url    = {https://github.com/smiler488/wheat-grain-analysis}
}
```

GrainScan：Whan, A. P. et al. (2014). GrainScan: a low cost, fast method for grain size and colour measurements. *Plant Methods*, 10, 23.

## 许可证

MIT，见 [LICENSE](LICENSE)。邓良超（Liangchao Deng）。
