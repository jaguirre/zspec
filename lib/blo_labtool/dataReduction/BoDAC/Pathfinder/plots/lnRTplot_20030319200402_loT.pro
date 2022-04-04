path = '/data1/BoDAC/3_Pathfinder/20030402/'
;restore, path+'20030319200402.sav'

!p.multi=[0,3,5]
psinit, /full, /letter, /color


;-----------------------------------
;select temperature stable measurements
ixt = bolodarkx_tdrift(x, limit=0.001, tfract=0.10, below=0.4)
xx = x[ixt]

nf       = n_elements(xx)
nchan = n_elements((*xx[0]).ubolo[*,0])

bolodarkx_rtstar, xx, Rstar, Tstar, clabel,  /plot

psterm, file=path+'lnRT20030319200402_loT.ps'
!p.multi=0

;-----------------------------------
;print values

openw, un, path+'RstarTstar20030319200402_loT.txt', /get_lun
printf, un, 'pixel', 'R_star', 'T_star', format='(a9,x,a7,x, a6)'
for i=0, nchan-1 do printf, un, clabel[i], Rstar[i], Tstar[i],  $
  	 		format='(a9,x,i7,x,f6.2)'
free_lun, un


