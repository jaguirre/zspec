; $Id: num_to_str.pro,v 1.1 2003/11/14 20:01:07 stoverp Exp $
; $Log: num_to_str.pro,v $
; Revision 1.1  2003/11/14 20:01:07  stoverp
; Initial import
;
function num_to_str, num, precision
; This function converts a number to a string
; precision determines the max number of characters in the string
; If not set, full precision is assumed

if(not keyword_set(precision)) then precision = 30

str = strcompress(string(num),/rem)
str = strmid(str,0,precision)
return, str

end
