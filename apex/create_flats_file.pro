pro create_flats_file,QSO=QSO

; JRK 12/3/12 Moved to SVN, originally created by Edo Ibar
; JRK 12/10/12: Added keyword QSO= array of strings to indicate
;  which QSOs to use.  If not specific will use default in the
;  routine.
; KSS 12/19/19: Committed latest version to svn

output_flat_file = !zspec_pipeline_root+'/processing/spectra/coadd_lists/flats_nov2012.txt'
output_flat_file_noextension = 'flats_nov2012' ; just used to print in file.

flagged_scans = [99637,$ ;failed in reduction
                 99554,99556,99575,99576,99584,99585,99588,99589,99678,99679,$
                 99852,99853,99855,99856,99999,100010,101348] ;bad

; In order to obtain this file, you should access to:
; ssh apex@apexmulti.apex-telescope.org 
;PASS = apecs4op                        
; run the windown to observe the logs from APEX 
; apexSearchScansDB & 
; 
; This is to convert the initial logfile into a structure format
;filename    = 'Log_files/save_search_ZSPEC.dat'
;output_file = filename+'.fits' ; this is actually not used
;logfile = create_fitsfile(filename, output_file)

logfile_data = load_logfile_str()
;
;print, tag_names(logfile_data)
;help
;
;YYYYMMDDTHHMMSS PROJECTID SCAN SOURCENAME SCANTYPE RECEIVER BACKEND
;FREQUENCY LINE PWV AZ EL RA DEC CA IE FOCUSX FOCUSY FOCUSZ DURATION
;SWITCHINGMODE REFERENCE JULIANDATE SCANCOMMAND SCANCOMMENTS

; Print out all sources observed for this project
;--------------------------------------------------------------------------
;all_sources = strcompress(data_Rob.SOURCE_NAME, /remove_all)
all_sources  = logfile_data.SOURCENAME
uniq_inx     = uniq(all_sources, sort(all_sources))
uniq_sources = all_sources[uniq_inx]
for j=0, n_elements(uniq_sources)-1 do begin
   print, 'Unique sources: ', uniq_sources[j]
endfor
;
;Unique sources:  Jupiter                
;Unique sources:  Mars                   
;Unique sources:  N/A                    
;Unique sources:  PKS0537-441            
;Unique sources:  PMNJ0210-5101          
;Unique sources:  RECYCLING              
;Unique sources:  SPT_0155-62            
;Unique sources:  SPT_0551-48            
;Unique sources:  Uranus                 
;Unique sources:  test1                  
;Unique sources:  test2                  

scan_type_for_QSO = 'on'
duration_threshold = 200        ;sec

date = logfile_data.YYYYMMDDTHHMMSS

;print, date_for_file

; DON'T put comments within the array.
; There must be only ONE LINE in this file that starts
; with calibrator_QSO_all = (spaces before don't matter).
if keyword_set(QSO) then calibrator_QSO_all=QSO else $
 calibrator_QSO_all = ['PKS0537-441',$
                       'J1229+021',$
                       'J1256-058'];,$
                       ;'0552+398',$
                       ;'J0145-276',$
                       ;'PNM0455-4616',$ 
                       ;'PMNJ0210-5101']


openw, lun, output_flat_file, /get_lun

printf, lun, output_flat_file_noextension
printf, lun, ''
printf, lun, '0.0     (=z unknown)'
printf, lun, ''

for k=0, n_elements(calibrator_QSO_all)-1 do begin

   calibrator_QSO = calibrator_QSO_all[k]
   
   inx = where(strcompress(logfile_data.sourcename, /remove_all) eq calibrator_QSO and $
               strcompress(logfile_data.SCANTYPE, /remove_all) eq scan_type_for_QSO and $
               logfile_data.DURATION gt duration_threshold)
;               strcompress(logfile_data.SCANCOMMENTS, /remove_all) eq '-' and $
;print, logfile_data[inx].source_name
;   print, inx
;
;   print, calibrator_QSO
   for j=0, n_elements(inx)-1 do begin

       inx_flag = where(logfile_data[inx[j]].SCAN eq flagged_scans)
       if inx_flag eq [-1] then begin
           
           uno = '' & dos = '' & tre = ''
           reads, date[inx[j]], uno, dos, tre, format='(a4,1x,a2,1x,a2)'
           
           print, j, ' ',  logfile_data[inx[j]].sourcename, '  ', logfile_data[inx[j]].SCANTYPE, '  ', logfile_data[inx[j]].SCAN, '  ', $
             date[inx[j]],  '  ', logfile_data[inx[j]].DURATION
           printf, lun,  uno+dos+tre, '   ', logfile_data[inx[j]].SCAN, '   ', 1, '   ', 1
       endif
   endfor
   printf, lun, ' '
endfor 
free_lun, lun

end

; After this file is created scp the flat_filename to:
; scp flats_jan2011.txt zspec@wakea.apex-telescope.org:/home/zspec/zspec_svn/processing/spectra/coadd_lists/
; PASS = !!highZco!
;
; open IDL in this directory:
; /home/zspec/zspec_svn/processing/spectra/coadd_lists/
;
; it will fail several times but repeat this until everthing looks
; *really* smooth.
;
;run_zapex, 'flats_jan2011.txt'
;
;'''
;THESE ARE THE FLAGGED PIXELS IDENTIFIED IN THE PREVIOUS 01- CODE
;flags = intarr(160)+1
;flags[0:5]=0
;flags[7]=0
;flags[8]=0
;flags[18]=0
;flags[81]=0
;flags[86]=0
;'''
; make_fitcal_wrapper_apex,'flats_jan2011.txt',/plot_obs,flags=flags
;
;check all .ps files output from this task in:
; /home/zspec/zspec_svn/processing/spectra/coadded_spectra/flats_winter2011/
;
; and flag the observations which did not provide a good calibration
;
; Remove all files from coadded_spectra/flats_winter11 again
;
; then re-run 
; make_fitcal_wrapper_apex,'flats_jan2011.txt',/plot_obs,flags=flags, nthresh=3.0,boloind=boloind,obsind=obsind
;
;
