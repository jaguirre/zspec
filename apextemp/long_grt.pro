fileroot='/home/zspec/data/telescope_tests/'

files = file_search(fileroot+'20101014/*board09.nc')
nfiles = n_e(files)

sin = read_ncdf(files[0],'sin')
ts = parse_udp_timestamp(read_ncdf(files[0],'timestampUDP'))
grt1 = grt_filter(tempconvert(sin[10,*],'grt29177','log'))
grt2 = grt_filter(tempconvert(sin[11,*],'grt29178','log'))

for i = 1,nfiles-1 do begin

    sin = read_ncdf(files[i],'sin')
    ts = [ts,parse_udp_timestamp(read_ncdf(files[i],'timestampUDP'))]
    grt1 = [grt1,grt_filter(tempconvert(sin[10,*],'grt29177','log'))]
    grt2 = [grt2,grt_filter(tempconvert(sin[11,*],'grt29178','log'))]

endfor

end
