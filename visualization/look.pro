blah = ''

;!p.multi = [0,1,4]

!p.charsize = 1.

psd = 0
ts = 1

set_plot,'ps'
device,file='ts_050601_0102.ps',/color,/landscape

for b = 1,8 do begin

;    window, b

    erase

;    print,'Box ',b
    for i=0,23 do begin

        if (i eq 0) then begin
            multiplot,[4,6] 
            tit = 'Box '+strcompress(b,/rem)
        endif else begin
            multiplot 
            tit = ''
        endelse

;        print,'cos',' ',i
        temp = data.cos[b,i]
        plot,temp-mean(temp),/xst, tit=tit
        legend,/top,/right,[string('cos ',i,format='(A4,I2)')],box=0

;        pd = psd(temp,samp=1./75.)

;        plot_io,pd[0,*],pd[1,*],/xst

;        read, blah

;        multiplot

;        legend,/top,/right,[string(i,format='(I2)')],box=0

    endfor

    erase
    
    for i=0,23 do begin

        if (i eq 0) then begin
            multiplot,[4,6] 
            tit = 'Box '+strcompress(b,/rem)
        endif else begin
            multiplot 
            tit = ''
        endelse

;        print,'sin',' ',i
        temp2 = data.sin[b,i]
        plot,temp2-mean(temp2),/xst, tit=tit
        legend,/top,/right,[string('sin ',i,format='(A4,I2)')],box=0
;        print,string(mean(temp),'     ',stddev(temp)*1.d6,'     ', $
;                     mean(temp2),'     ',stddev(temp2)*1.d6, $
;                     format = '(f8.3,A,f8.1,A,f8.3,a,f8.1)')
;        read, blah

        pd2 = psd(sqrt(temp^2 + temp2^2),samp=1./75.)

 

;        plot_oo,pd2[0,1:*],pd2[1,1:*]/137.*1.d9,/xst, $
;          title = tit, /yst,yr=[1,1000]
        
;        oplot,[.001,40],[7,7],col=2,line=2

;        legend,/top,/right,[string(i,format='(I2)')],box=0

    endfor

;        read,blah
        
;    print, ' '
    
endfor

device,/close_file
set_plot,'x'

multiplot,/reset
cleanplot,/silent

end
