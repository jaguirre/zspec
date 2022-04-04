;+
;=====================================================================
;  NAME: 
;		  blo_fknee
; 
;  DESCRIPTION: 
;		  Determine 1/f knee frequency in power spectrum
;
;  USAGE: 
;		  blo_fknee
;
;  INPUT: 
;		  none      
;     
;
;  OUTPUT: 
;		  list of 1/f knee frequencies     
; 
;
;  KEYWORDS:
;    noplot       if set no plots are generated (fast)			    
;    overwrite    if set no check is performed whether output file exists   
;                 and existing files are overwritten (Caution!) 	    
;    goodpix      if set only good pixels are taken			    
;    interval     If set, the interval will be used, otherwise the default  
;                 will be used 					    
;    infile       If set, the infile will be used			    
;    plot         If set, the program will produce plot output  	    
;
;  AUTHOR: 
;		  B. Schulz
;
;  Example:
;       blo_fknee
;
;  Edition History:
;
;  Date		Programmer  Remarks
;  2003/08/14   B. Schulz   initial test version
;  2003/12/18   L. Zhang    add a print statement when there is no 
;                           plateau found in the interval  
;  2003/12/19   L. Zhang    Add keyword_set testing for goodpix                        
;=====================================================================
;-
pro blo_fknee, noplot=noplot, overwrite=overwrite, interval=interval, $
                        goodpix=goodpix, infile=infile, plot=plot



if n_params() NE 0 then begin
  message, /info, 'Syntax Error!  Usage: blo_onefknee'
  message, /info, 'Keywords: noplot, overwrite, goodpix, infile
  return 
endif

if NOT keyword_set(infile) then begin
  infile = dialog_pickfile(/READ, /MUST_EXIST, FILTER = '*coadd.fits', $
                         GET_PATH=path, path=getenv('BLO_DATADIR'))
endif

if NOT keyword_set(interval) then interval=[5.,20.]     ;Default interval for white noise

blo_sepfilepath, infile, filename, path                                            

blo_sepfileext, filename, name, extens                                             

if infile[0] EQ '' then begin
  message, /info, 'No file selected!'
  return
endif

if keyword_set(goodpix) then begin 
   goodpx = blo_getgoodpix(path=path)               ;good pixel labels
endif 

outfile = path+name+'fknee'+ '.txt'                            

blo_noise_read_auto, infile, run_info, sample_info, $                              
          colname1, colname2, npts, ScanRateHz, SampleTimeS, $                     
          paramline=paramline, $                                                   
          data=data                           ;read data                           

if strpos(strupcase(colname1[0]), 'FREQ') LT 0 then begin                          
  message, /info, 'File contains no power spectrum!'  
  return
endif else begin                                                                   

;------------------------------------------------                                  
  ncol = n_elements(data[*,0])                                                     

 ;------------------------------------------------                                 
 ; verify output filename                                                          
                                                                                   
  if NOT keyword_set(overwrite) then begin                                         
    checkfile = findfile(outfile)           ;check for existing filename           
    if checkfile(0) NE '' then begin                                               
      blo_savename_dialog, fpath=path, extension='txt', outfile, $                 
                        title='Name Conflict!', file=outfile                       
    endif                                                                          
  endif                                                                            
  if outfile EQ '' then return                                                     

 ;------------------------------------------------                                 
 ; prepare output file                                                             

  ix = where(data[0,*] GT 0)
  minf = min(data[0,ix], /nan)
                                                                                   
  openw, unit, outfile, /get_lun                                                   
                                                                                   
  print, 'Processing: '+filename+', Outfile: '+outfile                             

  printf, unit, '1/f Knee Frequencies'                                          
  printf, unit, systime()
  printf, unit, 'Derived from: '+filename                                          
  printf, unit, 'Plateau Interval: '+string(interval[0])+' to '+string(interval[1])        
  printf, unit, 'Minimum Frequency is: '+string(minf)+' '+colname2[0]
  printf, unit                                                                     
  printf, unit, 'label', 'plateau', 'freq1', 'freq2', $   
              form='(a14,x,a12,x,a10,x,a10)'                       
  printf, unit, '', colname2[1], colname2[0], colname2[0], $   
              form='(a14,x,a12,x,a10,x,a10)'                
  printf, unit, '-------------------------------------------------', $  
              form='(a)'                                         


  if keyword_set(plot) then begin
    psinit, /full, /letter
    !p.multi=[0,4,6]
  endif

 ;------------------------------------------------               
 ; loop over channels                                            

  pxplot = 0
                                                                 
  for icol = 1, ncol-1 do begin                                  

    label = colname1[icol] 
