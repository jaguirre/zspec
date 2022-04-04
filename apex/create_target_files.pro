
pro create_target_files

; Originally by Edo Ibar, moved to SVN by JRK 12/3/12
;
; JRK 12/5/12: Changed flats to flats_nov2012_1
; KSS 12/19/12: Committed latest version to svn

;HATLAS_targets_all = ['SPT_0155-62', 'SPT_0551-48']
;flagged_scans = [99081, 99091, 99096, 99276, 99284,$
;                 99320, 99335, 99517, 99525, 99548]


flagged_scans = [99081, 99091, 99096, 99276, 99284, 99603, 99608, 99100, $ 
                 99320, 99335, $
                 99493, 99494, $
                 99517, 99525, 99548, 99589, $
                 99631, 99644, 99637,$
                 99775, $
                 99807, 99823, 99793, 99814, 99855, $
                 99946, 99966, 99942, 99999, $
                 99950, 99951, 99668, 99685, $
                 100010,100016,100292,100285,100371,100141,100156,$
                 99981, 100265,100103,100095,100099,100271,101204,$
                 100691,100693,101452,101388,101389,101623] 

; DON'T put comments WITHIN the array:
flagged_source_names = ['N/A','fake','test1','test2', 'RECYCLING', $
                        '0552+398','CRL618','J0145-276','J0854+201','J1229+021',$
                        'J1256-058','J2258-280',$
                        'Jupiter','Mars',$
                        'PKS0537-441','Uranus',$
                        'PMNJ0210-5101','PMNJ0455-4616',$
                        'J2357-532']

;--------------------------------------------------------------------------
; See the wiki for how to update the logfile.
logfile_data = load_logfile_str()
;--------------------------------------------------------------------------
;
;print, tag_names(logfile_data)

;--------------------------------------------------------------------------
restore,  !zspec_pipeline_root+'/apex/calibration_scans_dates.sav'
; save_scan, save_date_double_yr, save_date_double_mm

print, 'TEST'
print, save_scan
print, save_date_double_yr
print, save_date_double_mm
;--------------------------------------------------------------------------


;--------------------------------------------------------------------------
; Print out all sources observed for this project                    
;--------------------------------------------------------------------------
all_sources  = logfile_data.SOURCENAME
uniq_inx     = uniq(all_sources, sort(all_sources))
uniq_sources = strcompress(all_sources[uniq_inx], /remove_all)
HATLAS_targets_all = uniq_sources
print, ' '
print, '*** The list of sources that have been observed ***'
print, ' '
k=0
for j=0, n_elements(uniq_sources)-1 do begin
    inx_flag = where(uniq_sources[j] eq flagged_source_names)
    if inx_flag eq [-1] then begin
        print, 'Source: ', uniq_sources[j]
        HATLAS_targets_all[k] = uniq_sources[j]
        k=k+1
    endif else begin
        print, 'Source: ', HATLAS_targets_all[j], '       *** ignored'
    endelse
endfor
HATLAS_targets_all = HATLAS_targets_all[0:k-1]

;--------------------------------------------------------------------------
; Print out target observations 'on' source
;--------------------------------------------------------------------------

scan_type_for_target = 'on'
date_for_file = string(logfile_data.YYYYMMDDTHHMMSS, format='(a10)')
;print, logfile_data.SCAN_TYPE

;QSO_flat_filename = ' ' ;without the .txt !!!
QSO_flat_filename = 'flats_nov2012_1' ;without the _calcor.sav !!!

print, ''

for k=0, n_elements(HATLAS_targets_all)-1 do begin

   target = HATLAS_targets_all[k]
   
   target_filename = !zspec_pipeline_root+'/processing/spectra/coadd_lists/'+target+'_nov2012.txt'

   openw, lun, target_filename, /get_lun
   printf, lun, target
   printf, lun, ''
   printf, lun, '0.0     (=z unknown)'
   printf, lun, ''

   inx = where(strcompress(logfile_data.sourcename, /remove_all) eq target and $
               strcompress(logfile_data.SCANCOMMENTS, /remove_all) eq '-' and $
               strcompress(logfile_data.SCANTYPE, /remove_all) eq scan_type_for_target and $
               logfile_data.DURATION ne 0)
