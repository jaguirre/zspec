;; This is a function to create Declination axis labels for 
;; and RA/Dec plot.  Typical usage would be in the PLOT call set
;; the keyword YTICKFORMAT = 'dec_deg_ticks'.

FUNCTION dec_deg_ticks, axis, index, value
  dec_deg = FLOOR(value)
  dec_min = FLOOR((value - dec_deg) * 60)
  dec_sec = ROUND((((value - dec_deg) * 60) - dec_min) * 60)
  
  RETURN, STRING(dec_deg,dec_min,STRING("47B),$
                 dec_sec,STRING("47B),STRING("47B), $
                 F='(I0,"!M%",I02,"!M",A,I02,"!M",A,"!M",A)')
END
