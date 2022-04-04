path = '/data1/BoDAC/3_Pathfinder/20030404/'
filename = '200304040000_coadd_time'

psinit, /letter, /full
blovisu, path+filename+'.fits', xrange=[0.01,80], yrange=[0.00001,0.01], $
ndx=4, ndy=8
psterm, file=path+filename+'.ps'

filename = '200304041039_coadd_time'

psinit, /letter, /full
blovisu, path+filename+'.fits', xrange=[0.01,80], yrange=[0.00001,0.01], $
ndx=4, ndy=8
psterm, file=path+filename+'.ps'

