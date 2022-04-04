;=========================================================
; NAME		:  bolo_detchopfreq_20031007_25mv_300hz
;   
; DESCRIPTION	:  Make fits file
; 
; 2003/12/16    :  L. Zhang
;
; NOTE		:  This is time constant data reduction 
;		   STEP 3
;=========================================================

inpath='/data1/SPIRE_PFM_SLW/20031007/25mV_300Hz_4096pts/'
outfile = inpath+'20031007_25mV_300Hz_4096pts_frequ.txt'

blo_detchopfreq, inpath, outfile, channame='C1'

