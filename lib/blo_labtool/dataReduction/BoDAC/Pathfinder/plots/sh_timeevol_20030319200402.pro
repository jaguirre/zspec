;sh_timeevol_20030319200402

@restorex_20030319200402

psinit, /full, /letter
!p.multi=[0,1,2]

bolodark_sh_timeevol, x, time, T_c, ix

plot, time-2452718, t_c, psym=1, xrange=[ 2452718.8,2452719.6]-2452718, $
xtitle='julian date - 2452718', ytitle='T [K]', title='20-21 March 2003', $
charsize=1.5

plot, time-2452718, t_c, psym=1, xrange=[ 2452732.3,2452733.5]-2452718, $
xtitle='julian date - 2452718', ytitle='T [K]', title='2-3 April 2003', $
charsize=1.5

!p.multi=0
psterm, file='sh_timeevol_20030319200402.ps'


