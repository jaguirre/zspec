;+
;===========================================================================
;  NAME: 
;		  blo_read_dasgains
;
;  DESCRIPTION: 
;	          Read file containing DAS gains 
; 		  and return appropriate array.  
;
;  USAGE: 
;		  blo_read_dasgains(filename, path=path)
;
;  INPUT:
;     filename	  path + filename of amplifier gains file 
;		  typically "DASgains.txt"
;
;  OUTPUT:
;    function	  array with gain factors
;
;  KEYWORDS:
;    path	  (string) path of gains file
;
;  Author	
;		  B. Schulz
;
;  REMARKS:
;		   File is first searched at the specified location and filename.
;		   If unsuccessful the default filename is searched at the specified
;		   path and if again unsuccessful the default filename at the default
;		   location is tried.
;
;
;  Edition History:
;
;  Date		Programmer  Remarks
;  2002/07/24	B.Schulz    initial test version
;  2003/03/26	B. Schulz   improved search for gains file and error 
;			    reporting
;  2003/08/08	B. Schulz   new better editable ASCII 2 column format for 
;			    gains file 
;  2003/10/21   L. Zhang    If no dasgains found, the program exits 				          
;  2003/12/19   L. Zhang    Bernhard decided to let program run 
;                           even though there is no gain.  Removed
;                           the stop and set the gain is a 192
;                           elements array with value=1
;                           Removed the codes on looking for dasgains 
;                           according to the environment variable.
;
;                           The dasgains will only be read at the data
;                           directory.  If there is no DASgains.txt found
;                           the gain factor will be 1 for all 192 channels.
;                           Therefore, there will be no gain applied at the
;                           bin to fits conversion.
;==========================================================================
;-


function   blo_read_dasgains, filename, path=path

   if not keyword_set(path) then begin
       message,  "Keyword 'path' is not set, program exit!"
   endif
   
   if n_params() EQ 0 then filename = 'DASgains.txt'
 
   a = findfile(path + filename)

   if a EQ '' then a = findfile(path + 'DASgains.txt')

     
   if a EQ '' then begin 
     print, '***********************************WARNING*******************************************'
     message, /info, "DASgains file nonexistent in: '" +path+"' and the conversion will be "+ $
     "proformed without applying gain factor!"
      print, '************************************************************************************'
  
     ;12/19/03 L. Zhang, modified in order to let the program proceed 
     ;without applying gains at bodac_fitsb_convert.
     gains=replicate(1, 192)
     ;gains = -1
     ;stop
   endif else begin
   
     readcol, a, no, gains, /silent

   endelse
   
   return, gains

end
