;+
;===========================================================================
;  NAME:
;                  BODAC_SEPLOADC
;
;  DESCRIPTION:
;                  average/convert time ordered loadcurve data into loadcurve data structure
;
;  USAGE:
;                  BODAC_SEPLOADC
;
;  INPUT:
;                  bias_channel  (string) name of bias channel
;                  colname1      (array string) names of channels
;                  data          (double nxm array) data values with time in first column
;
;
;  OUTPUT:
;                  data1         (double nxm+1 array) plateau averaged data with time replaced by bias
;                                 and added error channels
;                  Time column is removed and data for the same bias level
;                  is averaged.
;                  File content will be coded as FITS binary tables.
;                  Units and column names follow the standard FITS definition.
;                  The first column contains the bias voltage while the following
;                  columns contain the voltages measured directly at the bolometer.
;                  File will also contain errors indicated by titles starting
;                  with 'ERR '.
;
;  KEYWORDS:
;     all                  If set, all the chennels will be converted to load curve fits files
;     temperature_channel  (string) name of temperature channel. Default is 'ULTRACOLD'
;     ubiasoffs            (float) offset voltage to be added to bias voltage [V]
;
;  AUTHOR:
;                  Bernhard Schulz (IPAC)
;
;
;  Uses:
;       astrolib Jan 2003 or later
;       us_daylswitch.pro
;       blo_sepfilepath.pro
;       blo_sepfileext.pro
;       blo_noise_read_binary.pro
;
;  Remarks:
;       uses logical 'BLO_DATADIR' as starting point for file search
;
;  Edition History:
;
;  Date        Programmer  Remarks
;  2003/03/12  B. Schulz   initial test version
;                          conv. from bodac_fitsb_convert.pro
;  2003/03/14  B. Schulz   first working version for FITS and bin-files
;  2003/03/19  B. Schulz   correct handling of arbitrary step averaging
;  2003/03/20  B. Schulz   read all 3 filetypes
;  2003/03/21  B. Schulz   hourglass added
;  2003/08/04  B. Schulz   changes to bias plateaux discrimination and
;                          gain conversion corrected (nogains keyword)
;  2003/08/12  L. Zhang    Removed all the dasgains related codes
;  2003/08/13  L. Zhang    Add an input parameter, filename
;                          the program was changed to reaad the new fits file
;  2003/08/13  L. Zhang    Add a keyword all to control how many channel
;                          to process
;  2003/08/15  L. Zhang    fix the problem with finding discrete bias plateaux
;
;  2003/09/08  L. Zhang    fix the bug at "clean out glitch" block  and fix
;                          the other bug at the "clean steps that have the
;                          same average within errors" block
;  2003/12/16  L. Zhang    remove the filename parameter
;                          add a filelist parameter which contains all
;                          the input *.bin files
;  2004/02/04  B. Schulz   fixed problem with missing path for search for
;                          selected channel file if keyword filename is set
;  NOTE:                   The SelectedChannel.txt file has to be in the
;                          data directory
;  2004/03/11  B. Schulz   another fix for the bias plateaux discrimination
;  2004/04/12  L. Zhang    add temperature_channel keyword
;  2004/06/03  B. Schulz   changed blo_read_selected_channel interface
;  2004/06/09  B. Schulz   ubiasoffs keyword added
;  2004/07/21  B. Schulz   subroutine separated out of bodac_loadc_convert.pro
;  2004/07/23  B. Schulz   added colname output and ubiasoffs keyword,
;                          stdev set to 0 if less than 2 elements on plateau
;  2004/07/28  B. Schulz   bugfix compare only first el. of where result
;
;===========================================================================
;-

pro bodac_seploadc, colname1, colname2, bias_channel, data, colname11, colname12, data1, ubiasoffs=ubiasoffs

;
nrow = n_elements(data(0,*))
ncol = n_elements(data(*,0))       ;determine number of columns
if NOT keyword_set(ubiasoffs) then ubiasoffs = 0.

;-----------------------------------------------------
; find discrete bias plateaux
;     width=3

bias_col = where(strpos(strlowcase(colname1), strlowcase(bias_channel)) eq 0 )
if (bias_col[0] eq -1) then message, 'No BIAS channel found, program exit!'

a = reform(data(bias_col,*))

t = reform(data[0,*])

b = shift(a,1)
c = ABS(a-b)              ;abs inserted 2003/8/4
c[0] = 0.

d = blo_clipsigma(c,2.5)

