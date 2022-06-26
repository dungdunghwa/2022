# 2022
P-median using R
================

Introdunction
-------------
This project used P-median method to locate best public parking lot for electric charger in Incheon, South Korea.   
To use P-median in R, you need to install 'tbart' and 'GISTools'.    
    
## 'tbart' package   
The function 'allocations' in tbart package will automatically give you P-median result only if the input data is 'Spatial* Dataframe.   
'coordinate()' function in Sp package which is also included in tbart package will turn your dataframe into Spatial dataframe.    
<pre>
<code>
coordinates(datame)<- ~lng+lat
</code>
</pre>
 
Also you need Eucladian distance matrix which is mutiplied with weight parameter.  
<pre>
<code>
eucdist=euc.dists(datame, datame)
dist=matrix(0, 157, 157)
for(i in 1:157){
  dist[i,]=datame$wei[i]*eucdist[i,]
}
allocations(datame, metric = dist, p=5, verbose = T)->result_t
</code>
</pre>
  
    
## 'GISTools' package  
Package 'GISTools' is not available for version 4 or above, so you have to download and install it by yourself.  
You can download in : <https://cran.r-project.org/src/contrib/Archive/GISTools/>    
GISTools is visualisation tool to make P-median graph.    
