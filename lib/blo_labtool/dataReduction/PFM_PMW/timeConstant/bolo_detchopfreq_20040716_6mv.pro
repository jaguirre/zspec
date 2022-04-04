;=========================================================
; NAME		: bolo_detchopfreq_20040716_6mv
;   
; DESCRIPTION	: Determine chopper frequency for all files
; 
; 2004/08/04    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_PMW/20040716/6mV/'
outfile = inpath+'20040716_6mV_frequ.txt'

blo_detchopfreq, inpath, outfile, channame='C10'

