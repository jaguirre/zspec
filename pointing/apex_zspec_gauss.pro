;______________________________________________________________________________________________
; 
; THIS IS THE FORWARD PROPAGATION PROGRAM FROM THE ZSPEC FEEDHORN TO THE PRIMARY
; YOU CAN INTRODUCE OFFSETS TO SEE THE EFFECT OF DE-FOCUSSING ON THE EDGE TAPERS
;
;SYSTEM PUTS WAIST AT THE FOCUS OF ELLIPSOIDAL M5 (approximate biconic as ellipsoid)
;
; OPTIONAL INPUTS:
; offset - introduce an additional offset between the feedhorn and M5
;          positive values increase the feedhorn - M5 distance
; plotfits - if files are generated for multiple offset positions, setting this keyword will 
;            read these files and plot the values
;OUTPUT:
; fits file containing the beam FWHM, egde tapers, aperture efficiency, etc., as a function of wavelength

pro apex_zspec_gauss,offset=offset,plotfits=plotfits



print,'SYSTEM PRESCRIPTION:'
print,'M5 is the first mirror in front of the feedhorn'
print,'M4 follows after the internal focus (IF)'
print,'F3 is the flat mirror above SHFI'
print,'The Nasmyth focus is in front of the elevation bearing, after F3'
print,'Other relay mirrors, in order: M2,F2,F1,M1. M1 ia the last mirror before secondary.'
print,'F3,F2, and F1 are flat. The M mirrors are powered. See the APEX manual for details.'
print,'Look at the <<Cass focus>> position to find the Cass focus location above M1.'
print,'The geometric M1-Cass distance is 803 mm. For the gaussian beam, there will be some offsets'
print,'from this position as a function of wavelength.'

loadct,39

    wavelength=[1.0,1.1,1.2,1.3,1.4,1.5,1.6]
    fqr2=[243.,322.5,442.5,810.,1320.];211.,275.,385.,790.,1250.]
fqr=(3.e8*1.e3/wavelength)*1.e-9;
;fqr=[fqr,fqr2]
;wavelength2=3.e8/fqr2*1.e-6
;wavelength=[wavelength,wavelength2]
nw=n_elements(wavelength)

nflorogold=1.65
gteflon=1.44
dfluorogold=2.
d1teflon=20.
d2teflon=15.
dzote=3.*25.4
nzote=1.


;___________________________________________________________________

;FEEDHORN PARAMETERS



   ; horn_slant=30.5 ;horn slant length

   horn_slant=37.

    hornrad=5.5 ;horn opening radius

    hornangle=asin(hornrad/horn_slant)  ;horn opening angle in radians


print,'hornangle',hornangle*180./!pi
;___________________________________________________________________

;APERTURE DIAMETERS



    ;telescope  (diameters taken from the ICD, )



       radprim=6000.

        radsec=753.7424/2.;376.87;750./2

        ;radencoder=150./2
        
        cassprime=55.61217/2.;27.8

        radM1=1143.951/2.;250./2
        
        radF1=136.217/2.;280./2
        
        radF2=252.3505/2.;220./2
        
        radM2=2241.292/2.;220./2
rir=30.;;;for the IR source
radnas=143.1944/2.;71.60
radF3=276.2591/2.;138.13
radM4=173.08/2.;407.54
radM5=303.95/2.;435.57
    ;defineable parameters
;paddle=33.
r_pad=33./2.;[0.,20.,30.,40.,50.,60.] ;;assumed paddle size. Change to compute real edge taper
print,'Paddle radius: ', r_pad

        ;radM5=266.7

        ;radM4=177.8 ;based on CSO optical layout diagram on website



;___________________________________________________________________

;GAUSSIAN BEAM INSIDE HORN (see Goldsmith p.173 - beware of typo in 7.38a)



    waist=0.644*hornrad/(1+((!pi*(0.644*hornrad)^2)/(wavelength*horn_slant))^2.)^0.5 ;beam waist for each wavelength



       print,'beam waist in horn for each wavelength:'

       print,waist

       print,' '



    z_waist=horn_slant/(1+((wavelength*horn_slant)/(!pi*(0.644*hornrad)^2))^2) ;distance from beam waist in horn to horn aperture



       print,'waist location from horn aperture:'

       print,z_waist

       print,' '



       print,'mean location of waist is:'

       print,mean(z_waist)

       print,' '



;__________________________________________________________________________

