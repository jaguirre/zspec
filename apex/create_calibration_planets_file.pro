; RL: start considering only calibration observations taken after the
; 23-Nov-2012
;
; JRK added to SVN on 12/3/12
;
; JRK 12/10/12: Can input keyword main_cal_planets=['Uranus','Mars'],
; for example, to determine which planets to use. Default if not set
; is Uranus.
; KSS 12/19/12: Committed latest version to svn.
; KSS 12/19/12: Added Neptune as planet calibrator by default. So now
;               uses both Neptune and Uranus for flux calibration.

;help, logfile  

pro create_calibration_planets_file,main_cal_planets=main_cal_planets

; This is to convert the initial logfile into a structure format
logfile=load_logfile_str()

; DON'T put comments WITHIN the array:
;main_cal_planets = ['Mars', 'Uranus', 'Neptune']
if ~keyword_set(main_cal_planets) then $
  main_cal_planets = ['Uranus','Neptune']
; THE ABOVE LINE must be the only one that starts with
; main_cal_planets = (spaces before don't matter).
output_filename  = !zspec_pipeline_root+'/calibration/calibration_obs_nov12.txt' ; JRK

filename_save_date = !zspec_pipeline_root+'/apex/calibration_scans_dates.sav' ; JRK

; Define the main criteria to select the calibration observations
SCANTYPE_criterion = 'on'       ; integrating on source
DURATION_criterion = 100        ; gt 100 sec
SWITCHINGMODE_criterion = 'WOB' ; with wobler on
DATE_criterion_yyyy = '2012'    ; observations after this date
DATE_criterion_mm   = '11'      ; observations after this date
DATE_criterion_dd   = '23'      ; observations after this date

date_double_yr_threshold = $
  double(DATE_criterion_yyyy)+ $
  double(DATE_criterion_mm)/12.0 + $
  double(DATE_criterion_dd)/12.0/30.0


; Manually removed scans
bad_scans = [101148,$ ;chopper phase error
             100517,100614,$ ;cannot process in flux_calibration.pro
             99493,99494,100537,100656,100848,100989,101160,101323] ;large outliers


;____________________________________________________________________________________________________
; project of interest, E-087.A-0820A-2010
data_all = logfile
;____________________________________________________________________________________________________
; Observations to planets for calibration
;
;print, tag_names(data_all)
;
;YYYYMMDDTHHMMSS PROJECTID SCAN SOURCENAME SCANTYPE RECEIVER BACKEND
;FREQUENCY LINE PWV AZ EL RA DEC CA IE FOCUSX FOCUSY FOCUSZ DURATION
;SWITCHINGMODE REFERENCE JULIANDATE SCANCOMMAND
;SCANCOMMENTS
;__________________________________________________________________________
; Print out all sources observed for this project
;--------------------------------------------------------------------------
;all_sources = strcompress(data_Rob.SOURCE_NAME, /remove_all)
all_sources  = data_all.SOURCENAME
uniq_inx     = uniq(all_sources, sort(all_sources))
uniq_sources = all_sources[uniq_inx]
for j=0, n_elements(uniq_sources)-1 do begin
   print, 'Unique sources: ', uniq_sources[j]
endfor
;
; OUTPUT:

;__________________________________________________________________________
; Print out Planet observations 'on' source
;--------------------------------------------------------------------------
;main_cal_planets = ['Mars', 'Uranus', 'Neptune']
;
; Define filename for the main planet calibration
;
filename = output_filename
;
; Example for how the file is structurised --- DO NOT ASSUME DIFFERENT
;                                              SPACES OR STRUCTURE!
;20110102	406	 Uranus     0
;20110103	423	 Uranus     0
;

save_scan           = lonarr(n_elements(logfile.SCAN))
save_date_double_yr = dblarr(n_elements(logfile.SCAN))
save_date_double_mm = dblarr(n_elements(logfile.SCAN))
kkk = 0

print, ' '
print, '*** Main flux calibrators found within the saved logfile***'
print, ' '
;
; Open a file to write the output
openw, lun, filename, /get_lun
;
for k=0, n_elements(main_cal_planets)-1 do begin

; Identify the scans corresponding to planets
;, on-source
; with intergration times highter than 100 seconds
; with WOBLER
    wobler = strcompress(data_all.SWITCHINGMODE,/remove_all) 
;    print, "WOB: ", string(wobler, format="(a3)")
    
; Define the selection criteria
    inx = where(strcompress(data_all.SOURCENAME,/remove_all) eq main_cal_planets[k] and $
                strcompress(data_all.SCANTYPE,/remove_all) eq SCANTYPE_criterion and $
                data_all.DURATION gt DURATION_criterion and $
                string(wobler, format="(a3)") eq SWITCHINGMODE_criterion)

   if inx ne [-1] then begin
      for j=0, n_elements(inx)-1 do begin
;
; The first observations to Uranus need to be flagged. They are not
; confidently on focus, so better to remove them. 
;
;         if data_all[inx[j]].SCAN gt 400 then begin
;
; A few other flaggings based on a by-eye inspection to the comments
; in each scan

            if where(data_all[inx[j]].SCAN eq bad_scans) eq [-1] then begin

                date = data_all[inx[j]].YYYYMMDDTHHMMSS
                print, date
                uno = '' & dos = '' & tre = ''
                cua = '' & cin = '' & sei = ''
                reads, date, uno, dos, tre, cua, cin, sei, format='(a4,1x,a2,1x,a2,1x,a2,1x,a2,1x,a2)'
                date_double_yr = double(uno)
                date_double_mm = double(dos)+(double(tre)+(double(cua)+(double(cin)+double(sei)/60.0)/60.0)/24.0)/30.0

                if strcompress(data_all[inx[j]].PROJECTID,/remove_all) eq 'E-086.A-0793A-2010' then project = 'SPT'
                if strcompress(data_all[inx[j]].PROJECTID,/remove_all) eq 'E-087.A-0820A-2010' then project = 'ATLAS'
                if strcompress(data_all[inx[j]].PROJECTID,/remove_all) eq 'E-087.A-0397A-2010' then project = 'HERMES'
                if strcompress(data_all[inx[j]].PROJECTID,/remove_all) eq 'C-090.F-9717B-2012' then project = 'INFANTE'
                if strcompress(data_all[inx[j]].PROJECTID,/remove_all) eq 'O-088.F-9328A-2011' then project = 'JOHANSSON' 
                if strcompress(data_all[inx[j]].PROJECTID,/remove_all) eq 'C-090.F-0024A-2012' then project = 'CASASSUS'

                    print, 'TEST: ', data_all[inx[j]].SOURCENAME, ' ', $
                      data_all[inx[j]].YYYYMMDDTHHMMSS, ' ', $
                      data_all[inx[j]].PROJECTID, ' ', $
                      data_all[inx[j]].SCAN, ' ', $
                      data_all[inx[j]].DURATION, '  ', $
                      strcompress(data_all[inx[j]].SCANCOMMENTS, /remove_all)

;                print, uno, ' ' ,dos, ' ' ,tre, ' ' , $
;                  double(DATE_criterion_yyyy), ' ', double(DATE_criterion_mm), ' ', double(DATE_criterion_dd)
;
;                if double(uno) ge double(DATE_criterion_yyyy) and $
;                   double(dos) ge double(DATE_criterion_mm) and $
;                   double(tre) ge double(DATE_criterion_dd) then begin
;
                if date_double_yr+date_double_mm gt date_double_yr_threshold then begin
;
; print the inputs into the file
                    printf, lun, uno+dos+tre, '     ', $ ;Date
                      data_all[inx[j]].SCAN, '     ', $ ;SCAN number
                      data_all[inx[j]].SOURCENAME, '     ', $ ;Planet name
                      1, $      ;intitial flag
                      "   "+project
;; print out the selected scans
;                    print, uno+dos+tre, '     ', $ ;Date
;                      data_all[inx[j]].SCAN, '     ', $ ;SCAN number
;                      data_all[inx[j]].SOURCENAME, '     ', $ ;Planet name
;                      strcompress(data_all[inx[j]].SCANCOMMENTS, /remove_all)

; Save these files for using wobler-to-intrument anngle definitions
                    save_scan[kkk] = data_all[inx[j]].SCAN
                    save_date_double_yr[kkk] = date_double_yr
                    save_date_double_mm[kkk] = date_double_mm
                    kkk = kkk+1

                endif
            endif
;endif
            project = 0
      endfor
   endif
endfor
free_lun, lun

save_scan           = save_scan[0:kkk-1]
save_date_double_yr = save_date_double_yr[0:kkk-1]
save_date_double_mm = save_date_double_mm[0:kkk-1]


;The main differece
; with the previous calibration is the inclusion of Venus.
print, ''
print, '***  Output filename save as: ', filename
print, ''
save, filename=filename_save_date, save_scan, save_date_double_yr, save_date_double_mm, $
  description='It contains main calibrator scans and dates (yr + mm)'
print, '***  Output sav data as: ', filename_save_date
print, ''

end

;
