pro cos_sin_bydates

dates=[12,13,14,15,16,17,18,19,21,22,24,25,26,27,28,29]


wantbias=0.010

biasrange=[wantbias-.001,wantbias+0.001]
firsttime=1
filesexist=0
total_obs_used=0

for i=0,n_elements(dates)-1 do begin

    filenameroot='/home/zspec/data/observations/ncdf/200604'+string(dates[i],format='(i2)')
    get_dc_curves=file_search(filenameroot+'/*_dc_curve.sav',count=n_obs)

    usethisdate=0

    datapoints_thisdate=0

    for k=0,n_obs-1 do begin

        restore,get_dc_curves[k]
    
        ;choose only files with the chosen bias
        use=1
        biascheck=where(bias le biasrange[0] or bias ge biasrange[1])
    
        if biascheck[0] ne -1 then begin 
            use=0
            print,'Not using file '+get_dc_curves[k]
            print,'Wrong bias!'
        endif    

        ;if passed bias check then add data to the pile
        if use then begin
        
            filesexist=1 & total_obs_used=total_obs_used+1 & usethisdate=1
        
            datapoints_thisdate=datapoints_thisdate + n_elements(sinbolos[1,1,*])

            if firsttime then begin ;if first time through the loop

                totalsin=sinbolos
                totalcos=cosbolos
                totalgrt1=grt1
                totalgrt2=grt2
                
                alldates=[1] ; first elements of alldate is 1.  need to take 
                             ; remember to take this out later.    

                firsttime=0

            endif else begin    ;not the first time through the loop

                totalsin=[[[totalsin]],[[sinbolos]]]
                totalcos=[[[totalcos]],[[cosbolos]]]
                totalgrt1=[totalgrt1,grt1]
                totalgrt2=[totalgrt2,grt2]

            endelse

        endif

    endfor ;loop through different obs on same date

    if usethisdate eq 1 then begin

        tempdate=intarr(datapoints_thisdate)
        tempdate[*]=dates[i]
        
        alldates=[alldates,tempdate]

    endif

endfor ;loop through all dates

alldates=alldates[1:n_e(alldates)-1]

;now go through and plot all cos vs sin for each detector

totalsin_bybolo=extract_channels(totalsin,'optical',bolo_config_file=$
                      './file_io/bolo_config_apr06.txt')

totalcos_bybolo=extract_channels(totalcos,'optical',bolo_config_file=$
                      './file_io/bolo_config_apr06.txt')

ps_file='~/lieko/cos_vs_sin_bydates_10mv.ps'

set_plot,'ps'

device,file=ps_file,/landscape,/color

!p.multi=[0,2,2,0,0]

for op_channels=0,159  do begin 

    freqid=op_channels
    nu=freqid2freq(freqid)

    c_index=2
    sym_index=1

    plot,totalcos_bybolo[0,*],totalsin_bybolo[0,*],/iso,$
          title='Freq ID = '+string(op_channels,format='(i3)')+$
          ' ,Freq = '+string(nu,format='(f7.2)')+' GHz',$
          xtitle='cos',ytitle='sin',/nodata

    for dateindex=0,n_elements(dates)-1 do begin
        
        wantdata=where(alldates eq dates[dateindex])
    
        if wantdata ne [-1] then begin

            oplot,totalcos_bybolo[op_channels,wantdata],totalsin_bybolo[op_channels,wantdata],$
              psym=sym_index,color=c_index

            if c_index le 6 then c_index=c_index+1 else c_index=2

            if sym_index le 6 then sym_index=sym_index+1 else sym_index=1

        endif

    endfor  

endfor

device,/close_file
set_plot,'x'

print,'The plots are saved in '+ps_file+'.'



stop

end
