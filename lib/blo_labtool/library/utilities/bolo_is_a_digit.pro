;+
;=============================================================================
; NAME: 
;		  bolo_is_a_digit
;
; DESCRIPTION: 
;		  It checks whether the character is
;                 a digit
;
; USAGE: 
;		  bolo_is_a_digit(c)
; 
; OUTPUT:	   
;    True	  If c is a digit (0, 1, 2, 3, 4, 5, 6, 7, 8, 9) 
;    False	  If c is something else    
;		 							    
; KEYWORDS:
;    NONE
;
;  AUTHOR: 
;		  L. Zhang
;
;  Edition History
; 
;  Date		Progarmmer   Remarks
;  2004/03/12 : L. Zhang     initial test version
;=============================================================================		
;-
FUNCTION bolo_is_a_digit, ch
  digit=['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
  
  ix=where(digit eq ch, count)
  
  if ix eq -1 then return, 0 else return, 1
  
  
  
end
