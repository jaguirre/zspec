;+
;===========================================================================
;  NAME: 
;	        bolodark_read_loadcrv			    
;
;  DESCRIPTION: 					  
;	        Read Bolometer Load Curve File  	    
;
;  USAGE: 
;	        bolodark_read_loadcrv, infiles  	    
;
;  INPUT: 
;    infiles    (array string) filenames   of inputfiles   
;    
;  OUTPUT:	 
;	        (array of pointers to structs){
;	        h_origin   (string) origin of data		     
;	        h_telescop (string) Data acquisition system	     
;	        h_filename (string) File name			     
;	        h_date     (string) Date of file creation (UT)       
;	        h_datepst  (string) Original date string (PST)       
;	        h_timepst  (string) Original time string (PST)       
;	        h_date_obs (string) Data creation date (UT)	     
;	        h_filetype (string) Detector signal versus time      
;	        h_fileorig (string) Original file or not	     
;	        h_code_ver (string) Data acquisition program	     
;	        h_nsamples (int)    Number of samples		     
;	        h_rotfrequ (float)  Readout frequency [Hz]	     
;	        h_samptime (float)  Sample time [s]    
;	        h_biasfreq (float)  Bias frequency [Hz]  
;	        h_biasvpp  (float)  Bias Vpp [V]	  
;	        h_waveform (string) Waveform	
;	        h_dcbiaseq (float)  DC Bias equivalent [V]
;               ubolo_label (array string) labels of channels	       [nchannel]
;  	        uboloerr_label (array string) labels of error channels [nchannel]
;	        ubolo	   (array float) bolometer voltage [V]         [nchannel,n]
;  	        uboloerr   (array float) error bolometer voltage [V]   [nchannel,n]
;               ubias	   (array float) bias voltage [V]	       [n] 
;  	        ubiaserr   (array float) error bias voltage [V]        [n] 
;               T_c }	   (array float) bath temperature [K]	       [n]
;
;       	Gains from DASGains file are applied
;        	Temperatures are converted to Kelvin if units were in Volts
;
; KEYWORDS:
;    chanlim 	(string array)channnel limits [from_label,to_label] 
;		defines channel range to be loaded		    
;    verbose	verbose 					    
;
; AUTHOR: 
;	      	Bernhard Schulz (IPAC)
; 
; Edition History:
;
; Date	       Programmer   Remarks
; 2003/04/29   B. Schulz    initial test version
; 2003/04/30   B. Schulz    temperature conversion and fixes
; 2003/05/06   B. Schulz    offset removal removed
; 2003/07/31   B. Schulz    included new temperature conversion
; 2003/08/13   L. Zhang     remove the channlim keyword
;                           check dasgains applied or not
; 2003/08/14   L. Zhang     Use keyword TC and BIAS to get temperature 
;			    and bias channels
;-------------------------------------------------------------------
;-

function bolodark_read_loadcrv, infiles, $
                        verbose            = verbose

;-----------------------------------------------------------
;
if (n_params() eq 0) then message, 'No input file, program exits!!!'


nfiles = n_elements(infiles)

strout = ptrarr(nfiles)

;-------------------------------------
; Loop over all files

for ifile = 0, nfiles-1 do begin

;-------------------------------------
;read primary FITS header

  hdr = headfits(infiles(ifile))
  h_dasgains = fxpar(hdr, 'DASGAINS')     ;set keyword dasgains if found
  if !err GE 0 then dasgains = 1 else dasgains=0

  filetype = strtrim(fxpar(hdr, 'FILETYPE'),2)
  if filetype EQ 'NOISE' OR filetype EQ 'LOADCRV' then begin
  
  temperature_channel_label = strtrim(fxpar(hdr, 'TC'),2)
  if !err LT 0 then  begin
      ;message, 'No temperature channel found in the hearder, program exit!'
      message, /infor, 'No TC keyword found, set Temperature channel to ULTRACOLD!'
      temperature_channel_label='ULTRACOLD'
  endif
  
  
  bias_channel_label = strtrim(fxpar(hdr, 'BIAS'),2)
  if !err LT 0 then begin
      ;message, 'No bias channel found in the hearder, program exit!'
       message, /info, 'No BIAS keyword found, set bias channel to BIAS!'
       bias_channel_label='BIAS'
  endif
  
