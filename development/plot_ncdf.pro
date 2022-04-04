off_beam = read_ncdf(netcdf_file,'off_beam')
on_beam = read_ncdf(netcdf_file,'on_beam')  
nodding = read_ncdf(netcdf_file,'nodding')
observing = read_ncdf(netcdf_file,'observing')
az_off = read_ncdf(netcdf_file,'azimuth_offset')
el_off = read_ncdf(netcdf_file,'elevation_offset')
sec_off = read_ncdf(netcdf_file,'secondary_mirror_focus_offset')
sin = read_ncdf(netcdf_file,'sin')

plot,observing+6,/xst,/yst,yr=[-1.2,11]

oplot,sin[0,10,*]+7.5,col=5

oplot,sin[1,0,*]/max(sin[1,0,*])+9

oplot,on_beam+4.5,col=2

oplot,off_beam+3,col=3

oplot,nodding+1.5,col=4

oplot,az_off/max(abs(az_off)),col=2

oplot,el_off/max(abs(el_off)),col=3

end
