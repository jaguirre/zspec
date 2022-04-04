pro plotopeff
wset,0
saturn=0
jupiter=0

;rt1='/home/kilauea/zspec/data/telescope_tests/20070422/'
;rt1=!zspec_data_root+'/telescope_tests/20090112/'
rt1='/halfT/data/zspec/data/telescope_tests/20090114/'

;rt2='/home/kilauea/zspec/data/telescope_tests/20070425/'

;files1=rt1+['front_1','front_2','elbrg_1','elbrg_2']+'.txt'
;files1=rt1+['amb_brg_1','amb_brg_2','amb_brg_3','amb_brg_4']+'.txt'
;files1=rt1+['amb_brg_1','amb_brg_2','amb_brg_3','amb_brg_4','amb_brg_5']+'.txt'
files1=rt1+['amb_amb_b']+'.txt'

;if saturn then begin
;files2=rt2+['saturn_1.txt','saturn_4.txt']
;endif else if jupiter then begin
;files2=rt2+['jupiter_1.txt','jupiter_2.txt']
;endif else begin
;files2=rt2+['amb_telbase','amb_telbase_2','amb_telbase_3','amb_telbase_4']+'.txt'
;endelse


n_files1=n_elements(files1)
;n_files2=n_elements(files2)

readcol,files1[0],box
nchan1=n_elements(box)

opeff1=fltarr(n_files1,nchan1)
for i=0,n_files1-1 do begin
    readcol,files1[i],box,ch,freq,bw,deltap,error,eff
    opeff1[i,*]=eff
endfor
freqs1=freqid2freq(boxchan2freqid(box,ch))

;readcol,files2[0],box
;nchan2=n_elements(box)

;opeff2=fltarr(n_files2,nchan2)
;for i=0,n_files2-1 do begin
;    readcol,files2[i],box,ch,freq,bw,deltap,error,eff
;    opeff2[i,*]=eff
;endfor
;freqs2=freqid2freq(boxchan2freqid(box,ch))


!p.multi=0
plot,freqs1,opeff1[0,*],psym=6,yrange=[-0.1,0.4]

for i=1,n_files1-1 do begin
    oplot,freqs1,opeff1[i,*],psym=6,color=i+1
end

;for j=0,n_files2-1 do begin
;    oplot,freqs2,opeff2[j,*],psym=6,color=n_files1+j+1
;end
;jup=0.5*(opeff2[0,*]-opeff2[1,*])
;   oplot,freqs2,jup,psym=5

stop
wset,1





jupeff=jup/juptemp(freqs1)/( opeff1[0,*]/199.)
plot,freqs2,jupeff,yrange=[0,1.],psym=5

tau=0.035*2.
sky=sky_zspec(tau)
sky_1=sky[boxchan2freqid(box,ch)]

oplot,freqs2,jupeff/(exp(-1*sky_1)),psym=5,color=2
stop
end

