; Generate a log for a given night from whatever obs_def files exist,
; using only the obs_def and rpc files (don't need to have run
; save_spectra)

; This can also create a text file and save file 

pro logbook, date, text = text, save = save, struct = struct

date_str = strcompress(date,/rem)

textfile = !zspec_data_root+'/ncdf/'+date_str+'/log_'+date_str+'.txt'
savfile = !zspec_data_root+'/ncdf/'+date_str+'/log_'+date_str+'.sav'

obs_def_files = $
  file_search(!zspec_data_root+'/ncdf/'+date_str+'/*obs_def.txt')
nfiles = n_e(obs_def_files)

date_list = strarr(nfiles)
obsnum_list = lonarr(nfiles)
utc_list = dblarr(nfiles)
hst_list = dblarr(nfiles)
source_list = strarr(nfiles)
fazo_list = dblarr(nfiles)
fzao_list = dblarr(nfiles)
tau_list = dblarr(nfiles)

log = replicate(create_struct('date',' ',$
                              'obs',0L,$
                              'utc',0.d,$
                              'hst',0.d,$
                              'source',' ',$
                              'chop_freq',0.d,$
                              'chop_throw',0.d,$
                              'fazo',0.d,$
                              'fzao',0.d,$
                              'tau_225',0.d),nfiles)

logstr = strarr(nfiles+2)

openw,lun,textfile,/get_lun

; The goofy space at the beginning is to make it easier to paste these
; things into the wiki page in a fixed format
printf,lun,' '+date_str
logstr[0] = ' '+date_str
printf,lun,' Obs','UTC','HST','Source','FAZO','FZAO','tau_225','BSW Frq','BSW Amp',$
  format='(A-6,A-7,A-7,A-27,A-8,A-8,A-10,A-11,A-10)'
logstr[1] = string(' Obs','UTC','HST','Source','FAZO','FZAO','tau_225','BSW Frq','BSW Amp',$
  format='(A-6,A-7,A-7,A-27,A-8,A-8,A-10,A-11,A-10)')

for i=0,nfiles-1 do begin

    temp = strsplit(obs_def_files[i],'/',/extract)
    date = temp[n_e(temp)-2]
    year = long(strmid(date,0,4))
    month = long(strmid(date,4,2))
    night = long(strmid(date,6,2))
    obsnum = long((strsplit(temp[n_e(temp)-1],'_',/extract))[0])

    obsdef = read_obsdef(year, month, night, obsnum)

    rpcfile = !zspec_data_root+'/rpc/'+date+'/'+date+'_'+$
      make_padded_num_str(obsdef.min[0],4)+'_rpc.bin'

    if (file_search(rpcfile) eq '') then $
      rpcfile = !zspec_data_root+'/rpc/'+date+'/'+date+'_'+$
      make_padded_num_str(obsdef.min[0]+1,4)+'_rpc.bin'

    rpc = read_rpc(rpcfile)
; Why aren't rpc.elevation and rpc.azimuth correct?

; Find the nearest time to the beginning of the observation
    utc0 = obsdef.utc[0]/3600.d
    wht = find_nearest(rpc.coordinated_universal_time,utc0)
; Go 5 seconds into the observation in question
    wht = min([wht[0]+5L,n_e(rpc.tm_sec)-1])

    log[i].date = date
    log[i].obs = obsnum

    log[i].utc = utc0
    utc_disp = sixty(utc0)
    hst0 = utc0 - 10.d
    if (hst0 lt 0.) then hst0 += 24.
    hst_disp = sixty(hst0)
    log[i].hst = hst0

    log[i].source = string(rpc[wht].source_name)
    log[i].tau_225 = rpc[wht].tau_225
    log[i].fazo = rpc[wht].azimuth_fixed_offset
    log[i].fzao =rpc[wht].elevation_fixed_offset

    log[i].chop_freq = rpc[wht].beam_switch_frequency
    log[i].chop_throw = rpc[wht].beam_switch_amplitude

    printf,lun,log[i].obs,utc_disp[0],utc_disp[1],$
      hst_disp[0],hst_disp[1],log[i].source,$
      log[i].fazo,log[i].fzao,log[i].tau_225,$
      log[i].chop_freq,log[i].chop_throw,$
      format='(I4,"  ",I02,":",I02,"  ",I02,":",I02,"  ",A-25,"  ",'+$
      'F6.1,"  ",F6.1,"  ",F5.3,"  ",F8.3,"  ",F8.1)'

    logstr[i+2] = string(log[i].obs,utc_disp[0],utc_disp[1],$
      hst_disp[0],hst_disp[1],log[i].source,$
      log[i].fazo,log[i].fzao,log[i].tau_225,$
      log[i].chop_freq,log[i].chop_throw,$
      format='(I4,"  ",I02,":",I02,"  ",I02,":",I02,"  ",A-25,"  ",'+$
      'F6.1,"  ",F6.1,"  ",F5.3,"  ",F8.3,"  ",F8.1)')

endfor

close,lun
free_lun,lun

;if keyword_set(save) then 
save,log,file=savfile

struct = log

print
for i=0,n_e(logstr)-1 do print,logstr[i]

end