;-------------------------------------
; Prepare gains array

    blo_sepfilepath, infiles[ifile], name, path
    
    if ( dasgains eq 0  ) then begin
        dgains = blo_read_dasgains(path=path)	 ;get gains factors
        message, /info, 'Loading: '+name
    endif 
;-------------------------------------
;get binary table labels, units, bias voltages and errors

    fxbopen, unit, infiles(ifile), 1, bhdr	  ;get binary table header
    ncoltot=fxpar(bhdr,'TFIELDS')

    fxbfind, unit, 'TTYPE', columns, colname1, n_found1
    fxbfind, unit, 'TUNIT', columns, colname2, n_found2
    if n_found1 NE ncoltot then message, 'Inconsistent header (TTYPE) in file: '+infiles(ifile)
    if n_found1 NE ncoltot then message, 'Inconsistent header (TUNIT) in file: '+infiles(ifile)

    fxbread, unit, ubias, bias_channel_label	;bias voltage
    fxbread, unit, ubiaserr, 'ERR '+bias_channel_label	;bias voltage error


    if (dasgains eq 0  ) then begin
       ubias = ubias / (dgains[n_elements(dgains)-1])[0]
       ubiaserr = ubiaserr / (dgains[n_elements(dgains)-1])[0]
    endif
    

    nrow = n_elements(ubias)	;get number of averaged elements

;-------------------------------------
   ;get the ubolo_labels, uboloerr_label
   
   ; Find the error channels
   ix = where(strpos(colname1,'ERR') EQ 0,cnt)
   ;take the bias err out
   uboloerr_label=colname1[ix]
   uboloerr_label=uboloerr_label[1:n_elements(uboloerr_label)-1]
   ;colname1[0] is the BIAS channel
   ubolo_label=colname1[1:ix[0]-1]
  
   if (n_elements(ubolo_label) NE n_elements(uboloerr_label)) then begin
       message, 'Inconsistent number of data and error channels!'
   endif
   
   ;find the temperature channel position
   ix = where(strmatch(ubolo_label, temperature_channel_label, /fold_case) ne 1 ) 
   ubolo_label=ubolo_label[ix]
   
   nchan=n_elements(ubolo_label)
 
;-------------------------------------
;get binary table bolometer voltages and errors

    ubolo = dblarr(nchan,nrow)		;data array for bolometer voltages
    for ichan=0, nchan - 1 do begin		;fill bolometer voltages
      fxbread, unit, data, ubolo_label[ichan]
      
      if (dasgains eq 0) then begin
           ubolo[ichan,*] = data / (dgains[ichan])[0] ;apply gain factors
      endif else begin
           ubolo[ichan, *] = data
      endelse
    endfor

    uboloerr = dblarr(nchan,nrow)
    for ichan=0, nchan -1  do begin		;fill bolometer voltage errors
      fxbread, unit, data, uboloerr_label[ichan]
      if  (dasgains eq 0 ) then begin
           uboloerr[ichan,*] = data / (dgains[ichan])[0] ;apply gain factors
       endif else begin
           uboloerr[ichan, *] = data
       endelse
    endfor

;    ibias = dblarr(nchan,nrow)		;data array for bias currents
;    R     = dblarr(nchan,nrow)		;data array for resistances
;    P     = dblarr(nchan,nrow)		;data array for powers

