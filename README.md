# wheat-grain-analysis

English | [中文](README.zh-CN.md)

[![CI](https://github.com/smiler488/wheat-grain-analysis/actions/workflows/test.yml/badge.svg)](https://github.com/smiler488/wheat-grain-analysis/actions/workflows/test.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) ![MATLAB R2019b+](https://img.shields.io/badge/MATLAB_R2019b%2B-informational)
A MATLAB script that measures length, width, area, perimeter and orientation of every wheat grain in a set of photographs, saves an annotated image per sample and writes the measurements to Excel and CSV.

I used it for a treatment trial in which grains from each plot were spread on a light background and photographed with a phone. I wanted per-grain data next to the plot means and a quick visual check of the segmentation, without setting up a dedicated seed-imaging station. Outputs from GrainScan for some of the same images are kept in `reference/grainscan/` for comparison.

## Requirements

MATLAB R2019b or newer with the Image Processing Toolbox.

## Usage

1. Put the images in `RAW/`, named `<treatment>-<replicate>.jpg`, for example `CK-1.jpg`, `T2-3.jpg`. JPG, PNG and TIFF are accepted.
2. Adjust the settings at the top of `wheat_grain_analysis.m` if needed.
3. Run `wheat_grain_analysis` in MATLAB.

| Setting | Default | Notes |
|---|---|---|
| `pixelsPerMm` | `[]` | scale; empty reports pixels. Put a ruler or a coin in the photo to get it |
| `opts.threshold` | `'global'` | Otsu; use `'adaptive'` for photos with uneven light |
| `opts.minArea` | 50 | objects below this many pixels are dropped |
| `opts.splitTouching` | `false` | watershed on the distance transform to separate touching grains |
| `opts.clearBorder` | `true` | ignore grains cut by the image edge |

The segmentation and measurement live in `analyze_grains.m`, which can also be called on its own:

```matlab
grains = analyze_grains(imread('RAW/CK-1.jpg'), struct('splitTouching', true));
```

## Output (`result/`)

- `<image>_result.jpg`: bounding box (red), major axis (red), minor axis (green), grain number and L/W.
- `result.xlsx`: one sheet per image with `Grain, Length, Width, AspectRatio, Area, Perimeter, Orientation_deg`.
- `grains_all.csv`: all grains of all images with `Image, Treatment, Replicate` columns, ready for R or Python.
- The command window shows mean and SD of length, width and area per treatment.

Length and width are the major and minor axes of the ellipse with the same second moments as the grain. This matches GrainScan's `majellipse` / `minellipse`.

## Tips

- Spread grains so that they do not touch. The watershed option helps with pairs but can cut long or creased grains in two.
- A matte, evenly lit background matters more than resolution. About 20 px across the grain width is enough for length and width.
- Shadows next to grains get counted as grain with the global threshold. Diffuse light from above, or a light box underneath, avoids that.

## Changes in this revision

- The major axis in the annotated images was mirrored about the horizontal axis (image y points down; the sign was wrong). The numbers in the tables were not affected.
- Images are now found automatically instead of looping over hard-coded `CK/T1/T2/T3 × 1–5` names.
- Optional pixel-to-mm scale, perimeter, aspect ratio, a combined CSV and a per-treatment summary.
- Optional watershed splitting and border clearing. The segmentation moved into `analyze_grains.m`.
- Figures are drawn off-screen, so batches no longer flash windows.
- GrainScan reference outputs moved to `reference/grainscan/`. Comments translated to English.

## Citation

```bibtex
@software{deng_wheat_grain_analysis,
  author = {Deng, Liangchao},
  title  = {wheat-grain-analysis: grain size and shape from photographs in MATLAB},
  year   = {2025},
  url    = {https://github.com/smiler488/wheat-grain-analysis}
}
```

GrainScan: Whan, A. P. et al. (2014). GrainScan: a low cost, fast method for grain size and colour measurements. *Plant Methods*, 10, 23.

## License

MIT, see [LICENSE](LICENSE). Liangchao Deng (邓良超).
