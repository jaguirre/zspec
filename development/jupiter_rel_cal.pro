date = '20050603'
ncdf_dir = '/home/zspec/data/observations/ncdf/'+date+'/'

restore,ncdf_dir+'20050603_008_jupiter.sav'

snu8 = snu[*,0]

restore,ncdf_dir+'20050603_009_jupiter.sav'

snu9 = snu[*,0]

jupiter_rel_cal = (snu8 + snu9)/2.

save,jupiter_rel_cal,file='jupiter_rel_cal.sav'

end
