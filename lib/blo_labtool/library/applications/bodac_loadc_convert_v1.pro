
;===========================================================
; BODAC_LOADC_CONVERT
;
; Convert selected list of original Bodac loadcurve files 
; (binary or fits format) into processed loadcurve products.
;
; Usage:
;  BODAC_LOADC_CONVERT
;
; Input:
;	filename to be selected online by widget
;       can be either FITS or bin-file.
;
; Output: Time column is removed and data for the same bias level
;	  is averaged.
;	  File content will be coded as FITS binary tables.
;         Units and column names follow the standard FITS definition.
;         The first column contains the bias voltage while the following
;         columns contain the voltages measured directly at the bolometer.
;         File will also contain errors indicated by titles starting
;         with 'ERR '.
;
;  Keywords:
;        none
;
;  Uses:
;    astrolib Jan 2003 or later
;	us_daylswitch.pro
;	blo_sepfilepath.pro
;	blo_sepfileext.pro
;	blo_noise_read_binary.pro
;
;  Remarks:
;	uses logical 'BLO_DATADIR' as starting point for file search
;
;  Author: Bernhard Schulz (IPAC)
;
;
;  Edition History:
;
;  2003/03/12  B. Schulz  initial test version 
;                         conv. from bodac_fitsb_convert.pro
;  2003/03/14  B. Schulz  first working version for FITS and bin-files
;  2003/03/19  B. Schulz  correct handling of arbitrary step averaging
;  2003/03/20  B. Schulz  read all 3 filetypes
;  2003/03/21  B. Schulz  hourglass added
;  2003/08/04  B. Schulz  changes to bias plateaux discrimination and
;                         gain conversion corrected (nogains keyword)
;  2003/08/12  L. Zhang   Removed all the dasgains related codes
;                         the program was changed to reaad the new fits file
;  2003/08/13  L. Zhang   Add a keyword all to control how many channel
;                         to process
;  2003/08/14  L. Zhang   Add a keyword filename to read the selected
;                         channels from it  
;  2003/08/15  L. Zhang   fix the problem with finding discrete bias plateaux   
;
;      
;===========================================================

pro bodac_loadc_convert_v1, filename,  all=all


filelist = dialog_pickfile( /MULTIPLE_FILES, $
                            /READ, /MUST_EXIST, FILTER = '*.fits', $
                            GET_PATH=path, path=getenv('BLO_DATADIR'))


if filelist(0) NE '' then begin

  widget_control, /hourglass

  nfiles = n_elements(filelist)
  for ifile=0, nfiles-1 do begin        ;start converting file list
    
    ;read file
    blo_noise_read_auto, filelist(ifile),run_info, sample_info, $
       colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=data, dasgains=dasgains

    ;filter the unused channels
    
    if NOT keyword_set(all) then begin
      blo_read_selected_channel, path=path, colname1=colname1, $
      channel_index=channel_index, channel_name=channel_name, $
      temperature_channel=temperature_channel, bias_channel=bias_channel
      ;first column of data is time
      channel_index=[0, channel_index]
      data=data[channel_index, *]
      colname1=colname1[channel_index]
      colname2=colname2[channel_index]
    endif 
    
    ncol = n_elements(data(*,0))       ;determine number of columns

    ;-----------------------------------------------------
    ;convert only if correct original Bodac format

    if strmid(run_info[0],1,1) EQ '/' OR strmid(run_info[0],2,1) EQ '/' $
