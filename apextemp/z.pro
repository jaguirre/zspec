; Attempt to make sense of the APECS multi-scan mode.  For this
; example, there are 10 subscans, but as we would call it, 5 nods with
; 2 nod positions each.  Given the MBFITS format, I'm not at all sure
; how you would decode these scans if you didn't already know what the
; pattern was.  

; OK - one interesting problem.  Current pipeline deglitches and
;      downsamples on a continuous timestream, but we no longer have
;      that with the way MBFITS requests and records data.  For now
;      ... let's skip this.

; find_onoff (find_nods) - this has effectively already been done for us
; make_chop_struct - what does this do?


pro z, scanno, n_nod_pos, rel_phase = rel_phase

scannostr = string(scanno,format='(I5)')

fileroot = $
  (file_search(!zspec_data_root+'/*/APEX-'+scannostr+'*',$
              /test_directory))[0]

if (fileroot eq '') then begin

    message,/info,'Data for scan '+scannostr+' not found.  Returning.'
    return

endif

scanroot = fileroot+'_scan'

; Read the subscan ncdf files
scans = file_search(scanroot+'*.nc')
nscans = n_e(scans)

npts = lonarr(nscans)
periods = dblarr(nscans)
dts = dblarr(nscans)

; Determine the lengths of each scan and the chopper period, and set
; the length of all scans to be the same and an integral number of
; chopper periods.
for i=0,nscans-1 do begin

    file = scanroot+strcompress(i+1,/rem)+'.nc'
    print,i,'  ',file
    ch = read_ncdf(file,'chop_enc')
    dts[i] = median(fin_diff(read_ncdf(file,'ticks')))
    npts[i] = n_e(ch)
    chop_struct = make_chop_struct(ch,samp=dts[i],/quiet)
    periods[i] = chop_struct.period

endfor

period = mean(periods)
dt = mean(dts)
samp_int = dt

nspscan = round(FLOOR(min(npts) / period) * period)
ntod = nscans * nspscan

; Create variables
ch = dblarr(nspscan*nscans)
t = dblarr(nspscan,nscans)
flags = dblarr(160,ntod)+1
sin = dblarr(160,ntod)
cos = dblarr(160,ntod)

indx = lindgen(nspscan)

for i=0,nscans-1 do begin
    file = scanroot+strcompress(i+1,/rem)+'.nc'
    ch[i*nspscan + indx] = (read_ncdf(file,'chop_enc'))[0:nspscan-1]
    t[i*nspscan + indx] = (read_ncdf(file,'ticks'))[0:nspscan-1]
    sin[*,i*nspscan + indx] = (read_ncdf(file,'sin'))[*,0:nspscan-1]
    cos[*,i*nspscan + indx] = (read_ncdf(file,'cos'))[*,0:nspscan-1]  
endfor

chop_struct = make_chop_struct(ch,samp=dt,/quiet)

; Fake a nod struct.  What. A. Pain. In. The. Ass.
;n_nod_pos = 1L
n_nods = nscans / n_nod_pos
pat = [1,-1]

temp = create_struct('i',0L,$
                     'f',0L,$
                     'sgn',0L)

nod_pos_struct = replicate(temp,n_nod_pos)

temp = create_struct('i',0L, $
                     'f',0L, $
                     'pos',nod_pos_struct)

nod_struct = replicate(temp,n_nods)

init = 0
fin = nspscan - 1
for i=0,n_nods-1 do begin
    nod_struct[i].i = i*n_nod_pos*nspscan
    nod_struct[i].f = (i+1)*n_nod_pos*nspscan-1
    for j=0,n_nod_pos-1 do begin
        nod_struct[i].pos[j].i = init
        nod_struct[i].pos[j].f = fin
        nod_struct[i].pos[j].sgn = pat[j]
        init += nspscan
        fin += nspscan
    endfor
endfor

vopt = slice_data(nod_struct,-(sin^2+cos^2),flags)
degree = 2
poly_subtract, vopt, POLY_DEG = degree, /quiet
psd_calc, vopt, samp_int, /quiet

if (n_nod_pos gt 1) then begin

if ~keyword_set(rel_phase) then $
  rel_phase=find_chop_bolo_phase3(nod_struct,vopt,chop_struct,nloops=3)
;rel_phase -= rel_phase

sliced_chop = $
  make_phased_sliced_chop(nod_struct,chop_struct,rel_phase)

vopt_spectra = $
  demod_and_diff3(nod_struct,vopt,sliced_chop,$
                  /CHOP_PRECOMPUTE)

;verr_spectra = $
;  demod_and_diff3(nod_struct,verr,sliced_chop,$
;                  /CHOP_PRECOMPUTE)

estimate_spec_err, vopt_spectra

endif
;estimate_spec_err, verr_spectra

savfile = fileroot+'_spec.sav'

message,/info,'No deglitching.'
message,/info,'No downsampling.'
message,/info,'No optimal phasing.'
message,/info,'Saving file '+savfile

save,vopt_spectra,nod_struct,vopt,rel_phase,file=savfile

end
