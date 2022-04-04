;=========================================================
; NAME		: @
;   
; DESCRIPTION	: Determine chopper frequency for all files
; 
; 2004/09/30    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_PMW2/20040926/30mV/'
outfile = inpath+'20040926_30mV_frequ.txt'

blo_detchopfreq, inpath, outfile, channame='G8'

