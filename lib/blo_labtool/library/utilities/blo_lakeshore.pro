;+
;==============================================================================
;  NAME: 
;		  BLO_LAKESHORE
;
;  DESCRIPTION:   
;		  transform resistance in [Ohm] measured by LakeShore 
;                 thermometer into temperature in [Kelvin]
;
;  USAGE: 
;		  T = blo_lakeshore(R)
;
;  INPUT:
;      R         (float) can be array, resistance in [Ohm]	  
;
;  OUTPUT:
;     function   (float) temperature in [Kelvin]		  
;
;  KEYWORDS:
;      ic        if set high temp. sensor GR-200A-500-CD is used  
;                default is low temp. sensor GR-200A-50-0.1B	  
;      grt       if set ow temp. sensor GRT No. 28027 is used	  
;
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  REMARKS      :
;      Conversion parameters and formula were taken from LakeShore
;      Calibration Reports 362107 and 401804.
;
;  Edition History:
;
;  Date         Programmer   Remarks 
;  ----------   ----------   ----------------------------------------------                     
;  2003/03/21   B.Schulz     initial test version                                
;  2003/03/25   B.Schulz     added array input capability                        
;  2003/07/32   B.Schulz     added new sensor GRT No. 28027           
;  2003/09/16   B.Schulz     more informative warning message and moved GRT
;                            threshold to 10200 Ohms                            
;  2003/09/16   B. Schulz    Quick fix for R>10kOhm  for grt sensor  
;  2003/10/13   B. Schulz    Change the default grt temperature from 253mK to 249mK
;  2003/12/09   B. Schulz    extended range of sensors GR-200A-500-CD and GRT No. 28027
;                            according to graph in data sheet
;==============================================================================
;-

function blo_lakeshore, R, ic = ic, grt=grt

r = abs(r)

T = R*0.
for j=0, n_elements(R)-1 do begin

if NOT keyword_set(ic) then begin
  if NOT keyword_set(grt) then begin

;-------------------------------------------------
; ULTRACOLD conversion
;-------------------------------------------------

   
    if R[j] LT 8.032 OR R[j] GT 8.32e4 then $
          message, /info, "R_uc["+strtrim(string(j),2)+"]="+ $
          strtrim(string(R[j]),2)+" outside calibrated range!"

    if R[j] GT 70.53 then begin

      ZL = 1.78881289835d
      ZU = 5.38213416015d

      A = [ 0.358231,  $
           -0.448313, $
            0.269381, $
           -0.169188, $
            0.087421, $
           -0.042129, $
            0.017921, $
           -0.001312, $
            0.005754, $
            0.002628, $
            0.003619]

    endif else $
    if R[j] GT 15.55 then begin

      ZL = 1.14781192521
      ZU = 1.90268115389

      A = [ 4.715195,  $
           -5.040443, $
            1.747838, $
           -0.462125, $
            0.113136, $
           -0.036068, $
            0.014404, $
           -0.005228, $
            0.001286]

    endif else begin

      ZL = 0.86955221726
      ZU = 1.25006676331

      A = [ 23.040586, $
           -18.766364, $
             3.916225, $
             0.260262, $
            -0.478334, $
             0.040831, $
             0.094534, $
            -0.032333, $
            -0.016280, $
             0.009190, $
             0.003285, $
            -0.005694]
            
    endelse

  endif else begin

;-------------------------------------------------
; COLDFINGER conversion
;-------------------------------------------------

    if R[j] LT 7.409 OR R[j] GT 17320. then $
          message, /info, "R_grt["+strtrim(string(j),2)+"]="+ $
          strtrim(string(R[j]),2)+" outside calibrated range!"


    if R[j] GT 6283. then begin
      
      A = 0
      lst_R = [6283.,   6833.   , 9525. , 17320.] ;last point extrapolated on graph
      lst_T = [0.300007,0.291015, 0.2526, 0.2   ]

    endif else $
    if R[j] GT 54.98 then begin

      ZL = 1.67104534868d
      ZU = 3.97845443337d

      A = [.919148,  $
           -.928186, $
           .401224, $
           -.197933, $
           .088885, $
           -.040003, $
           .016926, $
           -.005900, $
           .001623, $
           -.000675, $
           .000325]

    endif else $
    if R[j] GT 16.08 then begin

      ZL = 1.16040365879d
      ZU = 1.83534382616d

      A = [5.825509,  $
           -5.350946, $
           1.571688,  $
           -0.308869, $
           0.070785,  $
           -0.032335,  $
           0.011670  ]

    endif else $
    if R[j] GT 7.409 then begin

      ZL = 0.823681743610d
      ZU = 1.26657182954d

      A = [24.453453,  $
           -18.422008, $
           2.750794,   $
           0.582504,   $
           -0.216678,  $
           -0.127366,  $
           0.048212,   $
           0.027995,   $
           -0.014134,  $
           -0.009636  ]

    endif

  endelse
    
  endif else begin

  ;-------------------------------------------------
  ; INTRCOOL conversion
  ;-------------------------------------------------


    if R[j] LT 1.973 OR R[j] GT 16562.9 then $
          message, /info, "R_ic["+strtrim(string(j),2)+"]="+ $
            strtrim(string(R[j]),2)+" outside calibrated range!"

    if R[j] GT  10175.6 then begin                ;1.023e4

      A = 0
      lst_R = [10175.6, 12651.4, 16562.9]
      lst_T = [1.40265, 1.31274, 1.21303]

    endif else $
    if R[j] GT  269.9 then begin
    
      ZL = 2.18075928482
      ZU = 4.21913731242

      A = [ 3.716842, $
           -3.305466, $
            0.958110, $
           -0.153159, $
           -0.016348, $
            0.016172, $
           -0.000965, $
           -0.003868, $
            0.001615]
            
    endif else $
    if R[j] GT 11.11 then begin
    
      ZL = 0.9563753495
      ZU = 2.62672509845

      A = [ 14.721739, $
           -12.075463, $
             3.130963, $
            -0.847103, $
             0.157385, $
             0.001878, $
            -0.001585]
           
    endif else begin
    
      ZL = 0.24602439558
      ZU = 1.14648417674

      A = [ 56.339282, $
           -41.963818, $
            13.117493, $
            -4.820759, $
             2.063241, $
            -0.981983, $
             0.492488, $
            -0.256353, $
             0.142729, $
            -0.072790, $
             0.049007, $
            -0.018898, $
             0.019066]
           
    endelse
    
  endelse


  if n_elements(A) GT 1 then begin      ;Chebychev interpolation

    Z = alog10(R[j])

    X = ((Z-ZL) - (ZU-Z)) / (ZU-ZL)

    for i=0, n_elements(A)-1 do $
      T[j] = T[j] + total( A[i] * cos( i * acos(X)))

;    if abs(R[j]) GT 9400 AND keyword_set(grt) then T[j] = 0.249

  endif else begin
 
    if n_elements(lst_T) GT 0 then $    ;linear interpolated temperature from diagram
    
    T[j] = exp(interpol(alog(lst_T), alog(lst_R), alog(R[j]))) $

    else T[j] = 0                       ;uncalibrated temperature
    
  endelse


endfor


return, T

end
