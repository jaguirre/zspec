; slice_observations was designed to work on data continuously
; arriving.  That imposes a whole constraint that I don't really need
; once all the data is in place.  And needs to be patched up.

pro make_continuous_record, night_in, lun = lun

night = strcompress(night_in,/rem)
print,night

plogdir = !zspec_data_root+'/plog/'+night+'/'
rpcdir = !zspec_data_root+'/rpc/'+night+'/'
ncdfdir = !zspec_data_root+'/ncdf/'+night+'/'

; Process the rpc data
time_s,'Gunzipping RPC ... ',t0
spawn,'gunzip '+rpcdir+'*.gz'
time_e,t0

rpcfiles = file_search(rpcdir+'*rpc.bin')
nrpcfiles = n_e(rpcfiles)

; There's a potential bug here if the very first file is empty ...
rpc = read_rpc(rpcfiles[0])

time_s,'Reading RPC ... ',t0
print
for i=1,nrpcfiles-1 do begin
print,i,nrpcfiles-1,format='(I5," of ",I5)'
; Check for the 0 file length problem
    info = file_info(rpcfiles[i])
    if info.size gt 0 then begin
        rpc = [rpc,read_rpc(rpcfiles[i])]
    endif else begin
        str = 'File '+rpcfiles[i]+' has no data.  Skipping.'
        print,str
        if keyword_set(lun) then printf,lun,str
    endelse

endfor
time_e,t0

srt = sort(rpc.coordinated_universal_time)

time_s,'Writing RPC ... ',t0
rpcsav = ncdfdir+'rpc'+night+'.sav'
save,rpc,file=rpcsav
time_e,t0

time_s,'Gzipping RPC ... ',t0
spawn,'gzip '+rpcdir+'*.bin'
time_e,t0

return

; Process the plog data
time_s,'Gunzipping PLOG ... ',t0
spawn,'gunzip '+plogdir+'*.gz'
time_e,t0

plogfiles = file_search(plogdir+'*plog.bin')
nplogfiles = n_e(plogfiles)

plog = read_plog(plogfiles[0])

time_s,'Reading PLOG ... ',t0
for i=1,nplogfiles-1 do begin

; Check for the 0 file length problem
    info = file_info(plogfiles[i])
    if info.size gt 0 then begin
        plog = [plog,read_plog(plogfiles[i])]
    endif else begin
        str = 'File '+plogfiles[i]+' has no data.  Skipping.'
        print,str
        if keyword_set(lun) then printf,lun,str
    endelse

endfor
time_e,t0

srt = sort(plog.ticks)

time_s,'Writing PLOG ... ',t0
plogsav = ncdfdir+'plog'+night+'.sav'
save,plog,file=plogsav
time_e,t0

time_s,'Gzipping PLOG ... ',t0
spawn,'gzip '+plogdir+'*.bin'
time_e,t0

end
