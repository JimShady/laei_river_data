
import os,glob

files=glob.glob('AIS_DATA_2016/*.dat')

for name in files:
  new_name=name.replace(' ','_')
  os.rename(name,new_name)


