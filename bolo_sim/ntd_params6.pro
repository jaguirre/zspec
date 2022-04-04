;; TRYING TO PUT TOGETHER A Z-SPEC MODEL HERE


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
in=1.                           ; current noise in the JFETS, in fA/rtHz
;nep_photon = 1.5	;optical nep in e-17 W/rtHz
;vbias = 10.		;bias voltage across bolometer and load resistor stack in mV
;gain = 143.		;preamplifier gain (80000 is BoDAC gain)
beta=1.
tref_g=0.1
;;; PARAMETERS ABOVE USED FOR Z-SPEC


; adopt Planck heat capacity.
c0=4.25
;c0=c0/5.  ; divide Planck chips by 5 -- best case!
tref_c=1.
gamma=1.57

