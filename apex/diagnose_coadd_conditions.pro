pro diagnose_coadd_conditions

  ; JRK 12/3/12
  ;
  ; For all _nov2012.txt coadd files, look at the observing conditions.
  ; 
  ; INPUTS:
  ;  
  ;
  ; OUTPUTS:
  ;  plots...

cd,!zspec_pipeline_root+'/processing/spectra/coadd_lists/'
allcoadds=file_search('*nov2012.txt')
;allcoadds=['ADFS_27_nov2012.txt','MACSJ0717_nov2012.txt']
allcoadds=allcoadds[where(allcoadds NE 'flats_nov2012.txt'and allcoadds NE 'Jupiter_nov2012.txt' $
                  and allcoadds NE 'Mars_nov2012.txt' and allcoadds NE 'PKS0537-441_nov2012.txt' $
                  and allcoadds NE 'Uranus_nov2012.txt')]

psfile=!zspec_pipeline_root+'/apex/diagnose_2012.ps'

set_plot,'ps'
device,file=psfile,/color,xsize=7.5,ysize=8,yoffset=0.5,xoffset=0.5,/inches,/portrait

; Restore the GRT data.
restore,!zspec_pipeline_root+'/apex/grt_data_all_2012.sav'

; Load the log file.
log=load_logfile_str()

for c=0, n_e(allcoadds)-1 do begin
  !p.multi=[0,2,2,0,0]

  ; Choose this coadd file.
  obs_list=allcoadds[c]  

  ; Load the coadd file data.
  file=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+obs_list
  tempstruct = read_ascii(file, data_start=4, num_records=1)
  ncol = n_elements(tempstruct.field1)
  rformat='(a8,a6,i1,a26,a)'
  rformat2='(a8,a6,i1)'
  
  if (ncol eq 5) then readcol,file,date,obs,flag,chop_file,cal_corr_file,$
      format=rformat,comment=';',/sil $
    else readcol,file,date,obs,flag,chop_file,format=rformat2,comment=';',/sil
  
  nobs=n_e(obs) ; Do all, then worry about flags.
  whflag=where(flag EQ 0,nwhflag,complement=good,ncomplement=ngood)
  
  ; These we can get from the logs.
  pwv=fltarr(nobs)
  el=fltarr(nobs)
  az=fltarr(nobs)
  del=fltarr(nobs)
  daz=fltarr(nobs)
;  del30=fltarr(nobs)
;  daz30=fltarr(nobs)
  grt=fltarr(nobs)
  jdate=dblarr(nobs)
  focusz=fltarr(nobs)
  
  ; For sensitivity, we need to restore the most recent coadd.
  ; Remove _nov2012, find the most recent coadd.
  strind=strpos(obs_list,'_nov2012') 
  if strind NE -1 then obs_list2=strsplit(obs_list,'_nov2012',/regex,/extract)
  dir=!zspec_pipeline_root+'/processing/spectra/coadded_spectra/'+obs_list2[0]
  savefile=file_search(dir+'/'+obs_list2[0]+'_20121???_????.sav',count=nsav)
  savefile=savefile[nsav-1]
  restore,savefile

   ; Note, obs_labels.names has the ID  numbers, but has one for each NOD,
   ; We want one per observation.
  ncount=0
  for n=0, n_e(obs_labels.nnods)-1 do begin
    ninds=indgen(obs_labels.nnods[n])+ncount
    if obs_labels.names[ninds[0]] NE obs_labels.names[ninds[n_e(ninds)-1]] then stop
    if n eq 0 then savobs=long(obs_labels.names[ninds[0]]) else savobs=[savobs,long(obs_labels.names[ninds[0]])]
    ncount+=obs_labels.nnods[n]
