function juptemp,freq,fac
; calculates the beam-averaged antenna temperature of jupiter

physical_temp=165.
;size=42.5 ; arcsec
;size=36.5 ; arcsec
;39.19 arcsec ; Nov 2009
size= 48.6 ; 16 Oct 2010

d_tel = 1200.
; 1040. ; CSO

beam=1./freq*1.2*29.979/d_tel*206265

; For APEX
beam_size=fwhm_from_beammap(freq)*206265. * fac ;10.4/12.
beam = beam_size

coupling=1-exp(-1*size^2*0.693/beam^2)


return,physical_temp*coupling

end