;   print, ''
;   print, HATLAS_targets_all[k]
;   print, ''

   if inx ne [-1] then begin
;      print, logfile_data[inx].source_name
      
;   print, target
      for j=0, n_elements(inx)-1 do begin
;
; rename the date
         date = logfile_data[inx[j]].YYYYMMDDTHHMMSS
         uno = '' & dos = '' & tre = ''
         cua = '' & cin = '' & sei = ''
         reads, date, uno, dos, tre, cua, cin, sei, format='(a4,1x,a2,1x,a2,1x,a2,1x,a2,1x,a2)'
         date_double_yr = double(uno)
         date_double_mm = double(dos)+(double(tre)+(double(cua)+(double(cin)+double(sei)/60.0)/60.0)/24.0)/30.0
;
;         if uno+dos+tre eq '20121126' then scan_wob_cal_scan = 99067
;         if uno+dos+tre eq '20121127' then scan_wob_cal_scan = 99269
;         if uno+dos+tre eq '20121128' then scan_wob_cal_scan = 99294
;         if uno+dos+tre eq '20121129' then scan_wob_cal_scan = 99499
;         if uno+dos+tre eq '20121130' then scan_wob_cal_scan = 99626
;         if uno+dos+tre eq '20121201' then scan_wob_cal_scan = 99769

;;--------------------------------------------------------------------------
;restore, 'scans_and_dates.sav'
;; save_scan, save_date_double_yr, save_date_double_mm
;;--------------------------------------------------------------------------

;save_scan, save_date_double_yr, save_date_double_mm
         dist_time = abs((date_double_yr+date_double_mm) - (save_date_double_yr+save_date_double_mm))
         inx_min_dist = where(dist_time eq min(dist_time))
         scan_wob_cal_scan = save_scan[inx_min_dist[0]]

;         print,  uno+dos+tre, '   ', logfile_data[inx[j]].SCAN, '   ', 1, '   ', scan_wob_cal_scan, '   ', QSO_flat_filename

         inx_flag = where(logfile_data[inx[j]].SCAN eq flagged_scans)
         if inx_flag eq [-1] then flag_val = 1 else flag_val = 0

;; Print the file
         printf, lun,  uno+dos+tre, '   ', logfile_data[inx[j]].SCAN, '   ', flag_val, '   ', scan_wob_cal_scan, '   ', QSO_flat_filename

;; Print to the screen
;         print,  strcompress(logfile_data[inx[j]].source_name, /remove_all), '   ', $
;                 strcompress(logfile_data[inx[j]].SCAN_TYPE, /remove_all), '   ', $
;                 strcompress(logfile_data[inx[j]].SCAN, /remove_all), '   ', $
;                 logfile_data[inx[j]].DURATION, '   ', $
;                 strcompress(logfile_data[inx[j]].SCAN_COMMENTS, /remove_all), '   ', $
;                 logfile_data[inx[j]].YYYY_MM_DDTHH_MM_SS
      endfor
;      printf, lun, ' '
   endif
   free_lun, lun

   print, 'OUTPUT FILE = ', target_filename

endfor
print, ''


;print, 'Copy these output files to wakea:'
;print, 'scp *_winter2011.txt zspec@wakea.apex-telescope.org:/home/zspec/zspec_svn/processing/spectra/coadd_lists/'
;print, ''
;print, 'then zapex the scans that have not been analysed'
;print, ''
;print, "run_zapex, 'G12-29_winter2011.txt', proj='ATLAS'"
;print, ''
;print, 'then run uber_spectrum on the files, for example'
;print, ''
;print, "uber_spectrum, 'G9-97_winter2011.txt', /apex"
;print, ''
;print, 'Note that I had to modify the get_cal function in order to match the calibration filename'
;print, 'I think this could be fixed by using a different ,mean_calfile_basename while wrapping flat calibrations'
;print, ''
;print, 'anyway, after it finishes, copy-paste the output filename, including the directory, e.g.'
;print, ''
;;print, "plot_uber_spectrum_jk, 'G9-40/G9-40_20111123_2303.sav', /plot_sig, /plot_sens, 'plot.ps'"
;print, ''
;print, 'VOILA!'
;print, ''

end


