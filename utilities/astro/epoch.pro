function $
   epoch, $
      jd, rjd_flag = rjd_flag, mjd_flag = mjd_flag, fk4_flag = fk4_flag
; $Id:
; $Log:
;+
; NAME:
;	epoch
;
; PURPOSE:
;	Calculates the epoch from a Julian, reduced Julian date, or 
;       modified Julian date.
;
; CALLING SEQUENCE:
;	
;       value = $
;          epoch( $
;             jd, rjd_flag = rjd_flag, mjd_flag = mjd_flag, $
;             fk4_flag = fk4_flag)
;
; INPUTS:
;       jd: julian date or modified julian date.  Can be obtained from
;           calendar date using IDL JULDAY() function.  Remember that
;           the HH MM SS in a Julian date are in UT.
;
; OPTIONAL KEYWORD PARAMETERS:
;       rjd_flag: set this if your julian date is a "reduced"
;          julian day, which is just JD - 2400000.
;       mjd_flag: set this if your julian date is a "modified"
;          julian day, which is just JD - 2400000.5
;       fk4_flag: set this if you want the Besselian (FK4 system)
;          epoch instead of the Julian (FK5 system) epoch
;
; OUTPUTS:
;	epoch: epoch corresponding to the input jd, julian or
;	   besselian as specified by fk4_flag keyword
;
; COMMENTS:
;       Note the difference between RJD and MJD! 
;
; MODIFICATION HISTORY:
; 	2004/04/13 SG Yes, it's amazing that such a routine does not
;                     exist in the ASTRO library.
;-

if (n_params() ne 1) then begin
   message, 'Exactly one calling parameter allowed.'
endif
if (keyword_set(rjd_flag) and keyword_set(mjd_flag)) then begin
   message, 'Only one of RJD_FLAG and MJD_FLAG keywords may be set.'
endif

year_length = 365.25D
day_offset = 2451545D
epoch_offset = 2000D
if keyword_set(fk4_flag) then begin
   year_length = 365.242198781D
   day_offset = 2415020.31352D
   epoch_offset = 1950D
endif
if keyword_set(rjd_flag) then begin
   day_offset = day_offset - 2400000D
endif
if keyword_set(mjd_flag) then begin
   day_offset = day_offset - 2400000.5D
endif

return, epoch_offset + ( jd - day_offset ) / year_length

end
