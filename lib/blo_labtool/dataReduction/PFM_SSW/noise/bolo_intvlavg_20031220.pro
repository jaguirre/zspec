;=====================================================================   
; NAME		:  bolo_intvlavg_20031220
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

path    = '/data1/SPIRE_PFM_SSW/20031220/'
;path    = '/data1/SPIRE_PFM_SSW/20031220/test_fits_bin/'

;Our results
;infile  = '20031220_coadd.fits'
;outfile = '20031220_intvlavg.txt'

;using Hien's coadd file
infile  = '200312201336_coadd_cut.fits'
outfile = '200312201336_intvlavg_cut.txt'

;testing 
;infile  = 'mytest_bin_fits_coadd.fits'
;outfile = 'mytest_intvlavg.txt'


blo_chrnsespec, path+infile, path+outfile, intervals;, /goodpix


;=====================================================================
