# Wheat Grain Image Analysis and Quantification System

This project provides a MATLAB-based toolkit for automatic analysis and quantification of wheat grain morphological features. Using image processing techniques, the system automatically identifies wheat grains, measures morphological features such as length, width, area, and orientation, and exports the results as visualizations and Excel spreadsheets.

## Project Structure

```
wheat-grain-analysis/
├── RAW/                  # Original image folder
│   └── *.jpg             # Raw wheat grain images
├── result/               # Processing results folder
│   ├── *_result.jpg      # Visualization result images
│   └── result.xlsx       # Quantification data in Excel format
├── Grainscan/            # Third-party software results (reference)
│   ├── *.csv             # Quantification data
│   ├── *.grainLbl.tif    # Labeled images
│   └── *.grainOvr.jpg    # Overlay display result images
└── wheat_grain_analysis.m # Main MATLAB script
```

## Features

- **Automatic Grain Detection**: Uses image processing techniques to automatically identify and segment wheat grains
- **Morphological Feature Quantification**: Measures length, width, area, and orientation of each grain
- **Visual Analysis**: Labels grain numbers, bounding boxes, and main features on the original image
- **Data Export**: Exports quantification results to Excel spreadsheets for subsequent statistical analysis
- **Batch Processing**: Supports batch processing of multiple sample groups

## Usage

1. Place original wheat grain images in the `RAW` folder
2. Run the `wheat_grain_analysis.m` script in MATLAB
3. Processing results will be saved in the `result` folder

## Image Naming Convention

This system uses the following naming convention for processing images:
- Treatment group identifier (e.g., CK, T1, T2, T3) + hyphen + repetition number (1-5)
- For example: `CK-1.jpg`, `T1-2.jpg`, `T2-3.jpg`, etc.

## Technical Details

The system uses the following image processing techniques:
1. Grayscale conversion and image inversion
2. Adaptive binarization
3. Noise removal and hole filling
4. Connected component labeling
5. Morphological feature extraction

## System Requirements

- MATLAB R2019b or higher
- Image Processing Toolbox

## Example Results

Processed images contain the following information:
- Grain bounding boxes (red)
- Grain numbers (blue)
- Major axis (red line) and minor axis (green line)
- Length (L), width (W), area (A), and orientation (O) for each grain

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Citation

If you use this tool in your research, please cite:

```
@software{wheat-grain-analysis,
  author = {Liangchao Deng},
  title = {wheat-grain-analysis: Automatic analysis and quantification of wheat grain morphological features},
  year = {2025},
  url = {https://github.com/smiler488/wheat-grain-analysis
}
}
```
