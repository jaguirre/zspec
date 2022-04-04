; intvlavg_20030722.pro
; Determine averages at distinct frequencies of power spectra 

intervals = [[ 0.08, 0.12], $
             [ 0.9, 1.1], $
             [ 2.9, 3.1], $
             [ 9.9,10.1]]

path    = '/data1/SPIRE_CQM/20030722/'

;=====================================================================

infile  = '200307221041_coadd.fits'
outfile = '200307221041_intvlavg.txt'


blo_chrnsespec, path+infile, path+outfile, intervals


;=====================================================================

infile  = '200307220045_coadd.fits'
outfile = '200307220045_intvlavg.txt'


blo_chrnsespec, path+infile, path+outfile, intervals


;=====================================================================
