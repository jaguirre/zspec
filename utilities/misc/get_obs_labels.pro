;LE 2009-06-25
;This function reads in a list of observations in a coadd list and
;creates an obs_labels structure which has 2 tags:
;
; obs_labels.names = vector of length equal to total number of nods in
; the observations list, and each element is a date/obs# ID correponding to
; each nod
;
; obs_labels.nnods = vector of length equal to number of observations,
; and each element containing the number of nods in the corresponding
; observation
;
; Observations whose flags are set to '0' in the coadd list are excluded.
;
;Note that the obs_labels structure is created by default in the
;uber_spectrum routine and saved in the save file.  This function
;provides a way to get the same information from the coadd list, so
;it's sort of redundant.

function get_obs_labels,coadd_list

coadd_list=!zspec_pipeline_root+'/processing/spectra/coadd_lists/'+coadd_list

readcol,coadd_list,date,obs,flag,format='(a8,a3,i1)',comment=';'

n_obs=n_e(date)

     ;only use observations flagged 1
     wantdata=where(flag eq 1)
     n_obs=n_e(wantdata)
     date=date(wantdata)
     obs=obs(wantdata)

obs_labels=strarr(n_e(obs))

for q=0,n_obs-1 do begin
obs_id=string(date[q],f='(i08)')+'_'+string(obs[q],f='(i03)')
spectrum=!zspec_data_root+'/ncdf/'+date[q]+'/'+obs_id+'_spectra.sav'
restore,spectrum
nnods=n_e(vopt_spectra.in1.nodspec[0,*])
  if q eq 0 then begin
      names=replicate(obs_id,nnods)
      nods_in_obs=nnods
  endif else begin
      names=[names,replicate(obs_id,nnods)]
      nods_in_obs=[nods_in_obs,nnods]
  endelse
endfor

obs_labels=create_struct('names',names,$
                         'nnods',nods_in_obs)

return,obs_labels

end

