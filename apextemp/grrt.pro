; Stupid 

pro grrt, file, grt1, grt2

sin = read_ncdf(fileroot+'20101017_155818_board09.nc','sin')

grt1 = grt_filter(tempconvert(sin[10,*],'grt29177','log'))
grt2 = grt_filter(tempconvert(sin[11,*],'grt29178','log'))

end
