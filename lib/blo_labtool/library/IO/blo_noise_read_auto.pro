;+
;=================================================================
; NAME: 
;		   blo_noise_read_auto.pro
;
; DESCRIPTION: 
;		   Reads detector noise files with file extensions, '.fits', 
; 		   '.txt', or '.bin' and recognizes filetype automatically
;
; USAGE:
;  		   blo_noise_read_auto, infile, run_info, sample_info, $       
;  		   colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $  
;  		   paramline=paramline, data=data			       
;
; INPUT:
;  infile          The name of the file to read.			       
;
;
; OUTPUT:
;  run_info        array of strings, first string contains date of measurement 
;  sample_info     titles of three header parameters			       
;  colname1        An array of strings with identifiers of the columns in the  
;                  	  data array
;  colname2        An array of strings with the names of the columns in the    
;                  	  data array
;  PtsPerChan      Points per channel ( # of datapoints in one column)	       
;  ScanRateHz      The scanning rate in Hz.				       
;  SampleTimeS     Sample time						       
;
; KEYWORDS:
;  paramline       returns array of strings from parameter line in header	     
;                  The first 3 are PtsPerChan, ScanRateHz, SampleTimeS		     
;                  this keyword allows to read any other additional parameters	     
;
;  data            on return contains the data array with dimensions [n,m], where    
;                  n is the number of columns corresponding to the number of 	     
;                  elements of colname1 and colname2, and m is equal to PtsPerChan.  
;                  If the file could not be read, data has only one zero element.    
;  dasgains        if set dasgains keyword was found in fits header, zero for	     
;                  all other filetypes by default				     
;
;
;  History:
;
;  Date     	Programmer 	Remarks
;  ----------  	---------- 	-------
;  2003/03/20  	B. Schulz  	initial test version
;  2003/07/23  	B. Schulz  	added channel gains division
;  2003/08/04  	B. Schulz  	nogains keyword added
;  2003/08/04  	B. Schulz  	gains application removed
;  2003/08/11  	B. Schulz  	dasgains keyword added
;
;=================================================================
;-


pro blo_noise_read_auto, infile, run_info, sample_info, $
  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
  paramline=paramline, data=data, dasgains=dasgains


blo_sepfileext, infile, name, extension ;separate filename

help, infile

dasgains=0

case extension OF

'fits': $
  blo_noise_read_bfits, infile, run_info, sample_info, $           ;load first file
    colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
    paramline=paramline, data=data, dasgains=dasgains
'bin': $
  blo_noise_read_binary, infile, run_info, sample_info, $           ;load first file
    colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
    paramline=paramline, data=data
'txt': $
  blo_noise_read_ascjf, infile, run_info, sample_info, $           ;load first file
    colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
    paramline=paramline, data=data
else: begin
       message, 'Wrong filetype! Must be ".fits", ".txt", or ".bin".', /info
       data = [0]
       return
     end
endcase



end
