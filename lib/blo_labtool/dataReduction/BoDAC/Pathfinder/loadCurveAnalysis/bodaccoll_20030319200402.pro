path1 = '/data1/BoDAC/3_Pathfinder/2003031920lc/'
path2 = '/data1/BoDAC/3_Pathfinder/20030402/'

infiles = findfile(path1+'*lc.fits')
infiles = [findfile(path2+'*lc.fits'),infiles]

x = bolodark_read_loadcrv(infiles, chanlim=['CHAN 3-1','CHAN 4-24'])

save, x, filename = path2+'20030319200402.sav'



