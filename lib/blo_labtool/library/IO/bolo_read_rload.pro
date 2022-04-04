;+
;===========================================================================
;  NAME: 
;		  bolo_read_rload
;
;  DESCRIPTION: 
;		  read a Resistances from a file
;
;  USAGE: 
;		  bolo_read_rload, Rload1, Rload2,  path=path, $
;		  filename=filename
;
;  OUTPUT:	
;     Rload1	  The first load resistance	  
;     Rload2	  The second load resistance	  
;	
;  KEYWORDS:	  				 
;     path    	  the path of the Rload.txt file  
;     filename	  the load resistance file	  
; 
;  Author: 
;		  L. Zhang
;
;  Editing History
;
;  Date		Progarmmer   Remarks
;  20030918 	L. Zhang     initial testing version
;===========================================================================
;-

pro  bolo_read_rload, Rload1, Rload2,  path=path, filename=filename


    if not keyword_set(path) then $
        path = '/data1/SPIRE_CQM/20030722b/'

    if not keyword_set(filename) then $
       filename = 'Rload.txt'

    infile = findfile(path + filename, count=count)

    if ( count eq  0  ) then begin
       ;The maximum channel number is 120
       Rload1=dblarr(120) +1.e7
       Rload2=dblarr(120) +1.e7
      
    endif else begin
       readcol, /silent, infile, channelNo, Rload1, Rload2, format='A, f,f'
       Rload1=Rload1*1e6
       Rload2=Rload2*1e6
       
    endelse
    

    return
end
