pro plotjupeff,date,filenum,tau,za,fac
; MB 20091120.   Reads in text files created by jupeff.pro and plots the
; efficiency.  Note tha tyou have to edit the code juptemp.pro to put in the
; angular size corresponding to the date you are using.  
; date and filenum are strings, filenum can be an array, tau and za are
; floats, za in degrees.

;window,0 & window,1 
;wset,0
saturn=0
jupiter=1
help,fac

; files 1 is for the instrument efficiency measurement
; here using the old values
;rt1='/home/kilauea/zspec/data/telescope_tests/20070422/'
;rt1=!zspec_data_root+'/telescope_tests/20090112/'
;rt1='/halfT/data/zspec/data/telescope_tests/20090114/'
;rt1='/home/zspec/data/telescope_tests/20090227/'
;rt1='/home/kilauea/zspec/data/telescope_tests/20091118/'
;rt1=!zspec_data_root+'/../telescope_tests/'+date+'/'


;files1=rt1+['front_1','front_2','elbrg_1','elbrg_2']+'.txt'
;files1=rt1+['amb_brg_1','amb_brg_2','amb_brg_3','amb_brg_4']+'.txt'
;files1=rt1+['amb_brg_1','amb_brg_2','amb_brg_3','amb_brg_4','amb_brg_5']+'.txt'
;files1=rt1+['amb_amb_b']+'.txt'
;files1=rt1+['amb_n2_1']+'.txt'
files1=!zspec_pipeline_root+'/loadcurve_analysis/amb_n2_1.txt'

;;;;;;;;;;;;;; uses old instrument efficiency -- DON'T NEED TO CHANGE
;;;;;;;;;;;;;;                                   FOR QUICK TESTS

; files2 are the file for jupiter.  Saturn is vestigal

if saturn then begin
;files2=rt2+['saturn_1.txt','saturn_4.txt']
files2=rt2+['sat_sky_1.txt','sat_sky_3.txt']
endif else if jupiter then begin
;rt2=!zspec_data_root+'/../telescope_tests/'+date+'/' ; the jupiter data
rt2 = '/home/zspec/data/observations/'+date+'/'
;rt2='/home/kilauea/zspec/data/telescope_tests/20070425/'
;rt2=rt1
;files2=rt2+['jupiter_1.txt','jupiter_2.txt']
;files2=rt2+['jup_sky.txt','jup_sky2.txt']
files2=rt2+'jup_sky'+filenum+'.txt'
;;;;;;;;;;;;;;HERE'S WHERE YOU ENTER THE FILE NAMES
;;;;;;;;;;;;;;THOUGH YOU COULD ENTER TEH SAME ONE TWICE, BUT THEN MAKE
;;;;;;;;;;;;;;SURE YOU HAVE THE SIGN RIGHT BELOW

endif else begin
files2=rt2+['amb_telbase','amb_telbase_2','amb_telbase_3','amb_telbase_4']+'.txt'
endelse


n_files1=n_elements(files1)
n_files2=n_elements(files2)

readcol,files1[0],box
nchan1=n_elements(box)

opeff1=fltarr(n_files1,nchan1)
for i=0,n_files1-1 do begin
    readcol,files1[i],box,ch,freq,bw,deltap,error,eff
;    opeff1[i,*]=eff
    opeff1[i,*]=-1*eff
endfor
freqs1=freqid2freq(boxchan2freqid(box,ch))

readcol,files2[0],box
nchan2=n_elements(box)

opeff2=fltarr(n_files2,nchan2)
for i=0,n_files2-1 do begin
    readcol,files2[i],box,ch,freq,bw,deltap,error,eff
    opeff2[i,*]=eff
endfor
freqs2=freqid2freq(boxchan2freqid(box,ch))

!p.multi=0
plot,freqs1,opeff1[0,*],psym=6,yrange=[-0.1,0.4]

for i=1,n_files1-1 do begin
    oplot,freqs1,opeff1[i,*],psym=6,color=i+1
end

;for j=0,n_files2-1 do begin
;    oplot,freqs2,opeff2[j,*],psym=6,color=n_files1+j+1
;end
;jup=-0.5*(opeff2[0,*]+opeff2[1,*])
;jup=-0.5*(opeff2[0,*]-opeff2[1,*])
jup=1./n_files2*total(opeff2,1)

;;;;;;;;;;NOTE SIGN OF THIS, DEPENDS ON HOW YOU SUBTRACTED THE LOAD
;;;;;;;;;;CURVES IN OPEFF

   oplot,freqs2,jup,psym=5

;stop
;wset,1

if saturn then begin
jupeff=jup/sattemp(freqs1)/( opeff1[0,*]/199.)
endif else begin
jupeff=jup/juptemp(freqs1,fac)/( opeff1[0,*]/199.)
endelse
plot,freqs2,jupeff,yrange=[0,1.],psym=5

;tau=0.035*2.
sky=sky_zspec(tau/cos(za*!pi/180))
sky_1=sky[boxchan2freqid(box,ch)]

effcorr = jupeff/(exp(-1*sky_1))

oplot,freqs2,jupeff/(exp(-1*sky_1)),psym=5,color=2



whfreq = where(freqs2 ge 200. and freqs2 le 280)
oplot,minmax(freqs2),[1,1]*mean(effcorr[whfreq]),$
  line=2,col=2

xyouts,240,0.3,'Raw measured efficiency'
xyouts,240,0.35,'Tau-corrected efficiency',color=2
xyouts,250,0.25,'Did you check Jupiter size in juptemp.pro?'

print,mean(effcorr[whfreq],/nan)

;stop
end

