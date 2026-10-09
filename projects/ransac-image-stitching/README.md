# RANSAC Image Stitching

Aligns overlapping photographs and stitches them into a panorama. Features are matched between images and RANSAC estimates the geometric transform while ignoring bad matches.

## Pipeline

1. **Keypoints:** SIFT detects distinctive points and computes a descriptor for each.
2. **Matching:** a FLANN k-nearest-neighbour matcher pairs descriptors between images.
3. **Filtering:** Lowe's ratio test keeps only matches clearly better than the runner-up.
4. **Robust estimation:** RANSAC repeatedly fits a transform to a random sample of matches and keeps the one most matches agree with.
5. **Warping:** the second image is warped into the first image's frame and the two are combined.

## Notebook contents

| Part | Images | Transform | Points per sample |
|---|---|---|---|
| 1 | Parliament building, left and right | Affine (`cv.getAffineTransform`) | 3 |
| 2 | Glendon Hall, left, middle and right | Homography, solved with SVD (direct linear transform) | 4 |

## Tech stack

Python, OpenCV, NumPy, PyTorch / Kornia, scikit-image, Matplotlib

## Run it

The source photos are not included in this repository. Place `parliament-left.jpg`, `parliament-right.jpg` and `Glendon-Hall-{left,middle,right}.jpg` next to the notebook, then:

```bash
pip install -r requirements.txt
jupyter notebook RANSAC_Imaging.ipynb
```

## Known limitations

This was a course project and the RANSAC loops are simplified:

- In Part 1 the inlier count is not reset between iterations, and inliers are measured on the 3 sampled points rather than on all matches.
- In Part 2 the homography is fitted from a single random sample. The `iters` argument is not used yet.

Planned improvements: score each candidate transform on every match, run the full iteration loop, refit on the final inlier set, and blend all three Glendon Hall images into one canvas.
