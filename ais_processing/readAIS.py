
import ais.stream as astr
import pandas as pd
import numpy as np
import glob
import feather as ft

lloyds=pd.read_csv('20170627_LloydsList_PoL.csv')
lloyds=lloyds.loc[-np.isnan(lloyds.MMSI),:]
lloyds['MMSI']=lloyds.MMSI.astype(int)

files=glob.glob('AIS_DATA_2016/*.dat')

for name in files:
  
  msgs=[]
  
  with open(name) as f:
    for msg in astr.decode(f):
      msgs.append(msg)
  
  ############## Make table of IDs #############
  #ID=[msg['id'] for msg in msgs]
  #
  #IDuniq=pd.Series(ID).unique()
  #
  #ID_n=[]
  #for I_D in IDuniq:
  #  ID_n.append(np.sum(ID==I_D))
  #
  #IDtable=pd.DataFrame({'ID':IDuniq,'n':ID_n})
  ##############################################
  
  boatMsgs=[msg for msg in msgs if 'nav_status' in msg.keys()]
  
  ############### Make table of navstats #############################
  #navStat=[msg['nav_status'] for msg in boatMsgs]
  #
  #navStatuniq=pd.Series(navStat).unique()
  #
  #navStat_n=[]
  #for nav_Stat in navStatuniq:
  #  navStat_n.append(np.sum(navStat==nav_Stat))
  #
  #navStatTable=pd.DataFrame({'navStat':navStatuniq,'n':navStat_n})
  ####################################################################
  
  mmsi=[msg['mmsi'] for msg in boatMsgs]
  lon=[msg['x'] for msg in boatMsgs]
  lat=[msg['y'] for msg in boatMsgs]
  sog=[msg['sog'] for msg in boatMsgs]
  time=[msg['tagblock_timestamp'] for msg in boatMsgs]
  
  boatData=pd.DataFrame({'MMSI':mmsi,'lon':lon,'lat':lat,'sog_kts':sog,'time':time})
  boatData=boatData.loc[boatData.MMSI>=2,:]
  boatData=boatData.loc[boatData.lon<  0.4,:]
  boatData=boatData.loc[boatData.lon> -0.8,:]
  boatData=boatData.loc[boatData.lat< 51.8,:]
  boatData=boatData.loc[boatData.lat> 51.1,:]
   
  boatData=pd.merge(boatData,lloyds,how='left',on='MMSI')
  
  words=name.split('/')[1].split('.')[0].split('_')
  path='AIS_DATA_2016proc/'+words[0]+'_'+words[1]+'_'+words[4]+'_'+words[5]+'_'+words[6]+'.ftr'
  ft.write_dataframe(boatData,path)



