; Script to prepare FTS data for use in line fitting

; Load in data from FTS run (from Randol), variables nu & spec_coadd
; This file is not in the svn archive but can be found on the Z-Spec 
; website on the optical testing page.
RESTORE, /VERBOSE, !ZSPEC_PIPELINE_ROOT + '/line_cont_fitting/' + $
         'ftsdata/spec_coadd.sav'

; spec_coadd is a 192xN_E(nu) matrix where the first index can be calulated
; i = (box #)*24 + (chan #).  Make spec_coadd 10 x 24 x N_E(nu) matrix
; so that optical channels can be extracted using extract_channels
; nu ranges from ~ -400 to +400 GHz which is wider than necessary, so
; we'll trim that down before extracting channels
minfreq = 180
maxfreq = 320
band = WHERE(nu GT minfreq AND nu LT maxfreq,nband)
nu_trim = nu[band]
nbolos = 160
spec_coadd_reform = FLTARR(10,24,nband)

PRINT, 'Resorting FTS Scans'
FOR i = 0L, 191 DO BEGIN
   box = i/24 + 1 ;(bolometer readout boxes are 1 - 8, 0 & 9 are housekeeping)
   chan = i MOD 24
   PRINT, i, box, chan
   spec_coadd_reform[box,chan,*] = spec_coadd[i,band]
ENDFOR

PRINT, 'Extracting Optical Channels'
bc_file = !ZSPEC_PIPELINE_ROOT + '/file_io/bolo_config_apr06.txt'
spec_coadd_optical = extract_channels(spec_coadd_reform,'optical',$
                                      bolo = bc_file)

; Now compute the normalizing integral for each optical channel
norm = DBLARR(nbolos)
peak = norm
nu_peak = norm
spec_coadd_norm = spec_coadd_optical
PRINT, 'Computing Normalization Integral'
FOR i = 0L, nbolos - 1 DO BEGIN
   norm[i] = INT_TABULATED(nu_trim,spec_coadd_optical[i,*],/DOUBLE,/SORT)
   spec_coadd_norm[i,*] /= (norm[i])
   peak[i] = MAX(spec_coadd_norm[i,*],maxind)
   nu_peak[i] = nu_trim[maxind]
ENDFOR

SAVE, nu_trim, spec_coadd_norm, peak, nu_peak, $
      FILE = !ZSPEC_PIPELINE_ROOT + '/line_cont_fitting/' + $
      'ftsdata/normspec_nov.sav'
END 