flag = 0                ;all plateaux well distinguished?
ix = where(d GT 0,cnt)
if cnt  LT 1 then flag = 1

if flag EQ 0 then begin
  frx = where(d LT shift(d,1), nrow1)     ; begin valid
  tox = where(d LT shift(d,-1))           ; end valid

  if frx[0] GT 0 then begin
    frx = [0,frx-1]
    tox = [tox,nrow-1]
    nrow1 = nrow1 + 1
  endif else begin
    frx[1:*] = frx[1:*]-1
    tox[nrow1-1] = nrow-1
  endelse
  if frx[1]GT tox[1] then message, "From/To inconsistent!"

endif

;------------------------------------------------------
; clean out glitches

if flag EQ 0 then begin
  iz = where(frx NE tox AND frx NE tox-1 AND frx NE tox-2, cnt)  ;eliminate 1 step events
  if cnt GE 1 then begin
    frx = frx[iz]
    tox = tox[iz]
  endif
    nrow1 = cnt
    if nrow1 LT 10 then begin
      message, /info, "Intervals too small!!!"
      flag = 1     ;something went really wrong here
    endif
endif

;------------------------------------------------------
; Accept intervals and average

if flag EQ 0 then begin

  biastm = dblarr(nrow1)          ;calculate averages
  biases = dblarr(nrow1)
  biasns = dblarr(nrow1)
  for i=0, nrow1-1 do begin
    biastm[i] =   avg(t[frx[i]:tox[i]])
    biases[i] =   avg(a[frx[i]:tox[i]])
    biasns[i] = stdev(a[frx[i]:tox[i]])
  endfor

  ;plot, t,a
  ;oplot, biastm, biases, psym=6

;------------------------------------------------------
; clean steps that have the same average within errors

  while cnt GT 1 do begin
    dbias = (biases - shift(biases,1))[1:nrow1-1]   ;get interval differences
    dlim  = (biasns + shift(biasns,1))[1:nrow1-1]  / 2. ;get noise limits


    ix = where(abs(dbias) LT dlim*4., cnt)     ;check for indistinguishable intervals


    ;if cnt GT 0 then begin

    ; LZ 9/8/03, I think this is a bug when cnt=1
    if cnt GT 1 then begin  ;LZ changed to cnt GT 1

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

      biastm = dblarr(nrow1)        ;recalculate averages
      biases = dblarr(nrow1)
      biasns = dblarr(nrow1)
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

  biastm = dblarr(nrow1)
  biases = dblarr(nrow1)
  biasns = dblarr(nrow1)

  delta = totime / nrow1

  for i=0, nrow1-1 do begin

    ix = where(t GT i * delta AND t LE (i+1) * delta, cnt)
    if cnt LE 0 then begin

      frx[i] = -1           ;mark empty plateau
      tox[i] = -1
    endif else begin
      frx[i] = ix[0]
      tox[i] = ix[cnt-1]

      biastm[i] =   avg(t[ix]);calculate averages
      biases[i] =   avg(a[ix])

      if n_elements(ix) GE 2 then biasns[i] = stdev(a[ix]) $
      else biasns[i] = 0.
    endelse

  endfor

  ix = where(frx GT -1, cnt)
  if cnt LT nrow1 then begin
    frx = frx[ix]
    tox = tox[ix]
    biastm = biastm[ix]
    biases = biases[ix]
    biasns = biasns[ix]
    nrow1 = cnt
  endif
endelse

;------------------------------------------------------
;calculate final averages and errors

;plot,  t,a
;oplot, biastm, biases, psym=4

ncol1 = ncol - 1        ;no time axis anymore

data1 = dblarr(2*ncol1,nrow1)

for j=0, ncol1-2 do begin       ;signals
  for i=0, nrow1-1 do begin
    data1[j+1,i]       = avg(data[j+1,frx[i]:tox[i]])
    if frx[i] EQ tox[i] then data1[j+ncol1+1,i] = 0 $
    else data1[j+ncol1+1,i] = stdev(data[j+1,frx[i]:tox[i]]) / sqrt(tox[i]-frx[i]-1)
  endfor
endfor


;------------------------------------------------------


j = ncol1-1                    ;bias
for i=0, nrow1-1 do begin
  data1[0,i]    = avg(data[j+1,frx[i]:tox[i]]) + ubiasoffs
  if frx[i] EQ tox[i] then data1[ncol1,i] = 0 $
  else data1[ncol1,i] = stdev(data[j+1,frx[i]:tox[i]]) / sqrt(tox[i]-frx[i]-1)
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

return
end