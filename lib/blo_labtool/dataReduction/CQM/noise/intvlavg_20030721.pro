; intvlavg_20030721.pro
; Determine averages at distinct frequencies of power spectra 

intervals = [[ 0.08, 0.12], $
             [ 0.9, 1.1], $
             [ 2.9, 3.1], $
             [ 9.9,10.1]]

path    = '/data1/SPIRE_CQM/20030721/'

;=====================================================================

infile  = '200307211952_coadd.fits'
outfile = '200307211952_intvlavg.txt'


blo_chrnsespec, path+infile, path+outfile, intervals


;=====================================================================
