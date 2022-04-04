;+
;===========================================================================
;  NAME: 
;		   blo_sig2power
;
;  DESCRIPTION: 
;		   Calculate power spectrum from bolometer data file and save 
; 		   in another one
;  INPUT:
;    filelist 	   (string)					         
;
;  OUTPUT:        						        
;	file	   Output filename has '_pow' added before extension.     
;	           column updated in header.			         
;	           Title of first column is changed to 'frequency (Hz)'   
;
;  KEYWORDS:
;    nopower 	   return simple fourier spectrum without normalization   
;		   to W/sqrt[Hz] 				         
;    deglitch	   if set glitches above 5 sigma deviation are replaced   
;		   by the median value of the dataset		         
;  AUTHOR:
;		   Bernhard Schulz				         
;  Example:
;   IDL> fname = '/scr2/project/spire/bolo/hfi/code/bodacfitscnv_bfits/20021025_LIA2_gain_0_time.bin'
;   IDL> blo_sig2power, fname
;   Loading file: 
;   /home/bschulz/data/project/spire/bolo/hfi/code/bodacfitscnv_bfits/20021025_LIA2_gain_0_time_pow.bin
;   IDL> $ls -l /home/bschulz/data/project/spire/bolo/hfi/code/bodacfitscnv_bfits/*.ow*
;   -rw-r--r--   1 bschulz  herschel   400000 Jan 31 13:49 /home/bschulz/data/project/spire/bolo/hfi/
;   code/bodacfitscnv_bfits/20021025_LIA2_gain_0_time_pow.bin
;   IDL> 
;
;
; Edition History:
;
; Date	      Programmer  Remarks
; 2002/09/13  B. Schulz   initial test version
; 2003/01/27  B. Schulz   blo_hfi_noise_read renamed to blo_noise_read_binary
; 2003/01/27  B. Schulz   blo_noise_writedata renamed to blo_noise_write_binary
; 2003/01/27  B. Schulz   run_info update to identify power files
; 2003/01/31  B. Schulz   parameter passing via strarr only
; 2003/03/20  B. Schulz   automatic filetype recognition, output changed to FITS only
; 2003/03/20  B. Schulz   file selector added, frequency column corrected
; 2003/05/14  B. Schulz   prevent crash if no file selected
; 2003/05/16  B. Schulz   nopower keyword added
; 2003/07/09  B. Schulz   deglitch keyword added
; 2003/12/16  L. Zhang    add an input parameter filelists
; 2003/12/18  L. Zhang    fixed the bug on calling blo_noise_powerspec.
;                         It was called with nopower=nopower and did not
;                         check whether keyword nopower is set or not.
;===========================================================================
;-

pro blo_sig2power, filelist, nopower=nopower, deglitch=deglitch


if n_params() ne 1 then $ 
    filelist = dialog_pickfile( /MULTIPLE_FILES, $
                 /READ, /MUST_EXIST, FILTER = '*.*', $
                         GET_PATH=path, path=getenv('BLO_DATADIR'))

 
if filelist[0] EQ '' then begin
  message, /info, 'No files selected!'
  return
endif

nfiles = n_elements(filelist)

for fi = 0, nfiles-1 do begin 

  infile = filelist[fi]

  blo_sepfilepath, infile, filename, path

  infile = path+filename

  blo_noise_read_auto, infile, run_info, sample_info, $
            colname1, colname2, npts, ScanRateHz, SampleTimeS, $
            paramline=paramline, $
            data=data                           ;read data


  ;------------------------------------------------
  ncol = n_elements(data(*,0))

  freq = findgen(npts/2+1L)*scanratehz/npts


  for col = 0, ncol-1 do begin            ;calculate power spectrum
    
    ;12/18/03 L. Zhang 
    if keyword_set(nopower) then begin
        blo_noise_powerspec, data(col,*), npts, ScanRateHz, s, nopower=nopower, $
    			deglitch=deglitch

    endif else begin
         blo_noise_powerspec, data(col,*), npts, ScanRateHz, s, deglitch=deglitch 
    
    endelse 
   
    if col EQ 0 then begin
      npts1 = n_elements(s)
      dataout = fltarr(ncol, npts1)
      dataout(col,*) = freq
    endif else dataout(col,*) = s

  endfor


  paramline(0) = string(npts1)    ;update number of elements in column

  ;------------------------------------------------
  ;change of units

  blo_ch2fftunits, colname1, colname2, nopower=nopower

;  colname1(0) = 'Frequ'       ;update first column titles
;  colname2(0) = '[Hz]'            ;update first column titles

;  for i = 1, n_elements(colname2)-1 do begin  
;    if keyword_set(nopower) then $
;      colname1[i] = 'FFT '+colname1[i]	      $
;    else $
;      colname1[i] = 'Pow '+colname1[i]	      
;  endfor				      

;  if NOT keyword_set(nopower) then begin
;    for i = 1, n_elements(colname2)-1 do begin
;      p1 = strpos(strupcase(colname2[i]), '(V)')
;      p2 = strpos(strupcase(colname2[i]), '[V]')
;      if p1 GE 0 THEN colname2[i] = strmid(colname2[i],0,p1) + '[V/sqrt(Hz)]' + $
;      			strmid(colname2[i],p1+3)
;      if p2 GE 0 THEN colname2[i] = strmid(colname2[i],0,p2) + '[V/sqrt(Hz)]' + $
;      			strmid(colname2[i],p2+3)
;    endfor
;  endif

  ;------------------------------------------------

  run_info[0] = 'PowSpec: '+run_info[0]   ;identify as power spectrum

  parts = strsplit(filename,'.')          ;modify filename for output
  extp = parts(n_elements(parts)-1)
  outfilename = strmid(filename,0,extp-1)+'_pow.'+ 'fits'

  outfile = path+outfilename

  ;------------------------------------------------

  blo_noise_write_bfits, outfile, $                      ;write output file
                  run_info, sample_info, paramline, $
                  colname1, colname2, dataout

endfor

end