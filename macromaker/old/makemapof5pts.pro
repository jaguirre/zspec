pro makemapof5pts, size, pts, throw, filename, t_int

fiveptsx = [0, -throw, throw, 0    , 0     ]
fiveptsy = [0, 0     , 0    , throw, -throw]

actualx = fiveptsx
actualy = fiveptsy

step = size/FLOAT(pts-1)
half = FLOAT(pts-1)/2.0

FOR i = -half, half DO BEGIN
	FOR j = -half, half DO BEGIN
		actualx = [actualx,i*step+fiveptsx]
		actualy = [actualy,j*step+fiveptsy]
	ENDFOR
ENDFOR

comment = 'Map of ' + STRING(size) + 'arcsec in ' + STRING(pts) + $
		'total points. 5 point throw of ' + STRING(throw) + 'at each map point'

write_jiggle_macro, filename, actualx, actualy, t_int, comment

;print, actualx
;print, actualy

END
