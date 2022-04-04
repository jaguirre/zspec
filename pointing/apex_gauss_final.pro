;___
;; THIS IS THE BACK PROPAGATION PROGRAM FROM TELESCOPE FOCUS TO FEEDHORN
;; USE apex_zspec_gauss FOR FORWARD PROPAGATION, AND INSTRUMENT TESTING

___________________________________________________________________________________________

;SYSTEM PUTS WAIST AT THE FOCUS OF ELLIPSOIDAL M5 (approximate biconic as ellipsoid)

loadct,39


    wavelength=[1.0,1.1,1.2,1.3,1.4,1.5,1.6]
fqr=(3.e8*1.e3/wavelength)*1.e-9;
nwave=n_elements(wavelength)
;___________________________________________________________________

;FEEDHORN PARAMETERS



   ; horn_slant=30.5 ;horn slant length

   horn_slant=37.

    hornrad=5.5 ;horn opening radius

    hornangle=asin(hornrad/horn_slant)  ;horn opening angle in radians


print,'hornangle',hornangle*180./!pi
;___________________________________________________________________

;APERTURE DIAMETERS



    ;telescope  (diameters taken from SHARCII zemax model)



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



        ;radM5=266.7

        ;radM4=177.8 ;based on CSO optical layout diagram on website



;___________________________________________________________________

;GAUSSIAN BEAM FROM TELESCOPE



    waist=[6.11,6.697,7.277,7.850,8.416,8.974,9.524];[7.39,5.57,4.06,2.22,1.36] ;/0.65955 ;beam waist for each wavelength, 8.7dB



       print,'beam waist at Cass focus for each wavelength:'

       print,waist

       print,' '



    z_waist=[13.53,9.08,4.27,-0.867,-6.322,-12.073,-18.1];[806.3,804.9,804.0,803.5,803.2]-750. ;distance from Cas Focus



       print,'waist location from Cass focus:'

       print,z_waist

       print,' '



       print,'mean location of waist is:'

       print,mean(z_waist)

       print,' '



;__________________________________________________________________________

;FOLLOWING ARE DISTANCES TRAVELED BY BEAM



;	offset=32.8 ;amount by which the feedhorn is situated closer to the dewar center than in design

	offset=0.;246.97;125.41;-100.
	sec_offset=0.
;ifoffset=-10.
;mwaist=z_waist(6);mean(z_waist);z_waist(0);mean(z_waist);;0 for 1mm, 3 for 1.3 mm, 6 for 1.6mm
    cas_M1=803.+offset;750.;-z_waist(0)  ;M5 to horn aperture;-mwaist

    M1_F1=300./cos(34.*!dpi/180.);sqrt(202.3^2.+300.^2.)
    
    F1_F2=1635.8+202.3
    
    F2_M2=300.
    
    M2_nas=1115.6;648.6
    
    nas_F3=1070.;400.
    
    F3_frame=404.;
    
    frame_M4=382.26;650.;308.+96.+246.
    
    M4_IF=344.25-ifoffset;660.;720.
    
    IF_M5=605.7457+ifoffset
    
     M5_horn=160.07+342.14;502.14
    

 ;   ellipse_cass=ellipse_M4+M4_cass
;ir_m4_dist=M4_cass+[0.,IR1,IR1+IR2,IR1+IR2+IR3,IR1+IR2+IR3+IR4]print,
;n_ir=n_elements(ir_m4_dist)
;pow0=fltarr(n_ir,n_elements(wavelength))
;powr=pow0
;ntapers=pow0
;_______________________________________________________________________________________

;FOCAL LENGTHS


    f_M1=700.
    f_M2=1800.
    f_M4=302.0;220.;156.;225.
    f_M5=275.0;220.;262.;355.

    ;print,'f_ellipse is:' & print,f_ellipse



;_______________________________________________________________________________________

