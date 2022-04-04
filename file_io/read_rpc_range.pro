minute_range = [28L, 37]

root = '/home/zspec/data/cso_test/20050522/rpc/20050522_'

min = minute_range[0]

files = ['']
while (min lt minute_range[1]) do begin

    print,min
    if (min lt 1000) then minstr = '0'+strcompress(min,/rem)
    if (min lt 100) then minstr = '00'+strcompress(min,/rem)
    if (min lt 10) then minstr = '000'+strcompress(min,/rem)

    print,minstr
    
    files = [files,root+minstr+'_rpc.bin']

    min = min+1

endwhile

files = files[1:*]

stop

data = read_rpc(files[0])

for i=1,n_e(files)-1 do begin

    data = [data,read_rpc(files[i])]

endfor

end
