;+
;===========================================================================
;  NAME: 
;		  blovisu
;  
;  DESCRIPTION: 
;		  Show bolometer data
; 
;
;  USAGE: 
;		  blovisu, filename
; 
;  INPUT:         	   
;    filename     Name of file to be displayed. 			     
;                 File must be bolometer noise file in  		     
;                 either FITS binary table format, native bolometer format,  
;                 or Nicolet ASCII format.				     
;
;  OUTPUT:
;                 Display of each data colum starting from the second	     
;                 versus time. It is assumed that the first data column      
;                 represents time. 					     
;
;  KEYWORDS:     							     
;   fpath         path to initial data directory			     
;   ndx           number of diagrams to plot in x direction		     
;   ndy           number of diagrams to plot in y direction		     
;   pps           invokes plotting into a postscript file instead	     
;                 on screen						     
;   xrange        like in plot command  				     
;   yrange        like in plot command  				     
;   noxlog        prevent logarithmic scale on x-axis			     
;   ylog          logarithmic scale on y-axis'  			     
;   psym          give IDL symbol number for plot			     
;   psautoname    create name for ps autput automatically		     
;   symsize       give relative size for symbol 			     
;   help          show some command line help				     
;   goodpix       if set, only the good pixels will be displayed	     
;
; AUTHOR:
;       	  Bernhard Schulz, IPAC/Caltech 			     
;
; Edition History:      
;       2002/07/24 B. Schulz  initial test version
;       2003/01/22 B. Schulz  adapted to newer read routine, paths in
;                             logicals and DASgains defaults to 1
;       2003/01/27 B. Schulz  blo_hfi_noise_read renamed to blo_noise_read_binary
;       2003/01/29 B. Schulz  ps keyword added
;       2003/02/05 B. Schulz/H. Nguyen  adjustments
;       2003/02/28 B. Schulz  corrected display of titles, double ok? removed
;       2003/03/20 B. Schulz  enabled to read also FITS format, psym added
;       2003/08/06 B. Schulz  comply with blo_read_dasgains operation
;                             help keyword added, ylog, 
;       2003/08/11 B. Schulz  nogains keyword removed from call to read
;       2003/10/22 L. Zhang   add goodpix keyword to display only the good
;                             channels
;       2003/12/10 B. Schulz  keyword psautoname added
;===========================================================================
;-

pro blovisu, filename, fpath=fpath, ndx=ndx, ndy=ndy, goodpix=goodpix,$
                pps = pps, yrange=yrange, xrange=xrange, noxlog=noxlog, ylog=ylog, $
                psym=psym, symsize=symsize, help=help, psautoname=psautoname

if keyword_set(help) then begin
  print, 'blovisu: Show multi channel bolometer data'
  print
  print, 'Syntax: blovisu, <filename>'
  print
  print, 'Filename: Name of file to be displayed.
  print
  print, 'Keywords:'
  print, '  fpath           path to initial data directory'
  print, '  ndx             number of diagrams to plot in x direction'
  print, '  ndy             number of diagrams to plot in y direction'
  print, '  pps             invokes plotting into a postscript file instead'
  print, '                  on screen'
  print, '  psautoname      automatic filenames for ps output'
  print, '  xrange          like in plot command'
  print, '  yrange          like in plot command'
  print, '  noxlog          prevent logarithmic scale on x-axis'
  print, '  ylog            logarithmic scale on y-axis'
  print, '  psym            give IDL symbol number for plot'
  print, '  symsize         give relative size for symbol'
  print, '  help            show some command line help'
  return
endif

;-------------------------------------------
;Set default path to data
; change your preferred default path here!!
if NOT keyword_set(fpath) then $
        fpath = getenv('BLO_DATADIR')

;Select file to display via widget dialog
if n_params() GT 0 then filelist = filename $
else $
  filelist = dialog_pickfile(/READ, /MUST_EXIST, FILTER = ['*.*'], $
                                        GET_PATH=path, path=fpath)

if keyword_set(goodpix) then begin
    goodpix=blo_getgoodpix(path=fpath)
endif 

