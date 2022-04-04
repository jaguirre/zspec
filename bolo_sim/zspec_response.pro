pro zspec_response,freqid,itrans=itrans
ps=1
if not(keyword_set(itrans)) then itrans =0.25
p_optical=2^(findgen(160)/160 * 7)*0.1 ; Optical power in pW
;p_optical=2^(findgen(16)/16*7)*0.1
iload=0.03 ; fixed load in pW ( should include telescope + internal)
;freq=245.68
;bw=833. ; in MHz
;tau_factor=01.15919 ; for freqid 98, 245.7 GHz

freq=freqid2freq(freqid)
bw=freqid2bw(freqid)*1000.
tau_factor=(sky_zspec(0.1))[freqid]/0.1
;stop

forward_eff=0.9
nbar=1./(exp(0.04798*freq/270.)-1)

p_sky=p_optical-iload
shit=1.-p_sky/nbar/bw/freq/forward_eff*1.509e6
tau_220=-1*alog(shit)/tau_factor
trans=exp(-1*tau_factor*tau_220)
;stop
baset=[0.072,0.085,0.086]

;vbias=[5.,8.,12.,18.]  ; in mV
vbias=8. ; in mV
gain=141.
w_per_jy=1.e-26*0.65*!pi*(10.4/2)^2*(bw*1.e6)*itrans*0.5 ; 0.5 for single polarization

s_dc=fltarr(n_elements(baset),n_elements(p_optical))
nep_det=fltarr(n_elements(baset),n_elements(p_optical))
nep_johnson=fltarr(n_elements(baset),n_elements(p_optical))
nep_current=fltarr(n_elements(baset),n_elements(p_optical))
bolo_r=fltarr(n_elements(baset),n_elements(p_optical))
bolo_v=fltarr(n_elements(baset),n_elements(p_optical))
bolo_temp=fltarr(n_elements(baset),n_elements(p_optical))
tau=fltarr(n_elements(baset),n_elements(p_optical))

for i=0,n_elements(baset)-1 do begin
   for j=0,n_elements(p_optical)-1 do begin
      result=mather_tr(p_optical[j],baset[i],vbias,g0=13.6,params_index=6,/use_paramsfile)
        bolo_temp[i,j]=result[0] & bolo_r[i,j]=result[1]
        bolo_v[i,j]=vbias*(result[1]/(2*30.e6+result[1]))
        s_dc[i,j]=result[2] & nep_det[i,j]=result[3]
;        s_sky[i,j]=result[2]
        tau[i,j]=result[4] & nep_johnson[i,j]=result[6] & nep_current[i,j]=result[7]
     endfor
;stop
endfor

temp_index=1
;window,0 & 
range=[0.8,2.5]

if ps eq 1 then begin
set_plot,'ps'
device,filename='zspec_response_'+string(freqid,format='(i03)')+'.eps'
device,/color,/encapsulated,xsize=24,ysize=14 & 
device,set_font='Helvetica',/Bold
device,/landscape
!p.font=1
endif

plot,bolo_v[temp_index,*],s_dc[temp_index,*]*w_per_jy*gain*trans,/nodata,xrange=range,xtitle='Bolometer Voltage [mV] (no gain)',ytitle='Response [V / Jy] (with gain)',position=[.2,.1,0.95,0.95],/xst,/yst
;window,1
;plot,p_optical,nep_current[bias_index,*]
;window,2
;plot,p_optical,nep_det[bias_index,*]
ret=1.e-6
cols=[2,3,4]
for temp_index=0,2 do begin
;for temp_index=0,n_elements(baset)-1 do begin
;wset,0
oplot,bolo_v[temp_index,*],s_dc[temp_index,*]*w_per_jy*gain*trans,color=cols[temp_index],psym=2,thick=3
oplot,bolo_v[temp_index,*],s_dc[temp_index,*]*w_per_jy*gain,color=cols[temp_index],psym=1,thick=1
xyouts,1.5,3.1e-5+temp_index*ret,'T= '+string(baset[temp_index],format='(f5.3)'),color=cols[temp_index]
;wset,1
;oplot,p_optical,nep_current[bias_index,*],color=bias_index+1
;wset,2
;oplot,p_optical,nep_det[bias_index,*],color=bias_index+1
endfor

