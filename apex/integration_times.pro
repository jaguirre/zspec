
pro integration_times

; Created by Edo Ibar, moved into SVN by JRK 12/3/12
;
; JRK Dec 3 2012: The three files that make coadd lists for us need
;  to be manually updated to include all planet calibration, spectral flat
;  sources (QSOs) and science targets (actually, defines what is NOT a science
;  target).  To avoid mistakes, read each of those files to check
;  that all types of sources are accounted for.

flagged_scans = [-1]
flagged_source_names = ['N/A','fake','test1','test2', 'RECYCLING']

;--------------------------------------------------------------------------
; See wiki for instructions on updating the logfile.
logfile_data = load_logfile_str()
;--------------------------------------------------------------------------
;

;--------------------------------------------------------------------------
; Print out all sources observed for this project                    
;--------------------------------------------------------------------------
; Get all unique sources
all_sources  = logfile_data.SOURCENAME
uniq_inx     = uniq(all_sources, sort(all_sources))
uniq_sources = all_sources[uniq_inx]
HATLAS_targets_all = uniq_sources ; Used for the integration time table.

; For each source, flag 0 or 1 for the following:
;   - Calibration Planet
;   - Spectral Flat
;   - Target
tableflags=bytarr(n_e(uniq_sources),3)
createfiles=!zspec_pipeline_root+'/apex/'+['create_calibration_planets_file.pro','create_flats_file.pro','create_target_files.pro']
createphrase=['main_cal_planets=','calibrator_QSO_all=','flagged_source_names=']

for i=0, 2 do begin
    lines=file_lines(createfiles[i])
    createlines=strarr(lines)
    openr,lun,createfiles[i],/get_lun
    readf,lun,createlines
    close,lun & free_lun,lun

    start=where(strpos(strcompress(createlines,/remove_all),createphrase[i]) EQ 0 and $
         strpos(strcompress(createlines,/remove_all),';') NE 0,nstart) ; Commented out lines.
    if nstart NE 1 then message,'Error identifying which lines contain '+createphrase[i]+' in '+createfiles[i]+'.'
    
    fin=start+min(where(strpos(strcompress(createlines[start:start+20],/remove_all),']') NE -1)) ; The first instance where we find ]
    createlist=strsplit(strjoin(createlines[start:fin]),'[]',/extract)
    ;if n_e(createlist) NE 2 then message,'Error splitting string.'
    createlist=createlist[1]
    createlist=strsplit(createlist,"',$",/extract)

    for j=0, n_e(createlist)-1 do begin
      temp=strpos(strcompress(uniq_sources,/remove_all),createlist[j])
      usetemp=where(temp NE -1, nusetemp)
      if nusetemp GT 0 then tableflags[usetemp,i]=1
    endfor
endfor

print, ' '
print, '*** The list of sources that have been observed ***'
print, ' '
k=0
for j=0, n_elements(uniq_sources)-1 do begin
    stradd=''
    if tableflags[j,2] EQ 0 then stradd+='Target. ' else stradd+='        Flagged as not target. '
    if tableflags[j,0] EQ 1 then stradd+='Planet Cal. '
    if tableflags[j,1] EQ 1 then stradd+='Flat QSO. '

    inds=where(strcompress(logfile_data.sourcename,/remove_all) EQ strcompress(uniq_sources[j],/remove_all))
    if total(strpos(strcompress(logfile_data[inds].scantype,/remove_all),'point')) EQ 0 then stradd+='Point. '

    inx_flag = where(strcompress(uniq_sources[j], /remove_all) eq flagged_source_names)
    if inx_flag eq [-1] then begin
        print, 'Source: ', uniq_sources[j],stradd
        HATLAS_targets_all[k] = uniq_sources[j]
        k=k+1
    endif else begin
        print, 'Source: ', HATLAS_targets_all[j],stradd,'*** ignored'
    endelse
endfor
HATLAS_targets_all = HATLAS_targets_all[0:k-1]

;--------------------------------------------------------------------------
; Print out target observations 'on' source
;--------------------------------------------------------------------------

scan_type_for_target = 'on'
date_for_file = string(logfile_data.YYYYMMDDTHHMMSS, format='(a10)')
;print, logfile_data.SCAN_TYPE

for k=0, n_elements(HATLAS_targets_all)-1 do begin

   target = HATLAS_targets_all[k]
   
   inx = where(strcompress(logfile_data.sourcename, /remove_all) eq strcompress(target, /remove_all) and $
               strcompress(logfile_data.SCANCOMMENTS, /remove_all) eq '-' and $
               strcompress(logfile_data.SCANTYPE, /remove_all) eq scan_type_for_target and $
               logfile_data.DURATION ne 0,ninx)

   if inx ne [-1] then begin
      proj=strarr(ninx)
      for j=0, ninx-1 do begin
       case strtrim(logfile_data[inx[j]].projectID,2) of
          'E-086.A-0793A-2010': proj[j] = 'SPT'
          'E-087.A-0820A-2010': proj[j] = 'ATLAS'
          'E-087.A-0397A-2010': proj[j] = 'HERMES'
          'C-090.F-9717B-2012': proj[j] = 'INFANTE'
          'O-088.F-9328A-2011': proj[j] = 'JOHANSSON' 
          'C-090.F-0024A-2012': proj[j] = 'CASASSUS'
          else: proj[j]='Update project list in integration_times.pro'
       endcase
      endfor
       tproj=proj[uniq(proj, sort(proj))]
       
       print, target, total(logfile_data[inx].DURATION)/3600.0,'  ',tproj
   endif

endfor
print, ''

end
