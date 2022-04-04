; Here, JD is computed from UTC (which is what is the timestamps, I think)
restore,'grt_data.sav.old'

; JD is computed from local time on the fridge.  Which at the time was
; 4 hours beyind UTC.
restore,'fridge_data_044.sav'

jd0 = julday(9,26,2010,0,0,0.)

; Plot all the fridge data we have so far
plot,fridge_data.time-jd0,fridge_data.saltpill,psy=3,$
  /ylog,yr=[.07,1],/yst,/xst,xr=[0,13]
oplot,jd-4./24-jd0,grt1,psy=3,col=2

end