;FOLLOWING ARE DISTANCES TRAVELED BY BEAM



;	offset=32.8 ;amount by which the feedhorn is situated closer to the dewar center than in design

	if ~keyword_set(offset) then offset=0.;-12;49.;5.
	sec_offset=0.
        ifoffset=0.
;mwaist=z_waist(6);mean(z_waist);z_waist(0);mean(z_waist);;0 for 1mm, 3 for 1.3 mm, 6 for 1.6mm
    horn_M5=160.07+342.14+offset-mean(z_waist)  ;M5 to horn aperture;-mwaist
    

    M5_IF=605.7457+ifoffset
    
    IF_M4=344.25-ifoffset;-3.;+10.
    
    M4_frame=382.26
    
    frame_F3=404.;-2.;-12.
    
    F3_nas=1070.
    
    nas_M2=1115.6
    
    M2_F2=300.
    
    F2_F1=202.3+1635.8
    
    F1_M1=300./cos(34.*!dpi/180.)
    
    M1_cass=803.
    
    cass_sec=5882.86
    
    sec_pri=4800.-294.14;+0.5

   
;ir_m4_dist=M4_cass+[0.,IR1,IR1+IR2,IR1+IR2+IR3,IR1+IR2+IR3+IR4]
;n_ir=n_elements(ir_m4_dist)
;pow0=fltarr(n_ir,n_elements(wavelength))
;powr=pow0
;ntapers=pow0
;_______________________________________________________________________________________

;FOCAL LENGTHS



    ;R_pri=-8246.5164 & 
    fpri=4800.;R_pri/2.0d0

;;apertures
;radencod=63.5
;radrestr=58.7375
;radir=0.91*25.4

    ;fsec=-247.97

    fsec=-1./(1./294.14+1./cass_sec);619.24/2.;-241.80



    ;f_ellipse=1./(1./ellipse_cass+1./635.)
fM1=700.
fM2=1800.
fM4=302.0;1./(1./(M4_frame+frame_F3+F3_nas)+1./IF_M4)
fM5=275.0;1./(1./M5_IF+1./(160.07+342.14))
    ;print,'f_ellipse is:' & print,f_ellipse



;_______________________________________________________________________________________

;RAY TRANSFORMATION MATRICES (a la goldsmith p.43)



    nmatrices=26 ;total number of surafaces (i.e. number of ray transfer matrices needed)



    surfacename=strarr(nmatrices)

    matrices=fltarr(2,2,nmatrices)



    matrices(*,*,25)=[[1.,horn_M5],[0.,1.]] & surfacename(25)='Horn to M5';

    matrices(*,*,24)=[[1.,0.],[-1./fM5,1]] & surfacename(24)='M5'

    matrices(*,*,23)=[[1.,M5_IF],[0.,1.]] & surfacename(23)='M5 to IF'

    matrices(*,*,22)=[[1.,0],[0,1]] & surfacename(22)='IF'
    
    matrices(*,*,21)=[[1.,IF_M4],[0.,1.]] & surfacename(21)='IF to M4'

    matrices(*,*,20)=[[1.,0],[-1./fM4,1]] & surfacename(20)='M4'

    matrices(*,*,19)=[[1.,M4_frame],[0.,1.]] & surfacename(19)='M4 to Flexlink'

    matrices(*,*,18)=[[1.,0],[0,1]] & surfacename(18)='Flexlink';

    matrices(*,*,17)=[[1.,frame_F3],[0,1.]] & surfacename(17)='Flexlink to F3';

    matrices(*,*,16)=[[1.,0],[0,1]] & surfacename(16)='F3';

    matrices(*,*,15)=[[1.,F3_nas],[0,1.]] & surfacename(15)='F3 to Nasmyth focus';

    matrices(*,*,14)=[[1.,0],[0,1]] & surfacename(14)='Nasmyth focus';

    matrices(*,*,13)=[[1.,nas_M2],[0,1]] & surfacename(13)='Nasmyth focus to M2';

    matrices(*,*,12)=[[1.,0.],[-1/fM2,1.]] & surfacename(12)='M2';

    matrices(*,*,11)=[[1.,M2_F2],[0,1]] & surfacename(11)='M2 to F2';

    matrices(*,*,10)=[[1.,0],[0,1.]] & surfacename(10)='F2';

    matrices(*,*,9)=[[1.,F2_F1],[0,1]] & surfacename(9)='F2 to F1'
    
    matrices(*,*,8)=[[1.,0.],[0,1.]] & surfacename(8)='F1';

    matrices(*,*,7)=[[1.,F1_M1],[0,1]] & surfacename(7)='F1 to M1'
    
    matrices(*,*,6)=[[1.,0.],[-1/fM1,1.]] & surfacename(6)='M1';

    matrices(*,*,5)=[[1.,M1_cass],[0,1]] & surfacename(5)='M1 to Cass focus'
    
    matrices(*,*,4)=[[1.,0],[0,1.]] & surfacename(4)='Cass focus';
	
    matrices(*,*,3)=[[1.,cass_sec],[0,1.]] & surfacename(3)='Cass focus to Secondary'

    matrices(*,*,2)=[[1.,0],[1./fsec,1]] & surfacename(2)='Secondary'

    matrices(*,*,1)=[[1.,sec_pri],[0,1.]] & surfacename(1)='Secondary to Primary'

    matrices(*,*,0)=[[1.,0],[-1./fpri,1.]] & surfacename(0)='Primary'



