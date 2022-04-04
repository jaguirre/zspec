;=========================================================
; NAME		:  bolo_detchopfreq_20031007_40mv
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    :  L. Zhang
;
; NOTE		:  This is time constant data reduction 
;		   STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_SLW/20031007/40mV/'
outfile = inpath+'20031007_40mV_frequ.txt'

blo_detchopfreq, inpath, outfile, channame='C1'

