;+
;===========================================================================
;
; NAME: 	     
;		     blo_noise_write_binary
;
; DESCRIPTION:       
;	             Write bolometer data file
;
; USAGE: 	     
;                    BLO_NOISE_WRITE_BINARY, filename, $
;                    run_info, sample_info, paramline, $	       
;                    colname1, colname2, data			       
; INPUT:
;    outfile         (string) filename  		      	         
;    run_info        (strarr) The first line of the header, basically   
;    sample_info     (strarr) titles of header parameters     	         
;                    first must be  # of datapoints in one column      
;                    second must be the scanning rate in Hz.  	         
;                    third must be sample time  	      	         
;    colname1        (strarr) identifiers of the	      	         
;                    columns in the data array  	      	         
;    colname2        (strarr) with the names of the	      	         
;                    columns in the data array  	      	         
;    data            (float array) [ncol,nrow]  	      	         
;
;
; OUTPUT:
;       	    File content will be coded in special binary format as produced by 
;       	    JPL Labview program with 5 line ASCII header and rectangular 
;       	    4 byte floating point array
;
;
; KEYWORDS: none
;
; AUTHOR:	    
;                   Bernhard Schulz
;
; Edition History:
; 
; Date	    	Programmer   Remarks
; 2002/09/12	B. Schulz    initial test version
; 2003/01/27 	B. Schulz    blo_noise_writedata renamed to blo_noise_write_binary
; 2003/02/01 	B. Schulz    parameter passing all via strarr
; 2003/03/20 	B. Schulz    blo_tab_concat replaced by blo_tabstrcat
;
;===========================================================================
;-
pro blo_noise_write_binary, outfile, $
                run_info, sample_info, paramline, $
                colname1, colname2, data

openw, lun, outfile, /get_lun

printf, lun, blo_tabstrcat(run_info)
printf, lun, blo_tabstrcat(sample_info)
printf, lun, blo_tabstrcat(paramline)
printf, lun, blo_tabstrcat(colname1)
printf, lun, blo_tabstrcat(colname2)

data = float(data)      ;make sure it is float

if !version.os_family eq 'Windows' then data = swap_endian(data)

writeu, lun, data
free_lun, lun

if keyword_set(verbose) then message, "Done saving data...", /info

end
