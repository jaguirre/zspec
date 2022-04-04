;+
;===========================================================================
;  NAME: 
;	           blo_opt_bias_performance
;
;  DESCRIPTION: 
;	           Calulate the optimum performance and optimum bias
;
;  INPUT:
;     logfname     The optimum frequence log file			      
;   
;  OUTPUT:
;     pixeln       A string array containing the good pixle label	      
;     optBias      A double precision array containing the optimum Bias for   
;                  each channel or pixle				      
;     fitPeakBias  A double precision array containing the poly-fitted peak   
;                  bias value						      
;     
;  KEYWORDS:
;     plot         If set, the optimum performace plot will be produced       
;     path         path to files
;     fintvl       (2 elem. vector) bias interval to use for maximum fit
;
;  AUTHOR:
;		   L. Zhang						      
;
;  Edition History
;
;  Date         Programmer      Remark
;  2003-10-03   L. Zhang    Extracted from the dataReduction program and
;                           then modified to make it a more generic procedure
; 
;  2003-10-22 	L. Zhang    Add path keyword to read the good pixles 
;  2004-06-16 	B. Schulz   Bugfix in case more than one value = max found
;  			    keyword fintvl added
;===========================================================================
;-

PRO  blo_opt_bias_performance,logfname,pixeln,optBias,fitPeakBias,path=path, $
	plot=plot, fintvl=fintvl

  ;Read good pixeles
 
  if keyword_set(path) then begin 
      goodpx = blo_getgoodpix( path=path)	;good pixel labels
  endif else begin
      goodpx =blo_getgoodpix( )
      
  endelse
  
  npix = n_elements(goodpx)	;number of pixels

  ;Read the frequency log file
  readfmt, logfname, 'a28, f9', lg_fname, lg_cfrequ, /silent

  ;Find the date of the measurement for title in the plot
  dateOfMeasurement=strmid(lg_fname[0], 0, 8)
  

  nf = n_elements(lg_fname)


  dat = dblarr(nf, npix, 6)       ;storage for data
  bias = dblarr(nf)
  fnames = strarr(nf)

  fileext='_pow_pk'+string(fix(lg_cfrequ[0]*10),form='(i4.4)' ) + '.txt'
  
  ;Find the data path from the logfname
  blo_sepfilepath, logfname,  file, path

  for ifil = 0, nf-1 do begin
   
       ; find files
       fname1 = path+strmid(lg_fname[ifil], 0, 19)+fileext
       ;fname1 = path+strmid(lg_fname[ifil], 0, 19)+'_pow_pk0041.txt'
       fname2 = path+strmid(lg_fname[ifil], 0, 19)+'.fits'

       blo_rd_linestr, fname1, pxstore, finterval, srcfname, pixelnames=pixeln

       dat[ifil,*,*] = pxstore
       fnames[ifil] = fname1

       blo_noise_read_auto, fname2, run_info, sample_info, $
       colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=data

       bias[ifil] = avg(data[192,*])
     
   endfor

  ;npix = n_elements(dat[0,*,0])


 
   stdv = 1
   nn = 1
   
   optBias=dblarr(npix)
   fitPeakBias=dblarr(npix)
   
   for ipix = 0, npix-1 do begin
   
     ;only good peaks 
     low_frequ=lg_cfrequ[0]-0.1
     high_frequ=lg_cfrequ[0]+0.1
     ix = where(dat[*,ipix,0] LT high_frequ and dat[*,ipix,0] GT low_frequ)   
     rebin_arr, bias[ix], dat[ix,ipix,1], 40, rbx, rby, stdv=stdv, nelem=nn

     err = stdv/sqrt(nn)
     
     if keyword_set(plot) then begin
          plot, rbx*1000., rby*1e6, psym=6, title='Opt. Perf. '+ dateOfMeasurement+ $
              ' '+pixeln[ipix], xtitle = 'bias [mV]', ytitle='signal [muV]', $
              charsize=1.2, xstyle=3, symsize=0.6
            
         errplot, rbx*1000., (rby-err)*1e6, (rby+err)*1e6 
     endif 
     
     ;determine maximum
     ix0 = where( rby EQ max(rby)) & ix0 = ix0[0]
     
     if keyword_set(fintvl) then begin

       ix1 = where(rbx GE fintvl[0] AND rbx LE fintvl[1], cnt)
       if cnt LE 0 then message, "Bad interval!"

     endif else begin

       if ix0-1 GE 0 then ix1 = [ix0-1,ix0]
       if ix0-2 GE 0 then ix1 = [ix0-2,ix0]

       nrby = n_elements(rby)
       if ix0+1 LT nrby then ix1 = [ix1,ix0+1]
       if ix0+2 LT nrby then ix1 = [ix1,ix0+2]

     endelse
     
     a = poly_fit(rbx[ix1], rby[ix1], 2)
     peak = -a[1]/(2*a[2])

     n1 = 20
     mx1=max(rbx[ix1])
     mn1=min(rbx[ix1])
     xnew = findgen(n1)*(mx1-mn1)/(n1-1)+mn1
     
     ff = poly(xnew, a)
    
     if keyword_set(plot) then begin
         oplot, xnew*1000, ff*1e6
         oplot, [peak,peak]*1000, [min(rby),max(rby)]*1e6, linestyle=1
         xyouts, peak*1000, min(rby)*1e6, string(peak*1000,form='(f5.1)')
     endif
    
     optBias[ipix]=rbx[ix0[0]]
     fitPeakBias[ipix]=peak
   endfor

END
