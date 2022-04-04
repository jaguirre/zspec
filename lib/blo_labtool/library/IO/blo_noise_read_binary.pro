;+
;============================================================================
; NAME: 
;		   blo_noise_read_binary.pro
;
; DESCRIPTION: 
;		   Reads HFI and SPIRE proprietary binary detector noise files.
;
; USAGE:	  
; 		   blo_noise_read_binary, infile, run_info, sample_info, $
;                  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $  
;                  informat = informat, paramline=paramline, $  	       
;                  verbose = verbose, data=data 			       
;		   							       
; INPUT:
;  infile          The name of the file to read.
;
; KEYWORDS:
;  informat        An integer specifying the format of the			    
;                  file. Possibilities are:					    
;                    0: The "standard" ascii files				    
;                    1: The older, header-challenged HFI files. 		    
;                    2: The "standard" binary files, with the same headers	    
;                  	as the standard ascii files, but with binary data.
;                    3: The "standard" binary files, like informat=2 with n^2 pts.  
;                  Defaults to 3.						    
;  verbose         If set, you may get more informational messages.		    
;  paramline       returns array of strings from parameter line in header	    
;                  The first 3 are PtsPerChan, ScanRateHz, SampleTimeS		    
;                  this keyword allows to read any other additional parameters	    
;
;
; OUTPUT:
;  run_info        The first line of the header, basically		       
;  sample_info     titles of three header parameters			       
;  colname1        An array of strings with identifiers of the columns in the  
;                  data array						       
;  colname2        An array of strings with the names of the columns in the    
;                  data array						       
;  PtsPerChan      Points per channel ( # of datapoints in one column)	       
;  ScanRateHz      The scanning rate in Hz.				       
;  SampleTimeS     Sample time	
;
;  AUTHOR:
;		   Bernhard Schulz					       
;
; Examples:
;
; IDL> blo_noise_read_binary, $
; IDL>  '/home/bschulz/data/project/spire/bolo/hfi/data/41_7Hz1_2Vppd/01AM/41_7hz1_2vppd71_time.bin', $
; IDL>   run_info, sample_info, $
; IDL>   colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS
; IDL> print, run_info, sample_info, PtsPerChan, ScanRateHz, SampleTimeS
; 04/23/02 01:27:22 AM HFI DAS Code Version 2.13 AIDS no. 225304
; No.Pts/Chan Scan Rate (Hz) Sample Time (s)
;        65536         172         381
; IDL>
;
;
; History:
;
;    Date     Programmer Remarks
; ----------  ---------- -------
; 2002/01/26  K. Ganga   Added binary support and some docs.
; 2002/01/29  K. Ganga   Tweaked to take care of a very special case
;                        when the header is slightly inconsistent.
; 2002/01/30  W. Holmes  Added swap_endian for use with windows machines
; 2002/02/21  W. Holmes  Added informat=3 for 65536 pts
; 2002/05/29  B. Schulz  Separated out header read and changed parameters
; 2002/08/26  B. Schulz  Scrapped original interface
; 2002/08/26  B. Schulz  Fixed double TAB problem with Hien's files
; 2002/09/12  B. Schulz  new keyword paramline introduced
; 2002/10/03  B. Schulz  bugfix in threepar handling (I knew it!!!)
; 2002/10/05  B. Schulz  compatible with Linux x86
; 2002/11/05  B. Schulz  extracted subr. blo_extr_paramline.pro
; 2003/01/27  B. Schulz  renamed and cleaned
; 2003/02/01  B. Schulz  parameter passing via strarr only
;
;===========================================================================
;-
; Generic read routine

pro blo_noise_read_binary, infile, run_info, sample_info, $
                        colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
                        informat = informat, paramline=paramline,  $
                        verbose = verbose, data=data

  ; Set the defaults
  if NOT keyword_set(informat) then informat = 3L

  ; Give some input informations
  if keyword_set(verbose) then $
    message, "Input format = " + strtrim(string(informat), 2), /info

  ; Read in the data
  if keyword_set(verbose) then message, "Reading " + infile, /info
  openr, lun, infile, /get_lun

  run_info = ' '               ; Read in the "Run Information" (1st line)
  readf, lun, run_info
  run_info = strsplit(run_info, STRING(9B), /regex, /extract)

  sample_info = ' '            ; Read in the sample info
  readf, lun, sample_info      ;  I.e., what is in the next line
  sample_info = strsplit(sample_info, STRING(9B), /regex, /extract)
  nsample_info = n_elements(sample_info)

  threepar = ' '                ;read parameters
  readf, lun, threepar

  paramline = strsplit(threepar, STRING(9B), /regex, /extract)

  PtsPerChan  = long(paramline[0])  ;points per channel
  ScanRateHz  = long(paramline[1])  ;scan rate in [Hz]
  SampleTimeS = long(paramline[2])  ;Sample time in [s]
  

  ; Read in the column information
  colname1 = ' '
  colname2 = ' '
  if ( (informat eq 0) or $
       (informat eq 2) or $
       (informat eq 3) ) then begin
    readf, lun, colname1
    colname1 = strsplit(colname1, STRING(9B), /regex, /extract)
    ncol = n_elements(colname1)
    readf, lun, colname2
    colname2 = strsplit(colname2, STRING(9B), /regex, /extract)

    if (n_elements(colname2) eq ncol-1) then colname2 = ['time', colname2]

  endif else if ( informat eq 1 ) then begin

    strash = ' '
    readf, lun, strash
    strash = strsplit(strash, STRING(9B), /regex, /extract)
    ncol = n_elements(strash)

    close, lun
    openr, lun, infile
    strash = ' '
    for i = 1L, 3L do readf, lun, strash
    colname2 = 'Column ' + strtrim(string(lindgen(ncol)), 2)
    ScanRateHz = 50.0

  endif else begin

    message, "Problem with 'informat'"

  endelse

  ; Read in the data itself
  if keyword_set(verbose) then begin
     message, "Reading data...", /info
     message, "Points per channel = " + strtrim(string(PtsPerChan), 2), /info
     message, "Scan Rate = " + strtrim(string(ScanRateHz), 2) + " Hz", /info
     message, "Sample Time = " + strtrim(string(SampleTimeS), 2) + " s", /info
     message, "# columns = " + strtrim(string(ncol), 2), /info
     message, "# samples = " + strtrim(string(PtsPerChan), 2), /info
  endif
  data = fltarr(ncol, PtsPerChan)
  if ( (informat eq 2) or (informat eq 3) ) then begin
     readu, lun, data
     if !version.arch eq 'x86' then data = swap_endian(data)
  endif else begin
     readf, lun, data
  endelse
  if keyword_set(verbose) then message, "Done reading data...", /info

  close, lun                   ; Close the file
  free_lun, lun                ; Free the unit

end
