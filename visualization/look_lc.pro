blah = ''

;!p.multi = [0,1,4]

!p.charsize = 1.

psd = 0
ts = 1

nbox = 10

date = '20050601'
data_root = '/home/zspec/data/lab_tests/cso_tests/bze/'+date+'/'+date+'_'

; bias
;[0,12]

minute_range = [324, 326]

min = minute_range[0]

read = 0
if (read) then begin
; Make up the filenames.  Yet another little task.
    data_files = ['']
    minstr = ''
    while (min le minute_range[1]) do begin
        
        minstr = strcompress(min,/rem)
        if (min lt 1000) then minstr = '0'+strcompress(min,/rem)
        if (min lt 100) then minstr = '00'+strcompress(min,/rem)
        if (min lt 10) then minstr = '000'+strcompress(min,/rem)
        
        minstr_file = minstr
        
        data_files = [data_files,data_root+minstr+'_bze.bin']
        
        min = min+1
        
    endwhile
    
    data_files = data_files[1:*]
    
    data = read_bze(data_files[0],nbox)
    
    for i=1,n_e(data_files)-1 do begin
        
        data = [data, read_bze(data_files[i],nbox)]
        
    endfor

endif

;x = findgen(n_e(data))
; Aggressively deglitch the bias voltage
x = deglitch(reform(data.cos[0,12]),step=1.d-6)
sortx = sort(x)
xrange = [-.2,0]

;set_plot,'ps'
;device,file='lc_'+date+'_'+minstr+'.ps',/color,/landscape

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
        plot,x[sortx],deglitch(temp[sortx],step=1.d-4),/xst, tit=tit,xr=xrange
        legend,/top,/right,[string('cos ',i,format='(A4,I2)')],box=0

;        pd = psd(temp,samp=1./75.)

;        plot_io,pd[0,*],pd[1,*],/xst

        read, blah

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
        plot,x,temp2,/xst, tit=tit,xr=xrange,psy=1
        legend,/top,/right,[string('sin ',i,format='(A4,I2)')],box=0
;        print,string(mean(temp),'     ',stddev(temp)*1.d6,'     ', $
;                     mean(temp2),'     ',stddev(temp2)*1.d6, $
;                     format = '(f8.3,A,f8.1,A,f8.3,a,f8.1)')
        read, blah

        pd2 = psd(sqrt(temp^2 + temp2^2),samp=1./75.)

 

;        plot_oo,pd2[0,1:*],pd2[1,1:*]/137.*1.d9,/xst, $
;          title = tit, /yst,yr=[1,1000]
        
;        oplot,[.001,40],[7,7],col=2,line=2

;        legend,/top,/right,[string(i,format='(I2)')],box=0

    endfor

;        read,blah
        
;    print, ' '
    
endfor

;device,/close_file
;set_plot,'x'

multiplot,/reset
cleanplot,/silent

end
