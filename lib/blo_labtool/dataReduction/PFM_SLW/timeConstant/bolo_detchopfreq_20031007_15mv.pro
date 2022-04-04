;=========================================================
; NAME		:  bolo_detchopfreq_20031007_15mv
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    :  L. Zhang
;
; NOTE		:  This is time constant data reduction 
;		   STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_SLW/20031007/15mV/'
outfile = inpath+'20031007_15mV_frequ.txt'

blo_detchopfreq, inpath, outfile, channame='A3'

