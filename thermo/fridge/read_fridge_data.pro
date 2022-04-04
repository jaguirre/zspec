; 2nd input can now be an array of indicies which are concatenated together

; 02 Apr 07 - BN - Copied keywords from parse_labview_date_time

function read_fridge_data, cooldown_number, indicies, directory = directory, $
                           from_start = from_start, $
                           hours = hours, minutes = minutes, $
                           seconds = seconds
                           

if (not(keyword_set(directory))) then directory = './'

output_labels = strlowcase(['saltpill', $ 
                            'he3pot', $
                            'he4Pot', $
                            'HeShield', $ 
                            'HeColdPlate', $ 
                            'N2Shield', $ 
                            'cables4k', $ 
                            'PerSwitch', $ 
                            'Pressure', $
                            'he4Pump', $ 
                            'he3Pump', $ 
                            'he4PumpHS', $ 
                            'he3PumpHS', $ 
                            'hs400mk', $ 
                            'he3potHS' ])

; These are almost the labels in the .dat files, except that I had to
; edit some to make them conform to IDL's structure naming convention
calib_labels = strlowcase(['SaltPillBadReadTime', $ 
                           'SaltPillBadTemp', $ 
                           'SaltPillBad', $ 
                           'SaltPillReadTime', $ 
                           'saltpill', $ 
                           'SaltPillRes', $ 
                           'he3potReadTime', $ 
                           'he3pot', $ 
                           'he3potRes', $ 
                           'he3BoxReadTime', $ 
                           'he3BoxTemp', $ 
                           'he3BoxRes', $ 
                           'he4PotReadTime', $ 
                           'he4Pot', $ 
                           'he4PotRes', $ 
                           'FanOutAReadTime', $ 
                           'FanOutATemp', $ 
                           'FanOutARes', $ 
                           'FanOutIReadTime', $ 
                           'FanOutITemp', $ 
                           'FanOutIRes' ])

diode_labels = strlowcase(['DiodeReadTime', $
                           'JFETs', $ 
                           'HeShield', $ 
                           'HeColdPlate', $ 
                           'N2Shield', $ 
                           'cables4k', $ 
                           'PerSwitch', $ 
                           'PressureReadTime', $ 
                           'Pressure'])

fridge_labels = strlowcase(['CarbonReadTime', $ 
                            'he4Pump', $ 
                            'he3Pump', $ 
                            'he4PumpHS', $ 
                            'he3PumpHS', $ 
                            'hs400mk', $ 
                            'he3potHS'])

; Restore the templates for the files
restore,!zspec_pipeline_root+'/thermo/fridge/fridge_file_templates.sav',$
  /verb

FOR ind = 0, N_E(indicies)-1 DO BEGIN
   index = indicies[ind]

; Define the file names
   calib_file = directory + '/' + $
                string('Cooldown',cooldown_number,'.Calibrated.',index,'.dat',$
                       format= '(A,I3.3,A,I3.3,A)')
   diode_file = directory + '/' + $
                string('Cooldown',cooldown_number,'.Diodes.',index,'.dat',$
                       format= '(A,I3.3,A,I3.3,A)')
   fridge_file = directory + '/' + $
                 string('Cooldown',cooldown_number,'.FridgeSensors.', $
                        index,'.dat',$
                        format= '(A,I3.3,A,I3.3,A)')

   print,calib_file

; Read the calibrated data.
   calib = read_ascii(calib_file,templ=calib_templ)
   diode = read_ascii(diode_file,templ=diode_templ)
   fridge = read_ascii(fridge_file,templ=fridge_templ)
;   if ind eq 14 then stop
   ; Concatenate data
   IF ind EQ 0 THEN BEGIN
      allcalib = calib
      alldiode = diode
      allfridge = fridge
   ENDIF ELSE BEGIN
      allcalib = concat_struct(allcalib,calib)
      alldiode = concat_struct(alldiode,diode)
      allfridge = concat_struct(allfridge,fridge)
   ENDELSE
ENDFOR
calib = allcalib
diode = alldiode
fridge = allfridge
   
; Use salt pill read time to get valid points
goodpts = get_validpts_from_readtimes(calib.(3))

; Use DiodeReadTime for time varible
tv = calib.(3)[goodpts] 
; not strictly accurate for calibrated sensors, but should be good enough
time = parse_labview_date_time(tv, $
                               from_start = from_start, $
                               hours = hours, minutes = minutes, $
                               seconds = seconds)

wh_calib = where_arr(calib_labels,output_labels)
wh_diode = where_arr(diode_labels,output_labels)
wh_fridge = where_arr(fridge_labels,output_labels)

data = create_struct('time',time,$
                     'timestr',tv)

if (wh_calib[0] ne -1) then begin
    for i=0,n_e(wh_calib)-1 do begin
        data = create_struct(data, $
                             calib_labels[wh_calib[i]],$
                             calib.(wh_calib[i])[goodpts])
    endfor
endif

if (wh_diode[0] ne -1) then begin
    for i=0,n_e(wh_diode)-1 do begin
        data = create_struct(data, $
                             diode_labels[wh_diode[i]],$
                             diode.(wh_diode[i])[goodpts])
    endfor
endif

if (wh_fridge[0] ne -1) then begin
    for i=0,n_e(wh_fridge)-1 do begin
        data = create_struct(data, $
                             fridge_labels[wh_fridge[i]],$
                             fridge.(wh_fridge[i])[goodpts])
    endfor
endif

return, data

end
