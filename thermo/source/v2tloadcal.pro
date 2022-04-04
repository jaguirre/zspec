; v2tloadcal.pro - this program loads the appropriate coefficients
; for a chebychev conversion of voltage or resistance to 
; temperature.  It can deal with singlets or arrays of values
; and converts the reading(s) to the normalized varible useful
; for the chebychev expansion.
;
; 30 May 2005 - First Version by Bret Naylor

FUNCTION v2tloadcal, reading, sensor
	
	CASE sensor OF
		'diode' 	: coeffs = v2tcoeffsdiode(reading)
		'roxu01434' 	: coeffs = v2tcoeffsrox34(reading)
		'cerx31187' 	: coeffs = v2tcoeffscer87(reading)
		'grt29177' 	: coeffs = v2tcoeffsgrt77(reading)
		'grt29178' 	: coeffs = v2tcoeffsgrt78(reading)
	ENDCASE

	RETURN, coeffs
END
