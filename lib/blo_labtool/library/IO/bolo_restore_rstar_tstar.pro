;+
;=============================================================================
; NAME: 
;		  bolo_restore_rstar_tstar
;
; DESCRIPTION: 
;		  Restore the Rstar and Tstar from a file
;
; USAGE: 
;		  bolo_restore_rstar_tstar, rstar, tstar
; 
; OUTPUT:	   
;    Rstar	  A double precision array contains the Rstar values	    
;    Tstar	  A double precision array contains the Tstar values	    
;		 							    
; KEYWORDS:
;    path	  A string variable containing the path of the RTstar file  
;    filename	  A string containing the name of the file which	    
;	          contains the Rstar and Tstar
;    silent       if set resistances are not printed			    
; 
;  AUTHOR: 
;		  L. Zhang
;
;  Edition History
; 
;  Date		Progarmmer   Remarks
;  2003/09/15 : L. Zhang     initial test version
;  2004/03/11 : L. Zhang     When restore the Rstar and Tstar values, 
;                            if the Rstar and Tstar fields are '******',
;                            set the rstar and tstar expressed by '******' to 0.
;                            Remove all rows which is not valid Rstar and Tstar values
;                            such as '-----------------------------' etc.
;                            Purpose: Easy to see when we print Rstar and Tstar
;                            in the data reduction procedure
;  2004/04/24 : B.Schulz     introduced keyword silent
;=============================================================================		
;-

pro  bolo_restore_rstar_tstar, rstar, tstar, path=path, $
        filename=filename, silent=silent


    if not keyword_set(path) then $
        path = '/data1/SPIRE_CQM/20030722b/'

    if not keyword_set(filename) then $
       filename = 'RstarTstar_20030708.txt'

    ;readcol, /silent, path+filename, channelName, rstar, tstar, format='A, f,f'
    readcol, /silent, path+filename, channelName, rstar_str, tstar_str, format='A, A, A'
    
    ;Define the maxmimum possible size to hold all the data
    nchannel=n_elements(channelName)
    rstar=dblarr(nchannel)
    tstar=dblarr(nchannel)
    inx=0
    for i=0, nchannel-1  do begin  
        ;print, i, ' ', rstar_str[i]
        c=strmid(strtrim(rstar_str[i], 2), 0, 1)
        d=strmid(strtrim(tstar_str[i], 2), 0, 1)
        if ( c eq '*') or ( d eq '*') then begin
  	   rstar[inx]=0.0d
	   tstar[inx]=0.0d
           inx=inx+1
         endif else begin
             if bolo_is_a_digit(c) and bolo_is_a_digit(d) then begin
 	          rstar[inx]=double(rstar_str[i])
	          tstar[inx]=double(tstar_str[i])
                  inx=inx+1
  	      endif else continue
         endelse
    endfor
    ;remove the extra elements defined at the beginining.
    rstar=rstar[0:inx-1]  
    tstar=tstar[0:inx-1]
    if NOT keyword_set(silent) then begin
      for i=0, n_elements(rstar)-1 do begin
        print, i, ' ', rstar[i], ' ', tstar[i]
      endfor
    endif
    
    return
end