;_____________________________________________________________________

;PARAMS FOR EFFICIENCY CALCULATION



    qin=complex(z_waist,!pi*waist^2./wavelength)      ;q from horn aperture outward (goldsmith p.13)

    result=matrices[*,*,25]

    a=result[0,0] & b=result[1,0] & c=result[0,1] & d=result[1,1]
    print,a,b,c,d

    qout=(a*qin+b)/(c*qin+d)    ;goldsmith p.41
    print,qout

    outwaist=sqrt(imaginary(qout)*wavelength/!pi)   ;q is purely imaginary at the waist
    
    outr=1./(real_part(1./qout))

    outz=real_part(qout)    ;z is the real part of q

    curverad=outz+(1./outz)*(!pi*outwaist^2./wavelength)^2     ;goldsmith p.13

    outwidth=outwaist*sqrt(1.+(wavelength*outz/(!pi*(outwaist^2)))^2)    ;goldsmith p.13



;_______________________________________________________________________________________

;MULTIPLY MATRICES & PRINT GAUSSIAN BEAM PARAMETERS



    print,'Lambda              Surface      Output w0     Output R     Output z     Curvature     Width     Edge Taper (dB)   Paddle Taper (dB)   Spillov Eff'



	for s=0,nw-1 do begin



    print,string([wavelength(s)],format='(F3.1)')+string(surfacename(nmatrices-1),format='(A25)') + $

    	string([outwaist[s],outr[s],outz[s],curverad[s],6.*outwidth[s]],format='(5F13.3)')



	endfor

;>>> integrate prfile to get actual ege taper

for k=0,nmatrices-2 do begin



     result=matrices[*,*,nmatrices-2-k]##result

     a=result[0,0] & b=result[1,0] & c=result[0,1] & d=result[1,1]

     qout=(a*qin+b)/(c*qin+d)

     outwaist=sqrt(imaginary(qout)*wavelength/!pi)
     
     outr=1./(real_part(1./qout))

     outz=float(qout)

     curverad=outz+(1./outz)*(!pi*outwaist^2/wavelength)^2

     outwidth=outwaist*sqrt(1+(wavelength*outz/(!pi*(outwaist^2)))^2)



    ;edge tapers


      edgetaper=fltarr(n_elements(wavelength))
      
      paddletaper=fltarr(n_elements(wavelength))

      spilleff=fltarr(n_elements(wavelength))

       if nmatrices-2-k eq 18 then begin ;;;flexlink

        alphaencod=(rir/outwidth)^2.

        edgetaper=8.686*alphaencod  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alphaencod)
	
	paddletaper= 10.^(edgetaper/(-10.))
str_tap_flex=edgetaper
	endif

	      if nmatrices-2-k eq 22 then begin ;;;IF

        alphaencod=(rir/outwidth)^2.

        edgetaper=8.686*alphaencod  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alphaencod)
	
	paddletaper= 10.^(edgetaper/(-10.))
str_tap_if=edgetaper
	endif

	if nmatrices-2-k eq 14 then begin ;;;nasmyth

        alpharestr=(radnas/outwidth)^2.

        edgetaper=8.686*alpharestr  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alpharestr)

	paddletaper= 10.^(edgetaper/(-10.))
