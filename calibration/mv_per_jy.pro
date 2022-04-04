;This will eventually return a mV/Jy calibration value
;for each detector as a function of the DC voltage.

;For now, it simply ignores the DC voltage input (so you 
;can feed it garbage) and returns the result of spectra_div 
;and cal_vec.

function mv_per_jy,dc_volts,run

;________________________________________________________________
;FOR THIS TEMPORARY SOLUTION, HERE ARE THE VARIABLES 
;YOU NEED TO CHANGE FOR EACH CALIBRATION

unit=0 ;0 is Jy & 1 is K

case run of 
    'apr06':begin
       planet_observation=$
         !zspec_data_root+'/ncdf/20060427/20060427_003_spectra.sav'
       year=2006
       month=4
       night=27
       planet=0  ;Mars
    end
    'dec06':begin
          planet_observation=$
            !zspec_data_root+'/ncdf/20070123/20070123_002_spectra.sav'
          year=2007
          month=1
          night=23
          planet=1

;         planet_observation=$
;           !zspec_data_root+'/ncdf/20061222/20061222_004_spectra.sav'
;         year=2006
;         month=12
;         night=22
;         planet=1  ;Uranus
      end
      'spring07':begin
          planet_observation=$
            !zspec_data_root+'/ncdf/20070506/20070506_041_spectra.sav'
          year=2007
          month=5
          night=6
          planet=0
      end
      else:message,'Please define a calibration observation.'
endcase
;________________________________________________________________

;take the average over nods in the calibrator
restore,planet_observation

if run eq 'dec06' then begin
    caltau=median(rpc_params.tau_225)
;    calelev=$
;      median(read_ncdf(!zspec_data_root+'/ncdf/20061222/20061222_004.nc','elevation'))
     calelev=$
       median(read_ncdf(!zspec_data_root+'/ncdf/20070123/20070123_002.nc','elevation'))
endif

if run eq 'apr06' then begin
    caltau=0.0649 ;from Darren's smoothing code
    calelev=$
      median(read_ncdf(!zspec_data_root+'/ncdf/20060427/20060427_003.nc','elevation'))
endif

if run eq 'spring07' then begin
;    caltau=median(rpc_params.tau_225)
    calelev=$
      median(read_ncdf(!zspec_data_root+'/ncdf/20070506/20070506_041.nc','elevation'))
    median_ut=$
      median(read_ncdf(!zspec_data_root+'/ncdf/20070506/20070506_041.nc','ticks'))/3600.
    caltau=tau225smooth('20070506',median_ut)
endif

spectra_ave,vopt_spectra
jy_per_planet=cal_vec(year,month,night,source=planet,unit=unit)
airmass=1./sin(calelev*(!pi/180.))
trans=exp(-1.*airmass*sky_zspec(caltau))
cali_st=spectra_div(vopt_spectra,jy_per_planet*trans)
cali_arr=cali_st.in1.avespec

return,cali_arr

end