;-------------------------------------------
;Preparations to save results
if keyword_set(pps) AND filelist(0) NE '' then begin

  if keyword_set(psautoname) then begin
    blo_sepfileext, filelist(0), name, extens
    psfilename = name+'_bv.ps'

  endif else begin
    blo_savename_dialog, fpath=fpath, extension='ps', psfilename, $
                     title='Choose name for ps-output file!'
  endelse
  if psfilename NE fpath AND psfilename NE '' then begin
    pdev_save = !d.name
    set_plot, 'ps'
    device, /color, /landscape, ysize=7.0, xsize=10.0, /inches
    device, filename=psfilename
  endif else filelist(0) = ''
endif


;-------------------------------------------
;Continue if file selected
if filelist(0) NE '' then begin

  blo_sepfilepath, filelist[0], filename, path

  blo_noise_read_auto, path+filename, run_info, sample_info, $
        colname1, colname2, PtsPerChan, $
        ScanRateHzdata, SampleTimeS, data=data       ;read data

 
 if keyword_set(goodpix) then begin
     n=n_elements(goodpix)
     ix=intarr(n)
     for i=0, n-1 do begin
         ix[i] = where( strpos(strupcase(colname1), strupcase(goodpix[i])) eq 0 ) 
    endfor
    colname1=colname1[ix]
    colname2=colname2[ix]
 endif else begin 
   n = n_elements(colname2)                       ;determine number of columns
 endelse  

;-------------------------------------------
; open plot window
  if !D.name EQ 'X' OR !D.name EQ 'WIN' then begin
    window, /free, xsize=1000, ysize=700, title=filename, xpos=10, ypos=10
    windx = !D.WINDOW
  endif

  if NOT keyword_set(ndx) then ndx = 8  ;number of diagrams in x
  if NOT keyword_set(ndy) then ndy = 4  ;number of diagrams in y
  if keyword_set(noxlog) then xlog = 0 ELSE xlog = 1  ;prevent log plot?

  !p.multi=[0,ndx,ndy]

;-------------------------------------------
; loop to plot all diagrams
  for i=1, n-1 do begin

        
    if strlowcase(colname2(i)) EQ strlowcase(colname1(i)) then $
      title = colname1(i) $
    else title = colname1(i)+' '+colname2(i)
    
    if xlog AND NOT keyword_set(xrange) then begin            ;prevent zero plotting with log x-axis
      ix = where(data(0,*) GT 0, cnt)
      if cnt GT 1 then xrange=[min(data(0,ix)), max(data(0,ix))]
    endif

    if keyword_set(ylog) AND NOT keyword_set(yrange) then begin    ;prevent zero plotting with log y-axis
      ix = where(data(i,*) GT 0, cnt)
      if cnt GT 1 then yrange=[min(data(i,ix)), max(data(i,ix))]
    endif
    
    plot, data(0,*), data(i,*),  title=title, $
       xcharsize = 1.0, ycharsize = 1.0, charsize = 1.5, yrange=yrange, $
       xrange=xrange, xlog=xlog, ylog=ylog, psym=psym, ystyle=3, xstyle=3, $
       symsize=symsize
       
    xyouts, 0.1, 0.003, filename, /normal, charsize = 1.5

    if i MOD (ndx*ndy) EQ 0  AND $                              ;wait at end of page
          (!D.name EQ 'X' OR !D.name EQ 'WIN')then begin        ;if screen display
          x = dialog_message("Click 'OK' to continue!")
    endif

  endfor
  if NOT keyword_set(psautoname) then $
    x = dialog_message("Click 'OK' to close the plot window!")
;-------------------------------------------

;  if i MOD (ndx*ndy) NE 0 AND (!D.name EQ 'X' OR !D.name EQ 'WIN') then $
;        x = dialog_message("Click 'OK' to continue!")

  !p.multi=0

  if keyword_set(pps) then begin
    device, /close
    set_plot, pdev_save
    if NOT keyword_set(psautoname) then $
      x = dialog_message('Plot in file: '+psfilename, /information)
  endif else $
    if !D.name EQ 'X' OR !D.name EQ 'WIN' then wdelete, windx     ;close plot window

endif else begin
  message, /info, "No file selected!"
endelse

end
