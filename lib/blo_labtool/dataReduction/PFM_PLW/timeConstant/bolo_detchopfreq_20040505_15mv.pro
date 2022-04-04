;=========================================================
; NAME		: bolo_detchopfreq_20040505_15mv
;   
; DESCRIPTION	: Determine chopper frequency for all files
; 
; 2004/06/03    : B. Schulz
;
; NOTE		: This is time constant data reduction STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_PLW/20040505/15mV/'
outfile = inpath+'20040505_15mV_frequ.txt'

blo_detchopfreq, inpath, outfile, channame='A8'

