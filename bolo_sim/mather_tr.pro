function mather_tr,poptical,baset,vbias,g0=g0,params_index=params_index,r0=r0,delta=delta,beta=beta,use_paramsfile=use_paramsfile

; modified 22 Nov 2006 to allow parameters to be entered
; modified 31 July 2006 to do noise as well.
;returns a 5-element vector of [temperature[K], resistance[Ohms],S_DC[V/W],NEP_bolo[e-18],tau[ms],P_e[aW], johnson noise NEP, current noise NEP [e-18 W / sqrt(Hz) ]
;returns a 2-D vector of [temperature, resistance]

; wants voltages in mV, load resistances in MOhms, R0 in Ohms, temps in K, powers in pW
; g0 in pW / K

; input bolometer parameters
; this particular version used for Z-Spec calcs April 2006

if not(keyword_set (use_paramsfile)) then use_paramsfile=0

if use_paramsfile eq 1 then begin

if not(keyword_set (params_index)) then params_index=1

BLISS=1
if BLISS ne 1 then begin

r0 = 58.8			;ntd thermistor r0 parameter
delta = 17.5                    ;ntd thermistor delta parameter
if not (keyword_set(g0)) then g0 = 13.6       ;bolometer conductance at 300 mK in pW/K
tref = 0.1			;reference temperature for g300 and c300
beta = 1.2			;power exponent of the thermal conductance
;c100 = 0.2; a guess             ;bolometer heat capacity at 300 mK in pJ/K
gamma = 1.0                     ;power exponent of the heat capacity
rl1 = 30.0                      ;load resistor + side in MOhms
rl2 = 30.0			;load resistor - side in MOhms
;input operating conditions
;t0 = 0.075			;baseplate temperature in K
vn = 10.0			;noise of the amplifier chain in nV/rtHz
;nep_photon = 1.5	;optical nep in e-17 W/rtHz
;vbias = 10.		;bias voltage across bolometer and load resistor stack in mV
;gain = 143.		;preamplifier gain (80000 is BoDAC gain)
;;; PARAMETERS ABOVE USED FOR Z-SPEC
;;; PARAMETERS BELOW USED FOR BLISS-NTD
endif else begin

if params_index eq 1 then begin
@'ntd_params1.pro'
endif
if params_index eq 2 then begin
@'ntd_params2.pro'
endif
if params_index eq 3 then begin
@'ntd_params3.pro'
endif
if params_index eq 4 then begin
@'ntd_params4.pro'
endif
if params_index eq 5 then begin
@'ntd_params5.pro'
endif
if params_index eq 6 then begin
@'ntd_params6.pro'
endif

; r0=50.
; delta=10.
; if not (keyword_set(g0)) then g0=0.6 ; pW /K  per Jamie spreadsheet
; tref_g=0.05
; beta=1.0 ; from Jamie spreadsheet
; c0=0.144 ; in pJ/K based on Jamie value of 0.072 pJ/K at 50 mK
; tref_c=0.100
; gamma = 1.0                     ;power exponent of the heat capacity
; rl1=60.
; rl2=60.
; vn = 10.0		
                                ;noise of the amplifier chain in nV/rtHz
endelse

endif else begin  ; Here we're adding the additional parameters that would otherwise be assigned by reading in the file.
rl1=60. & rl2=60.
c0=0.144 ; in pJ/K based on Jamie value of 0.072 pJ/K at 50 mK
tref_c=0.100
tref_g=0.100  ; need to check these, reference temps in K
gamma=1.0
vn=10.
endelse

t0=baset
q = poptical			;optical power in pW

;solve for the bolometer operating temperature
;calculate the power balance on the device which should be zero
;use Newton's recursion until power balances

tb = 1.5*baset			;an initial guess at bolometer temperature
for i=0,10 do begin
	pow_ex = g0*(tb^(1+beta)-t0^(1+beta))/((1+beta)*(tref_g^beta)) - q
	pow_ex = pow_ex - 1.0e12*r0*exp(sqrt(delta/tb))*((vbias/1000.0)/(r0*exp(sqrt(delta/tb))+rl1*1.0e6 + rl2*1.0e6))^2
	dpow_ex = 1.0e6*r0*exp(sqrt(delta/tb))*0.5*sqrt(delta/tb)*(1.0/tb)*vbias^2
	dpow_ex = dpow_ex*(rl1*1.0e6 + rl2*1.0e6 - r0*exp(sqrt(delta/tb))) / ((rl1*1.0e6 + rl2*1.0e6 + r0*exp(sqrt(delta/tb)) ))^3
	dpow_ex = (g0*(tb/tref_g)^beta)+dpow_ex
	;there was an error in the eidp spreadsheet in the derivative that is fixed here
	;even so the eidp still converged to the correct value of tb
	tb = tb - pow_ex/dpow_ex
;print,tb
	endfor

rbol = r0*exp(sqrt(delta/tb))	;bolometer impedance in Ohms
; the proper formula which includes the electric field effect
; rbol= r0*exp(sqrt(delta/tb)- (eV L (T) / dkT) )
; L(T) = L_0 / T^m   (L_0 450 angstrom per WH)
; d is distance between electrodes, standard is 300 microns

vbol = vbias*rbol/(rbol + rl1*1.0e6 + rl2*1.0e6)   ;bolometer voltage in mV
ibol = 1.0e6*vbol/rbol          ;bolometer current in nA
a = -0.5*sqrt(delta/tb)                ;mather impedance exponent
c = c0*(tb/tref_c)^gamma       ;heat capacity at tb in pJ/K
g = g0*(tb/tref_g)^beta                ;thermal conductance at tb in pW/K
x = tb/t0                      ;Tbol/T0
p = ibol*vbol                  ;electrical power in pW


z_r = (-1-(g*tb/(p*a)))/(1-(g*tb/(p*a)))        ;z/r = (dV/dI)/r
tau = 500*(z_r+1)*(c/g)*(1+(rl1+rl2)*1.0e6/rbol)/(z_r+(rl1+rl2)*1.0e6/rbol)    ;time constant in ms
sdc = 0.5*1.0e6*sqrt(rbol/p)*(1-z_r)/(1+z_r*(rbol*1.0e-6/(rl1+rl2)))   ;responsitivity in V/W
nep_j = 1.0e12*2*(z_r+(rl1+rl2)*1.0e6/rbol)/((1+(rl1+rl2)*1.0e6/rbol)*(z_r+1))
nep_j = nep_j*sqrt(4*1.38e-23*(tb^3)*(g^2)/(p*a^2))                    ;Johnson nep in 1e-18 W/rtHz
nep_phonon = 1.0e12*sqrt(4*1.38e-23*(t0^2)*g)*sqrt((beta+1)*((x^(2*beta+3))-1))
nep_phonon = nep_phonon/sqrt((2*beta+3)*(x^beta)*((x^(1+beta))-1))     ;Phonon nep in 1e-18 W/rtHz
nep_lr = 1.0e6*sqrt(4*1.38e-23*t0/(rl1+rl2))*abs(2*z_r*rbol*ibol/(z_r-1))
nep_lr = nep_lr*(rbol*1.0e-6+((rl1+rl2)/z_r))/(rbol*1.0e-6+rl1+rl2)    ;Load resistor nep in 1e-18 W/rtHz
nep_amp = 1.0e9*vn/sdc          ;Amplifier nep in 1e-18 W/rtHz

; MB added current noise below August 15, 2007
nep_current=in*1e3*rbol/(1+rl1*1e6/(rbol+rl1*1e6)) / sdc  ; an approximation to the current noise contribution to the bolometer NEP


nep_det = sqrt(nep_j^2+nep_phonon^2+nep_lr^2+nep_amp^2+nep_current^2)                        ;total detector nep in 1e-18 W/rtHz
;nep_tot = sqrt(nep_det^2 + nep_photon^2) ;total nep in 1e-17 W/rtHz
;dqe = nep_photon^2/nep_tot^2   ;detective quantum efficiency
;vn_tot = nep_tot*sdc*1.0e-8    ;total voltage noise in nV/rtHz
tau=1000.*c/g*0.5*(z_r+1)*(1+(rl1+rl2)/rbol*1.e6) / (z_r+(rl1+rl2)/rbol*1.e6)    ; thermal time constant in ms

;stop
johnson=sqrt(nep_j^2+nep_lr^2)
print,johnson,nep_current ;& stop
return,[tb,rbol,sdc,nep_det,tau,ibol^2*rbol,johnson,nep_current]
end

