;=====================================================================   
; NAME		:  bolo_intvlavg_20031009.pro
;
; DESCRIPTION	:  Determine averages at distinct frequencies of 
;		   power spectraC
; 
; 2003/12/16    :  L. Zhang
; 
; NOTE		:  This is noise analysis STEP 3 (last step)
; 
;  
;=====================================================================


intervals = [[ 0.09, 0.11], $
             [ 0.9, 1.1], $
             [ 2.9, 3.1], $
             [ 9.9,10.1]]

path    = '/data1/SPIRE_PFM_SLW/20031009/'

;=====================================================================

infile  = '200310091722_coadd.fits'
outfile = '200310091722_intvlavg.txt'


blo_chrnsespec, path+infile, path+outfile, intervals


;=====================================================================
