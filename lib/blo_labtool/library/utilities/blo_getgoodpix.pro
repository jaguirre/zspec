;+
;===========================================================================
;  NAME: 
;		  blo_getgoodpix
; 
;  DESCRIPTION: 
;		  Get string labels of good bolometer pixels
;
;  USAGE: 
;		  goodpixeles = blo_getgoodpix(filename, path=path)
;  
;  INPUT:
;    filename	  A string containing the name of the good pixle file
;  
;  OUTPUT:  
;    goodpixles    A string containing all the good pixles
;
;  KEYWORDS:
;    path	  A string variable containing the path where the good
;	          pixles file is located
;
;
;  Edition History
;
;  Date		Programmer 	Remark
;  2003/05/12  	B. Schulz  	initial test version w. 'Pathfinder' values 
;  2003/07/16 	B. Schulz  	entirely new version with file load
;  2003/10/01   L. Zhang        Change the message to inform the user what 
;                               to check
;===========================================================================
;-

function blo_getgoodpix, filename, path=path

  
   if not keyword_set(path) then begin
       path = getenv('BLO_DASGDIR')
       inputFlag=0
   endif else begin
       inputFlag=1
   endelse
   
   if n_params() EQ 0 then filename = 'Goodpixels.txt'
   a = findfile(path + filename)

   if a EQ '' then a = findfile(path + 'Goodpixels.txt')

   if a EQ '' then a = findfile(getenv('BLO_DASGDIR') + 'Goodpixels.txt')
    
 
   if a EQ '' then begin 
      if ( inputFlag eq 0 ) then begin
          message, /info, "BLO_DASGDIR environment variable not set!"
      endif else begin 
          msg="Goodpixels file nonexistent in " + path
          message, /info, msg
      endelse
     gains = -1


   endif else begin
   
     readfmt, a, 'a12', goodpix, /silent
     goodpix = strtrim(goodpix, 2)

   endelse  

return, goodpix

end
