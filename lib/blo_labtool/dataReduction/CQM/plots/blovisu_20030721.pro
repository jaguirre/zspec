path = '/data1/SPIRE_CQM/20030721/'


filename = '200307211952_coadd'
psinit, /letter, /full
blovisu, path+filename+'.fits', $
ndx=4, ndy=8, /ylog
psterm, file=path+filename+'.ps'

