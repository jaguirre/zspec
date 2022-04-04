sn=dblarr(160,14)
v1=[7.8,10.,12.,14.,15.5,20.,24.,30.,34., 10., 7.8, 7.8, 6., 4.]

restore,'/home/zspec/data/observations/20101020/APEX-79630-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec30=vopt_psderror.in1.avespec
spec30_err=vopt_psderror.in1.aveerr
sn(*,0)=spec30/spec30_err

restore,'/home/zspec/data/observations/20101020/APEX-79629-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec29=vopt_psderror.in1.avespec
spec29_err=vopt_psderror.in1.aveerr
sn(*,1)=spec29/spec29_err

restore,'/home/zspec/data/observations/20101020/APEX-79631-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec31=vopt_psderror.in1.avespec
spec31_err=vopt_psderror.in1.aveerr
sn(*,2)=spec31/spec31_err

restore,'/home/zspec/data/observations/20101020/APEX-79632-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec32=vopt_psderror.in1.avespec
spec32_err=vopt_psderror.in1.aveerr
sn(*,3)=spec32/spec32_err

restore,'/home/zspec/data/observations/20101020/APEX-79633-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec33=vopt_psderror.in1.avespec
spec33_err=vopt_psderror.in1.aveerr
sn(*,4)=spec33/spec33_err

restore,'/home/zspec/data/observations/20101020/APEX-79636-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec36=vopt_psderror.in1.avespec
spec36_err=vopt_psderror.in1.aveerr
sn(*,5)=spec36/spec36_err

restore,'/home/zspec/data/observations/20101020/APEX-79637-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec37=vopt_psderror.in1.avespec
spec37_err=vopt_psderror.in1.aveerr
sn(*,6)=spec37/spec37_err

restore,'/home/zspec/data/observations/20101020/APEX-79638-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec38=vopt_psderror.in1.avespec
spec38_err=vopt_psderror.in1.aveerr
sn(*,7)=spec38/spec38_err

restore,'/home/zspec/data/observations/20101020/APEX-79639-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec39=vopt_psderror.in1.avespec
spec39_err=vopt_psderror.in1.aveerr
sn(*,8)=spec39/spec39_err

restore,'/home/zspec/data/observations/20101020/APEX-79647-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec47=vopt_psderror.in1.avespec
spec47_err=vopt_psderror.in1.aveerr
sn(*,9)=spec47/spec47_err

restore,'/home/zspec/data/observations/20101020/APEX-79645-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec45=vopt_psderror.in1.avespec
spec45_err=vopt_psderror.in1.aveerr
sn(*,10)=spec45/spec45_err

restore,'/home/zspec/data/observations/20101020/APEX-79646-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec46=vopt_psderror.in1.avespec
spec46_err=vopt_psderror.in1.aveerr
sn(*,11)=spec46/spec46_err

restore,'/home/zspec/data/observations/20101018/APEX-79643-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec43=vopt_psderror.in1.avespec
spec43_err=vopt_psderror.in1.aveerr
sn(*,12)=spec43/spec43_err

restore,'/home/zspec/data/observations/20101020/APEX-79644-2010-10-20-E-086.A-0793A-2010_spec.sav';,/ver
spec44=vopt_psderror.in1.avespec
spec44_err=vopt_psderror.in1.aveerr
sn(*,13)=spec44/spec44_err



; Get median SNR
medianSNR=median(sn,dim=1)
stdsnr=dblarr(14)
for j=0,13 do begin
 stdSNR(j)=stddev(sn(*,j))
 stdSNR(j)/=sqrt(size(sn(*,j),/dim))
end

loadct,39

nu=freqid2freq()
!p.charsize=2.5
window,1,xsize=900,ysize=900
!p.multi=[0,1,5]
for j=0,4 do begin
plot,nu,sn(*,j),psym=10,/yst,yr=[0,80],title=sstr(v1(j),prec=2)
hline,medianSNR(j),color=240
hline,40
end

window,2,xsize=900,ysize=900
!p.multi=[0,1,5]
for j=5,8 do begin
plot,nu,sn(*,j),psym=10,/yst,yr=[0,80],title=sstr(v1(j),prec=2)
hline,medianSNR(j),color=240
hline,40
end

window,3,xsize=900,ysize=900
!p.multi=[0,1,5]
for j=9,13 do begin
plot,nu,sn(*,j),psym=10,/yst,yr=[0,80],title=sstr(v1(j),prec=2)
hline,medianSNR(j),color=240
hline,40
end

;;; Examine median SNR versus bias.
; determine scale factor between the two sources. 
; entries 0-8 are on 1924-292, 9-13 are on neptune
; sn(0) and sn(10:11) are at 7.8
; sn(1) and sn(9) are at 10
SF=((sn(0)/mean(sn(10:11)))+(sn(1)/sn(9)))/2

window,4;,xsize=400,ysize=400
!p.multi=0
plot,v1(0:8),medianSNR(0:8),psym=1,yrange=[0,40],xr=[0,35],xtit='Bias',ytit='SNR'
oplot,v1(9:13),SF*medianSNR(9:13),psym=7
oploterr,v1(0:8),medianSNR(0:8),stdSNR(0:8),1
oploterr,v1(9:13),SF*medianSNR(9:13),SF*stdSNR(9:13),1

end
