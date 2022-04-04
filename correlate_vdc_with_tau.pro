dir = '/home/jaguirre/data/observations/ncdf/20100509/'

restore,dir+'rpc20100509.sav'

ncdf_files = file_search(dir+'*.nc')

q = extract_channels(read_ncdf(ncdf_files[0],'cos'), $
                     read_ncdf(ncdf_files[0],'sin'), $
                     'optical')
t = read_ncdf(ncdf_files[0],'ticks')
grt1 = (get_temps(ncdf_files[0])).grt1
;mjd = read_ncdf(ncdf_files[0],'epoch')


; We want to seriously rebin this ... sample rates are ~35 Hz, so
; let's rebin to order a minute
nbin = 2100L

nt = n_e(t)
trunc_len = (nt/nbin)*nbin
new_len = nt/nbin

t = rebin(t[0:trunc_len-1],new_len)
q = rebin(q[*,0:trunc_len-1],160,new_len)
grt1 = rebin(grt1[0:trunc_len-1],new_len)

for i=1,n_e(ncdf_files)-1 do begin

    print,i,' of ',n_e(ncdf_files)-1
    
    qtemp = extract_channels(read_ncdf(ncdf_files[i],'cos'), $
                             read_ncdf(ncdf_files[i],'sin'), $
                             'optical')
    ttemp = read_ncdf(ncdf_files[i],'ticks')
    gtemp = (get_temps(ncdf_files[i])).grt1

    nt = n_e(ttemp)
    trunc_len = (nt/nbin)*nbin
    new_len = nt/nbin

    t = [t,rebin(ttemp[0:trunc_len-1],new_len)]
    q = [[q],[rebin(qtemp[*,0:trunc_len-1],160,new_len)]]
    grt1 = [grt1,rebin(gtemp[0:trunc_len-1],new_len)]

;    mjd = [mjd,read_ncdf(ncdf_files[i],'epoch')]
    
endfor

thr = t/3600.
tau = interpol(rpc.tau_225,rpc.tau_225_time,thr)
vdc = reform(q[100,*])

dm = transpose([[grt1],[tau]])
c = regress(dm,vdc)

end
