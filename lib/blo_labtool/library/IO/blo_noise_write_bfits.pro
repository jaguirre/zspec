;+
;==========================================================================================
; NAME: 		  
;			  BLO_NOISE_WRITE_BFITS
;
; DESCRIPTION:  	  
;			  Write noise data to binary table FITS format file
;
; USAGE: 		  
;			  BLO_NOISE_WRITE_BFITS, filename, $
;               	  run_info, sample_info, paramline, $
;               	  \ colname1, colname2, data
;
; INPUT:
;   filename    	  (string) filename
;   run_info        	  (string array)
;                   	   1. date of measurement format: MM/DD/YYYY HH:MM:SS
;                   	   2. name of data acquisition program used
;                   	   3. 'AIDS'
;                   	   4. telescope name
;   sample_info 	  not used
;   paramline   	  (array string) [number of samples, $
;			  		  readout frequency [Hz], sample time[s] ]
;               	   
;   colname1    	  string with TAB separated identifiers of the
;               	  columns in the data array
;   colname2    	  A string with the TAB separated names of the
;               	  columns in the data array
;   data        	  (float array) [ncol,nrow]
;
; OUPUT: 
;	                  File content will be coded as binary tables.
;	                  Units and column names follow the standard FITS definition.
;
; KEYWORDS:
;    loadcrv  		  if set the FILETYPE keywords is set to LOADCRV
;               	  The FILEORIG keyword is set to BIASSTEP to indicate
;               	  processed file contents
;    dasgain		  If set the dasgain will be written to the fits header
;    temperature_channel  If set, the bath temperature channel will be written to the header
;		  	  If set, the bias channel will be written to the fits file hearder
;    bias_channel
;
;
;  Author:
;			  Bernhard Schulz (IPAC)
;
;  Remarks:
;        Need at least 2002 Dec 11 version of fxbwritem.pro  in astrolib !
;
; Uses
;    astrolib June 2002 or later
;        us_daylswitch.pro
;        blo_sepfilepath.pro
;        blo_sepfileext.pro
;
;
;  Edition History:
;
;  Date		Programme   Remarks
;  2003/01/23   B. Schulz   from FITS_BODAC_CONVERT.PRO
;  2003/02/01   B. Schulz   parameter passing via strarr only
;  2003/03/14   B. Schulz   loadcrv keyword added
;  2003/08/08   L. Zhang    Add a keyword: dasgain.
;  2003/08/14   L. Zhang    Add keyword: temperature_channel, 
;                           bias_channel                     
;  2004/07/29   B. Schulz   manage dates without AM/PM entry 
;      
;===========================================================================
;-
pro blo_noise_write_bfits, filename, $
                  run_info, sample_info, paramline, $
                  colname1, colname2, data, loadcrv=loadcrv, dasgains=dasgains,$
                  temperature_channel=temperature_channel, bias_channel=bias_channel


nrow = n_elements(data(0,*))       ;determine number of rows
ncol = n_elements(data(*,0))       ;determine number of columns


 
@fxbintable                        ;FITS library common definitions

;--------------------------------------------------
; construct primary header


fxhmake, hd, /initialize, /extend

fxaddpar, hd, 'ORIGIN', 'JPL/NASA', 'Jet Propulsion Laboratory/NASA'
fxaddpar, hd, 'TELESCOP', run_info(3), 'Data acquisition system'

blo_sepfilepath, filename, fname, path          ;remove path from filename
fxaddpar, hd, 'FILENAME', fname, 'File name'    ;write only filename to header

get_date, dte, /timetag
fxaddpar, hd, 'DATE', dte, 'Date of file creation (UT)

;extract and convert date assuming it is in PST
; first check if date available
if strpos(run_info[0], '/') GE 0 then begin

  dte     = strsplit(run_info[0],/extract)
  if n_elements(dte) EQ 2 then dte = [dte,'AM'] $
  else dte = dte[n_elements(dte)-3:*]
  
  spldate = fix(strsplit(dte[0],'/',/extract))
  spltime = float(strsplit(dte[1],':',/extract))
  spldate[0] = strmid(spldate[0], strlen(spldate[0])-2, 2)    ;cut string before month

  fxaddpar, hd, 'DATEPST', string(format='(i4.4,"-",i2.2,"-",i2.2)', $
        spldate[2], spldate[0], spldate[1]) , 'Original date string (PST)'

  fxaddpar, hd, 'TIMEPST', string(format='(i2.2,":",i2.2,":",i2.2, " ", a2)', $
        spltime[0], spltime[1], spltime[2], dte[2]) , 'Original time string (PST)'

