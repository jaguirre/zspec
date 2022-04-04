pro cos_sin_curves

dates=[12,13,14,15,16,17,18,19,21,22,24,25,26,27,28,29]
;dates=[23,24]

wantbias=0.010

biasrange=[wantbias-.001,wantbias+0.001]
firsttime=1
filesexist=0
total_obs_used=0

for i=0,n_elements(dates)-1 do begin

    filenameroot='/home/zspec/data/observations/ncdf/200604'+string(dates[i],format='(i2)')
    get_dc_curves=file_search(filenameroot+'/*_dc_curve.sav',count=n_obs)

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
        
            filesexist=1 & total_obs_used=total_obs_used+1
        
            if firsttime then begin ;if first time through the loop

                totalsin=sinbolos
                totalcos=cosbolos
                totalgrt1=grt1
                totalgrt2=grt2

                firsttime=0

            endif else begin    ;not the first time through the loop

                totalsin=[[[totalsin]],[[sinbolos]]]
                totalcos=[[[totalcos]],[[cosbolos]]]
                totalgrt1=[totalgrt1,grt1]
                totalgrt2=[totalgrt2,grt2]

            endelse

        endif

    endfor

endfor

;now plot everything

if filesexist then begin

mogul=' '

    for box=1,8 do begin
        for ch=0,23 do begin

            plot, totalcos[box,ch,*],totalsin[box,ch,*],$
              psym=4,xtitle='cos',ytitle='sin',$
              title='Box '+string(box)+', Channel '+string(ch),/iso
        
            read,mogul

        endfor
    endfor

endif else begin

    print,'There are no observations with the right bias for these dates.'

endelse

stop

end
