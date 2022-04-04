;+
;=================================================================
;  NAME: 
;		   BLO_LOAD_MULTIDATA
;
;
;  DESCRIPTION: 
;		   load multiple data files into buffer
;	           by default concatenate files if same number of 	  
;	           channels upon keyword set coadd files if same  	
;	           per channel and same timing					
;	           Three filetypes are distinguished automatically by   
;	           extensions  '.fits', .'txt', and '.bin'					
;
;
;  USAGE: 
;		   blo_load_multidata, 
;
;  INPUT:
;     filelist     (array of strings) filenames to load        
;     dtim	   (array double) new x axis of data array     
;     data	   (array double) 2 dim data array	       
;     run_info     (string) first file header line	       
;     sample_info  (string array) new sample info	       
;     paramline    (string array)  new parameter line	       
;     colname1     (string array)  new channel names	       
;     colname2     (string array) new channel units	       
;
;  OUTPUT: 
;		   updated data and control structures
;
;  KEYWORDS:
;     coadd        (int) if set multiple files are coadded and averaged 
;		   rather than concatenated
;
;
;  AUTHOR: 
;		   Bernhard Schulz (IPAC)
;
;  Using:
;       blo_noise_read_auto
;       blo_sepfilepath
;       blo_replace_buffer
;
;
;  Edition History:
;  
;  Date		Programmer  Remark
;  2002/10/14   B. Schulz   initial test version
;  2002/10/15   B. Schulz   interface change
;  2003/01/17   B. Schulz   FITS reading capability
;  2003/01/27               Changed to FITS binary table IO and
;                           blo_hfi_noise_read renamed to
;               B. Schulz   blo_noise_read_binary
;  2003/02/01   B. Schulz   parameter passing via strarr only
;  2003/03/20   B. Schulz   automatic filetype recognition including Nicolet 
;                           ASCII format
;
;
;===========================================================================
;-

pro blo_load_multidata, filelist, dtim, data, run_info, $
                              sample_info, paramline, colname1, colname2, $
                                    coadd=coadd

print, "Loading file: ", filelist[0]

blo_noise_read_auto, filelist[0],run_info, sample_info, $           ;load first file
  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
  paramline=paramline, data=data

 
dtim = reform(data[0,*])             ;time
ndata = n_elements(dtim)             ;number of signals
 
nfiles = n_elements(filelist)
actfiles = 1               ;counter for actually loaded files
blo_sepfilepath, filelist[0], filename_short, path  ;get short filename

run_info=[filename_short, run_info]

;---------------------------------------------------------------------
 
if nfiles GT 1 then begin

  for ifile = 1, nfiles-1 do begin
  
    print, "Loading file: ", filelist(ifile)


    blo_noise_read_auto, filelist[ifile], run_info1, sample_info1, $   ;load additional file
      colname11, colname21, PtsPerChan1, ScanRateHz1, SampleTimeS1, $
      data=data1

;---------------------------------------------------------------------
    if keyword_set(coadd) then begin

      if n_elements(data(0,*)) EQ n_elements(data1(0,*))  then begin
        ndata = n_elements(data(0,*))                         ;number of signals

        for isig = 0, ndata-1 do $
          data(1:*,isig) = data(1:*,isig) + data1(1:*,isig)   ;coadd data without changing time

        actfiles = actfiles+1          ;count # of files loaded
      endif else begin
        message, /info, 'File: '+filelist(ifile)+' different number of channels!'
      endelse

;---------------------------------------------------------------------
    endif else begin
 
      if n_elements(data(*,0)) EQ n_elements(data1(*,0))  then begin
        ndata = n_elements(data(0,*))                           ;previous number of signals
        dtim  = [dtim, reform(data1(0,*) + dtim(ndata-1) + $
                              (dtim(ndata-1)- dtim(ndata-2)))]  ;adjust time axis one delta
                                                                ;away from previous dataset
 
        data = transpose([transpose(data),transpose(data1)])    ;add more data
        actfiles = actfiles+1          ;count # of files loaded
      endif else begin
        message, /info, 'File: '+filelist(ifile)+' different number of channels!'
      endelse

    endelse
;---------------------------------------------------------------------
 
  endfor

  if keyword_set(coadd) then begin
    data(1:*,*) = data(1:*,*) / actfiles   ;make average
    run_info[0] = 'Average '+ run_info[0]
    
    run_info = [run_info, string(actfiles, form='(i2)') + ' files, first: ' + filename_short]
  endif else begin
    data(0,*) = dtim    ;get time right in first channel of concatenated buffers
    run_info[0] = 'Concat '+ run_info[0]
    run_info = [run_info, string(actfiles, form='(i2)') + ' files, first: ' + filename_short]
  endelse

endif

end

