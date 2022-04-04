; v2tscalev - this function scales the voltage(s) given based
; on the sensor type and measurement type.  It is based on
; the BZ electronics system which directly reads out the 
; 10 uA breakdown voltages of diode sensors or reads out
; a scaled voltage directly proportional to or logarithmically
; proportional to the resistance of a calibrated sensor.
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION v2tscalev, voltage, sensor, measurement
	; This ensures that reading is the same type as voltage
	reading = voltage

	CASE sensor OF
		; diode measurements do not need to be scaled
                                ; Actually, there seems to be a gain
                                ; on the diode analog card
		'diode' 	: reading = voltage / 2.

		; measurements of calibrated sensors need to be converted
		; from voltage to log(resistance) based on the linear or 
		; logrithmic output from the GRT readout card.  
		'roxu01434' 	: reading = ALOG10(v2tconv2res(voltage, measurement))
		'cerx31187' 	: reading = ALOG10(v2tconv2res(voltage, measurement))
		'grt29177' 	: reading = ALOG10(v2tconv2res(voltage, measurement))
		'grt29178' 	: reading = ALOG10(v2tconv2res(voltage, measurement))
	ENDCASE

	RETURN,  reading
END
