; v2tconv2res.pro - this program converts voltage(s) from the
; BZ electronics to measurements of resistance based on the
; measurement (lin or log) type.  
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION v2tconv2res, voltage, measurement
	; This is the calculation of vgrt from Yuki's spreadsheet
	vref = 5.0009
	vgrt = vref * !PI/2.0
	vgrt = vgrt * (1.0/(1.0 + 51.0))
	vgrt = vgrt / 495.0

	; These are other constants from Yuki's spreadsheet
	rcurrsen = 523000.0
	iref = vref/51000.0
	lingain = 101.

	; This ensures the type of res matches the type of voltage
	res = voltage

	CASE measurement OF
		'lin' : BEGIN
			res = voltage * !PI/2.0
			res = res / lingain
			res = res / rcurrsen
			res = vgrt / res
			END
		'log' : BEGIN
			res = voltage * 3.0
			res = iref / (10.0 ^ (res - 6.0))
			res = res * !PI/2.0
			res = res / rcurrsen
			res = vgrt / res
			END
	ENDCASE

	RETURN, res
END
