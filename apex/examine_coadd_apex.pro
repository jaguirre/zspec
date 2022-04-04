pro examine_coadd_apex,coadd_file

run='E-086.A-0793A-2010'

; The purpose of this routine is to display
; information about all observations in a coadd
; to better inform which are used or not.

dir=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'

; Read in the data
  tempstruct = read_ascii(dir+coadd_file, data_start=4, num_records=1)
  ncol = n_elements(tempstruct.field1)
    ;if #columns equal to 5, user has supplied a calibration correction
    ;file for spectral flattening, so read this in

  rformat='(a8,a6,i1,a26,a)'
  rformat2='(a8,a6,i1)'
  if (ncol eq 5) then readcol,dir+coadd_file,date,obs,flag,chop_file,cal_corr_file,$
    format=rformat,comment=';' $
  else readcol,dir+coadd_file,date,obs,flag,chop_file,format=rformat2,comment=';'

  nobs=n_e(obs)

; For each file, gather the following information:
; 1) Tau, 2) Elevation, 3) Time 4) Loading something...?  Don't have GRTs...

ifsav=fltarr(nobs)
tau=fltarr(nobs)
median_ut=fltarr(nobs)
el=fltarr(nobs)
nsec=fltarr(nobs)
vbolo_quad_sum=fltarr(nobs)
grt=fltarr(nobs)

for i=0, nobs-1 do begin
   savfile=!zspec_data_root+'/apex/APEX-'+obs[i]+'*-'+run+'_spec.sav'
   spawn,'ls '+savfile,savresult
   if savresult[0] NE '' then begin
       ifsav[i]=1
       restore,savresult[0]
       ; Tau - this takes too long, uncomment if weather was a concern,doubt it.
       nods_in_obs=n_e(vopt_spectra.in1.nodspec[0,*])
       nod_start=nod_struct.i
       nod_end=nod_struct.f
       ticks=nc_ticks
       median_ut[i]=median(ticks[nod_start[0]:nod_end[nods_in_obs-1]])/3600.
       ;readcol,'/home/zspec/data/obs_logs/zspec_search.dat',xa,xb,xc,xd,xe,xf,xg,xh,xi,xj,$
       ;  format='(A19,A18,L5,A13,A6,A5,A7,A5,A4,F4.2)'
       ;wtau=where(xc eq obs[i])
       ;if wtau(0) ne -1 then tau[i]=pwv2tau(xj(wtau(0))) else $
       ;  print,'Scan number not found for computing tau. Make sure to copy the latest logs.'
       ; Elevation
       el[i]=median(nc_elevation)
       ; Total time
       nsec[i]=n_sec
       ; Bolo voltages
       vdcfile=strsplit(savresult[0],'_',/extract)
       vdcfile[n_e(vdcfile)-1]='_vdc.sav'
       vdcfile=strjoin(vdcfile)
       restore,vdcfile
       vbolo_quad_sum[i]=median(vbolo_quad) ; ahhh is that useful???
       ; Can't get GRTs from file, but can get using timestamp?
       ; See grt.pro

   endif
endfor

; Get the GRTs by date... ugh.
; NOW THIS REQUIRES THE RIGHT UT DATE YO!
dates=date[uniq(date)]
for i=0, n_e(dates)-1 do begin
    thisdate=dates[i]
    print,'Getting GRT data for '+thisdate
    grt, thisdate, t_temp , grt_temp,/noplot
    ; WTF is up with the timestamps?  arrrrggghhh
    use_obs=WHERE(date EQ thisdate,nuse)
    for j=0, nuse-1 do begin
        index=use_obs[j]
        bin=value_locate(t_temp,median_ut[index])
        CASE 1 OF
           bin EQ -1: grt[index]=grt_temp[0]
           bin EQ (n_e(t_temp)-1): grt[index]=grt_temp[n_e(grt_temp)-1]
           else: if ABS(t_temp[bin]-median_ut[index]) $
             GT ABS(t_temp[bin+1]-median_ut[index]) THEN $
             grt[index]=grt_temp[bin] ELSE grt[index]=grt_temp[bin]
        ENDCASE
    endfor
endfor

grt*=1.e-9
; wtf is up with these units?
grt*=1.e3

; Print this information
    print,'UT Date , ObsNum , Flag , Elevation , GRT'
for i=0, nobs-1 do begin
    if ifsav[i] EQ 1 then print,date[i],'  ',obs[i],flag[i],el[i],grt[i] $ ; tau excluded.
      else print,date[i],'  ',obs[i],flag[i],'  No savefile.'  
endfor


end
