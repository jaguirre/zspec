; i_of_n.pro - returns a string 
; 'thing i of n - Time Remaining in group = (thingtime)*(n-(i-1)) timeunit'

FUNCTION i_of_n, thing, i, n, group, thingtime, timeunit
	istr = STRING(i, FORMAT = '(I0)')
	nstr = STRING(n, FORMAT = '(I0)')
	trem = thingtime*(n - (i-1))
	tremstr = STRING(trem, FORMAT = '(F0.1)')
	
	RETURN, thing + ' ' + istr + ' of ' + nstr + $
		' - Time remaining in ' + group + ' = ' + $
		tremstr + ' ' + timeunit
END
