pro bodacfit_20030319200402



path1 = '/data1/BoDAC/3_Pathfinder/2003031920lc/'
path2 = '/data1/BoDAC/3_Pathfinder/20030402/'

logfile = path2+'20030319200402lc_fitlog.txt'

infiles = findfile(path1+'*lc.fits')
infiles = [findfile(path2+'*lc.fits'),infiles]

;x = bolodark_read_hfi_files(infiles=infiles)
;t_c = fltarr(x.nfiles)	;get temperatures
;for i=1, x.nfiles do t_c[i-1] = median(x.(i).t_c)
;ix = sort(t_c)
;infiles = infiles(ix)	;sort according to temperature


mdlstart = 3
nmdl = 2
nchan = 24
chlabels = strarr(nmdl*nchan)

for mdl=0,nmdl-1 do $
 for chan=1, nchan do $
   chlabels[mdl*nchan+(chan-1)] = 'CHAN '+strtrim(string(mdlstart+mdl),2) + '-' + $
   				strtrim(string(chan),2) 

!p.multi=[0,1,3]

;i = 1
for i=0, n_elements(chlabels)-1 do begin

  psinit, /full , /color, /letter
  bolodark, infiles=infiles, bolo_channel_label = chlabels[i], /whiteback, $
		tol=1e-7, nmed = 25, logfile=logfile

  psterm, file=path2+'20030319200402_'+strcompress(chlabels[i],/rem)+'.ps'
endfor
!p.multi=0


end