;convert to UT

  juldate, [spldate(2), spldate(0), spldate(1), $
      spltime(0), spltime(1), spltime(2)], juliand


  if dte[2] EQ 'PM' then juliand = juliand + 0.5

  juliand = juliand + 8./24. $                ;convert to UT
           + 2400000.D     $                ;convert to unreduced Julian date
           - us_daylswitch(spldate[2], spldate[0], spldate[1], $
                           ten(spltime[0], spltime[1], spltime[2]))/24.
                                            ;adjust for daylight savings time
    
  daycnv, juliand, yr, mn, day, hr            ;make calendar days
  hrs = sixty(hr)                             ;make hours minutes seconds

  fxaddpar, hd, 'DATE-OBS', string(format='(i4.4,"-",i2.2,"-",i2.2,"T"' + $
                                        ',i2.2,":",i2.2,":",i2.2)', $
          yr, mn, day, hrs[0], hrs[1], hrs[2]) , 'Data creation date (UT)'
endif

;--------------------------------------------------
if keyword_set(loadcrv) then begin 
  filetype = 'LOADCRV'
  comment1 = 'Bolometer voltage versus bias voltage'
  fileorig = 'BIASSTEP'
  comment2 = 'Averaged bias plateaux'
endif else begin
  filetype = 'NOISE'
  comment1  = 'Detector signal versus time'
  fileorig = 'ORIGINAL'
  comment2 = 'Original file'
endelse



fxaddpar, hd, 'FILETYPE', filetype, comment1
fxaddpar, hd, 'FILEORIG', fileorig, comment2

if strpos(strlowcase(run_info[0]), 'concat') GE 0 then $
fxaddpar, hd, 'FILEORIG', 'CONCAT',             'Derived from concatenated files'
if strpos(strlowcase(run_info[0]), 'average') GE 0 then $
fxaddpar, hd, 'FILEORIG', 'AVERAGE',            'Derived from averaged files'
if strpos(strlowcase(run_info[0]), 'pow') GE 0 then $
fxaddpar, hd, 'FILEORIG', 'POWERSP',            'Power spectrum'
if strpos(strlowcase(run_info[0]), 'hist') GE 0 then $
fxaddpar, hd, 'FILEORIG', 'HISTOG',            'Histogram'

fxaddpar, hd, 'CODE_VER', run_info(1),         'Data acquisition program'
fxaddpar, hd, 'NSAMPLES', fix(paramline(0)),   'Number of samples'
fxaddpar, hd, 'ROTFREQU', float(paramline(1)), 'Readout frequency [Hz]'
fxaddpar, hd, 'SAMPTIME', float(paramline(2)), 'Sample time [s]'
if n_elements(paramline) GT 3 then $
  fxaddpar, hd, 'BIASFREQ', float(paramline(3)), 'Bias frequency [Hz]'
if n_elements(paramline) GT 4 then $
fxaddpar, hd, 'BIASVPP',  float(paramline(4)), 'Bias Vpp [V]'
if n_elements(paramline) GT 5 then $
fxaddpar, hd, 'WAVEFORM', paramline(5),        'Waveform'
if n_elements(paramline) GT 6 then $
fxaddpar, hd, 'DCBIASEQ', float(paramline(6)), 'DC Bias equivalent'

if keyword_set(dasgains) then begin
        dasgains='Applied'
        comment3='DASGAINS file is applied'
        fxaddpar, hd, 'DASGAINS', dasgains, comment3
endif
if keyword_set(temperature_channel) then begin
        comment='Bath Temperature'
        fxaddpar, hd, 'TC', temperature_channel, comment
endif
if keyword_set(bias_channel) then begin
        comment='Bias Voltage'
        fxaddpar, hd, 'BIAS', bias_channel, comment
endif

;--------------------------------------------------
; write header to disk

fxwrite, filename, hd


;--------------------------------------------------
; construct new extension header for binary tables

fxbhmake, binhead, nrow

for i=0, ncol-1 do $
  fxbaddcol,i+1,binhead,data[i,0],colname1[i], tunit = colname2[i]
                                           ;Use first element in each array

pp = ptrarr(ncol)
for i=0, ncol-1 do pp[i] = ptr_new(data[i,*])

fxbcreate, unit, filename, binhead

fxbwritm,unit,colname1, PASS_METHOD='POINTER', POINTERS = pp, BUFFERSIZE=0
fxbfinish,unit                 ;Close the file

ptr_free, pp



end


