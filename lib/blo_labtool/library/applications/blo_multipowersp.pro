;+
;===========================================================================
;  NAME: 
;		    BLO_MULTIPOWERSP
;
;  DESCRIPTION:   
;		    load multiple data files, calculate power spectra 
;   		    and coadd results quadratically
;
;
;  USAGE: 
;		    blo_multipowersp
;
;  INPUT: 
;		    file selection via gui
;
;  OUTPUT: 
;		    file selection via gui
;
;  KEYWORDS:
;     deglitch      if set signal deglitching is activated before   
;                   FFT transform				    
;
;  AUTHOR: 
;		    Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  15/10/2002   initial test version                    B.Schulz
;  16/10/2002   coadding bugs removed                   B.Schulz
;  27/01/2003   blo_hfi_noise_read renamed to
;               blo_noise_read_binary                   B.Schulz
;  28/01/2003   outfile dialog moved to start           B.Schulz
;  31/01/2003   parameter passing only via strarr       B.Schulz
;  03/02/2003   bugfix run_info                         B.Schulz
;  20/03/2003   only FITS output                        B.Schulz
;  2003/03/21   hourglass added                         B. Schulz  
;  2003/07/09   deglitch keyword added                  B. Schulz  
;  2003/08/07   labels changed back to channel names    B. Schulz  
;  2003/08/11   force DASgains factors                  B. Schulz  
;  2003/10/21   command line input added                B. Schulz  
;  2003/12/18   Add the keyword testing on deglitch     L. Zhang
;               when call blo_noise_powerspec.
;               It was called with deglitch=deglitch
;               before.  Therefore, the deglitch
;               had no effect.  Now the program
;               will test whether deglitch is set.
;               If set, the blo_noise_powerspec will
;               called with deglitch=deglitch
;  2004/06/11   Removed forcing DASGains file           B. Schulz
;===========================================================================
;-

pro blo_multipowersp, flist, outfile, deglitch=deglitch

if n_params() GT 0 then $ 
  filelist = flist $
else $
  filelist = dialog_pickfile( /MULTIPLE_FILES, $
                 /READ, /MUST_EXIST, FILTER = '*.*', $
                         GET_PATH=path, path=getenv('BLO_DATADIR'))

if n_params() EQ 2 then $
  outfilename = outfile $
else $
  blo_savename_dialog, fpath=getenv('BLO_DATADIR'), $
                                extension='fits', outfilename

if filelist[0] NE '' AND outfilename NE '' then begin

  print, "Loading file: ", filelist[0]
  widget_control, /hourglass

  blo_noise_read_auto, filelist[0],run_info, sample_info, $           ;load first file
    colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
    paramline=paramline, data=data, dasgains=dasgains
  if dasgains NE 1 then message, /info, 'No DASgains factors applied!'

  dtim = reform(data[0,*])                ;time
  ndata = n_elements(dtim)                ;number of signals
  nchan = n_elements(data[*,0])           ;number of channels

  frequ = findgen(ndata/2+1L)*ScanRateHz/ndata
  powersp = dblarr(nchan, ndata/2+1)      ;reserve space

  for ichan = 0, nchan-1 do begin
      if keyword_set(deglitch) then begin 
           blo_noise_powerspec, reform(data[ichan,*]), ndata, ScanRateHz, outp, deglitch=deglitch
           powersp(ichan,*) = outp^2
      endif else begin
      
           blo_noise_powerspec, reform(data[ichan,*]), ndata, ScanRateHz, outp

      endelse 
      powersp(ichan,*) = outp^2
 
  endfor


  nfiles = n_elements(filelist)
  actfiles = 1                       ;counter for actually loaded files
  blo_sepfilepath, filelist[0], filename_short, path  ;get short filename

  if nfiles GT 1 then begin
    for ifile = 1, nfiles-1 do begin
 
      print, "Loading file: ", filelist(ifile)
      blo_noise_read_auto, filelist(ifile),run_info1, sample_info1, $ ;load additional file
        colname11, colname21, PtsPerChan1, ScanRateHz1, SampleTimeS1, $
        data=data1
 
  ;---------------------------------------------------------------------

      if nchan EQ n_elements(data1[*,0]) AND  $
         ndata EQ n_elements(data1[0,*])  then begin

 
        for ichan = 0, nchan-1 do begin
	  if keyword_set(deglitch) then begin 
                blo_noise_powerspec, reform(data1[ichan,*]), ndata, ScanRateHz1, outp, deglitch=deglitch
          endif else begin
	        blo_noise_powerspec, reform(data1[ichan,*]), ndata, ScanRateHz1, outp
    
	  endelse 
          powersp(ichan,*) = powersp[ichan,*] + outp^2         ;coadd data quadratically
        endfor

        actfiles = actfiles+1          ;count # of files loaded

      endif else begin
        message, /info, 'File: '+filelist(ifile)+' different number of channels or signals!'
      endelse

  ;---------------------------------------------------------------------
 
    endfor
  endif

  colname1[0] = 'frequency'				   
  colname2[0] = '[Hz]'					   
  for ichan = 1, nchan-1 do begin			   
   ; colname1[ichan] = string(ichan,form='(I3)')+' power'  
    colname1[ichan] =  colname1[ichan]			   
    colname2[ichan] = '[V/sqrt(Hz)]'			   
    powersp[ichan,*] = sqrt(powersp(ichan,*) / actfiles)   
  endfor						   

  powersp[0,*] = frequ  	      ;set frequency axis  
;    run_info = 'Coadd of ' + string(actfiles, form='(i2)') + ' files, first: ' + filename_short
  run_info = [run_info,'Coadd ' + string(actfiles, form='(i2)') + ' files, first: ' + filename_short]


  run_info[0] = 'PowSpec: ' + run_info[0]
  paramline[0] = string(ndata/2+1,form='(I6)')


  blo_save_dialog, powersp, run_info, sample_info, paramline, $
       colname1, colname2, outfilename=outfilename, /fits, dasgains=dasgains
endif else message, /info, 'No File chosen!'

end

