;+
;===========================================================================
;  NAME: 
;		     BLO_SAVE_DIALOG
;
;  DESCRIPTION: 
;		      Dialog to save bolometer data files
;
;  USAGE: 
;		      blo_save_dialog, data, run_info, sample_info, paramline,$
;                     colname1, colname2, fdasgains=fdasgains
;
;  INPUT:
;     data            (double) 2 dim array [channel,signal] of bolometer      
;                     signals in several channels. First channel is time in [s]  	  
;                     Bolometer signals are in [V]		    	 	  
;    run_info         (strarr) The first line of the header, basically		    
;    sample_info      (string array) titles of header parameters 		    
;                     first must be  # of datapoints in one column   		   
;                     second must be the scanning rate in Hz.	     		   
;                     third must be sample time 		     		   
;    paramline        (string array) first 3 items are  			    
;                      PtsPerChan : Points per channel ( # of datapoints    	    
;                       		  in one column)		    	    
;                     ScanRateHz:  The scanning rate in Hz.		    	    
;                     SampleTimeS: Sample time 			    	    
;
;    colname1         (string array) identifiers of the columns in the data array   
;    colname2         (string array) names of the columns in the data array	    
;
;
;  OUTPUT	:
;       	      saved file
;
;  KEYWORDS:
;   outfilename       (string) name of outputfile. If provided, dialog for 
;                     filename is suppressed
;   dasgains          (int)    if set the DASgains keyword is set for FITS-files.
;                      Not allowed for binary file writing. 
;  AUTHOR:
;		       Bernhard Schulz
; Examples:
;

; Edition History:
;
; 2002/10/15 B. Schulz initial test version
; 2003/01/27 B. Schulz blo_noise_writedata renamed to blo_noise_write_binary
; 2003/01/28 B. Schulz keyword outfilename added
; 2003/01/30 B. Schulz keyword fits added
; 2003/02/01 B. Schulz parameter passing all via strarr
; 2003/03/20 B. Schulz check for bias in col 1 to detect load curve
; 2003/08/22 B. Schulz Dasgains keyword added
; 2003/12/19 L. Zhang  Fixed the buy at saving binary file
;===========================================================================
;-

pro blo_save_dialog, data, run_info, sample_info, paramline, $
                     colname1, colname2, outfilename=outfilename, $
                     fits=fits, dasgains=dasgains
		     
		     
if keyword_set(fits) then extens = 'fits' else extens = 'bin'

if keyword_set(dasgains) and keyword_set(fits) then dasgains = 1

if keyword_set(dasgains) and NOT keyword_set(fits) then $
        message, "Dasgains keyword not allowed in binary files!"


if NOT keyword_set(outfilename) then $
  blo_savename_dialog, fpath=getenv('BLO_DATADIR'), $
                                extension=extens, outfilename

if outfilename NE '' then begin

  widget_control, /hourglass

  if strpos(strlowcase(colname1[0]), 'bias') GE 0 then loadcrv=1 $
  else loadcrv = 0      ;check if loadcurve file 
 
 
  if keyword_set(fits) then $
    blo_noise_write_bfits, outfilename, $        ;write data
         run_info, sample_info, paramline, $
         colname1, colname2, data, loadcrv = loadcrv, dasgains=dasgains $
  else $
    blo_noise_write_binary, outfilename, $        ;write data
         run_info, sample_info, paramline, $
         colname1, colname2, data

  print, 'Saving file: ' + outfilename
endif


end
