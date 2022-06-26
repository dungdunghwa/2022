# 2022
P-median using R
================

Introdunction
-------------
This project is used P-median method to locate best public parking lot for electric charger in Incheon, South Korea.   
To use P-median in R, you need to install 'tbart' and 'GISTools'.    
    
# tbart package   
The function 'allocations' in tbart package will automatically give you P-median result only if the input data is 'Spatial* Dataframe.   
'coordinate()' function in Sp package which is also included in tbart package will turn your dataframe into Spatial dataframe.    
<pre>
<code>
coordinates(datame)<- ~lng+lat
</code>
</pre>
    
# GISTools package  
Package 'GISTools' is not available for version 4 or above, so you have to download and install it by yourself.  
You can download in : <https://cran.r-project.org/src/contrib/Archive/GISTools/>    
GISTools is visualisation tool to make P-median graph.    
