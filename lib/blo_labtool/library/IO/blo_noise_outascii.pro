;+
;===========================================================================
; NAME: 
;		      blo_noise_outascii
;
; DESCRIPTION: 
;		      Print Power Spectrum into ASCII file
;
; USAGE: 
;		      blo_noise_outascii, filename, outdir, run_info, $
;		      column_names, x_s, y, cols2use=cols2use, $
;	              time1stcol=time1stcol
;
; INPUT:
;    filename 	      name of output file
;    outdir           output path 
;    run_info         (string) the first line of the data header
;    column_names     (string) names of data columns	    
;    x_s 	      frequency [Hz]		    
;    s 	              power spectrum [V]	    
;		            
;
; OUTPUT:
;		      ASCII file in outdir
;
; KEYWORDS:
;    cols2use 	      index vector of columns to print
; 
;
; AUTHOR: 
;		      B. Schulz
;
;
; Edition History
;
; Date    	Programmer 	Remarks
; ---------- 	---------- 	-------
; 2002-05-02 	B.Schulz   	Extracted from coadd_spectra_files.pro
; 2002-05-24 	B.Schulz   	keyword to set time name in first column
;
;===========================================================================
;-

pro blo_noise_outascii, filename, outdir, run_info, $
				column_names, x_s, y, cols2use=cols2use, $
                    time1stcol=time1stcol
                    
   ncols = n_elements(column_names)
   if ncols NE n_elements(y(0,*)) then $
   		message, "Problem with number of columns!"

   if keyword_set(cols2use) then begin
     ncols2use  = n_elements(cols2use)     
   endif else begin
     ncols2use = ncols
     cols2use = findgen(ncols)
   endelse



   ; Write out the spectra in one file

   if n_elements(filename) gt 0 then begin
      get_lun, lun                                ; Get a logical unit number
      openw, lun, outdir + filename                  ; Open the file
      printf, lun, run_info                       ; Write out header info
      if keyword_set(time1stcol) then	$
      	printf, lun, 'Time(s)', $
      		format = "($, a14,tr1)" 	$			; Write header for time column
      else $
      	printf, lun, 'Freq(Hz)', $
      		format = "($, a14,tr1)" 				; Write header for frequency column

      for icol = 0L, ncols2use-1L do begin    ; Write out column headers
        column_index = cols2use(icol)
        printf, lun, column_names[column_index] + STRING(9B), $
          format = "($, a14,tr1)"
      endfor
      printf, lun, " "

      for i = 0L, n_elements(x_s)-1L do begin     ; Write out each sample
         printf, lun, x_s[i], format = "($, g14.8,tr1)"

         for icol = 0L, ncols2use-1L do begin ; Write each channel
           column_index = cols2use(icol)
           printf, lun, y[i, column_index], $
             format = "($, g14.8,tr1)"
         endfor
         
         printf, lun, " "
      endfor

      close, lun                                  ; Close the file
      free_lun, lun                               ; Free the unit

   endif

end
