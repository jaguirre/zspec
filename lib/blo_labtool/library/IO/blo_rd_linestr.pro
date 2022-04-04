;+
;===========================================================================
; NAME: 	 
;		 blo_rd_linestr  
;
; DESCRIPTION:   
;	 	 Read line strength file produced by blo_linestrength.pro
;
; USAGE: 	 
;                blo_rd_linestr, filename, pxstore, finterval, srcfname
;	
; INPUT:        
;   filename 	 (string)
;
; OUTPUT:       
;   pxstore	 (array) [npix,6] where npix is the number of good pixels,  
;		 and the 6 columns are: 				    
;	         mxfreq    frequency of maximum value			    
;	         mxlevel   peak value					    
;	         gfrequ    frequency from Gauss fit			    
;	         gpeak     peak value from Gauss fit			    
;	         gwidth    width of Gaussian				    
;	         gbase     base of Gaussian				    
;   finterval	 frequency interval used				    
;   srcfname	 name of file result was derived from			    
;
; KEYWORDS:
;   pixelnames	 (array string) returns names of pixels
;   path          If set, the blo_getgoodpix will look for
;	         the good pixles from there
;
; AUTHOR:
;		 Bernhard Schulz
;
; Example:
;
;  filename = '/data1/BoDAC/3_Pathfinder/20030520/200305201635_0_time_pow_pk0007.txt'
;  blo_rd_linestr, filename, pxstore, finterval, srcfname
;  IDL> help, pxstore	
;  PXSTORE	   DOUBLE    = Array[36, 6]
;  IDL> print, finterval, srcfname
;  0.500000 1.00000
;  200305201635_0_time_pow.fits
;
;
;
; Edition History:
;
;  Date	       Programmer   Remarks
; 2003/06/09   B. Schulz    initial test version
; 2003/07/23   B. Schulz    keyword pixelnames implemented
; 2003/08/12   B. Schulz    label in file changed to one of fixed length
; 2003/10/22   L. Zhang     Add path keyword to get goodpix from  
;
;===========================================================================
;-
pro blo_rd_linestr, filename, pxstore, finterval, srcfname, $
		pixelnames=pixelnames, path=path

if keyword_set(path) then begin
   goodpx = blo_getgoodpix(path=path)	;good pixel labels
endif else begin
   goodpx = blo_getgoodpix()	;good pixel labels
endelse 

pixelnames=goodpx

npix = n_elements(goodpx)
pxstore = dblarr(npix,6)
pxname  = strarr(npix)


;form='(a14,f9,f11,f9,f11,f11,f11)'

readcol, filename, pxname, mxfreq, mxlevel, gfrequ, gpeak, gwidth, gbase, $
	form='a27,f,f,f,f,f,f', /silent

for pix = 0, npix-1 do begin
  ix = where(goodpx[pix]  EQ pxname, cnt)
  if cnt GT 0 then begin
    pxstore[pix,*] = [mxfreq[ix[0]], mxlevel[ix[0]], gfrequ[ix[0]], $
    		       gpeak[ix[0]],  gwidth[ix[0]], gbase[ix[0]]]
  endif

endfor


readfmt, filename, 'a80', head, numline=2, /silent
srcfname = strtrim(strmid(head[0], (strsplit(head[0],' '))[2]),2)
tmp = strsplit(head[1],' ',/extr)
finterval = [tmp[1], tmp[3]]


end
