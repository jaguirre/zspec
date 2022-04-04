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
;REL 01/03/2011: propagate the pwv from the ncdf files to the sav files
;REL 01/03/2011: check for empty subscans and exclude them, as well as
;entire scans where all the subsacans are unusable
; 12/19/2012 - KSS - Committed latest version to svn.
; 12/20/2012 - KSS - Fixed minor bug in analyzing real-time pointings.

pro zapex, scanno, rel_phase, n_nod_pos, quad=quad, MS_decorr=MS_decorr, $
           tempflag=tempflag, PCA_decorr=PCA_decorr, filt=filt, status=status



 ;Now what is rel_phase? There are 4 cases: 
 ;rel_phase=0 --> no correction
 ;rel_phase=1 --> find rel_phase from this observation
 ;rel_phase=3x160 array --> use this rel_phase
 ;rel_phase=.sav file containing rel_phase --> restore file and use rel_phase

scannostr = strcompress(scanno,/rem);string(scanno,format='(I05)')

filex = $
  (strsplit((file_search(!zspec_data_root+'/apexnc/*/APEX-'+scannostr+'-*'))[0],$
           '_',/extract));[0]
fileroot=(strsplit((file_search(!zspec_data_root+'/apexnc/*/APEX-'+scannostr+'-*'))[0],'_'+filex(n_e(filex)-1),/extract,/regex))[0]
;,$
;              /test_directory))[0]

if (fileroot eq '') then begin

    message,/info,'Data for scan '+scannostr+' not found.  Returning.'
    status=0
    return
   
endif

scanroot = fileroot+'_subscan'
fnameind = strpos(scanroot, '/', /reverse_search)+1
fname_root = strmid(scanroot, fnameind)

; Read the subscan ncdf files
; check for empty nc files and adjust the number of scans accordingly
scans = file_search(scanroot+'*.nc')
nscans = n_e(scans)
scans_empty = file_search(scanroot+'*.nc.empty')
if scans_empty(0) ne '' then begin 
n_empty=n_e(scans_empty)
print,'Found '+sstr(n_empty)+' empty subscans'
i_empty=intarr(n_empty)
for j=0,n_empty-1 do begin
dum=0
reads,strmid(scans_empty(j),10,2,/reverse_offset),dum
i_empty(j)=dum
endfor
print,i_empty
allscans=intarr(nscans)
allscans(i_empty-1)=1
uscans=where(allscans ne 1,nscans)
endif else begin
print,'Found 0 empty subscans'
uscans=findgen(nscans)
endelse

;print,uscans

;also check for bad but non-empty subscans




;return if all subscans are bad
bad=0
if nscans eq 0 then begin
message,'The entire scan '+scannostr+' was bad. Skipping...',/cont
bad=1
goto,writesav
endif

npts = lonarr(nscans)
periods = dblarr(nscans)
dts = dblarr(nscans)

; Determine the lengths of each scan and the chopper period, and set
; the length of all scans to be the same and an integral number of
; chopper periods.

for i=0,nscans-1 do begin
    ;file = scanroot+string(uscans(i)+1,format='(I02)')+'.nc'
    file=scans[i]
    print,i,'  ',file
    ch = read_ncdf(file,'chop_enc')
    if n_e(ch) eq 1 and ch[0] eq -1 then begin
        status=0
        return
    endif
    dts[i] = median(fin_diff(read_ncdf(file,'ticks')))
    npts[i] = n_e(ch)

    chop_struct = make_chop_struct(ch,samp=dts[i],/quiet)
    ;if chop_struct.chop_status eq 0 then begin
    ;    status=0
    ;    return
    ;endif
    periods[i] = chop_struct.period
endfor

period = mean(periods)
dt = mean(dts)
samp_int = dt

nspscan = round(FLOOR(min(npts) / period) * period)
ntod = nscans * nspscan
; Create variables
;scans=scans[2:nscans-1]
;nscans-=2

