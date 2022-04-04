	FUNCTION STR2UTC, UTC, EXTERNAL=EXTERNAL, DMY=DMY, MDY=MDY
;+
; Project     :	SOHO - CDS
;
; Name        :	STR2UTC()
;
; Purpose     :	Parses UTC time strings.
;
; Explanation :	This procedure parses UTC time strings to extract the date and
;		time.  
;
; Use         :	Result = STR2UTC( UTC )
;		Result = STR2UTC( UTC, /EXTERNAL )
;
; Inputs      :	UTC	= A character string containing the date and time.  The
;			  target format is the CCSDS ASCII Calendar Segmented
;			  Time Code format (ISO 8601), e.g.
;
;				"1988-01-18T17:20:43.123Z"
;
;			  The "Z" is optional.  The month and day can be
;			  replaced with the day-of-year, e.g.
;
;				"1988-018T17:20:43.123Z"
;
;			  Other variations include
;
;				"1988-01-18T17:20:43.12345"
;				"1988-01-18T17:20:43"
;				"1988-01-18"
;				"17:20:43.123"
;
;			  Also, the "T" can be replaced by a blank, and the
;			  dashes "-" can be replaced by a slash "/".  This is
;			  the format used by the SoHO ECS.
;
;			  In addition this routine can parse dates where only
;			  two digits of the year is given--the year is assumed
;			  to be between 1950 and 2049.  Character string
;			  months, e.g. "JAN" or "January", can be used instead
;			  of the number.
;
;			  Dates in a different order than year-month-day are
;			  supported, but only through the /MDY and /DMY
;			  keywords.
;
; Opt. Inputs :	None.
;
; Outputs     :	The result of the function is a structure containing the (long
;		integer) tags:
;
;			DAY:	The Modified Julian Day number.
;			TIME:	The time of day, in milliseconds since the
;				beginning of the day.
;
;		Alternatively, if the EXTERNAL keyword is set, then the result
;		is a structure with the elements YEAR, MONTH, DAY, HOUR,
;		MINUTE, SECOND, and MILLISECOND.
;
;		Any elements not found in the input character string will be
;		set to zero.		
;
; Opt. Outputs:	None.
;
; Keywords    :	EXTERNAL = If set, then the output is in CDS external format,
;			   as described above.
;		DMY	 = Normally the date is in the order year-month-day.
;			   However, if DMY is set then the order is
;			   day-month-year.
;		MDY	 = If set, then the date is in the order
;			   month-day-year.
;
; Calls       :	DATATYPE, DATE2MJD, UTC2INT, MJD2DATE, NINT, VALID_NUM
;
; Common      :	None.
;
; Restrictions:	The components of the time must be separated by the colon ":"
;		character, except between the seconds and fractional seconds
;		parts, where the separator is the period "." character.
;
;		The components of the date must be separated by either the dash
;		"-" or slash "/" character.
;
;		The only spaces allowed are at the beginning or end of the
;		string, or between the date and the time.
;
;		This routine does not check to see if the dates entered are
;		valid.  For example, it would not object to the date
;		"1993-February-31", even though there is no such date.
;
; Side effects:	None.
;
; Category    :	Utilities, Time.
;
; Prev. Hist. :	Part of the logic of this routine is taken from TIMSTR2EX by M.
;		Morrison, LPARL.  However, the behavior of this routine is
;		different from the Yohkoh routine.  Also, the concept of
;		"internal" and "external" time is based in part on the Yohkoh
;		software by M. Morrison and G. Linford, LPARL.
;
; Written     :	William Thompson, GSFC, 13 September 1993.
;
; Modified    :	Version 1, William Thompson, GSFC, 21 September 1993.
;		Version 2, William Thompson, GSFC, 28 September 1993.
;			Expanded the capabilities of this routine based on
;  			TIMSTR2EX.
;		Version 3, William Thompson, GSFC, 20 October 1993.
;			Corrected small bug when the time string contains
;			fractional milliseconds, as suggested by Mark Hadfield,
;			NIWA Oceanographic.
;		Version 4, William Thompson, GSFC, 18 April 1994.
;			Corrected bugs involved with passing arrays as
;			input--routine was not calling itself reiteratively
;			correctly.
;
; Version     :	Version 4, William Thompson, 18 April 1994.
;-
;
	ON_ERROR, 2
	MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', $
		'SEP', 'OCT', 'NOV', 'DEC']
;
;  Check the input array.
;
	IF N_PARAMS() NE 1 THEN MESSAGE, 'Syntax:  Result = STR2UTC( UTC )'
	IF DATATYPE(UTC,1) NE 'String' THEN MESSAGE,	$
		'UTC must be of type string'
;
;  Form the structure to be returned.
;
	DATE = {CDS_EXT_TIME,	$
		YEAR:	0,	$
		MONTH:	0,	$
		DAY:	0,	$
		HOUR:	0,	$
		MINUTE:	0,	$
		SECOND:	0,	$
		MILLISECOND: 0}
