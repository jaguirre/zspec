;; This function returns a position variable for a plot command that will
;; create a plot with isometric axes in terms of arcseconds. startx and
;; starty are the window coordinates of the lower left hand corner of the
;; plot. delx and dely are the maximum desired width and height of the
;; plot (also in window coordinates).  The returned position variable
;; will produce a plot that falls within the position
;; [startx,starty,startx+delx,starty+dely]. aspect_ratio is the ratio of
;; width to height for the window or page size (this is given by
;; (XSIZE/YSIZE) from a WINDOW or DEVICE call).  delra is the width of
;; the plot in ra hours, deldec is the height in degrees. deco is the
;; declination in degrees that should be used to scale the ra coordinate
;; into arcseconds (by COS(deco)).

FUNCTION get_radec_plotpos, startx, starty, delx, dely, aspect_ratio, $
                            delra, deldec, deco
  endx = startx
  endy = starty

  delra_deg = 15*delra*COS(deco*!PI/180.)
  data_aspect_ratio = delra_deg/deldec

  IF delx GT dely*(data_aspect_ratio/aspect_ratio) THEN BEGIN
     endx += dely*(data_aspect_ratio/aspect_ratio)
     endy += dely
  ENDIF ELSE BEGIN
     endx += delx
     endy += delx/(data_aspect_ratio/aspect_ratio)
  ENDELSE
  
  RETURN, [startx,starty,endx,endy]
END