temp_index=1
if ps then device,set_character_size=[200,200]
for j=0,n_elements(p_optical)-1 do begin
   if j mod 2 eq 0 then begin
      ;oplot,bolo_v[temp_index,j]*[1,1],[0.4e-6,.5e-6] 
      oplot,bolo_v[temp_index,j]*[1,1],[01.7e-5,1.8e-5] 
   endif
   if j mod 4 eq 1 then begin
      if bolo_v[temp_index,j] gt range[0]+0.02 and bolo_v[temp_index,j] lt range[1] then begin
                                ;        xyouts,bolo_v[temp_index,j]-0.003,.5e-6,string(p_optical[j],format='(f4.2)')
                                ;        xyouts,bolo_v[temp_index,j]-0.003,.3e-6,string(tau_220[j],format='(f4.2)')
        xyouts,bolo_v[temp_index,j]-0.003,1.85e-5,string(p_optical[j],format='(f4.2)')
        xyouts,bolo_v[temp_index,j]-0.003,1.6e-5,string(tau_220[j],format='(f5.3)')
   ;      xyouts,tau_220[j]-0.003,.2e-6,string(tau_220[j]);,format='(f5.3)')
      endif
      endif
endfor
if ps then device,set_character_size=[300,300]
;xyouts,0.15,0.7e-6,'Optical Power [pW] if T_bath = '+string(baset[temp_index],format='(f5.3)')
;xyouts,0.15,0.2e-6,'tau_225 if T_bath = '+string(baset[temp_index],format='(f5.3)')+' and P_fixed = '+string(iload,format='(f4.2)')+' pW'
xyouts,1.4,2e-5,'Optical Power [pW] if T_bath = '+string(baset[temp_index],format='(f5.3)')
xyouts,1.3,1.5e-5,'tau_225 if T_bath = '+string(baset[temp_index],format='(f5.3)')+' and P_fixed = '+string(iload,format='(f4.2)')+' pW, nu = '+string(freq,format='(f4.0)')+' GHz'


fitrange=where(bolo_v[1,*] ge range[0] AND bolo_v[1,*] le range[1])
fit_v=bolo_v[1,fitrange]
fit_s=s_dc[1,fitrange]*w_per_jy*gain*trans[fitrange]

fit=linfit(fit_v,fit_s)

oplot,fit_v,fit[0]+fit[1]*fit_v
;xyouts,0.2,1.3e-6,'Fit: '+string(fit[0],format='(e8.1)') +' + '+string(fit[1],format='(e8.1)')+' * bolo_v' 
xyouts,1.8,2.5e-5,'Fit: '+string(fit[0],format='(e8.1)') +' + '+string(fit[1],format='(e8.1)')+' * bolo_v'
xyouts,1.8,2.5e-5-ret,'   (for T='+string(baset[temp_index],format='(f5.3)')+' K)' 
xyouts,1.2,2.75e-5,'resp. w/o trans correction'
;xx=0.12 & yy=3.5e-6 & ret=0.2e-6
xx=0.9 & yy=4e-5 & ret=1e-6
if ps then device,set_character_size=[350,350]
xyouts,xx,yy,'Z-Spec modeled response'
xyouts,xx,yy-ret,'65% aperture eff'
xyouts,xx,yy-2*ret,string(bw,format='(f4.0)')+' MHz bandwidth, e.g. @ '+string(freq,format='(f4.0)')+' GHz'
xyouts,xx,yy-3*ret,'single polarization, 25% inst eff'
xyouts,xx,yy-4*ret,'8 mV bias'
xyouts,xx,yy-5*ret,'Gain = '+string(gain,format='(f4.0)')
xyouts,xx,yy-6*ret,'Atm trans correction included'
if ps eq 1 then begin
device,/close & set_plot,'x'
endif
;stop


end
