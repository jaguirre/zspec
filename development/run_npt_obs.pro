rawfiles = $
  '/home/zspec/data/observations/ncdf/20050603/'+$
[ $
  '20050603_002_jupiter_raw.nc', $
  '20050603_003_jupiter_raw.nc', $
  '20050603_004_jupiter_raw.nc', $
  '20050603_005_jupiter_raw.nc', $
  '20050603_006_jupiter_raw.nc', $
  '20050603_007_jupiter_raw.nc', $
  '20050603_008_jupiter_raw.nc', $
  '20050603_009_jupiter_raw.nc'  $
]

savfiles = $
  '/home/zspec/data/observations/ncdf/20050603/'+$
[ $
  '20050603_002_jupiter.sav', $
  '20050603_003_jupiter.sav', $
  '20050603_004_jupiter.sav', $
  '20050603_005_jupiter.sav', $
  '20050603_006_jupiter.sav', $
  '20050603_007_jupiter.sav', $
  '20050603_008_jupiter.sav', $
  '20050603_009_jupiter.sav'  $
]

for i=3,n_e(rawfiles)-1 do begin
    
    npt_obs,rawfiles[i]

    fivepoint,savfiles[i]

endfor



end