;       and strpos(strlowcase(run_info[0]),'loadc') GE 0
       then begin

      blo_sepfilepath, filelist(ifile), fname, path
      blo_sepfileext, fname, name, extension
      extension = 'fits'

      nrow = n_elements(data(0,*))

    ;-----------------------------------------------------
    ; find discrete bias plateaux


     width=3
   
      bias_col = where(strpos(strlowcase(colname1), strlowcase(bias_channel)) eq 0 ) 
      if (bias_col eq -1) then message, 'No BIAS channel found, program exit!'
      a = smooth(reform(data(bias_col,*)),width, /EDGE_TRUNCATE, /NAN)
       
      t = reform(data[0,*])
     
      b = shift(a,1)
      c = ABS(a-b)              ;abs inserted 2003/8/4
      c[0] = 0.
      d = blo_clipsigma(smooth(c,width,/EDGE_TRUNCATE,/NAN  ),2.5)
      flag = 0                ;all plateaux well distinguished?
      ix = where(d GT 0,cnt)
      if cnt  LT 1 then flag = 1

      if flag EQ 0 then begin
        frx = where(d LT shift(d,1), nrow1)     ; begin valid
        tox = where(d GT shift(d,1))            ; end valid
        nrow1 = nrow1 - 1
        for i=0, nrow1 do if frx[i] GT tox[i] then flag = 1
      endif


      ;------------------------------------------------------
      ; clean out glitches
      
      if flag EQ 0 then begin
         iz = where(frx NE tox-1 AND frx NE tox-2, cnt)  ;eliminate 1 step events
         ;iz = where(frx NE tox AND frx NE tox-1, cnt)  ;eliminate 1 step events
         if cnt GE 1 then begin
           frx = frx[iz]
           tox = tox[iz]
         endif
         nrow1 = cnt


        biastm = fltarr(nrow1)          ;calculate averages
        biases = fltarr(nrow1)
        biasns = fltarr(nrow1)
        for i=0, nrow1-1 do begin
          biastm[i] =   avg(t[frx[i]:tox[i]])
          biases[i] =   avg(a[frx[i]:tox[i]])
          biasns[i] = stdev(a[frx[i]:tox[i]])
        endfor

        plot, t,a
        oplot, biastm, biases, psym=6

      ;------------------------------------------------------
      ; clean steps that have the same average within errors

        cnt = 1
        while cnt GT 0 do begin

          dbias = (biases - shift(biases,1))[1:nrow1-1]   ;get interval differences
          dlim  = (biasns + shift(biasns,1))[1:nrow1-1]  / 2. ;get noise limits


          ix = where(abs(dbias) LT dlim*4., cnt)     ;check for indistinguishable intervals

          
          if cnt GT 0 then begin
         
	  ; LZ 9/8/03, I think this is a bug when cnt=1
          ;if cnt GT 1 then begin  ;LZ changed to cnt GT 1 
          
            nix = n_elements(ix)
            iy = intarr(nix)
            for i=1, nix-1 do $
              if ix[i]-1 EQ ix[i-1] and iy[i-1] NE 1 then iy[i] = 1
            iy = where(iy NE 1)
            ix = ix(iy)           ;positions to be removed

            flgs = intarr(nrow1)  ;invert selection
            flgs[ix] = 1
            ixt = where(flgs NE 1)
            flgs[ix+1] = 2
            ixf = where(flgs NE 2)
 
            nrow1 = n_elements(ixt)       ;adjust number of rows

            frx = frx[ixf]         ;remove indistinguishable pairs
            tox = tox[ixt]

            
            biastm = fltarr(nrow1)        ;recalculate averages
            biases = fltarr(nrow1)
            biasns = fltarr(nrow1)
            for i=0, nrow1-1 do begin
              biastm[i] =   avg(t[frx[i]+1:tox[i]-1])
              biases[i] =   avg(a[frx[i]+1:tox[i]-1])
              biasns[i] = stdev(a[frx[i]+1:tox[i]-1])
            endfor

      ;      oplot, biastm, biases, psym=7


          endif

        endwhile
      ;------------------------------------------------------
      ; divide bias arbitrarily if no discrete steps are found due to noise
      
      endif else begin
        message, /info, 'No discrete bias plateaux detected!'

        totime = t[nrow-1] - t[0]

        mindt = (t[1]-t[0])*3.
        if mindt GT 0.5 then avgdt = mindt else avgdt = 0.5
					;0.5 sec plateaux but minimum 3 readouts per plateau
        nrow1 = fix(totime / mindt)          
        if nrow1 LT 10 then message, 'Insufficient measurement time!'

        frx = lonarr(nrow1)
        tox = lonarr(nrow1)

        biastm = fltarr(nrow1)
        biases = fltarr(nrow1)
        biasns = fltarr(nrow1)

        delta = totime / nrow1
        for i=0, nrow1-1 do begin

          ix = where(t GT i * delta AND t LE (i+1) * delta, cnt)
          frx[i] = ix[0]
          tox[i] = ix[cnt-1]

          biastm[i] =   avg(t[ix]);calculate averages
          biases[i] =   avg(a[ix])
          biasns[i] = stdev(a[ix])
        endfor
 
      endelse

      ;------------------------------------------------------
      ;calculate final averages and errors 

      plot,  t,a
      oplot, biastm, biases, psym=4

      ncol1 = ncol - 1        ;no time axis anymore

      data1 = fltarr(2*ncol1,nrow1)

      for j=0, ncol1-2 do begin       ;signals
        for i=0, nrow1-1 do begin
          data1[j+1,i]       = avg(data[j+1,frx[i]:tox[i]])
          data1[j+ncol1+1,i] = stdev(data[j+1,frx[i]:tox[i]]) / sqrt(tox[i]-frx[i]-1)
        endfor
      endfor


      ;------------------------------------------------------


      j = ncol1-1                    ;bias
      for i=0, nrow1-1 do begin
        data1[0,i]    = avg(data[j+1,frx[i]:tox[i]])
        data1[ncol1,i] = stdev(data[j+1,frx[i]:tox[i]]) / sqrt(tox[i]-frx[i]-1)
      endfor

      colname1[0] = colname1[ncol-1]  ;move bias to front
      colname2[0] = colname2[ncol-1]

      colname1 = colname1[0:ncol-2]   ;remove bias column
      colname2 = colname2[0:ncol-2]

      colname11 = strarr(ncol1*2)
      colname12 = strarr(ncol1*2)
      ixx1 = indgen(ncol1)
      ixx2 = ixx1 + ncol1

      colname11[ixx1] = colname1         ;signals
      colname12[ixx1] = colname2         ;signal units
      colname11[ixx2] = 'Err '+colname1  ;errors
      colname12[ixx2] = colname2         ;error units


    ;-----------------------------------------------------


      blo_noise_write_bfits, path+blo_getdirsep()+name+'_lc'+'.'+extension, $
                        run_info, sample_info, paramline, $
                        colname11, colname12, data1, /loadcrv, /dasgains, $
                        temperature_channel=temperature_channel,          $
                        bias_channel=bias_channel
      message, /info, filelist(ifile)+': Converted to FITS binary table.'

    endif else begin
      message, /info, filelist(ifile)+': No original BoDAC File header! No output produced.'
    endelse
  endfor    ;filelist

endif else begin
  message, /info, 'No File selected!'
endelse


end
