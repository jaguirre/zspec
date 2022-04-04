
function cal_vec,year,month,night,source,apex=apex

;angular diameter, from JPL planetary ephemeris caculator
;INSTRUCTIONS FOR USING JPL EPHEMERIS (WEB INTERFACE)
;----------------------------------------------------
;1. Go to: http://ssd.jpl.nasa.gov/horizons.cgi
;2. Change settings so the values under "Current Settings" looks like
;   this:
;
;   Ephemeris Type [change] : 	 OBSERVER
;   Target Body [change] : 	 Mars [499]
;   Observer Location [change] : user defined ( 155°28'33.0''W, 19°49'21.0''N, 13300 ft )
;   Time Span [change] : 	 Start=2010-04-24, Stop=2010-04-30, Step=1 d
;   Table Settings [change] : 	 QUANTITIES=13; date/time format=JD; CSV format=YES
;   Display/Output [change] : 	 plain text
;
;   The only things you need to change are:
    ;a) the Time Span Start and Stop dates
    ;b) the Target Body (Mars, Uranus, or Neptune)
    ;c) Observer Location: above is CSO. For APEX use: 67°45'33.0''W, 23°00'20.8''S, 5105 m
;
;3. Click "Generate Ephemeris". Copy the information for the angular
;   diameter and julian dates into PLANETNAME_size_data.dat. Commit
;   changes to .dat file to svn.

