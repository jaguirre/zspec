;+
;===========================================================================
;  NAME: 
;		    BLO_SAVENAME_DIALOG
;
;  DESCRIPTION: 
;		    Dialog to get filename for saving a file
;
;  USAGE: 
;		    blo_savename_dialog, fpath=fpath, extension=extension,$
;		      outfilename
;
;  INPUT: 
;		    none
;
;  OUTPUT:
;     outfilename   (string) filename to use for saving
;
;
;  KEYWORDS:
;     fpath         (string) provide path to start with
;     extension     (string) enforce extension for output file
;                    if not given, extension will be added
;                    Note: Do not provide decimal separator!
;  AUTHOR:
;		    Bernhard Schulz
;
;
; Edition History:
;
; 22/10/2002 B. Schulz initial test version
; 29/01/2003 B. Schulz title keyword added + bugfix
;
;=================================================================
;-

pro blo_savename_dialog, fpath=fpath, extension=extension, outfilename, $
                        title=title, file=file

if keyword_set(extension) THEN $
  filter = '*.'+extension $
ELSE filter = ''

filelist = dialog_pickfile( /WRITE, FILTER = filter, $	;select filename
              GET_PATH=path, path=fpath, title=title, file=file)

if filelist(0) EQ '' OR filelist(0) EQ path then begin
  message, /info, "No file selected!"
  outfilename = ''
endif else begin

  blo_sepfileext, filelist(0), name, extens, /leavedot

;  parts = strsplit(filelist(0),'.')          ;modify filename for output
;  extp = parts(n_elements(parts)-1)          ;need .bin extension !!
;  extens = strmid(filelist(0),extp-1)


  if keyword_set(extension) then begin
    if extens NE '.'+extension then $
       outfilename = filelist(0)+'.'+extension $
    else outfilename = filelist(0)
  endif else outfilename = filelist(0)

  
  checkfile = findfile(outfilename)       ;check for existing filename
  if checkfile(0) NE '' then begin
    x = dialog_message("Do you want to overwrite the file "+ $
                           checkfile, /cancel )
  endif else x = 'OK'

  if x NE 'OK' then outfilename = ''
endelse


end
