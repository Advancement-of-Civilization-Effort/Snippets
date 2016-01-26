

testing different algo for doing autocrop ...
===

1. using PDL minmax funtions
2. using for loop and exiting asap
3. a mix of both

results:
--------

example: 640x480
PDL: Double D [640,480]
algo 1: speed= 58.823529
 xmin,ymin = 126,16
 xmax,ymax = 521,444
algo 2: speed= *200.000000*
 y: min=16, max=444
 x: min=126, max=521
algo 3: speed= 125.000000
 ymin,ymax = 16,444
 x: min=126, max=521