str_spill=spilleff
;ntapers(0,*)=edgetaper
;pow0(0,*)=2./!dpi/outwidth^2;exp(-2.*(pr/outwidth(ii)*10.)^2.)
;powr(0,*)=(2./!dpi/outwidth^2)*exp(-2.*(radir/outwidth)^2.)

	endif
	
	
		if nmatrices-2-k eq 12 then begin ;;;M2

        alpharestr=(radM2/outwidth)^2.

        edgetaper=8.686*alpharestr  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alpharestr)

	paddletaper= 10.^(edgetaper/(-10.))

;ntapers(0,*)=edgetaper
;pow0(0,*)=2./!dpi/outwidth^2;exp(-2.*(pr/outwidth(ii)*10.)^2.)
;powr(0,*)=(2./!dpi/outwidth^2)*exp(-2.*(radir/outwidth)^2.)

	endif

		if nmatrices-2-k eq 10 then begin ;;;F2

        alpharestr=(radF2/outwidth)^2.

        edgetaper=8.686*alpharestr  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alpharestr)

	paddletaper= 10.^(edgetaper/(-10.))

;ntapers(0,*)=edgetaper
;pow0(0,*)=2./!dpi/outwidth^2;exp(-2.*(pr/outwidth(ii)*10.)^2.)
;powr(0,*)=(2./!dpi/outwidth^2)*exp(-2.*(radir/outwidth)^2.)

	endif

		if nmatrices-2-k eq 6 then begin ;;;M1

        alpharestr=(radM1/outwidth)^2.

        edgetaper=8.686*alpharestr  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alpharestr)

	paddletaper= 10.^(edgetaper/(-10.))

;ntapers(0,*)=edgetaper
;pow0(0,*)=2./!dpi/outwidth^2;exp(-2.*(pr/outwidth(ii)*10.)^2.)
;powr(0,*)=(2./!dpi/outwidth^2)*exp(-2.*(radir/outwidth)^2.)


	;make array for integration
pside=(radM1+r_pad/2.)/10. ;cm M5 has a 20 in diameter ; outermost position of the paddle is 5*2*25.4 mm
pbin=0.01
pow=dblarr(pside/pbin,pside/pbin)
pr=sqrt(((dindgen(pside/pbin)*pbin)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin)^2.)
rpaddle=r_pad/10.;25.4/10.
ppos=[0.,20.,30.,40.,50.,60.]/10.
npaddle=n_e(ppos);5.;;offset paddle positions
gaussm1=fltarr(n_elements(wavelength),npaddle)
	
	for ii=0,n_elements(wavelength)-1 do begin
	
	pow=exp(-2.*(pr/outwidth(ii)*10.)^2.)
	rcen=where(pr le rpaddle)
	pcen1=total(pow(rcen))
	p0=pow(0,0)
	pow(0,*)=0.
	pow(*,0)=0.
	pcen2= total(pow(rcen))
	pcen=2.*pcen1+2.*pcen2-p0
	gaussm1(ii,0)=pcen
	;pow(rcen)=0.
	
	for ni=1,npaddle-1 do begin
	radni=ppos(ni);radM5/50.*(ni+1);(ni+1)*2*25.4/10.
	xycen=radni*sin(45./180.*!dpi);/pbin
proff=sqrt(((dindgen(pside/pbin)*pbin-xycen)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin-xycen)^2.);

	roff=where(proff le rpaddle)
	poff=total(pow(roff))
	gaussm1(ii,ni)=poff
	;pow(roff)=0
	;stop
	endfor
	
	paddletaper(ii)=-10.*alog10(poff/pcen);

	endfor;

nposg = 2.*(npaddle-1)+1
x = [(-1.)*reverse(ppos(1:*)),ppos];(findgen(nposg)-5.)*2.*25.4 ; in mm
xfine = interpol(x,100)
gfit=fltarr(4,n_elements(wavelength));

for ig=0,n_elements(wavelength)-1 do begin
loadct,39
    gy=[reverse((reform(gaussm1(ig,*)))(1:*)),reform(gaussm1(ig,*))]
    fit = gaussfit(x,gy,a,nterms=4) 
    print,gy
    ;plot,x,gy,/xst,psy=10
    ;oplot,x,fit,color=240
    ;stop
    gfit[*,ig] = a
    
    
endfor;

