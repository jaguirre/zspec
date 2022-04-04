; Make plot of all resistances at 290mK

pro bodacfit_rev01

path1 = '/data1/BoDAC/3_Pathfinder/2003031920lc/'
path2 = '/data1/BoDAC/3_Pathfinder/20030402/'

logfile = path2+'20030319200402lc_fitlog.txt'

infiles = findfile(path1+'*lc.fits')
infiles = [findfile(path2+'*lc.fits'),infiles]

;x = bolodark_read_hfi_files(infiles=infiles, bolo_channel_label='CHAN 3-2')
;save, x, filename=path2+'all_ch3-2loadcurves.sav'
restore, filename=path2+'all_ch3-2loadcurves.sav'

t_c = fltarr(x.nfiles)	;get temperatures
for i=1, x.nfiles do t_c[i-1] = median(x.(i).t_c)
ixs = sort(t_c)
infiles = infiles(ixs)	;sort according to temperature

mdlstart = 3
nmdl = 2
nchan = 24
chlabels = strarr(nmdl*nchan)

for mdl=0,nmdl-1 do $
 for chan=1, nchan do $
   chlabels[mdl*nchan+(chan-1)] = 'CHAN '+strtrim(string(mdlstart+mdl),2) + '-' + $
   				strtrim(string(chan),2) 

plot, t_c(ixs), psym=3, ystyle=3, charsize=1.8, $
xtitle='Meas # sorted according to rising T', $
ytitle='Temperature T_c [Kelvin]', color=310000, title='19/20 March & 2 April'

ixt = where(t_c GT 0.285 AND t_c LT 0.295)

ind = ixt(0)	;index of 0.291K file

help, x.(ind+1), /stru
lca = ptrarr(nchan*nmdl)
;for i=0, (nchan*nmdl)-1 do $
;  lca[i] = ptr_new(bolodark_read_bodac_file( x.(ind+1).filename, bolo_channel_label=chlabels(i)))
;save, lca, filename=path2+'all_0.285Kloadcurves.sav'
restore, filename=path2+'all_0.285Kloadcurves.sav'


T_c_med = median(x.(ind+1).t_c)
print, 'median(T_c) = ', T_c_med,' K'

res = fltarr(nchan*nmdl)
for i=0, nchan*nmdl-1 do begin
  ix = sort((*lca[i]).P)
  Res[i] = exp(avg((*lca[i]).lnr[ix[0:50]]))
endfor


blo_sepfilepath, x.(ind+1).filename, name, path

xx = indgen(nchan*nmdl)+1
plot, xx, res, color=310000, psym=10, yrange=[0,2e7], title='R(P=0) median(T_c)='+string(T_c_med)+' K', $
xtitle='Channel # of modules 3 and 4', ytitle='R [Ohm]', charsize=1.8, $
SUBTITLE=name




end