endfor

  for i=0, nobs-1 do begin
  
    savind=where(savobs EQ long(obs[i]),nsavind)
    ; Note, savind will return values for EACH NOD in the observation.
    ; But sensitivity is only by observation, not by nod.
    
    if nsavind EQ 0 then begin ; No match.
      if i EQ 0 then sens_obs=!values.f_nan else sens_obs=[sens_obs,!values.f_nan]
    endif else begin
      if i EQ 0 then sens_obs=median(obs_labels.sensitivity[*,savind]) else $
         sens_obs=[sens_obs,median(obs_labels.sensitivity[*,savind])]
      if obs_labels.nnods[savind] EQ 1 then sens_obs[i]=!values.f_nan
    endelse 

    ind=where(long(log.scan) EQ obs[i],nind)
    if nind NE 1 then message,'Error?'
    pwv[i]=log[ind].pwv
    el[i]=log[ind].el
    az[i]=log[ind].az
    focusz[i]=log[ind].focusz

    temp=log[ind].yyyymmddthhmmss
    temp=strsplit(temp,'-T:',/extract)
    temp=float(temp)
    ; Days since 11/23/12, 00:00:00
    jdate[i]=temp[2]+temp[3]/24.0+temp[4]/(60.0*24.0) ; Bah, seconds.
    if temp[1] EQ 11 then jdate[i]-=23
    if temp[1] EQ 12 then jdate[i]+=7
    
    ; Determine how much the telescope has moved.
    ; Since the last move...
  ;  lastind=ind
  ;  lastmove=0
  ;  while lastmove EQ 0 do begin
  ;    if log[ind].sourcename EQ log[lastind].sourcename then $
  ;     lastind-=1 else lastmove=1
  ;  endwhile
  ;  del[i]=log[lastind].el-log[ind].el
  ;  daz[i]=log[lastind].az-log[ind].az
  
    ; Since the last observation...
    del[i]=log[ind-1].el-log[ind].el
    daz[i]=log[ind-1].az-log[ind].az
  
  ; NOW RETURN TO HERE, CALCULATE THE DISTANCE, 
  ; MAY ALSO WNAT TO RECORD D(AZ) AND D(EL) SEPARATELY.
  
    ; In the last 30 min...
  
   ; T_GRT
    grtind=value_locate(ut,log[ind].juliandate)
    case grtind of 
       -1: grt[i]=!values.f_nan
       n_e(ut)-1: begin
          grt[i]=!values.f_nan
          message,'Need to update GRT values. If continue, will not have all values.',/info
          stop
         end
       else: if abs(ut[grtind]-log[ind].juliandate) GT abs(ut[grtind+1]-log[ind].juliandate) then $
               grt[i]=t_grt[grtind+1] else grt[i]=t_grt[grtind]
    endcase
    
  endfor
  
  ; Save all.
  if c EQ 0 then begin
    sens_obs_tot=sens_obs
    sens_tot=median(uber_psderror.in1.aveerr*sqrt(total_n_sec))
    cmatch=replicate(0,nobs)
    all_pwv=pwv
    all_el=el
    all_grt=grt
    all_jdate=jdate
    med_grt=median(grt[good])
    all_focusz=focusz
  endif else begin
    sens_obs_tot=[sens_obs_tot,sens_obs]
    sens_tot=[sens_tot,median(uber_psderror.in1.aveerr*sqrt(total_n_sec))]
    cmatch=[cmatch,replicate(c,nobs)]
    all_pwv=[all_pwv,pwv]
    all_el=[all_el,el]
    all_grt=[all_grt,grt]
    all_jdate=[all_jdate,jdate]
    med_grt=[med_grt,median(grt[good])]
    all_focusz=[all_focusz,focusz]
  endelse


  ; PLOT FOR THIS COADD LIST.
  
  plot,jdate,pwv,$
    xtitle='Days Since Nov 23',ytitle='PWV',$
    yrange=[0,4],/nodata,title=obs_list,ysty=9
  oplot,jdate[good],pwv[good],psym=4
  hline,median(pwv[good])
  xyouts,0.1*(!x.crange[0]-!x.crange[1]),median(pwv[good]),string(median(pwv[good]),format='(F4.2)')
;  hline,stddev(pwv[good])+median(pwv[good])
;  hline,median(pwv[good])-stddev(pwv[good])
  if nwhflag GT 0 then oplot,jdate[whflag],pwv[whflag],psym=4,color=2
  
  axis,yaxis=1,yrange=0.0413292*!y.crange+0.00941576,/ysty,ytitle='Tau_225'
  
  plot,jdate,el,$
    xtitle='Days Since Nov 23',ytitle='Elevation',/nodata
  oplot,jdate[good],el[good],psym=4
  if nwhflag GT 0 then oplot,jdate[whflag],el[whflag],psym=4,color=2
  hline,median(el[good])
  
;  plot,daz,del,$
;    xtitle='Most Recent Delta Azimuth',ytitle='Most Recent Delta Elevation',$
;    xrange=[-30,30],yrange=[-30,30],/xsty,/ysty,/nodata
;  oplot,daz[good],del[good],psym=4
;  if nwhflag GT 0 then oplot,daz[whflag],del[whflag],psym=4,color=2
  
  ;hline,median(del[good])+[-stddev(del[good]),0,stddev(del[good])]
  ;vline,median(daz[good])+[-stddev(daz[good]),0,stddev(daz[good])]
  
  plot,jdate,grt,$
    xtitle='Days Since Nov 23',ytitle='GRT [K]',$
    yrange=[0.07,0.15],/ysty,/nodata
  oplot,jdate[good],grt[good],psym=4
  if nwhflag GT 0 then oplot,jdate[whflag],grt[whflag],psym=4,color=2
  hline,median(grt[good])
  xyouts,1,0.08,string(median(grt[good])*1e3,format='(I3)')+' mJy'

  plot,jdate,sens_obs,$
    xtitle='Days Since Nov 23',ytitle='Sensitivity Median Across Band [Jy s!E1/2!N]',$
    yrange=[0,3],/ysty,psym=4
  hline,sens_tot[c]
 
endfor ; All coadds.

; sens_tot is one sensitivity for each COADD list.

; NOW PLOT MORE STUUUUUUFFF

!p.multi=[0,1,2,0,0]
yr=[0,3]

plot,all_grt*1e3,sens_obs_tot,$
  psym=4,yr=yr,$
  xtitle='GRT Temp [mKy]',ytitle='Sensitivity Each Observation [Jy s!E1/2!N]'

plot,all_jdate,sens_obs_tot,$
   psym=4,yr=yr,$
   xtitle='Days Since Nov 23',ytitle='Sensitivity Each Observation [Jy s!E1/2!N]',$
   ysty=9
axis,yaxis=1,yr=[0,5],/save,ytitle='PWV (red)'
oplot,all_jdate[sort(all_jdate)],all_pwv[sort(all_jdate)],color=2

plot,all_pwv,sens_obs_tot,$
   psym=4,yr=yr,$
   xtitle='PWV',ytitle='Sensitivity Each Observation [Jy s!E1/2!N]'

plot,all_el,sens_obs_tot,$
   psym=4,yr=yr,$
   xtitle='Elevation',ytitle='Sensitivity Each Observation [Jy s!E1/2!N]'

plot,all_focusz,sens_obs_tot,$
   psym=4,yr=yr,$
   xtitle='FocusZ',ytitle='Sensitivity Each Observation [Jy s!E1/2!N]


device,/close
set_plot,'x'

spawn,'gv '+psfile+' &'

end
