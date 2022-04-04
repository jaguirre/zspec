;=========================================================
; NAME		: bolo_detchopfreq_20040926_10mv
;   
; DESCRIPTION	: Determine chopper frequency for all files
; 
; 2004/09/30    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_PMW2/20040926/10mV/'
outfile = inpath+'20040926_10mV_frequ.txt'

;blo_detchopfreq, inpath, outfile, channame='C10'
blo_detchopfreq, inpath, outfile, channame='G8'

