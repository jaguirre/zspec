;+	
;===========================================================================
; NAME: 
;		     blo_noise_read_ascjf.pro
;
; Description: 
;		     Reads proprietary ASCII format noise files from Nicolet data
; 		     acquisition system.
;
; USAGE:
;  		     blo_noise_read_ascjf, infile, run_info, sample_info, $	     	    	
;  		     colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
;  		     paramline=paramline, data=data
;	
; INPUT:
;     infile	     The name of the file to read.
;
; KEYWORDS:
;  	
;     paramline	     returns array of strings from parameter line in header	  
;	             The first 3 are PtsPerChan, ScanRateHz, SampleTimeS	  
;	             this keyword allows to read any other additional parameters  
;
; OUTPUTS:
;     run_info	     array of strings, first string contains date of measurement     
;	             sample_info: titles of three header parameters		     
;
;     colname1	     An array of strings with names of the columns in the	     
;	             data array 						     
;
;     colname2	     An array of strings with the units of the columns in the	     
;	             data array 						     
;
;     PtsPerChan     Points per channel ( # of datapoints in one column)
;
;     ScanRateHz     The scanning rate in Hz.
;
;     SampleTimeS    Sample time
;
;
; AUTHOR: 
;		     B. Schulz
;
; Edition History:
;
;  Date     	Programmer 	Remarks
; ----------  	---------- 	-------
; 2003/03/20 	 B. Schulz  	initial test version
;
;===========================================================================
;-


pro blo_noise_read_ascjf, infile, run_info, sample_info, $ 
  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
  paramline=paramline, data=data


; read header
openr, un, infile, /get_lun
hd = strarr(6) & h=''
for i=0, 5 do begin 
  readf, un, h, format='(a)' 
  hd[i] = h
endfor
free_lun, un


; extract header information
dateln = strsplit(hd[1], ' ', /regex, /extract)    ;get data measurement date

a = strmid(dateln[3],0,2)+'-'+strupcase((strmid(dateln[2],0,3)))+ $
              '-'+dateln[4]+' '+ dateln[5]

a = date_conv(a, 'F')  ;get month name decoded to FITS format
                       ;example: '2003- 2-18T15:01:08.00'

tt = 'AM'              ;convert to US date convention
hh = fix(strmid(a,11,2))
if hh GE 12 then begin
 hh = hh-12
 tt = 'PM'
endif


;prepare output

run_info = strarr(4)
run_info[0] = strtrim(strmid(a,5,2),2)+'/'+strtrim(strmid(a,8,2),2)+'/'+ $
    strmid(a,0,4)+' '+strtrim(string(hh),2)+ $
    ':'+strtrim(strmid(a,14,2),2)+':'+strtrim(strmid(a,17,2),2) $
    +' '+tt

run_info[1] = 'JFET Data Aquisition'
run_info[2] = 'AIDS'
run_info[3] = 'Nicolet'

sample_info = ['No.Pts/Chan'    ,$
               'Scan Rate (Hz)' , $
               'Sample Time (s)']

colname1 = strsplit(hd[4], string(9B), /regex, /extract)       ;column names
colname2 = strsplit(hd[5], string(9B), /regex, /extract)       ;column units

ncol = n_elements(colname1)     ;number of columns
ncol2 = n_elements(colname2)
if ncol NE ncol2 then message, "Error in file header!!"


; read remainder of file
PtsPerChan = numlines(infile)-6         ; get number of lines

data = fltarr(ncol,PtsPerChan)

openr, un, infile, /get_lun            ; read data
line=''
for i=0, 5 do readf, un, line, format='(a)' ;skip header
for i=0, PtsPerChan-1 do begin 
  readf, un, line, format='(a)' 
  lnel = strsplit(line, string(9B), /regex, /extract)       ;column units
  if n_elements(lnel) EQ ncol then data[*,i] = float(lnel) $
  else print, 'line '+string(i+5)+'skipped!'
endfor
free_lun, un

; recover timing parameters for header
SampleTimeS = data[0,PtsPerChan-1] - data[0,0]
ScanRateHz = (PtsPerChan-1) / SampleTimeS

paramline = [string(PtsPerChan), $
             string(ScanRateHz), $
             string(SampleTimeS)]

end
