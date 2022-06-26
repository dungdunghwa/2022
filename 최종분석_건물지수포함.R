require(tbart)
require(dplyr)
require(geosphere)
require(GISTools)
setwd('D:/2022시계열스터디/데이터/필수데이터')
idx=read.csv("idx_df.csv")
building=read.csv('building_final.csv')
target_parking=read.csv("target_parking.csv")
#빌딩 데이터의 위도와 경도가 10996행부터 바뀜
id=seq(10996, 14259)
lng=building$lng
lat=building$lat
building$lat[id]=lng[id]
building$lng[id]=lat[id]

target_parking_count=data.frame(super_count=rep(0, dim(target_parking)[1]), count=rep(0, dim(target_parking)[1]))
super_count=0
count=0
for(j in 1:dim(target_parking)[1]){
  for (i in 1:dim(building)[1]){
    distance=distGeo(c(building$lng[[i]], building$lat[[i]]), c(target_parking$경도[[j]], target_parking$위도[[j]]))
    if (distance <= 500){
      super_count=super_count+1
      print(paste("500m 이내 생활근린시설 : ", building$add[[i]]))
    }
    else if (distance <=1000){
      count=count+1
      print(paste("1000m 생활근린시설 : ",building$add[[i]]))
    }
    target_parking_count[j,1]=super_count
    target_parking_count[j,2]=count
  }
  super_count=0
  count=0
}

hist(target_parking_count$super_count, breaks=50)
#대부분의 값은 200언저리에 있는데 300 이상의 이상치들이 조금씩 있음. 
#하지만 300이상의 유동성이 있다고 해서 더 높은 값을 줄 필요는 없음. 일정 수준의 유동성만 확보된다면 크게 차이가 있다고 보지 않는다.
#또한 건물이 많은 것은 지역별로 상대적이라서 후반부의 이상치는 주로 발달된 중심지의 주차장으로 치우칠 가능성이 높다.
#따라서 box-cox tranformation, 루트 변환으로 이상치에 robust한 데이터로 만들어준다.

target_parking=cbind(target_parking, sqrt(target_parking_count))
colnames(target_parking)[9:10]=c("X500m생활근린시설", "X1000m생활근린시설")




#지수 스케일링
datame=target_parking
datame=datame[,-1]
datame$X500m생활근린시설=(target_parking$X500m생활근린시설 - min(target_parking$X500m생활근린시설))/(max(target_parking$X500m생활근린시설)-min(target_parking$X500m생활근린시설))
datame$주민등록세대=(target_parking$주민등록세대 - min(target_parking$주민등록세대))/(max(target_parking$주민등록세대)-min(target_parking$주민등록세대))
datame$전기차등록수=(target_parking$전기차등록수-min(target_parking$전기차등록수))/(max(target_parking$전기차등록수)-min(target_parking$전기차등록수))
datame$X500m충전소=(target_parking$X500m충전소 - min(target_parking$X500m충전소))/(max(target_parking$X500m충전소)-min(target_parking$X500m충전소))
datame$wei=datame$X500m충전소 + datame$X500m생활근린시설 + datame$주민등록세대 + datame$전기차등록수


#write.csv(datame, "D:/2022시계열스터디/데이터/필수데이터/datame.csv")
datame$wei=datame$X500m충전소 + datame$주민등록세대 + datame$전기차등록수 + datame$X500m생활근린시설
colnames(datame)[c(1,2)]=c('lat', 'lng')
coordinates(datame)<- ~lng+lat
eucdist=euc.dists(datame, datame)
dist=matrix(0, 157, 157)
for(i in 1:157){
  dist[i,]=datame$wei[i]*eucdist[i,]
}
allocations(datame, metric = dist, p=5, verbose = T)->result_t


#p를 고르자
score<-c()
for (i in 1:20){ans<-allocations(datame,metric=dist,p=i,verbose=T)
ans_unique <- unique(ans$allocation)
score[i]<- sum(ans$allocdist)}
options(scipen=999) #이거 한번 입력해주면 숫자 포멧 해결
plot(score,type='b',main='Weighted distance versus P-values',xlab="p")

#시각화
plot(result_t,border='grey')
shading.result_t=auto.shading(result_t$allocdist,n=6)
shading.result_t$cols=add.alpha(brewer.pal(6,"Blues"),0.7)
choropleth(result_t,v=result_t$allocdist,add=T,shading = shading.result_t)
choro.legend(-78.4,43,sh=shading.result_t,title="distance/feet",cex = 0.85)
plot(star.diagram(result_t),col='red',lwd=1,add=TRUE)
points(point,col="yellow",pch=10)
legend(-78.4,43.1,legend="fixed clinics",pch = 10,col="yellow")

print('P-median 입지선정 결과')
idx[unique(result_t$allocation),3]
result_t$lat[unique(result_t$allocation)]
result_t$lng[unique(result_t$allocation)]
'''
P-median결과
신문리주차창(37.74691, 126.4821)
작전역 환승 서쪽(남측) (37.52994 , 126.7217 )
석산길 (37.46327 , 126.7135 )
늘봄공원지하주차장 (37.41320 , 126.6785 )
경동공영주차장 (37.47154 , 126.6308 )
'''