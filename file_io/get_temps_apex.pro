; Fucking stupid
; I agree

function get_temps_apex, ncdf_file

singrt = read_ncdf(ncdf_file,'sin_extra')

if singrt(0) ne -1 then begin
;jfet_diode = tempconvert(sin[9,1,*],'diode','')
;cernox = tempconvert(sin[9,8,*],'cerx31187','log')
;ruox = tempconvert(sin[9,9,*],'roxu01434','log')

grt1 = tempconvert(singrt[7,*],'grt29177','log')
grt2 = tempconvert(singrt[8,*],'grt29178','log')

out = create_struct($
;                     'jfet_diode',jfet_diode,$
;                     'cernox',cernox,$
;                     'ruox',ruox,$
                     'grt1',grt_filter(grt1,/apex),$
                     'grt2',grt_filter(grt2,/apex))
endif else out=0

return,out

end

