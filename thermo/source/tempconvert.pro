; tempconvert.pro - this function converts voltage(s) from the BZ
; electronics and converts to temperatures based on the type 
; of sensor chosen (diode, roxu01434, cerx31187, grt29177, or
; grt29178) and the type of measurement (lin, log).  Diode
; sensor type ignores the measurement type.  
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION tempconvert, voltage, sensor, measurement
	; First scale the voltage so that it is appropriate
	; for the calibration
	scaledv = v2tscalev(voltage, sensor, measurement)
	
	; Then load the chebychev coefficients and scale
	; the sensor reading to the normalized varible
	cyccooefs = v2tloadcal(scaledv, sensor)

	; Compute the chebychev expansion
	temp = v2tchebychev(scaledv, cyccooefs)

	RETURN, temp

END
