;+
;======================================================================
;
; NAME: 
;		  drop_filepath
;
; DESCRIPTION: 
;		  Remove path of extended filename
;
; USAGE: 
;		  shortfilename = drop_filepath(filename)
;  	
;
; INPUT: 	  
;   filename 	 (string) full filename including path
;	
;
; OUTPUT:	  
;   function     (string) filename without path
;
;
; AUTHOR: 
;		  Bernhard Schulz (IPAC)
;	
; 
; Edition History:
;
;    Date    Programmer Remarks
; ---------- ---------- -------
; 2002-08-08 B. Schulz  initial version
;
;-------------------------------------------------------------------
;-

function drop_filepath, filename

  pos = strpos(filename, get_ops_separator(), /reverse_search)
  if pos GE 0 then return, strmid(filename, pos+1) $
  else return, filename

end
