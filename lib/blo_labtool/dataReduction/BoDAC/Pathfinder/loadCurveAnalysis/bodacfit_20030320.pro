pro bodacfit_20030320

;@init

path = '/data1/BoDAC/3_Pathfinder/2003031920lc/'
logfile = path+'20030320lc_fitlog.txt'


list = findfile(path+'20030320*lc.fits')

;ix = indgen(n_elements(list)/3.)*3 
;infiles = list[ix]
infiles = list

x = bolodark_read_hfi_files(infiles=infiles, bolo_channel_label = bolo_channel_label)

t_c = fltarr(x.nfiles)	;get temperatures
for i=1, x.nfiles do t_c[i-1] = median(x.(i).t_c)
ix = sort(t_c)

infiles = infiles(ix)	;sort according to temperature


mdlstart = 3
nmdl = 2
nchan = 24
chlabels = strarr(nmdl*nchan)

for mdl=0,nmdl-1 do $
 for chan=1, nchan do $
   chlabels[mdl*nchan+(chan-1)] = 'CHAN '+strtrim(string(mdlstart+mdl),2) + '-' + $
   				strtrim(string(chan),2) 
;bolo_channel_label='CHAN 3-2'
bolo_channel_label='CHAN 1-17'

!p.multi=[0,1,3]

;i = 1
for i=0, n_elements(chlabels)-1 do begin

  psinit, /full , /color, /letter
  bolodark, infiles=infiles, bolo_channel_label = chlabels[i], /whiteback, $
		tol=1e-7, nmed = 25, logfile=logfile

  psterm, file=path+'20030320_'+strcompress(chlabels[i],/rem)+'.ps'
endfor
!p.multi=0


;x = bolodark_read_hfi_files(infiles=infiles, bolo_channel_label = bolo_channel_label)

;nn = x.nfiles

;for i=1, nn-1 do plot, x.(i).bolo, x.(i).bias, psym=6

end
