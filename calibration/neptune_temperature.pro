FUNCTION neptune_temperature, date, apex=apex

;08/30/10 - KSS - Got a makeover to ease addition of information for new
;           observing runs.
;09/01/10 - KSS - Uses SMA model for brightness temperature of Neptune.

;returns a 160-element vector with Neptune's Antenna temp at the CSO for a
;given UT date (YYYYMMDD)

;angular diameter, from JPL planetary ephemeris caculator
;INSTRUCTIONS FOR USING JPL EPHEMERIS (WEB INTERFACE)
;----------------------------------------------------
;1. Go to: http://ssd.jpl.nasa.gov/horizons.cgi
;2. Change settings so the values under "Current Settings" looks like
;   this:
;
;   Ephemeris Type [change] : 	 OBSERVER
;   Target Body [change] : 	 Neptune [799]
;   Observer Location [change] : user defined ( 155°28'33.0''W, 19°49'21.0''N, 13300 ft )
;   Time Span [change] : 	 Start=2010-04-24, Stop=2010-04-30, Step=1 d
;   Table Settings [change] : 	 QUANTITIES=13; date/time format=JD; CSV format=YES
;   Display/Output [change] : 	 plain text
;
;   The only things you need to change are:
    ;a) the Time Span Start and Stop dates
    ;b) Observer Location: above is CSO. For APEX use: 67°45'33.0''W, 23°00'20.8''S, 5105 m
;
;3. Click "Generate Ephemeris". Copy the information for the angular
;   diameter and julian dates into Neptune_size_data.dat. Commit
;   changes to .dat file to svn.

;get template to read ascii files
restore, !zspec_pipeline_root+'/calibration/size_template.sav'

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

   restore,!zspec_pipeline_root+$
     '/line_cont_fitting/ftsdata/normspec_nov.sav'

   fwhm=fwhm_from_beammap(nu_trim)*206265.
if (keyword_set(apex)) then fwhm *= 10.4/12.
   coupling=1.-exp(-(alog(2))*dia_neptune^2./fwhm^2.)

  ;get data from SMA (http://sma1.sma.hawaii.edu/planetvis.html)
   restore, !zspec_pipeline_root+'/calibration/SMA_TB_template.sav'
   tempdatafile = !zspec_pipeline_root+'/calibration/Neptune_brightness_temperature.dat'
   tinfo = read_ascii(tempdatafile, template=sma_tb_template) 
   ;interpolate to nu_trim
   neptune_physical_temp = cspline(tinfo.freq, tinfo.tb, nu_trim)

;   ;Neptune temperature from Griffin & Orton
;   a0=-598.901
;   a1=655.681
;   a2=-229.545
;   a3=28.994
;   lambda=3.E5/nu_trim          ;in micron

;   neptune_physical_temp=$
;     a0+a1*(alog10(lambda))+a2*(alog10(lambda))^2.+$
;          a3*(alog10(lambda))^3.

   t_neptune=neptune_physical_temp*coupling

   ;observed temperature per bret's temp*fts profile calc
   nbolos=n_e(spec_coadd_norm[*,0])
   neptune_temp_int=dindgen(nbolos)
   delnu=mean(nu_trim[1:*]-nu_trim[0:n_e(nu_trim)-2])
   for bolo=0L,nbolos-1 do $
     neptune_temp_int[bolo]=total(delnu*t_neptune*spec_coadd_norm[bolo,*])

  return,neptune_temp_int
end