;------------------------------------------------               
 ; check if good pixel if keyword set                            

    if keyword_set(goodpix) then begin 
      ix = where(strtrim(strupcase(label),2) EQ goodpx, cnt)       
    endif
    
    if cnt GT 0 OR NOT keyword_set(goodpix) then begin  
  
 ;------------------------------------------------               
 ;select 'good' data                            
                                                                 
      
      ix1 = where(data[0,*] GT 0 AND data[icol,*] GT 0,cnt)
      if cnt GT 0 then begin 
        freq1 = reform(data[0,ix1])
        dat1  = reform(data[icol,ix1])

;      xrange=[min(freq1[ix1]), max(freq1[ix1])]
      xrange=[0.001, max(freq1[ix1])]
    

;------------------------------------------------               
;determine plateau level

      ixint = where( freq1 GE interval[0] AND $       ;pointer to data         
                     freq1 LE interval[1], cnt)       ;within interval         

      plateau = median(dat1[ixint])


;------------------------------------------------               
; find knee

      kfact = 2.0

      ix = where(dat1 LE plateau * kfact AND freq1 LT interval[0], cnt)
      
      if cnt GT 1 then begin
      
        fknee = min(freq1[ix],ixknee, /nan )  ;knee frequency 1st method      

        if keyword_set(plot) then begin                    
          plot_oo, freq1, dat1, psym=3, ystyle=3, xstyle=3, $            
            xtitle='frequency', ytitle='signal', charsize=0.8, $ 
            xthick=2, ythick=2, title=label, $
            xrange=xrange

          oplot, xrange, [1.,1.]*plateau, linest=3               
          oplot, [fknee,fknee],[0.1,100]*1e-9, linestyle=3      
        endif
        
	

        if ix[ixknee] EQ 0  then begin    
                                                      
          printf, unit, colname1[icol], plateau, '----', '----', $                  
                       form= '(a14,x,e12.2,x,a10,x,a10)'                            
        endif else begin                                                            
          ix1 = where(freq1 LE 2*fknee AND dat1 GT plateau, cnt1)                   
                                                                                    
          lgfreq = alog(freq1[ix1])                                                 
          lgf1 = alog(1./ freq1[ix1])   ;model 1/f function in log space            
          
          lgdat = alog(dat1[ix1]-plateau)       ;1/f portion of data in log space   

          rebin_arr, lgfreq, lgdat-lgf1, 6, rbx, rby

          const = avg(rby)    ;fit factor                                 
          lgf2 = lgf1 + const                                                       

          ;plot, lgfreq, lgdat, psym=6    ;test plot                                
          ;oplot, lgfreq, alog(1./freq1[ix1]*exp(const)), linestyle=1               

          fknee2 = 1./ (plateau/exp(const) ) ;more accurate knee frequency          

          if keyword_set(plot) then begin                                          
             oplot, freq1, 1./freq1 * exp(const), linestyle=1                       
             oplot, [fknee2,fknee2],[0.5,5]*plateau, linestyle=1                    
          endif                                                                    

;          c=get_kbrd(1)

          printf, unit, colname1[icol], plateau, fknee,fknee2, $                    
                       form= '(a14,x,e12.2,x,f10.3,x,f10.3)'                        

        endelse                                                                     
        
        if keyword_set(plot) then begin                
          if (pxplot MOD 32) EQ 0 then xyouts, 0.02, 0.02 ,/normal, filename
          pxplot = pxplot + 1
        endif
        
      endif else begin
       ;12/18/03 L. Zhang gadd the following print statement
        result = [0,0]
	printf, unit, colname1[icol], plateau, '----', '----', $                  
                       form= '(a14,x,e12.2,x,a10,x,a10)'      
      endelse

 ;------------------------------------------------               

      endif else begin

        message, /info, 'Pixel '+colname1[icol]+' No valid data found!'
        printf, unit, colname1[icol], '----', '----', '----', $
                        form= '(a14,x,a12,x,a10,x,a10)'

      endelse

;------------------------------------------------               
    endif             ;if good pixel                             



  endfor              ;loop over channels icol                   

 ;------------------------------------------------               
 ;close output file                                              
                                                                 
  free_lun, unit                                                 

  if keyword_set(plot) then begin
    blo_sepfileext, outfile, name, extens
    psterm, file=name+'.ps'
    !p.multi=0
  endif
                                                                 
;------------------------------------------------                
endelse                                                          


end
