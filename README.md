# SCALE-SPACE-BLOB-DETECTION
The goal of the project is to implement a Laplacian blob detector

Algorithm outline
1. Generate a Laplacian of Gaussian filter.
2. Build a Laplacian scale space, starting with some initial scale and going for n 
iterations:
1. Filter image with scale-normalized Laplacian at current scale.
2. Save square of Laplacian response for current level of scale space.
3. Increase scale by a factor k.
3. Perform nonmaximum suppression in scale space.
4. Display resulting circles at their characteristic scales.
