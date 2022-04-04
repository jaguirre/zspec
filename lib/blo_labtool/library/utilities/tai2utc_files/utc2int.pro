	FUNCTION UTC2INT, UTC
;+
; Project     :	SOHO - CDS
;
; Name        :	UTC2INT()
;
; Purpose     :	Converts CCSDS calendar time to internal format.
;
; Explanation :	This procedure converts Coordinated Universal Time (UTC)
;		calendar time, as either a seven element structure variable, or
;		in the CCSDS/ISO 8601 ASCII calendar format, into CDS internal
;		format.
;
; Use         :	Result = UTC2INT( UTC )
;
; Inputs      :	UTC	= This can either be a structure with the tags YEAR,
;			  MONTH, DAY, HOUR, MINUTE, SECOND, MILLISECOND, or a
;			  character string in CCSDS/ISO 8601 format, e.g.
;
;				"1988-01-18T17:20:43.123Z"
;
;			  or one of it's variants--see STR2UTC for more
;			  details.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a structure with the tags:
;
;			DAY	= The Modified Julian Day number
;			TIME	= The time of day, in milliseconds since the
;				  start of the day.
;
; Opt. Outputs:	None.
;
; Keywords    :	None.
;
; Calls       :	DATATYPE, DATE2MJD, STR2UTC
;
; Common      :	None.
;
; Restrictions:	None.
;
; Side effects:	None.
;
; Category    :	None.
;
; Prev. Hist. :	None.  However, the concept of "internal" and "external" time
;		is based in part on the Yohkoh software by M. Morrison and G.
;		Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 13 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;
; Version     :	Version 1, 13 September 1993.
;-
;
	ON_ERROR, 2
;
;  Check the input parameter.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  Result = UTC2INT( UTC )'
	CASE DATATYPE(UTC,1) OF
		'String':	UT = STR2UTC(UTC,/EXTERNAL)
		'Structure':	UT = UTC
		ELSE:  MESSAGE, 'UTC must be either a structure or a string'
	ENDCASE
;
;  Convert the date into a Modified Julian Day number, and the number of
;  milliseconds into the day.
;
	DATE = {CDS_INT_TIME, DAY: 0L, TIME: 0L}
	IF N_ELEMENTS(UT) GT 1 THEN BEGIN
		DATE = REPLICATE(DATE,N_ELEMENTS(UT))
		SZ = SIZE(UTC)
		DATE = REFORM(DATE,SZ(1:SZ(0)))
	ENDIF
	DATE.DAY = DATE2MJD(UT.YEAR,UT.MONTH,UT.DAY)
	DATE.TIME = UT.HOUR*3600000L + UT.MINUTE*60000L + UT.SECOND*1000L + $
		UT.MILLISECOND
;
	RETURN, DATE
	END
