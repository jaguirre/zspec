; Fucking stupid

function get_temps, ncdf_file

;cos = read_ncdf(ncdf_file,'cos')
sin = read_ncdf(ncdf_file,'sin')

jfet_diode = tempconvert(sin[9,1,*],'diode','')
cernox = tempconvert(sin[9,8,*],'cerx31187','log')
ruox = tempconvert(sin[9,9,*],'roxu01434','log')
grt1 = tempconvert(sin[9,10,*],'grt29177','log')
grt2 = tempconvert(sin[9,11,*],'grt29178','log')

out = create_struct('jfet_diode',jfet_diode,$
                    'cernox',cernox,$
                    'ruox',ruox,$
                    'grt1',grt1,$
                    'grt2',grt2)

return,out

end

