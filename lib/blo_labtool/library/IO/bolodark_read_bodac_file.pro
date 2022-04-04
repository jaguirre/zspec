;+
;=========================================================================== 
;  NAME: 
;		       bolodark_read_bodac_file
;  
;  DESCRIPTION: 
;		       Read Bolometer Load Curve File (BoDAC version)
;
;  USAGE: 
;		       bolodark_read_bodac_file, infile
;  	
;
;  INPUT:	
;    infile	       (string) filename of inputfile 
;    
; OUTPUT: 
;   function	       (struct) 		       
;		               'filename'	       
;                       	'time'  	       
;                       	'version'	       
;                       	'aids'  	       
;                       	'bolo_label'	       
;                       	'bolo'  	       
;                       	'bias'  	       
;                       	'T_c'		       
;                       	'lnR'		       
;                       	'P'		       
;
;
; KEYWORDS:
;   bias_channel_label	bias_channel_label
;   bolo_channel_label	bolo_channel_label
;   temp_channel_label	temp_channel_label
;   verbose		verbose
;
; AAUTHOR: 
;			Ken Ganga(IPAC)
; 
; Edition History:
;
;    Date    Programmer Remarks
; ---------- ---------- -------
; 2002-08-08 B. Schulz  converted to separate file version
; 2002-08-15 B. Schulz  changed divider from 76.957d0 to 79.573538d0
; 2003-03-24 B. Schulz  renamed and adapted to read BoDAC files
; 2003-03-25 B. Schulz  force R and P to be positive
; 2003-03-26 B. Schulz  use of DASgains file, divider removed
; 2003-04-02 B. Schulz  lsquadratic interpolation for offset removed
; 2003-08-04 B. Schulz  T-conversion GRT if DASgains <> 1.0
;=========================================================================== 
;-

function bolodark_read_bodac_file, infile, $
                        bias_channel_label = bias_channel_label, $
                        bolo_channel_label = bolo_channel_label, $
                        temp_channel_label = temp_channel_label, $
                        verbose            = verbose

   ; Parse the command line
   if n_elements(bias_channel_label)  ne 1L then $
      bias_channel_label  = 'BIAS    '
   if n_elements(Rload)   ne 1L then Rload   = 10.0d6
   if n_elements(temp_channel_label) ne 1 then $
      temp_channel_label = 'ULTRCOLD'

   
   current_T = 0.005 ;[A] constant current for temperature voltage conversion
                     ; to resistance. Probably includes amplification factors. 
   print, infile
   
   blo_noise_read_bfits, infile, run_info, sample_info, $           ;load first file
       columns, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=dat

   time    = run_info[0]
   version = run_info[1]
   aids    = run_info[3]

   ; Read the list of columns
   ncolumns = n_elements(columns)
   if keyword_set(verbose) then message, $
      "Number of channels in file = " + strtrim(string(ncolumns), 2), /info

   nlines = n_elements(dat[0,*])
   nsamps = nlines


   ; Extract the bolometer load curves
   ;dat = reform(dat, ncolumns, nsamps)
   dat = transpose(dat) 	;now we have dat[line, channel]

   ; Extract the bolometer voltages

   if keyword_set(bolo_channel_label) then begin
     bolochannel = where(columns eq bolo_channel_label, count)
     if count ne 1 then $
        message, "Problem finding column for " + bolo_channel_label
   endif else begin
     bolochannel = 0
     bolo_channel_label = columns(0)
   endelse

   blo_sepfilepath, infile, name, path
    
   dgains = blo_read_dasgains(path=path)	;get gains factors
   
   ; Restore Bolometer Voltage
   bolo = dat[*, bolochannel] / (dgains[bolochannel])[0]

   ; Find the Bias Voltage
   biaschannel = where(strupcase(columns) EQ bias_channel_label, count)
   if count ne 1L then message, "Problem finding bias channel"
   bias_voltage = dat[*, biaschannel] / (dgains[n_elements(dgains)-1])[0]

   ;Sort ascending bias voltage
   ix           = sort(bias_voltage)
   bias_voltage = bias_voltage[ix]
   bolo         = bolo[ix]


   ; Find the zeropoint and remove the offset
;   offset = reform(interpol(bolo, bias_voltage, 0.0d0, /lsquadratic))
   offset = reform(interpol(bolo, bias_voltage, [0.0d0]))
   bolo = bolo - offset[0L]

;print, "Offset removed! :", offset

   ; Orient the curve correctly
   index = where(bias_voltage ge 0.0d0, count)
   if count gt 0L then begin
      if total(bolo[index]) lt 0.0d0 then begin
        bolo[index] = -bolo[index]
        print, '1) bolo flipped !!'
      endif
   endif

   index = where(bias_voltage lt 0.0d0, count)
   if count gt 0L then begin
      if total(bolo[index]) gt 0.0d0 then begin
        bolo[index] = -bolo[index]
        print, '2) bolo flipped !!'
      endif
   endif

   ; Create the bias current
;   bias = (bias_voltage/divider - 0.5d0*bolo)/Rload    ;HFI version Check !!!!!!
   bias = (bias_voltage - bolo)/Rload/2.		;BoDAC version

   ; Find the coldplate temperatures


   tempchannel = where(columns eq temp_channel_label, count)
   if count ne 1L then message, "Problem finding temp channel"
   T_c = reform(dat[*, tempchannel])

   ;convert only if units are not Kelvin, assume Volts then
   if strpos(strupcase(colname2[tempchannel]), 'K') LT 0 then begin
     if (dgains[tempchannel-1])[0] EQ 1.0 then $
       T_c = blo_lakeshore(T_c / current_T) $   ;convert R to T
     else begin
       T_c = T_c / (dgains[tempchannel-1])[0]
       T_c = blo_lakeshore(T_c, /grt )
     endelse
   endif


   ; Find the resistance and power
   r = abs(bolo/bias)			;must be positive
   p = abs(bolo*bias)			;must be positive

   ln_r = alog(r)
   index = where(r gt 0.0d0 and p gt 0.0d0, count)
   if count le 0L then message, "No good R/P points"
   ln_r = alog(r[index])
   p = p[index]
   bolo = bolo[index]
   bias = bias[index]
   T_c = T_c[index]

   ; Make the structure
   str = create_struct(name=infilename, $
                          'filename'  , infile            , $
                          'time'      , time              , $
                          'version'   , version           , $
                          'aids'      , aids              , $
                          'bolo_label', bolo_channel_label, $
                          'bolo'      , bolo              , $
                          'bias'      , bias              , $
                          'T_c'       , T_c               , $
                          'lnR'       , ln_r              , $
                          'P'         , p                   )

   ; Later
   return, str
end
