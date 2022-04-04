; Version 2010/09/28
; For use at APEX on illapa with TPD's nc files

;pro extract_noise_apex, file_root, yrange = yrange, navg = navg, ntod = ntod
filename='/home/zspec/data/telescope_tests/20101017/noise_20101017_2209_merged.nc'
; This is from Lieko, 10 Mar 2007
; Unused channels
unused = intarr(8,24)
unused[1-1,[4, 6, 22, 23]] = 1
unused[2-1,[4, 7, 14, 16]] = 1
unused[3-1,[1, 2, 3, 7, 8, 10, 23]] = 1
unused[4-1,[6, 14, 19, 20, 21, 22]] = 1
unused[5-1,[7, 18, 19, 21]] = 1
unused[6-1,[2]] = 1
unused[7-1,[8, 9, 10]] = 1
unused[8-1,[1]] = 1
;sstop
; Fixed
fixed = intarr(8,24)
fixed[6-1,[9, 23]] = 1

; nV / rtHz
;if not keyword_set(yrange) then yrange = [1.d-10,1.d-6]*1.d9

!p.charsize = 1.

nbox = 10
nchan = 24

; These are now 240 by ntime
cos_in = read_ncdf(filename,'cos')
sin_in = read_ncdf(filename,'sin')
if ~keyword_set(ntod) then begin
    ntod = n_e(cos_in[0,*])
endif else begin
    ntod = ntod
endelse

; Get the timestamp and turn into jd
timestamp =  read_ncdf(filename,'timestampUDP')
jd = parse_udp_timestamp(timestamp)
sample_interval = median(fin_diff(jd[0,*])*24.*3600.d)

print,'Total number of samples is '+string(ntod,format='(I10)')
print,'corresponding to '+string(ntod*sample_interval,format='(I10)')+' sec'
print,'Sample interval is '+string(sample_interval,format='(F6.4)')+' sec'

cos = dblarr(10,24,ntod)
sin = dblarr(10,24,ntod)

for b = 0,nbox-1 do begin
    for c = 0,24-1 do begin
        cos[b,c,*] = cos_in[b*nchan + c,0:ntod-1]
        sin[b,c,*] = sin_in[b*nchan + c,0:ntod-1]
    endfor
endfor

data = replicate(create_struct('cos',dblarr(10,24),'sin',dblarr(10,24)),ntod)

for i = 0,nbox-1 do begin

    data[*].sin[i,*] = sin[i,*,*]
    data[*].cos[i,*] = cos[i,*,*]

endfor

; Extract the optical channels
optical = extract_channels(data.cos,data.sin,'optical')
;stop

;;use samples 76000 to 80000
pos=[[75930,76330],[76360,76600],[76650,76800],[76840,77155],[77168,77432],[77455,77657],[77720,78000],$
[78035,78260],[78300,78580],[78600,78840],[78870,79160],[79193,79407],[79415,79800]]

;stop

out=median(optical(*,pos(0,12):pos(1,12)),dimension=2)

spos=dblarr(160,12)
for j=0,11 do spos(*,j)=out-median(optical(*,pos(0,j):pos(1,j)),dimension=2)

lpos=[0.,-20.,-30.,-40.,-50.,-60.,0.,20.,30.,40.,50.,60.]
uu=[1,2,3,4,5,7,8,9,10,11]
x=lpos(uu)
cc=(spos(*,0)+spos(*,6))/2.

y=spos(*,uu)

;y(*,5)=cc

sy=sort(lpos(uu))
xfit=x(sy)
yfit=y(*,sy)

gfit=dblarr(160,4)
loadct,39
for i=0,159 do begin
    
    fit = gaussfit(xfit,yfit[i,*],a,nterms=4) 
    
    plot,xfit,yfit[i,*],/xst,psy=10,tit='Bolo '+strcompress(i,/rem)
    oplot,xfit,fit,col=240
hline,0
    
    gfit[i,*] = a
    
  ;blah = ''
  ;read, blah
    
endfor

nu=freqid2freq()
plot,nu,gfit(*,2)*2.*sqrt(2.*alog(2.)),psym=10,xtit='Frequency (GHz)',ytit='FWHM (mm)',ys=1,yr=[0,100]

;;Expected

wavelength=[1.0,1.1,1.2,1.3,1.4,1.5,1.6]
fqr=(3.e8*1.e3/wavelength)*1.e-9;

zoff=[0,-5.,5.,10.,-20.];;mm
cgauss=dblarr(n_e(zoff),n_e(fqr))
tgauss=cgauss
cgauss(0,*)=[51.8348,52.3662,52.9433,53.5649,54.2297,54.9365,55.6840]
tgauss(0,*)=[48.9564,49.5056,50.1001,50.7385,51.4190,52.1400,52.8999]

cgauss(1,*)=[47.1887,47.5269,47.8976,48.2979,48.7257,49.1817,49.6657]
tgauss(1,*)=[44.0763,44.4380,44.8308,45.2539,45.7064,46.1875,46.6963]

cgauss(2,*)=[56.7084,57.4561,58.2664,59.1374,60.0670,61.0534,62.0949]
tgauss(2,*)=[53.9367,54.6904,55.5041,56.3753,57.3013,58.2796,59.3074]

cgauss(3,*)=[61.7744,62.7524,63.8219,64.9699,66.1939,67.4916,68.8609]
tgauss(3,*)=[58.9917,59.9620,61.0071,62.1230,63.3062,64.5528,65.8594]

cgauss(4,*)=[35.4091,35.4132,35.4178,35.4227,35.4280,35.4337,35.4398]
tgauss(4,*)=[30.5160,30.5213,30.5272,30.5336,30.5405,30.5479,30.5559]


loadct,39

for j=0,n_e(zoff)-1 do begin
oplot,fqr,cgauss(j,*),color=50.*(j+1)
oplot,fqr,tgauss(j,*),color=50.*(j+1),line=2

endfor

legend,['Dewar-M5 offset',reform((sstr(zoff,prec=1))(0,*))+' mm'],textcolors=[255,50.*(indgen(n_e(zoff))+1)],/bottom,/right

end