;-------------------------------------
; Get the coldplate temperatures
; conversion will be done if units of temp channel are 'V'
; If DASgains factor is 1 then assume factor 200 must be applied to come to Ohms
; and default conversion is applied.
; If DASGains factor is not zero GRT conversion is applied
; DASgains factor must convert Volts to Ohms (1/current)

    fxbread, unit, T_c, temperature_channel_label
    fxbclose, unit
    
    ix = where(strpos(colname1,temperature_channel_label) EQ 0) - 1 ;find position

    if ( dasgains eq 0  ) then begin
      if strpos(colname2[ix[0]], 'V') GE 0 then begin	;conversion needed?
         if dgains(ix[0]) EQ 1 then begin
             current_T = 0.005 ;[A] constant current for temperature voltage conversion
                          ; to resistance. Probably includes amplification factors. 
             T_c = blo_lakeshore(T_c / current_T)    ;convert R to T
         endif else begin
             T_c = blo_lakeshore(T_c / dgains(ix[0]),/grt)    ;convert R to T
         endelse
      endif
    endif
;--------------------------------------------
; Go around channels

    for ichan = 0, nchan -1  do begin
 
;-------------------------------------
; Remove the offset

     ; ix = sort(abs(ubias))	   ;select 12 closest elem. to zero bias
     ; iy = sort(ubias[ix[0:12]])
     ; ix = ix[iy]
    
     ; a = linfit(ubias[ix], ubolo[ichan,ix])	   ;linefit around zero
     ; ubolo[ichan,*] = ubolo[ichan,*] - a[0]	   ;correct ubolo to zero


;-------------------------------------
; swap bolometer voltage if necessary

      ix1 = where(ubias ge 0.0d0, cnt1)
      ix2 = where(ubias lt 0.0d0, cnt2)

      flag = 0

      if cnt1 GT 0 then begin
        if total(ubolo[ichan,ix1]) LT 0 then begin
	   flag = flag+1
        endif
      endif else flag = flag+1
   
      if cnt2 GT 0 then begin
        if total(ubolo[ichan,ix2]) GT 0 then begin
	   flag = flag+1
        endif
      endif else flag = flag+1

      if flag EQ 2 and keyword_set(verbose) then begin
           ubolo[ichan,*] = -ubolo[ichan,*]
           message, /info, 'swapped ubolo, channel: '+ubolo_label(ichan)
      endif

    endfor	;end channel loop

;-------------------------------------
; Make the structure
  tstru ={ $
  	 h_origin    	:fxpar(hdr, 'ORIGIN'), $
  	 h_telescop  	:fxpar(hdr, 'TELESCOP'), $
  	 h_filename  	:fxpar(hdr, 'FILENAME'), $
  	 h_date      	:fxpar(hdr, 'DATE'), $
  	 h_datepst   	:fxpar(hdr, 'DATEPST'), $
  	 h_timepst   	:fxpar(hdr, 'TIMEPST'), $
  	 h_date_obs  	:fxpar(hdr, 'DATE-OBS'), $
  	 h_filetype  	:fxpar(hdr, 'FILETYPE'), $
  	 h_fileorig  	:fxpar(hdr, 'FILEORIG'), $
  	 h_code_ver  	:fxpar(hdr, 'CODE_VER'), $
  	 h_nsamples  	:fxpar(hdr, 'NSAMPLES'), $
  	 h_rotfrequ  	:fxpar(hdr, 'ROTFREQU'), $
  	 h_samptime  	:fxpar(hdr, 'SAMPTIME'), $
  	 h_biasfreq  	:fxpar(hdr, 'BIASFREQ'), $
  	 h_biasvpp   	:fxpar(hdr, 'BIASVPP'), $
  	 h_waveform  	:fxpar(hdr, 'WAVEFORM'), $
  	 h_dcbiaseq  	:fxpar(hdr, 'DCBIASEQ'), $
  	 ubolo_label 	:ubolo_label[0:nchan-1] , $
  	 uboloerr_label :uboloerr_label[0:nchan-1] , $
  	 ubolo       	:ubolo ,$
  	 uboloerr    	:uboloerr ,$
  	 ubias       	:ubias ,$
  	 ubiaserr       :ubiaserr,$
  	 T_c	     	:T_c}

;  	 ibias       	:ibias ,$
;  	 lnR	     	:R ,$
;  	 P           	:P $


   ;----------------------------------
    strout[ifile] = ptr_new(tstru)
  endif else message, /info, 'No data! File: '+infiles[ifile]

endfor ; ifile 0..nfiles-1

return, strout
end
