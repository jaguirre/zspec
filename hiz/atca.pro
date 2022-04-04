; Redshift range is 2.5 to 5.7
; Really need apparent L_FIR
pth = !zspec_pipeline_root+'/hiz/'

readcol,pth+'spt_alma.txt',$
  name,z,T_d,T_d_err,L_IR,L_IR_err,dv,$
  comment='#',format='(A,F,F,F,F,F,F)'

ngals = n_e(name)

; in mJy
s_co = dblarr(ngals)
s_co_lo = s_co
s_co_hi = s_co
s_co2 = s_co
s_co2_lo = s_co
s_co2_hi = s_co

; in GHz
nu_obs = 115.27120200/(z+1)
nu_obs_21 = 230.53800000/(z+1)

for i=0,ngals-1 do begin

    solomon_co_lum,L_IR[i],lp_co,z[i],dv[i],nu_obs[i],tmp
    s_co[i] = tmp*1e3
    solomon_co_lum,L_IR[i]-L_IR_err[i],lp_co,z[i],dv[i],nu_obs[i],tmp
    s_co_lo[i] = tmp*1e3
    solomon_co_lum,L_IR[i]+L_IR_err[i],lp_co,z[i],dv[i],nu_obs[i],tmp
    s_co_hi[i] = tmp*1e3

    solomon_co_lum,L_IR[i],lp_co2,z[i],dv[i],nu_obs_21[i],tmp
    s_co2[i] = tmp*1e3
    solomon_co_lum,L_IR[i]-L_IR_err[i],lp_co2,z[i],dv[i],nu_obs_21[i],tmp
    s_co2_lo[i] = tmp*1e3
    solomon_co_lum,L_IR[i]+L_IR_err[i],lp_co2,z[i],dv[i],nu_obs_21[i],tmp
    s_co2_hi[i] = tmp*1e3

endfor

set_plot,'ps'
device,file='atca_spt.eps',/color,/encap

plot,nu_obs,s_co,psy=3,xtit='Observed Frequency (GHz)',ytit='mJy',$
  xthick=2,ythick=2,/xst,xr=[15,50],/yst,yr=[0,3]
oploterror,nu_obs,s_co,s_co-s_co_lo,/lobar,psy=3,col=3,errc=4,thick=4
oploterror,nu_obs,s_co,s_co_hi-s_co,/hibar,psy=3,col=3,errc=4,thick=4

whclose = where(name eq '0113-46' or name eq '2134-50' or name eq '2332-53')
whnotclose = intersect(lindgen(ngals),whclose,/xor)
xyouts,nu_obs[whnotclose]-0.2,s_co[whnotclose],name[whnotclose],$
  orientation=90,alignment=0.5,charsize=0.75
xyouts,nu_obs[whclose]+0.3,s_co[whclose],name[whclose],$
  orientation=90,alignment=0.5,charsize=0.75

; CO 2-1

oploterror,nu_obs_21,s_co2,s_co2-s_co2_lo,/lobar,psy=2,col=2,errc=2,thick=4
oploterror,nu_obs_21,s_co2,s_co2_hi-s_co2,/hibar,psy=2,col=2,errc=2,thick=4
xyouts,nu_obs[whnotclose]*2-0.2,s_co2[whnotclose],name[whnotclose],$
  orientation=90,alignment=0.5,charsize=0.75
xyouts,nu_obs[whclose]*2+0.3,s_co2[whclose],name[whclose],$
  orientation=90,alignment=0.5,charsize=0.75

band12mm = [16,25]
band7mm = [30,50]

readcol,pth+'atca_sens_12mm.txt',comment='#',format='(F,F,F,F,F)',$
  ghz_atca_12mm, dv_atca_12mm, mjybm_atca_12mm_good, $
  mjybm_atca_12mm_avg, mjybm_atca_12mm_med

; Scale up the ATCA errors to account for only 5 antennas
worse = sqrt(6.*5/(5.*4))

oplot,ghz_atca_12mm,mjybm_atca_12mm_good*sqrt(dv_atca_12mm/400.)*5*worse,col=3
oplot,ghz_atca_12mm,mjybm_atca_12mm_avg*sqrt(dv_atca_12mm/400.)*5*worse,col=5
oplot,ghz_atca_12mm,mjybm_atca_12mm_med*sqrt(dv_atca_12mm/400.)*5*worse,col=2

readcol,pth+'atca_sens_7mm.txt',comment='#',format='(F,F,F,F,F)',$
  ghz_atca_7mm, dv_atca_7mm, mjybm_atca_7mm_good, $
  mjybm_atca_7mm_avg, mjybm_atca_7mm_med

oplot,ghz_atca_7mm,mjybm_atca_7mm_good*sqrt(dv_atca_7mm/400.)*5*worse,col=3
oplot,ghz_atca_7mm,mjybm_atca_7mm_avg*sqrt(dv_atca_7mm/400.)*5*worse,col=5
oplot,ghz_atca_7mm,mjybm_atca_7mm_med*sqrt(dv_atca_7mm/400.)*5*worse,col=2

device,/close
set_plot,'x'

end
