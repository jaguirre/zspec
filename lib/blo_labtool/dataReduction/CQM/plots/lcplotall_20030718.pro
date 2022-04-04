;lcplotall_20030718

@restorex_20030718

;select temperature stable measurements

ixt = bolodarkx_tdrift(x, limit=0.005, tfract=0.10, below=0.4)
xx = x[ixt]



nf       = n_elements(xx)
nchan = n_elements((*x[0]).ubolo[*,0])

psinit, /full,/letter, /color
!p.multi=[0,2,5]
for i=0, nchan-1 do begin bolodark_pl_loadcrv, xx, i, /yfree
psterm, file='lcplotall_20030718.ps'

psinit, /full,/letter, /color
!p.multi=[0,2,5]
for i=0, nchan-1 do begin bolodark_pl_loadcrv, xx, i
psterm, file='lcplotall_20030718fix.ps'

!p.multi=0


