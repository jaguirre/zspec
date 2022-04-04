;+
;=============================================================================
; NAME: 
;		  bolo_restore_rstar_tstar_g0_beta
;
; DESCRIPTION: 
;		  Restore the 4 bolometer parameters from a file
;
; USAGE: 
;		  bolo_restore_rstar_tstar_g0_beta, rstar, tstar
; 
; OUTPUT:	   
;    Rstar	  A double precision array contains the Rstar values	    
;    Tstar	  A double precision array contains the Tstar values	    
;    G0	          A double precision array contains the G0 values	    
;    beta	  A double precision array contains the beta values	    
;		 							    
; KEYWORDS:
;    path	  A string variable containing the path of the input file  
;    filename	  A string containing the name of the input file
;    det          returns detector names from file
;           
;  AUTHOR: 
;		  B. Schulz

;  Edition History
; 
;  Date		Progarmmer   Remarks
;  2004/05/02 : B. Schulz    initial test version
;=============================================================================		
;-

pro  bolo_restore_rstar_tstar_g0_beta, rstar, tstar, g0, beta, path=path, $
        filename=filename, silent=silent, det=det


;/data1/SPIRE_CQM/20030711/bolo_rstar_tstar_g0_beta_200307110754.txt


    readcol, /silent, path+filename, channelName, rstar_str, tstar_str, format='A, A, A'

if not keyword_set(path) then path = './'

if not keyword_set(filename) then $
       filename = 'bolo_rstar_tstar_g0_beta.txt'


;path = '/data1/SPIRE_CQM/20030711/'
;filename = 'bolo_rstar_tstar_g0_beta_200307110754.txt'

readfmt, path+filename, "a64", list, skip=2

n = n_elements(list)
rstar = dblarr(n) & tstar = dblarr(n) & g0 = dblarr(n) & beta = dblarr(n)
det = strarr(n)

for i=0, n-1 do begin 
  a = strsplit(list[i], ' ', escape='\', /extract)
  ix = where(strpos(a,'**') GE 0, cnt)
  if cnt GT 0 then a[ix] = '0.0'
  rstar[i] = string(a[1])
  tstar[i] = string(a[2])
  g0[i]    = string(a[3])
  beta[i]  = string(a[4])
  det[i]   = a[0]
endfor

return
end

