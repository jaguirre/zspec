files = getenv('HOME')+'/data/cso_test/20050522/plog/20050522_'+$
        ['0111']$
;         '0052', $
;         '0053'] $
;         '0031' $;, $
;         '0032', $
;         '0033', $
;         '0034', $
;         '0035', $
;         '0036', $
;         '0037'] $
  + '_plog.bin'
;, $
;         file_search(getenv('HOME')+$
;                     '/data/cso_test/20050522/plog/*027*_plog.bin'), $
;         file_search(getenv('HOME')+$
;                     '/data/cso_test/20050522/plog/*028*_plog.bin')]

nfiles = n_e(files)

n2xfer = lonarr(nfiles)

for i=0,nfiles-1 do begin

    n2xfer[i] = read_plog(files[i],/get)

endfor

data = read_plog(files[0],n2xfer = n2xfer[0])

for i = 1,nfiles-1 do begin
    
    data = [data, read_plog(files[i],n2xfer = n2xfer[i])]

endfor

end
