pro chop_phase_z

file=''
read,'Sliced data file? ',file

; Get digital signals
acquired=read_ncdf(file,'acquired')
nodding=read_ncdf(file,'nodding')
on_beam=read_ncdf(file,'on_beam')

; Get chopper information
chop_enc=read_ncdf(file,'chop_enc')

; Get the data                                
ac_bolos=read_ncdf(file,'ac_bolos')
;dc_bolos=read_ncdf(file,'dc_bolos')

; Get the bolo info
;readcol,bolo_params_file,comment=';',format='(A,I,F,F)',$
;  bolo_name,good_flag,theta,r
;goodbolos = where(good_flag eq 1,ngoodbolos)

set_plot,'x'
window,0
!p.multi=0
plot,nodding,/xst,yrange=[-0.1,1.1],$
xtitle='N_sample',ytitle='Nodding'
; sample range to use
read,'N_sample range to use (min,max): ',nsmin,nsmax

nstot=nsmax-nsmin
nsrange=nstot-1
n21=(nstot)/2+1
delta=0.02
trange=nstot*delta
m=(INDGEN(nstot)-(nstot/2-1))
f=m/(nstot*delta)

; set mean of chopper signal to zero
chop_ave=TOTAL(chop_enc[nsmin:nsmax-1])/nstot
chop_enc=chop_enc-chop_ave
chmax=max(chop_enc)
chop_enc=chop_enc/(2.*chmax)

; PSD and autocorrelation of chopper signal
psd_chop=SHIFT(ABS(FFT(chop_enc[nsmin:nsmax-1]))^2,-n21)
  chop_norm=SQRT(TOTAL(psd_chop))
; FFT and autocorrelation of chopper signal
chop_fft=FFT(chop_enc[nsmin:nsmax-1])
auto_chop_fft=chop_fft*CONJ(chop_fft)/chop_norm^2
auto_corr_chop=FFT(auto_chop_fft,/inverse)

; Bins with f = 1 Hz, 3 Hz, and 5 Hz 
onehzt=WHERE(psd_chop eq MAX(psd_chop))
zerohz=WHERE(f eq 0)
onehz=onehzt[1]
n_off=onehz-zerohz
threehz=3*n_off+zerohz
fivehz=5*n_off+zerohz
; Test to make sure we really got the correct 3 Hz and 5 Hz bins
threehz_t=WHERE(psd_chop[threehz-100L:threehz+100L] eq $
		MAX(psd_chop[threehz-100L:threehz+100L]))+threehz-100L
if(threehz_t ne threehz) then begin
  print,'Changing value of 3 Hz bin: '
  print,'Old value: ',threehz,' New value: ',threehz_t 
  threehz=threehz_t
endif
fivehz_t=WHERE(psd_chop[fivehz-100L:fivehz+100L] eq $
		MAX(psd_chop[fivehz-100L:fivehz+100L]))+fivehz-100L
if(fivehz_t ne fivehz) then begin
  print,'Changing value of 5 Hz bin: '
  print,'Old value: ',fivehz,' New value: ',fivehz_t 
  fivehz=fivehz_t
endif

window,0
!p.multi=[0,1,2]
  plot,chop_enc[nsmin:nsmin+1000L],/xst,/yst,yrange=[-0.55,0.55],$
  xtitle='N_sample',ytitle='chop_enc'
  plot,f,psd_chop,/ylog,/xst,yrange=[1.0e-14,1.],/yst,$
  xtitle='Frequency (Hz)',ytitle='PSD'

nbolo=0

while (nbolo ge 0) do begin
read, 'Enter bolometer number (negative number to exit): ', nbolo

if(nbolo ge 0) then begin
; set mean of bolometer signal to zero
    ac_bolo_ave=TOTAL(ac_bolos[nbolo,nsmin:nsmax-1])/nstot
; print,ac_bolo_ave
    ac_bolos[nbolo,*]=ac_bolos[nbolo,*]-ac_bolo_ave

; PSD of bolometer signal
    psd_ac_bolo=SHIFT(ABS(FFT(ac_bolos[nbolo,nsmin:nsmax-1]))^2,-n21)
    bolo_norm=SQRT(TOTAL(psd_ac_bolo))

; Cross-correlation of chopper and bolometer signals
    ac_bolo_fft=FFT(ac_bolos[nbolo,nsmin:nsmax-1])
    cross_fft=ac_bolo_fft*CONJ(chop_fft)/(chop_norm*bolo_norm)
    auto_bolo_fft=ac_bolo_fft*CONJ(ac_bolo_fft)/bolo_norm^2
    cross_phi=SHIFT(ATAN(IMAGINARY(cross_fft),REAL_PART(cross_fft)),-n21)
    chop_phi=ATAN(IMAGINARY(chop_fft),REAL_PART(chop_fft))
    ac_bolo_phi=ATAN(IMAGINARY(ac_bolo_fft),REAL_PART(ac_bolo_fft))

; Chopper/bolometer phase shifts at 1, 3 and 5 Hz (in radians)
    angcon=5.729578d1
    delta_phi_1=fltarr(1)
    delta_phi_3=fltarr(1)
    delta_phi_5=fltarr(1)
    delta_phi_1=cross_phi[onehz]
    delta_phi_3=cross_phi[threehz]
    delta_phi_5=cross_phi[fivehz]

    print,'1 Hz phase difference (deg): ',delta_phi_1*angcon
    print,'3 Hz phase difference (deg): ',delta_phi_3*angcon
    print,'5 Hz phase difference (deg): ',delta_phi_5*angcon

    cross_corr=FFT(cross_fft,/inverse)

    str1=STRING(STRCOMPRESS(nbolo,/remove_all),format='(i3)')
    strlab1='N_bolo='+str1

    window,1
    !p.multi=[0,1,2]
    plot,ac_bolos[nbolo,nsmin:nsmin+1000L],$
      xtitle='N_sample',ytitle='ac_bolo'
    plot,f,psd_ac_bolo,/ylog,/xst,yrange=[1.0e-16,1.0e-6],/yst,$
      xtitle='Frequency (Hz)',ytitle='PSD'
    xyouts,-20.0,1.0e-8,strlab1,charsize=2.0

    window,2
    !p.multi=0
    plot,f,cross_phi,xrange=[0.9,1.1],yrange=[-3.5,3.5],/xst,/yst,$
      xtitle='!6Frequency (Hz)',ytitle='!7Du!6 (rad)'
    oplot,f[onehz:onehz],delta_phi_1[0:0],psym=2
    xyouts,0.91,3.0,'1 Hz',charsize=2.0
    wait,3.0
    plot,f,cross_phi,xrange=[2.9,3.1],yrange=[-3.5,3.5],/xst,/yst,$
      xtitle='!6Frequency (Hz)',ytitle='!7Du!6 (rad)'
    oplot,f[threehz:threehz],delta_phi_3[0:0],psym=2
    xyouts,2.91,3.0,'3 Hz',charsize=2.0
    wait,3.0
    plot,f,cross_phi,xrange=[4.9,5.1],yrange=[-3.5,3.5],/xst,/yst,$
      xtitle='!6Frequency (Hz)',ytitle='!7Du!6 (rad)'
    oplot,f[fivehz:fivehz],delta_phi_5[0:0],psym=2
    xyouts,4.91,3.0,'5 Hz',charsize=2.0
endif

endwhile

!p.multi=0

end
