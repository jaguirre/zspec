dir='/home/zspec/zspec_svn/processing/spectra/coadded_spectra/'
SPT3=dir+'SPT3/SPT3_20101020_0212.sav'

restore,SPT3

n = uber_psderror.in1.aveerr

readcol,!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt',$
  box,chan,type,flag,freqid,format='(I,I,A,I,I)'

loadct,39

cleanplot
erase

multiplot,[1,8],/init
multiplot

for b=1,8 do begin

    wh = where(box eq b and freqid ne -1)
    plot,chan[wh],n[freqid[wh]],psy=2,/yst,yr=[0,0.35]
;    print,minmax(chan[wh])
;    print,b
;    print,n[freqid[wh]]
    print,median(n[freqid[wh]])
    multiplot

;    blah = ''
;    read, blah

endfor

end
