;+
;===========================================================================
;  NAME: 
;		      bolo_get_time_constant
;
;  DESCRIPTION:     
;		      Calculate time constant for the noise analysis
;
;  USAGE: 
;		      bolo_get_time_constant, logfname, goodpx, tau,	 $
;                     sigma_over_tau,path=path, d83=d83, plot=plot		  
;
;  INPUT: 
;     logfname        A string containing the chopper frequence file's name	  
;     goodpx          A string array containing the good pixel label		  
;     
;  OUTPUT: 
;     tau             A double array containing the time constants		  
;     sigma_over_tau
;                     A double array containing the ratio or sigma/tau  	  
;       
;  KEYWORD:
;     path            A string array containing the input data path. If set, the  
;                     procedure will search files in this directory		  
;     d83             if set, the layout of the plot will be 8 by 3		  
;     plot            If set the plots will be produced 			  
;     bias            A string  						  
;
;  Author: 
;		      L Zhang (extract most of it from the original data 
;                       reduction procedure)
;
;  Edition History
;  
;  date         Programmer      Remarks
;  2003-10-02   L. Zhang        Initial test version
;  2003-12-17   L. Zhang        Add a bias key word to label the bias
;                               amplitude in the plot titile
;  2004-06-03   B. Schulz       bugfix: removed spaces from lg_fname
;				message if file not found
;===========================================================================
;_

PRO bolo_get_time_constant, logfname, goodpx, tau, sigma_over_tau,path=path, $
         bias=bias, d83=d83, plot=plot

   npix = n_elements(goodpx)       ;number of pixels

   readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent
   lg_fname = strcompress(lg_fname, /rem)
   nf = n_elements(lg_fname)

   dat1 = dblarr(1,npix,6)
   fnames = strarr(1)

   dat = dblarr(nf, npix, 6)       ;storage for data
   ;nel = fltarr(nf,npix)           ;storage  
   
   for ifil = 0, nf-1 do begin

     ; find files and load data for same chopper frequency
       if keyword_set(path) then begin 
            flist = findfile(path+strmid(lg_fname[ifil], 0, 13)+'*_pow_*.txt')
       endif else begin
            flist = findfile(strmid(lg_fname[ifil], 0, 13)+'*_pow_*.txt')
       endelse 
       if flist[0] EQ '' then message, 'file '+ strmid(lg_fname[ifil], 0, 13)+'*_pow_*.txt' + ' not found!'
       
       nf1 = n_elements(flist)
     
       dummy = fltarr(nf1,npix,6)     
       for i=0, nf1-1 do begin
           blo_rd_linestr, flist[i], pxstore, finterval, srcfname, path=path
           dummy[i,*,*] = pxstore
       endfor

     ; dat1   = [dat1, dummy]
     ; fnames = [fnames,flist]


     ; average over results of same frequency
       for ipix = 0, npix-1 do begin  
          ix = where(dummy[*,ipix,0] GT 0, cnt)    ;valid entry?
          if cnt GT 0 then begin                      
              ;nel[ifil,ipix] = cnt                 ;number of valid entries
              for i=0, 5 do begin                  ; 6 enteries in the 
                  dummy[0,ipix,i] = avg(dummy[ix,ipix,i])  ;average entries
              endfor
          endif
       endfor
       dat[ifil,*,*] = reform(dummy[0,*,*])      ;save result in first plane
     
       dat1   = [dat1, dummy]
       fnames = [fnames,flist]

  
   endfor  
 
     
   dat1 = dat1[1:*,*,*]
   fnames = fnames[1:*]

   ;plot single values
  
   if keyword_set(plot) then begin 
       if keyword_set(d83) then begin
          !p.multi=[0,8,3] 
          psinit, /letter, /landscape, /color
       endif else begin
          !p.multi=[0,4,6]
          psinit, /letter, /full, /color
       endelse
       if keyword_set (bias) then begin 
           bolo_fit_tau, dat1, goodpx, tau, sigma_over_tau, bias=bias, /plot
       endif else begin
           bolo_fit_tau, dat1, goodpx, tau, sigma_over_tau,  /plot
       endelse 
   endif else begin
       if keyword_set (bias) then begin 
           bolo_fit_tau, dat1, goodpx, tau, sigma_over_tau, bias=bias
       endif else begin
           bolo_fit_tau, dat1, goodpx, tau, sigma_over_tau
       endelse 

   endelse 
 END
