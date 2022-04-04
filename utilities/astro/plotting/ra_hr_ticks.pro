;; This is a function to create Right Ascension axis labels for 
;; and RA/Dec plot.  Typical usage would be in the PLOT call set
;; the keyword XTICKFORMAT = 'ra_hr_ticks'.  This assumes that
;; the RA coordinate is in units of hours

FUNCTION ra_hr_ticks, axis, index, value
  ra_hr = FLOOR(value)
  ra_min = FLOOR((value - ra_hr) * 60)
  ra_sec = ROUND((((value - ra_hr) * 60) - ra_min) * 60)
  
  RETURN, STRING(ra_hr,ra_min,ra_sec,$
                 F='(I0,"!Eh!N",I02,"!Em!N",I02,"!Es!N")')
END