;RAY TRANSFORMATION MATRICES (a la goldsmith p.43)



    nmatrices=22 ;total number of surafaces (i.e. number of ray transfer matrices needed)



    surfacename=strarr(nmatrices)

    matrices=fltarr(2,2,nmatrices)



    matrices(*,*,21)=[[1.,cas_M1],[0.,1.]] & surfacename(21)='Cas to M1';

    matrices(*,*,20)=[[1.,0.],[-1./f_M1,1]] & surfacename(20)='M1'

    matrices(*,*,19)=[[1.,M1_F1],[0.,1.]] & surfacename(19)='M1 to F1'

    matrices(*,*,18)=[[1.,0],[0,1]] & surfacename(18)='F1'

    matrices(*,*,17)=[[1.,F1_F2],[0.,1.]] & surfacename(17)='F1 to F2'

    matrices(*,*,16)=[[1.,0],[0,1]] & surfacename(16)='F2';

    matrices(*,*,15)=[[1.,F2_M2],[0,1.]] & surfacename(15)='F2 to M2';

    matrices(*,*,14)=[[1.,0],[-1./f_M2,1]] & surfacename(14)='M2';

    matrices(*,*,13)=[[1.,M2_nas],[0,1.]] & surfacename(13)='M2 to Nasmyth';

    matrices(*,*,12)=[[1.,0],[0,1]] & surfacename(12)='Nasmyth'
    
    matrices(*,*,11)=[[1.,nas_F3],[0,1]] & surfacename(11)='Nasmyth to F3'

    matrices(*,*,10)=[[1.,0],[0,1]] & surfacename(10)='F3'
    
    matrices(*,*,9)=[[1.,f3_frame],[0,1]] & surfacename(9)='F3 to Flexlink'

    matrices(*,*,8)=[[1.,0],[0,1]] & surfacename(8)='Flexlink'
    
    matrices(*,*,7)=[[1.,frame_M4],[0,1]] & surfacename(7)='Flexlink to M4'

    matrices(*,*,6)=[[1.,0],[-1./f_M4,1]] & surfacename(6)='M4'

    matrices(*,*,5)=[[1.,M4_IF],[0,1]] & surfacename(5)='M4 to IF'
    
    matrices(*,*,4)=[[1.,0],[0,1]] & surfacename(4)='IF'
    
     matrices(*,*,3)=[[1.,IF_M5],[0,1]] & surfacename(3)='IF to M5'

    matrices(*,*,2)=[[1.,0],[-1./f_M5,1]] & surfacename(2)='M5'
    
     matrices(*,*,1)=[[1.,M5_horn],[0,1]] & surfacename(1)='M5 to Feedhorn'

    matrices(*,*,0)=[[1.,0],[0,1]] & surfacename(0)='feedhorn'

;_____________________________________________________________________

;PARAMS FOR EFFICIENCY CALCULATION



    qin=complex(z_waist,!pi*waist^2./wavelength)      ;q from horn aperture outward (goldsmith p.13)

    result=matrices[*,*,21]

    a=result[0,0] & b=result[1,0] & c=result[0,1] & d=result[1,1]
    print,a,b,c,d

    qout=(a*qin+b)/(c*qin+d)    ;goldsmith p.41
    print,qout

    outwaist=sqrt(1./imaginary(-1./qout)*wavelength/!pi)   ;q is purely imaginary at the waist
    
    outr=1./(real_part(1./qout))

    outz=real_part(qout)    ;z is the real part of q

    curverad=outz+(1./outz)*(!pi*outwaist^2./wavelength)^2     ;goldsmith p.13

    outwidth=outwaist*sqrt(1.+(wavelength*outz/(!pi*(outwaist^2)))^2)    ;goldsmith p.13


;_______________________________________________________________________________________

;MULTIPLY MATRICES & PRINT GAUSSIAN BEAM PARAMETERS



    print,'Lambda              Surface      Output w0     Output R     Output z     Curvature     Width     Diameter'



	for s=0,nwave-1 do begin



    print,string([wavelength(s)],format='(F3.1)')+string(surfacename(nmatrices-1),format='(A25)') + $

    	string([outwaist[s],outr[s],outz[s],curverad[s],outwidth[s],outwidth[s]*6.],format='(5F13.3)')



	endfor

;>>> integrate profile to get actual ege taper

for k=0,nmatrices-2 do begin



     result=matrices[*,*,nmatrices-2-k]##result

     a=result[0,0] & b=result[1,0] & c=result[0,1] & d=result[1,1]

     qout=(a*qin+b)/(c*qin+d)

     outwaist=sqrt(imaginary(qout)*wavelength/!pi)
     
     outr=1./(real_part(1./qout))

     outz=real_part(qout)

     curverad=outz+(1./outz)*(!pi*outwaist^2/wavelength)^2

     outwidth=outwaist*sqrt(1+(wavelength*outz/(!pi*(outwaist^2)))^2)

;if k eq 4 then print,sqrt(imaginary(qout)*1.3/!pi)

for s=0,nwave-1 do begin

     print,string([wavelength(s)],format='(F3.1)')+string(surfacename(nmatrices-2-k),format='(A25)') + $

     	string([outwaist[s],outr[s],outz[s],curverad[s],$

        outwidth[s],outwidth[s]*6.],format='(7F13.3)')
endfor



endfor

end





