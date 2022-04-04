fileroot='/home/zspec/data/telescope_tests/'+$
  '20101017/'

sin = read_ncdf(fileroot+'20101017_155818_board09.nc','sin')

grt1 = grt_filter(tempconvert(sin[10,*],'grt29177','log'))
grt2 = grt_filter(tempconvert(sin[11,*],'grt29178','log'))

help,grt1

plot,grt1,/xst,/yst,yr=[0.06,0.150]

end
