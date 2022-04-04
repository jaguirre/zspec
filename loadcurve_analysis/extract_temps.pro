data_file = 'data_20100928_1330'

nbox = 10
n = lonarr(nbox)

for i = 0,nbox-1 do begin

    sin = read_ncdf(data_file+'_board'+string(i,format='(I02)')+'.nc','sin')
    n[i] = n_e(sin[0,*])
    
endfor
ntod = min(n)

data = replicate(create_struct('cos',dblarr(10,24),'sin',dblarr(10,24)),ntod)

for i = 0,nbox-1 do begin

    sin = read_ncdf(data_file+'_board'+string(i,format='(I02)')+'.nc','sin')
    cos = read_ncdf(data_file+'_board'+string(i,format='(I02)')+'.nc','cos')
; Reason number 78 million to hate IDL
    data[*].sin[i,*] = reform(sin[*,0:ntod-1],1,24,ntod)
    data[*].cos[i,*] = reform(cos[*,0:ntod-1],1,24,ntod)

endfor

; Get temperature data

jfet_diode = tempconvert(data.sin[9,1],'diode','')

; Basically, all these thermistors - the GRTs in particular - are of
;                                    such low impedance that the
;                                    linear range is useless.

cernox = tempconvert(data.sin[9,8],'cerx31187','log')
ruox = tempconvert(data.sin[9,9],'roxu01434','log')
grt1 = tempconvert(data.sin[9,10],'grt29177','log')
grt2 = tempconvert(data.sin[9,11],'grt29178','log')

end
