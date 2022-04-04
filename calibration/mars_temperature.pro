;April 2008 update by MB and LE
;incorporates phase-angle dependent Mars temperatures 
;per model by Wright (astro-ph/0703640).
;INSTRUCTION FOR GETTING MARS TEMPERATURE:
;***OLD - no longer need to do this step*** (08/31/10)
;-----------------------------------------
;1. Go to: http://www.astro.ucla.edu/~wright/old_mars.txt for the table
;2. Compute modified julian date for days you'll be observing as follows:
;   IDL> mjd = julday(MM, DD, YYYY) - 2440000
;3. Use 1st and last columns in the table to select Mars brightness
;   temperature over appropriate range in UT Date, and fill in
;   information below.

;Feb 2008 update by LE
;Now uses fwhm_from_beamap.pro to use beam widths derived from
;beam maps taken at the telescope.

;11/7/06 Updated to use freqid2freq & freqid2bw functions
;04/20/10 - KSS - Updated temperatures and angular diameters for
;           upcoming Apr/May 2010 observing run. Added instructions
;           for doing this in header for future observers.
;08/30/10 - KSS - Got a makeover to ease addition of information for new
;           observing runs.
;08/31/10 - KSS - Now looks up Mars brightness temperature in an
;           external table.
;11/11/11 - ES (note by KSS) - fixed bug in beam size for apex

function mars_temperature,date,apex=apex

;returns antenna temperature of mars for a given UT date for the April 2006
;zspec run, takes UT date as argument    MB 18APR06

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
    ;b) Observer Location: above is CSO. For APEX use: 67°45'33.0''W, 23°00'20.8''S, 5105 m
;
;3. Click "Generate Ephemeris". Copy the information for the angular
;   diameter and julian dates into Mars_size_data.dat. Commit
;   changes to .dat file to svn.

;get template to read ascii files
restore, !zspec_pipeline_root+'/calibration/size_template.sav'

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

;Mars physical temperature with phase angle corrections per Wright (2007)
restore, !zspec_pipeline_root+'/calibration/Mars_brightness_temperature.template'
tempdatafile = !zspec_pipeline_root+'/calibration/Mars_brightness_temperature.dat'
tinfo = read_ascii(tempdatafile, template=marstemp_template)
daycnv, (tinfo.jd_mod+2440000.0), yr, mn, day
yrmnday = yr*10000L + 100L*mn + day
mars_tb = tinfo.tb_350um
;take temperate at 350um, interpolate
mars_physical_temp = cspline(yrmnday, mars_tb, date)

; USE FTS response to refine calibration calculation
RESTORE, !ZSPEC_PIPELINE_ROOT + $
         '/line_cont_fitting/ftsdata/normspec_nov.sav'

;beam size based on fits to beammaps at telescope (LE Feb 2008)
beam_size=fwhm_from_beammap(nu_trim)*206265.
;This can't have ever worked! (ES 11 Nov 2011)
;if (keyword_set(apex)) then fwhm *= 10.4/12.
if (keyword_set(apex)) then beam_size *= 10.4/12.

; From convolution of zspec's gaussian beam & mars' top-hat angular shape
mars_temp=(1-exp(-1.*mars_size^2*alog(2)/beam_size^2)) * mars_physical_temp

; Integrate mars_temp * fts profile for each channel to get observed
; mars temperature
nbolos = N_E(spec_coadd_norm[*,0])
mars_temp_int = DINDGEN(nbolos)
delnu = MEAN(nu_trim[1:*]-nu_trim[0:N_E(nu_trim)-2])
FOR bolo = 0L, nbolos - 1 DO $
   mars_temp_int[bolo] = TOTAL(delnu*mars_temp*spec_coadd_norm[bolo,*])

return,mars_temp_int
end
