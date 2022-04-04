path1 = '/data1/BoDAC/3_Pathfinder/20030320/'

infiles = findfile(path1+'*lc.fits')

x = bolodark_read_loadcrv(infiles, chanlim=['CHAN 3-1','CHAN 4-24'])

save, x, filename = path1+'20030320.sav'