;
;  If UTC is an array, then call this routine recursively to interpret each
;  element individually.
;
	SZ = SIZE(UTC)
	IF SZ(0) GE 1 THEN BEGIN
		DATE = REPLICATE(DATE, N_ELEMENTS(UTC))
		FOR I=0,N_ELEMENTS(UTC)-1 DO BEGIN
			DT = STR2UTC(UTC(I), /EXTERNAL, DMY=DMY, MDY=MDY)
			DATE(I).YEAR   = DT.YEAR
			DATE(I).MONTH  = DT.MONTH
			DATE(I).DAY    = DT.DAY
			DATE(I).HOUR   = DT.HOUR
			DATE(I).MINUTE = DT.MINUTE
			DATE(I).SECOND = DT.SECOND
			DATE(I).MILLISECOND = DT.MILLISECOND
		ENDFOR
		DATE = REFORM(DATE, SZ(1:SZ(0)))
		GOTO, FINISH
	ENDIF
;
;  Separate the input string into the date and time parts.
;
	UT = STRTRIM(UTC,2)
	SEP = STRPOS(UT,'T') > STRPOS(UT,' ')
	IF SEP LT 0 THEN BEGIN
		DTSEP = STRPOS(UT,'-') > STRPOS(UT,'/')
		IF DTSEP GE 0 THEN BEGIN
			DT = UT
			TIME = ''
		END ELSE BEGIN
			DT = ''
			TIME = UT
		ENDELSE
	END ELSE BEGIN
		DT = STRMID(UT,0,SEP)
		TIME = STRTRIM(STRMID(UT,SEP+1,STRLEN(UT)-SEP-1),2)
	ENDELSE
;
;  If the date contains the colon ":" character, then the date and time are
;  reversed.
;
	IF STRPOS(DT,':') GE 0 THEN BEGIN
		TEMP = DT
		DT = TIME
		TIME = TEMP
	ENDIF
;
;  Decide whether or not the date is given as year, month, day or as year,
;  day-of-year.  If the latter, calculate the month and day from the Modified
;  Julian Day number.
;
	IF STRPOS(DT,'-') GE 0 THEN DTSEP = '-' ELSE DTSEP='/'
	DT = STR_SEP(DT,DTSEP)
;
;  Day-of-year variation.
;
	IF N_ELEMENTS(DT) EQ 2 THEN BEGIN
		MJD = DATE2MJD(FIX(DT(0)),FIX(DT(1)))
		MJD2DATE,MJD,YEAR,MONTH,DAY
;
;  Year, month, and day variation.  First select out the three components
;  depending on the settings of the keywords.
;
	END ELSE IF N_ELEMENTS(DT) EQ 3 THEN BEGIN
		IF KEYWORD_SET(DMY) THEN BEGIN
			YEAR = DT(2)
			MONTH = DT(1)
			DAY = FIX(DT(0))
		END ELSE IF KEYWORD_SET(MDY) THEN BEGIN
			YEAR = DT(2)
			MONTH = DT(0)
			DAY = FIX(DT(1))
		END ELSE BEGIN
			YEAR = DT(0)
			MONTH = DT(1)
			DAY = FIX(DT(2))
		ENDELSE
;
;  If the year is only two digits, then assume that the year is between 1950
;  and 2049.
;
		N_CHAR = STRLEN(YEAR)
		YEAR = FIX(YEAR)
		IF N_CHAR EQ 2 THEN YEAR = ((YEAR + 50) MOD 100) + 1950
;
;  If the month is not a number, then assume that it is a month string.
;
		IF NOT VALID_NUM(MONTH) THEN BEGIN
			MONTH = STRUPCASE(STRMID(MONTH,0,3))
			MONTH = (WHERE(MONTH EQ MONTHS) + 1)(0)
			IF MONTH EQ 0 THEN MESSAGE,	$
				'Unrecognizable date format'
		END ELSE MONTH = FIX(MONTH)
;
;  No date.
;
	END ELSE IF TOTAL(STRLEN(DT)) EQ 0 THEN BEGIN
		YEAR = 0
		MONTH = 0
		DAY = 0
	END ELSE MESSAGE, 'Unrecognizable date format'
;
;  Parse the time.  First remove any trailing Z characters.
;
	Z = STRPOS(TIME,'Z')
	IF Z GT 0 THEN TIME = STRMID(TIME,0,Z)
	TM = STRARR(3)
	TM(0) = STR_SEP(TIME,':')
	HOUR = FIX(TM(0))
	MINUTE = FIX(TM(1))
	SECOND = DOUBLE(TM(2))
;
;  Store everything in the structure variable, and return.
;
	DATE.YEAR   = YEAR
	DATE.MONTH  = MONTH
	DATE.DAY    = DAY
	DATE.HOUR   = HOUR
	DATE.MINUTE = MINUTE
	MILLISECOND = NINT(1000*SECOND)
	DATE.SECOND = MILLISECOND / 1000
	DATE.MILLISECOND = MILLISECOND MOD 1000
;
;  If the EXTERNAL keyword is not set, then convert the date into the CDS
;  internal format.
;
FINISH:
	IF NOT KEYWORD_SET(EXTERNAL) THEN DATE = UTC2INT(DATE)
;
	RETURN, DATE
	END