ch = dblarr(nspscan*nscans)
ticks = dblarr(nspscan*nscans)
elevation = dblarr(nspscan*nscans)
flags = dblarr(160,ntod)+1
pwv = dblarr(nscans)
indx = lindgen(nspscan)
sin = dblarr(160,ntod)
cos = dblarr(160,ntod)
    
for i=0,nscans-1 do begin
    ;file = scanroot+string(i+1,format='(I02)')+'.nc'
    file=scans[i]
    ncdf_sin=read_ncdf(file,'sin')
    ncdf_cos=read_ncdf(file,'cos')
    
    if keyword_set(filt) or keyword_set(ms_decorr) or $
      keyword_set(pca_decorr) then begin
        s=size(ncdf_sin)
        for j=0, s[1]-1 do begin
            m=mean(ncdf_sin[j,*])
            ncdf_sin[j,*]=bpfilt(ncdf_sin[j,*])
            ncdf_sin[j,*]+=m
            m=mean(ncdf_cos[j,*])
            ncdf_cos[j,*]=bpfilt(ncdf_cos[j,*])
            ncdf_cos[j,*]+=m
        endfor
    endif
    
    sin[*,i*nspscan + indx] = ncdf_sin[*,0:nspscan-1]
    cos[*,i*nspscan + indx] = ncdf_cos[*,0:nspscan-1]  
    
    ch[i*nspscan + indx] = (read_ncdf(file,'chop_enc'))[0:nspscan-1]
    ticks[i*nspscan + indx] = (read_ncdf(file,'ticks'))[0:nspscan-1]
    elevation[i*nspscan + indx] = (read_ncdf(file,'elevation'))[0:nspscan-1]
    pwv[i]=read_ncdf(file,'pwv')
endfor

chop_struct = make_chop_struct(ch,samp=dt,/quiet)
;stop
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

temp = strsplit(fname_root,'-',/extract)

year = long(temp[2])
month = long(temp[3])
night = long(temp[4])
obsnum = long(temp[1])

;year =long(strmid(fname_root,11,4));2010
;month = long(strmid(fname_root,16,2));10
;night = long(strmid(fname_root,19,2));18
;obsnum = 999
; is the convention vr = sin correct?
; how do we get the bias signal out?
avebias = 0.010
;rel_phase = 1

resolve_routine, 'zanalyze', /is_function
writesav:

base_file = zanalyze(year,month,night,obsnum,fileroot,rel_phase, $
                     samp_int, sin, cos,ch, $
                     nscans, n_nods, n_nod_pos, nspscan,$
                     nod_struct, chop_struct, avebias,$
                     ticks, elevation,pwv,bad=bad,/save_all,$
                     MS_decorr=MS_decorr, $
                     PCA_decorr=PCA_decorr)

status=1

;vopt = slice_data(nod_struct,-(sin^2+cos^2),flags)
;degree = 2
;poly_subtract, vopt, POLY_DEG = degree, /quiet
;psd_calc, vopt, samp_int, /quiet
;
;if (n_nod_pos gt 1) then begin
;
;if ~keyword_set(rel_phase) then $
;  rel_phase=find_chop_bolo_phase3(nod_struct,vopt,chop_struct,nloops=3)
;;rel_phase -= rel_phase
;
;sliced_chop = $
;  make_phased_sliced_chop(nod_struct,chop_struct,rel_phase)
;
;vopt_spectra = $
;  demod_and_diff3(nod_struct,vopt,sliced_chop,$
;                  /CHOP_PRECOMPUTE)
;
;;verr_spectra = $
;;  demod_and_diff3(nod_struct,verr,sliced_chop,$
;;                  /CHOP_PRECOMPUTE)
;
;estimate_spec_err, vopt_spectra
;
;endif
;;estimate_spec_err, verr_spectra
;
;savfile = fileroot+'_spec.sav'
;
;message,/info,'No deglitching.'
;message,/info,'No downsampling.'
;message,/info,'No optimal phasing.'
;message,/info,'Saving file '+savfile
;
;save,vopt_spectra,nod_struct,vopt,rel_phase,file=savfile
;
end
