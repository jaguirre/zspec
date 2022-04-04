;+
;=====================================================================
;  NAME: 
;		   blo_ch2fftunits
;  
;  DESCRIPTION: 
;		   Change units and labels in file header for 
;		   power/fft spectrum
; 
;
;  INPUT:           
;    colname1	  (string arr) labes of channels      			     
;    colname2,    (string arr) units of channels     			     
;
;  OUTPUT:        							    
;    colname1	  (string arr) labes of channels      			     
;    colname2,    (string arr) units of channels    			     
;       
;
;  KEYWORDS:
;    nopower	  return simple fourier spectrum without normalization       
;    		  to W/sqrt[Hz] 					     
; AUTHOR:
;		  Bernhard Schulz					     
;
;
; Edition History:
;
; 2003/05/15 B. Schulz initial test version
; 2003/08/12 B. Schulz change of labels removed
;
;=====================================================================
;-
pro blo_ch2fftunits, colname1, colname2, nopower=nopower

  colname1(0) = 'Frequ'       ;update first column titles
  colname2(0) = '[Hz]'            ;update first column titles

;  for i = 1, n_elements(colname2)-1 do begin  
;    if keyword_set(nopower) then $
;      colname1[i] = 'FFT '+colname1[i]	      $
;    else $
;      colname1[i] = 'Pow '+colname1[i]	      
;  endfor				      

  if NOT keyword_set(nopower) then begin
    for i = 1, n_elements(colname2)-1 do begin
      p1 = strpos(strupcase(colname2[i]), '(V)')
      p2 = strpos(strupcase(colname2[i]), '[V]')
      if p1 GE 0 THEN colname2[i] = strmid(colname2[i],0,p1) + '[V/sqrt(Hz)]' + $
      			strmid(colname2[i],p1+3)
      if p2 GE 0 THEN colname2[i] = strmid(colname2[i],0,p2) + '[V/sqrt(Hz)]' + $
      			strmid(colname2[i],p2+3)
    endfor
  endif

return
end