;Returns a 160-element vector of flux densities for mars, uranus, or
;neptune (not based on a temperature intermediary, but based on
;calculating directly the solid angle of the planet and convolving it
;with z-spec's beam.

;originally written by MB 2008-05-23

;modified by LE 2008-05-27 to include Neptune and Uranus, and also our
;FTS-measured bandpasses (instead of square).

;modified by KS 2010-05-05 to include calibration for
;winter2009/spring2010.
;08/30/10 - Updated for winter09/spring10, uranus and neptune
;         - Got a makeover to ease addition of information for new
;           observing runs.
;08/31/10 - KSS - Now looks up Mars brightness temperature in an
;           external table.
;09/01/10 - KSS - Uses SMA model for brightness temperature of Uranus
;           and Neptune.
;____________________________________________________
;TURN YEAR,MONTH,NIGHT INTO DATE

date=night+100L*month+10000L*year

;get template to read ascii files
restore, !zspec_pipeline_root+'/calibration/size_template.sav'

;_____________________________________________________
;UNITS ARE ARCSEC

case source of

0:begin ;for Mars

    ;get julian date, angular diameter data
    sizedatfile = !zspec_pipeline_root+'/calibration/Mars_size_data.dat'
    info = read_ascii(sizedatfile, template=size_template)
    daycnv, info.julian_day, yr, mn, day
    yrmnday = yr*10000L + 100L*mn + day
    ang_diam = info.ang_diam
   
    whmatch = where(yrmnday eq date, nmatch)
    if (nmatch eq 0) then message,'Angular diameter for Mars not defined for '+string(date)
    if (nmatch gt 1) then message,'Multiple definitions for angular diameter of Mars for '+string(date)
    mars_size = (ang_diam[whmatch])[0]

end
1:begin ;for Uranus

    ;get julian date, angular diameter data
    sizedatfile = !zspec_pipeline_root+'/calibration/Uranus_size_data.dat'
    info = read_ascii(sizedatfile, template=size_template)
    daycnv, info.julian_day, yr, mn, day
    yrmnday = yr*10000L + 100L*mn + day
    ang_diam = info.ang_diam
   
    whmatch = where(yrmnday eq date, nmatch)
    if (nmatch eq 0) then message,'Angular diameter for Uranus not defined for '+string(date)
    if (nmatch gt 1) then message,'Multiple definitions for angular diameter of Uranus for '+string(date)
    dia_uranus = (ang_diam[whmatch])[0]

end

3:begin ;for Neptune

    ;get julian date, angular diameter data
    sizedatfile = !zspec_pipeline_root+'/calibration/Neptune_size_data.dat'
    info = read_ascii(sizedatfile, template=size_template)
    daycnv, info.julian_day, yr, mn, day
    yrmnday = yr*10000L + 100L*mn + day
    ang_diam = info.ang_diam
   
    whmatch = where(yrmnday eq date, nmatch)
    if (nmatch eq 0) then message,'Angular diameter for Neptune not defined for '+string(date)
    if (nmatch gt 1) then message,'Multiple definitions for angular diameter of Neptune for '+string(date)
    dia_neptune = (ang_diam[whmatch])[0]

end

endcase


;______________________________________________________________________
;RESTORE Z-SPEC'S FTS DATA

   restore,!zspec_pipeline_root+$
     '/line_cont_fitting/ftsdata/normspec_nov.sav'

;_______________________________________________________________________
;GET BRIGHTNESS TEMPERATURES 

case source of

    0: begin    
       ;Mars physical temperature with phase angle corrections per Wright (2007)
        restore, !zspec_pipeline_root+'/calibration/Mars_brightness_temperature.template'
        tempdatafile = !zspec_pipeline_root+'/calibration/Mars_brightness_temperature.dat'
        tinfo = read_ascii(tempdatafile, template=marstemp_template)
        daycnv, (tinfo.jd_mod+2440000.0), yr, mn, day
        yrmnday = yr*10000L + 100L*mn + day
        mars_tb = tinfo.tb_350um
        ;take temperate at 350um, interpolate
        temperature = cspline(yrmnday, mars_tb, date)
        ;and set planet_size
        planet_size=mars_size
   end

   1: begin      

       ;get data from SMA (http://sma1.sma.hawaii.edu/planetvis.html)
       restore, !zspec_pipeline_root+'/calibration/SMA_TB_template.sav'
       tempdatafile = !zspec_pipeline_root+'/calibration/Uranus_brightness_temperature.dat'
       tinfo = read_ascii(tempdatafile, template=sma_tb_template)
       ;interpolate to nu_trim
       temperature = cspline(tinfo.freq, tinfo.tb, nu_trim)

;       ;Uranus temperature from Griffin & Orton (keep code around for reference)
;       a0=-795.694
;       a1=845.179
;       a2=-288.946
;       a3=35.2
;       lambda=3.E5/nu_trim      ;in micron

;       temperature=$
;         a0+a1*(alog10(lambda))+a2*(alog10(lambda))^2.+$
;         a3*(alog10(lambda))^3.

       ;and set planet_size
       planet_size=dia_uranus
   end


   3: begin     

       ;get data from SMA (http://sma1.sma.hawaii.edu/planetvis.html)
       restore, !zspec_pipeline_root+'/calibration/SMA_TB_template.sav'
       tempdatafile = !zspec_pipeline_root+'/calibration/Neptune_brightness_temperature.dat'
       tinfo = read_ascii(tempdatafile, template=sma_tb_template)
       ;interpolate to nu_trim
       temperature = cspline(tinfo.freq, tinfo.tb, nu_trim)

;       ;Neptune temperature from Griffin & Orton (keep code around for reference)
;       a0=-598.901
;       a1=655.681
;       a2=-229.545
;       a3=28.994
;       lambda=3.E5/nu_trim      ;in micron
       
;       temperature=$
;         a0+a1*(alog10(lambda))+a2*(alog10(lambda))^2.+$
;         a3*(alog10(lambda))^3.

       ;and set planet_size
       planet_size=dia_neptune

   end
endcase
   

;_______________________________________________________________________
;NOW GET JY AT EACH FREQUENCY

    beam_size=fwhm_from_beammap(nu_trim)*206265.
    if keyword_set(apex) then beam_size*=(10d/12d)

    flux_density=2.*1.381e-23*temperature/(2.9979e-1/nu_trim)^2*$
         (!dpi/(4.*alog(2)))*beam_size^2*(1-exp(-1*planet_size^2*alog(2)/beam_size^2))$
         /206265.^2 $ ;in W/m^2/Hz
         /1.e-26      ;in Jy      
 
;_______________________________________________________________________
;INTEGRATE OVER EACH CHANNEL

    nbolos=n_e(spec_coadd_norm[*,0])
    flux_int = dindgen(nbolos)
    delnu=mean(nu_trim[1:*]-nu_trim[0:n_e(nu_trim)-2])
    
    for bolo=0L,nbolos-1 do $
      flux_int[bolo]=total(delnu*flux_density*spec_coadd_norm[bolo,*])

return,flux_int

end
