plot,wavelength,gfit[2,*]*sigma_to_fwhm()*10.,psy=10,/xst,xtit='Wavelength (mm)',ytit='FWHM'
oplot,wavelength,outwidth*1.1774,line=2
print,'BEAM SIZE AT M1 (FWHM - mm)'
print,'paddle:',gfit[2,*]*sigma_to_fwhm()*10.
print,'theoretical:',outwidth*1.1774;

str_fwhmM1=gfit[2,*]*sigma_to_fwhm()*10.


	endif

		if nmatrices-2-k eq 8 then begin ;;;F1

        alpharestr=(radF1/outwidth)^2.

        edgetaper=8.686*alpharestr  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alpharestr)

	paddletaper= 10.^(edgetaper/(-10.))

;ntapers(0,*)=edgetaper
;pow0(0,*)=2./!dpi/outwidth^2;exp(-2.*(pr/outwidth(ii)*10.)^2.)
;powr(0,*)=(2./!dpi/outwidth^2)*exp(-2.*(radir/outwidth)^2.)

	endif

	
	
      if nmatrices-2-k eq 24 then begin

        alphaM5=(radM5/outwidth)^2.

        edgetaper=8.686*alphaM5  ;edge taper on M5 (goldsmith p.129)

        spilleff=1.- exp(-2.*alphaM5)
	
	;make array for integration
pside=(radM5+25.4)/10. ;cm M5 has a 20 in diameter ; outermost position of the paddle is 5*2*25.4 mm
pbin=0.01
pow=dblarr(pside/pbin,pside/pbin)
pr=sqrt(((dindgen(pside/pbin)*pbin)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin)^2.)
rpaddle=25.4/10.
npaddle=5.;;offset paddle positions
gaussm5=fltarr(n_elements(wavelength),npaddle+1)
	
	for ii=0,n_elements(wavelength)-1 do begin
	
	pow=exp(-2.*(pr/outwidth(ii)*10.)^2.)
	rcen=where(pr le rpaddle)
	pcen1=total(pow(rcen))
	p0=pow(0,0)
	pow(0,*)=0.
	pow(*,0)=0.
	pcen2= total(pow(rcen))
	pcen=2.*pcen1+2.*pcen2-p0
	gaussm5(ii,0)=pcen
	pow(rcen)=0.
	
	for ni=0,npaddle-1 do begin
	radni=radM5/50.*(ni+1);(ni+1)*2*25.4/10.
	xycen=radni*sin(45./180.*!dpi)
proff=sqrt(((dindgen(pside/pbin)*pbin-xycen)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin-xycen)^2.);

	roff=where(proff le rpaddle)
	poff=total(pow(roff))
	gaussm5(ii,ni+1)=poff
	pow(roff)=0
	endfor
	
	paddletaper(ii)=-10.*alog10(poff/pcen);

	endfor;

nposg = 2.*npaddle+1
x = (findgen(nposg)-5.)*2.*25.4 ; in mm
xfine = interpol(x,100)
gfit=fltarr(4,n_elements(wavelength));

for ig=0,n_elements(wavelength)-1 do begin
loadct,39
    gy=[reverse((reform(gaussm5(ig,*)))(1:*)),reform(gaussm5(ig,*))]
    fit = gaussfit(x,gy,a,nterms=4) 
    print,gy
;    plot,x,gy,/xst,psy=10
;    oplot,x,fit,color=240
;    stop
    gfit[*,ig] = a
    
    
endfor;

plot,wavelength,gfit[2,*]*sigma_to_fwhm(),psy=10,/xst,xtit='Wavelength (mm)',ytit='FWHM'
oplot,wavelength,outwidth*1.1774,line=2
print,'BEAM SIZE AT M5 (FWHM - mm)'
print,'paddle:',gfit[2,*]*sigma_to_fwhm()
print,'theoretical:',outwidth*1.1774;

str_fwhmM5=gfit[2,*]*sigma_to_fwhm()
endif



	  if nmatrices-2-k eq 20 then begin

        alphaM4=(radM4/outwidth)^2.

        edgetaper=8.686*alphaM4  ;edge taper on M4 (goldsmith p.129)

        spilleff=1.- exp(-2.*alphaM4)
	
	;make array for integration
;pside=50. ;cm
;pbin=0.01
;pow=dblarr(pside/pbin,pside/pbin)
;pr=sqrt(((dindgen(pside/pbin)*pbin)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin)^2.)
;rpaddle=9.
;xycen=radM4*sin(45./180.*!dpi)/10.
;proff=sqrt(((dindgen(pside/pbin)*pbin-xycen)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin-xycen)^2.);

