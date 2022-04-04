pro get_telescope_data

writefile='obslog0603.txt'

filenames=file_search('/home/zspec/data/observations/ncdf/20050603/*.nc')
filenames=[filenames[1:15],filenames[17:48]]
openw,unit,writefile,/get_lun
printf,unit,'Z-Spec 20050603'
printf,unit,'    UTstart    ','UTend  ','  azmean   ','  elmean ','  fazo     ','  fzao   ','  tazo   ','  tzao'
for i=0,n_elements(filenames)-1 do begin
;for i=9,9 do begin
fn=filenames[i]
fzao=mean(read_ncdf(fn,'elevation_fixed_offset'))
fazo=mean(read_ncdf(fn,'azimuth_fixed_offset'))
tazo=mean(read_ncdf(fn,'azimuth_t_term_offset'))
tzao=mean(read_ncdf(fn,'elevation_t_term_offset'))
utstart=(read_ncdf(fn,'coordinated_universal_time'))[0]
utend=max(read_ncdf(fn,'coordinated_universal_time'))

zamean=mean(read_ncdf(fn,'elevation'))
azmean=mean(read_ncdf(fn,'azimuth'))
printf,unit,fn
printf,unit,utstart,utend,azmean,zamean,fazo,fzao,tazo,tzao,format='(8f10.4)'
print,i
end
close,unit

stop
end


