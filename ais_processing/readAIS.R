
library(feather)

outDir<-'AIS_DATA_2016proc_Rfiles/'

files<-list.files('AIS_DATA_2016proc',full.names=T)

i<-1
for (file in files)
  {
  print(i)
  i<-i+1
  data<-read_feather(file)

  data<-data.frame(data)

  outFile<-paste(strsplit(strsplit(file,'/')[[1]][2],'.',fixed=T)[[1]][1],
                 '.Rdata',sep='')

  save(data,file=paste(outDir,outFile,sep=''))
  }