;	
;	for ii=0,n_elements(wavelength)-1 do begin
;	
;	pow=exp(-2.*(pr/outwidth(ii)*10.)^2.)
;	rcen=where(pr le rpaddle)
;	pcen1=total(pow(rcen))
;	p0=pow(0,0)
;	pow(0,*)=0.
;	pow(*,0)=0.
;	pcen2= total(pow(rcen))
;	pcen=2.*pcen1+2.*pcen2-p0
;	
;	pow(rcen)=0.
;	roff=where(proff le rpaddle)
;	poff=total(pow(roff))
;	pow(roff)=0
;	
;	paddletaper(ii)=-10.*alog10(poff/pcen);

;	endfor;

      endif;;;



	  if nmatrices-2-k eq 2 then begin;

        alphasec=(radsec/outwidth)^2.;

        edgetaper=8.686*alphasec  ;edge taper on secondary (goldsmith p.129);

        spilleff=1.- exp(-2.*alphasec)
;	
;	;make array for integration
pside=50. ;cm
pbin=0.01
pow=dblarr(pside/pbin,pside/pbin)
pr=sqrt(((dindgen(pside/pbin)*pbin)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin)^2.)
rpaddle=9.
xycen=radsec*sin(45./180.*!dpi)/10.
proff=sqrt(((dindgen(pside/pbin)*pbin-xycen)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin-xycen)^2.);

	
	for ii=0,n_elements(wavelength)-1 do begin
	
	pow=exp(-2.*(pr/outwidth(ii)*10.)^2.)
	rcen=where(pr le rpaddle)
	pcen1=total(pow(rcen))
	p0=pow(0,0)
	pow(0,*)=0.
	pow(*,0)=0.
	pcen2= total(pow(rcen))
	pcen=2.*pcen1+2.*pcen2-p0
	
	pow(rcen)=0.
	roff=where(proff le rpaddle)
	poff=total(pow(roff))
	pow(roff)=0
	
	paddletaper(ii)=-10.*alog10(poff/pcen)
;stop 
	endfor
str_taperM2=paddletaper
      endif



      if nmatrices-2-k eq 0 then begin

        alphaprim=(radprim/outwidth)^2.

        edgetaper=8.686*alphaprim  ;edge taper on secondary (goldsmith p.129)

        spilleff=1.- exp(-2.*alphaprim)
	
	;make array for integration
