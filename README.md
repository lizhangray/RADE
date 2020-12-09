# FADE：Fast Region-Adaptive Defogging and Enhancement

MATLAB code for our ICPR 2020 paper "Z. Li, X. Zheng, B. Bhanu, S. Long, Q. Zhang, Z. Huang. Fast Region-Adaptive Defogging and Enhancement for Outdoor Images Containing Sky."  
## Run
````
example:
   HazyIn = imread('3.jpg'); 
   DehazeOut = RADE(HazyIn,5,0.8,0.03);
````
Authorized by Zhan Li (lizhan@jnu.edu.cn) created on Feb 23th, 2020 and released on Dec. 9th, 2020.

## Requirement
The code was tested on MATLAB (R2015a), 64-bit Win10.  

## Citing 

The code is free for academic/research purpose. Please kindly cite our work in your publications if it helps your research.  

```BibTeX
@article{
  title={Fast Region-Adaptive Defogging and Enhancement for Outdoor Images Containing Sky},
  author={Z. Li, X. Zheng, B. Bhanu, S. Long, Q. Zhang, Z. Huang},
  conference={The 25th International Conference on Pattern Recognition (ICPR). IEEE, Milan, Italy. 2021, 10th-15th Jan},
  year={2020}
}
```
## Example
**Comparison**
![1](./Example/1.PNG)

**other**
<figure class="half">
    <img src="./Example/2.jpg">
    <img src="./Example/3.jpg">
</figure>

