;+
;=================================================================
; NAME:
;                  blo_noise_read_bfits.pro
;
; DESCRIPTION:
;                  Read bolometer noise files in binary table FITS format
;
; USAGE:
;                  blo_noise_read_pfits, infile, run_info, sample_info, $
;                  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
;                  paramline=paramline, data=data
;
; INPUT:
;  infile          The name of the file to read.
;
; KEYWORDS:
;  paramline       returns array of strings from parameter line in header
;                  The first 3 are PtsPerChan, ScanRateHz, SampleTimeS
;                  this keyword allows to read any other additional parameters
;  dasgains        if set dasgains keyword was found in header
;
;
; OUTPUT:
;  run_info        (string array)
;                    1. date of measurement format: MM/DD/YYYY HH:MM:SS
;                    2. name of data acquisition program used
;                    3. 'AIDS'
;                    4. telescope name
;
;  sample_info     (string array) titles of three header parameters
;  colname1        An array of strings with identifiers of the columns in the
;                  data array
;  colname2        An array of strings with the names of the columns in the
;                  data array
;  PtsPerChan      Points per channel ( # of datapoints in one column)
;  ScanRateHz      The scanning rate in Hz.
;  SampleTimeS     Sample time (inverse of ScanRateHz)
;  data            data array
;
; Example:
;      IDL> path = '/scr2/project/spire/bolo/hfi/code/bodacfitscnv_bfits/'
;      IDL>
;      IDL>
;      IDL> blo_noise_read_bfits, $
;      IDL>  path+'20021025_LIA2_gain_0_time.fits', $
;      IDL>   run_info, sample_info, $
;      IDL>   colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
;      IDL>   paramline=paramline, data=data
;      % READFITS: Now reading 193 by 1024 array
;      IDL>
;      IDL> print, run_info
;      10/25/2002 02:33:28 PM BoDAC DAS Code Version 1.01 AIDS BoDAC
;      IDL> print, sample_info
;      No.Pts/Chan Scan Rate (Hz) Sample Time (s) Bias Freq (Hz) Bias Vpp Waveform
;       DCbiasEquivalent
;      IDL> print, PtsPerChan
;            1024.00
;      IDL> print, ScanRateHz
;            1000.00
;      IDL> print, SampleTimeS
;            1.00000
;      IDL> print, paramline
;              1024        1000.0000        1.0000000        0.0000000
;              0.0000000 square          0.0000000
;      IDL> help, colname1
;      COLNAME1        STRING    = Array[193]
;      IDL> print, colname1[0:3]
;      TIME     Chan 1-1 Chan 1-2 Chan 1-3
;      IDL> help, colname2
;      COLNAME2        STRING    = Array[193]
;      IDL> print, colname2[0:3]
;      [sec]    [Volts]  [Volts]  [Volts]
;      IDL> help, data
;      DATA            FLOAT     = Array[193, 1024]
;      IDL>
;
;
; Author: Bernhard Schulz
;
; History:
; 2003/01/17  B. Schulz  initial test version
; 2003/01/27  B. Schulz  bugfix filetype
; 2003/01/27  B. Schulz  blo_fits_noise_read renamed to blo_noise_read_pfits
; 2003/01/28  B. Schulz  close unit
; 2003/01/30  B. Schulz  parameter passing via strarr only
; 2003/03/14  B. Schulz  file type LOADCRV allowed
; 2004/02/19  B. Schulz  compatibility with FTS bolometer files
;                        and bugfix for TUNIT not found condition
; 2004/02/25  B. Schulz  several fixes in case important keywords are not found in header
; 2004/07/15  B. Schulz  absolute times restored due to sync problem with offset adition
;                        and ensured colons in original PST time string.
; 2004/07/18  B. Schulz  safeguard against string variables in input column
; 2004/07/28  B. Schulz  bugfix compare only first el. of findfile result
;=================================================================
;-
; Generic read routine

pro blo_noise_read_bfits, infile, run_info, sample_info, $           ;load first file
  colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
  paramline=paramline, data=data, dasgains=dasgains



filen = findfile(infile)
if filen[0] EQ '' then message, "File not existing!"

hdr = headfits(infile)                  ;get primary header


filetype = strtrim(fxpar(hdr, 'FILETYPE'),2)
;if filetype EQ 'NOISE' OR filetype EQ 'LOADCRV' OR filetype EQ 'KD Jython Script?' then begin
if filetype EQ 'NOISE' OR filetype EQ 'LOADCRV' OR filetype EQ 'TF Jython Script' then begin
endif else begin
  message, /info, 'Unknown file type!'
  data = [0]
endelse


;get binary table data

fxbopen, unit, infile, 1, bhdr          ;get binary table header
ncol=fxpar(bhdr,'TFIELDS')

fxbfind, unit, 'TTYPE', columns, colname1, n_found1
if n_found1 NE ncol then begin
  message, /info, 'Inconsistent header (TTYPE) in file: '+infile
  message, /info, 'Empty column names!"
  colname1=strarr(ncol)
endif

fxbfind, unit, 'TUNIT', columns, colname2, n_found2
if n_found2 NE ncol then begin
  message, /info, 'Inconsistent header (TUNIT) in file: '+infile
  message, /info, 'Empty unit names!"
  colname2=strarr(ncol)
endif


h_origin   = fxpar(hdr, 'ORIGIN')
h_telescop = fxpar(hdr, 'TELESCOP', count=h_telescop_c)
h_filename = fxpar(hdr, 'FILENAME')
h_date     = fxpar(hdr, 'DATE')
h_datepst  = fxpar(hdr, 'DATEPST',  count=h_datepst_c)
h_timepst  = fxpar(hdr, 'TIMEPST',  count=h_timepst_c)
h_date_obs = fxpar(hdr, 'DATE-OBS', count=h_date_obs_c)
h_filetype = filetype
h_code_ver = fxpar(hdr, 'CODE_VER', count=h_code_ver_c)
h_nsamples = fxpar(hdr, 'NSAMPLES', count=h_nsamples_c)
h_rotfrequ = fxpar(hdr, 'ROTFREQU', count=h_rotfrequ_c)
h_samptime = fxpar(hdr, 'SAMPTIME', count=h_samptime_c)
h_biasfreq = fxpar(hdr, 'BIASFREQ', count=h_biasfreq_c)
h_biasvpp  = fxpar(hdr, 'BIASVPP',  count=h_biasvpp_c)
h_waveform = fxpar(hdr, 'WAVEFORM', count=h_waveform_c)
h_dcbiaseq = fxpar(hdr, 'DCBIASEQ', count=h_dcbiaseq_c)
h_fileorig = fxpar(hdr, 'FILEORIG', count=h_fileorig_c)

h_dasgains = fxpar(hdr, 'DASGAINS')     ;set keyword dasgains if found
if !err GE 0 then dasgains = 1 else dasgains=0


;------------------------------------------------
; get data

fxbreadm, unit, colname1, PASS_METHOD='POINTER', POINTERS = ppp, BUFFERSIZE=0

fxbclose, unit

nline=n_elements(*ppp[0])
data = dblarr(ncol, nline)

for idx=0l,ncol-1 do begin
  if size( (*ppp[idx])[0], /type) NE 7 then $
    data[idx,*] = (*ppp[idx]) $
  else message, /info, 'Column '+colname1[idx]+' '+string(idx,form='(i3)')+' string, ignored!'
endfor

ptr_free,ppp

;-----------------------------------------------------------

if h_date_obs_c EQ 0 then begin
  if data[0,0] LT 1e9 then begin
    h_date_obs = '0000-00-00T00:00:00'
  endif else begin
    time = data[0,0]
    h_date_obs =  tai2utc(time,/ccsds)
  endelse
endif

if h_datepst_c EQ 0 then begin
    h_datepst=strmid(h_date_obs,0,10)
endif

if h_timepst_c EQ 0 then begin
    h_timepst=strmid(h_date_obs,11,8)
endif else begin
  h_timepst=repstr(h_timepst,'-',':')   ;ensure format with colons
endelse


if h_nsamples_c EQ 0 then begin
  h_nsamples = nline
  message, /info, "NSAMPLES keyword not found!"
endif


if h_nsamples NE nline then begin
  message, /info, "Inconsistent NSAMPLES in header and data!"
  h_nsamples = nline
endif

if h_rotfrequ_c EQ 0 then begin
  if h_samptime_c EQ 0 then begin
    h_rotfrequ = float(nline-1)/(data[0,nline-1]-data[0,0])
    h_samptime = 1./h_rotfrequ
  endif else begin
    h_rotfrequ = 1./h_samptime
  endelse
endif else begin
  if h_samptime_c EQ 0 then begin
    h_samptime = 1./h_rotfrequ
  endif
endelse

if h_waveform_c EQ 0 then begin
  h_waveform = ''
  message, /info, "WAVEFORM keyword not found!"
endif

if h_code_ver_c EQ 0 then begin
  h_code_ver = ''
  message, /info, "CODE_VER keyword not found!"
endif

if h_telescop_c EQ 0 then begin
  h_telescop = ''
  message, /info, "TELESCOP keyword not found!"
endif

if data[0,0] GE 1e9 THEN begin

  ;data[0,*] = data[0,*] - data[0,0]     ;make small times
endif
;-----------------------------------------------------------

run_info=[strmid(h_datepst,5,2)+'/'+ $
          strmid(h_datepst,8,2)+'/'+ $
          strmid(h_datepst,0,4)+' '+ $
          h_timepst, $
          h_code_ver, $
          'AIDS', $
          h_telescop]

if h_fileorig NE '' then begin
  if strtrim(h_fileorig,2) EQ 'CONCAT'  then $
     run_info[0] = 'Concat ' +run_info[0]
  if strtrim(h_fileorig,2) EQ 'AVERAGE' then $
     run_info[0] = 'Average '+run_info[0]
  if strtrim(h_fileorig,2) EQ 'POWERSP' then $
     run_info[0] = 'PowSpec: '+run_info[0]
  if strtrim(h_fileorig,2) EQ 'HISTOG' then $
     run_info[0] = 'Histogram: '+run_info[0]
endif

sample_info = ['No.Pts/Chan', $
              'Scan Rate (Hz)', $
              'Sample Time (s)', $
              'Bias Freq (Hz)', $
              'Bias Vpp', $
              'Waveform', $
              'DCbiasEquivalent']

paramline = [string(h_nsamples), $
            string(h_rotfrequ), $
            string(h_samptime), $
            string(h_biasfreq), $
            string(h_biasvpp), $
            h_waveform, $
            string(h_dcbiaseq)]

PtsPerChan = float(h_nsamples)
ScanRateHz = float(h_rotfrequ)
SampleTimeS = float(h_samptime)

return
end