;pside=50. ;cm
;pbin=0.01
;pow=dblarr(pside/pbin,pside/pbin)
;pr=sqrt(((dindgen(pside/pbin)*pbin)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin)^2.)
;rpaddle=9.
;xycen=radsec*sin(45./180.*!dpi)/10.
;proff=sqrt(((dindgen(pside/pbin)*pbin-xycen)^2.)#replicate(1,pside/pbin)+replicate(1,pside/pbin)#(dindgen(pside/pbin)*pbin-xycen)^2.);

;	
;	for ii=0,n_elements(wavelength)-1 do begin
;	
;	pow=exp(-2.*(pr/outwidth(ii)*10.)^2.)
;	rcen=where(pr le rpaddle)
;	pcen1=total(pow(rcen))
;	p0=pow(0,0)
;	pow(0,*)=0.
;	pow(*,0)=0.
;	pcen2= total(pow(rcen))
;	pcen=2.*pcen1+2.*pcen2-p0
;	
;	pow(rcen)=0.
;	roff=where(proff le rpaddle)
;	poff=total(pow(roff))
;	pow(roff)=0
;	
;	paddletaper(ii)=-10.*alog10(poff/pcen);

;	endfor;

      endif



for s=0,nw-1 do begin



     print,string([wavelength(s)],format='(F3.1)')+string(surfacename(nmatrices-2-k),format='(A25)') + $

     	string([outwaist[s],outr[s],outz[s],curverad[s],$

        6.*outwidth[s],edgetaper[s],paddletaper[s],spilleff[s]],format='(7F13.3)')



endfor



endfor



;__________________________________________________________________________________________________________

;NOW LOOK AT APERTURE EFFICIENCY BASED ON PRIMARY
;;coupling efficiency is basically the antenna efficiency


		fb=radsec/radprim

		apeff=(2./alphaprim)*(exp(-1.*fb^2.*alphaprim)-exp(-1.*alphaprim))^2.


print,'Horn-M5 distance',horn_M5,offset
	print,'Aperture efficiency on primary including blockage is'

	print, apeff
;str_apeff=apeff


freqsforwave=(3E11/wavelength)/1E9

print,freqsforwave

cutoff=fltarr(nw)

for j=0,nw-1 do begin

	cutoff[j]=freqsforwave[j+1]+(freqsforwave[j]-freqsforwave[j+1])/2

endfor

print,cutoff

str={fqr:fqr,fwhmM5:str_fwhmM5,spill:str_spill,taperM2:str_taperM2,apeff:apeff,tap_flex:str_tap_flex,tap_if:str_tap_if}
mwrfits,str,'apex_zspec_focus'+sstr(offset)+'.fits',/create
if keyword_set(plotfits) then begin

offsets=findgen(9)*5.-20.
noff=9
nwav=n_elements(fqr)
fwhms=fltarr(noff,nwav)
tapers=fltarr(noff,nwav)
spills=fltarr(noff,nwav)
apeffs=fltarr(noff,nwav)
taps_flex=fltarr(noff,nwav)
taps_if=fltarr(noff,nwav)

for j=0,noff-1 do begin
dum=mrdfits('apex_zspec_focus'+sstr(offsets(j))+'.fits',1)
fwhms(j,*)=dum.fwhmM5
tapers(j,*)=reform(dum.taperM2)
spills(j,*)=dum.spill
apeffs(j,*)=dum.apeff
taps_if(j,*)=dum.tap_if
taps_flex(j,*)=dum.tap_flex
endfor

maxapeff=max(apeffs)
apeffs=apeffs/maxapeff

set_plot,'ps'
device,file='apex_zspec_focus.ps',/color,/isolatin1,/landscape,/times,xsize=9.5,ysize=7.0,/inches,encapsulated=0,bits=24
loadct,39
!p.multi=[0,2,3]
!p.font=0
!p.charsize=1.5

plot,offsets,fwhms(*,0),xs=1,xtit='Dewar offset (mm)',ytit='FWHM at M5 (mm)',ys=1,yr=[70,160],tit='A positive offset increases the M5-horn distance'
for k=1,nwav-1 do oplot,offsets,fwhms(*,k),color=k*40.

plot,offsets,tapers(*,0),xs=1,xtit='Dewar offset (mm)',ytit='Edge taper at secondary (dB)',/ylog
for k=1,nwav-1 do oplot,offsets,tapers(*,k),color=k*40.

;plot,offsets,100.-spills(*,0)*100.,xs=1,xtit='Dewar offset (mm)',ytit='Spillover at the Nasmyth tube (%)'
;for k=1,nwav-1 do oplot,offsets,100.-spills(*,k)*100.,color=k*40.

plot,offsets,apeffs(*,0),xs=1,xtit='Dewar offset (mm)',ytit='Relative aperture efficiency - no spillover',ys=1,yr=[0,1],tit='Max aperture efficiency is '+sstr(maxapeff*100.,prec=1)+'%'
for k=1,nwav-1 do oplot,offsets,apeffs(*,k),color=k*40.

plot,tapers(*,0),apeffs(*,0),xs=1,xtit='Edge taper at secondary (dB)',ytit='Relative aperture efficiency - no spillover',ys=1,yr=[0,1],/xlog
for k=1,nwav-1 do oplot,tapers(*,k),apeffs(*,k),color=k*40.

;plot,fwhms(*,0)-fwhms(5,0),apeffs(*,0),xs=1,xtit='FWHM change at M5 (mm)',ytit='Relative aperture efficiency - no spillover',ys=1,yr=[0,1]
;for k=1,nwav-1 do oplot,fwhms(*,k)-fwhms(5,k),apeffs(*,k),color=k*40.


plot,offsets,taps_if(*,0),xs=1,xtit='Dewar offset (mm)',ytit='Edge taper at IF (dB)',/ylog,tit='30mm IR circle'
for k=1,nwav-1 do oplot,offsets,taps_if(*,k),color=k*40.

plot,offsets,taps_flex(*,0),xs=1,xtit='Dewar offset (mm)',ytit='Edge taper at Flexlink rack (dB)',/ylog,tit='30mm IR circle'
for k=1,nwav-1 do oplot,offsets,taps_flex(*,k),color=k*40.


device,/close
set_plot,'x'
!p.multi=0
endif

end





