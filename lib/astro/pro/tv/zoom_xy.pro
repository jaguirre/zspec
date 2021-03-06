pro zoom_xy, xim, yim, xtv, ytv, OFFSET=offset, ZOOM = zoom
;+
; NAME:
;      ZOOM_XY
; PURPOSE:
;       Converts X, Y position on the image array to the the X,Y position 
;       in the current window.   (These  positions are identical 
;       only for an unroamed, zoomed image with with pixel (0,0) of the 
;       image placed at position (0,0) on the TV.)
;
; CALLING SEQUENCE:
;      ZOOM_XY, Xim,Yim,Xtv,Ytv, [ OFFSET =, ZOOM = ]
;
; INPUTS:
;      XIM - Scalar or vector giving X position(s) as read on the image
;            display (e.g. with CURSOR,XIM,YIM,/DEVICE)
;      YIM - Like XTV but giving Y position(s) as read on the image display.
;
;      If only 2 parameters are supplied then XIM and YIM will be modfied
;      on output to contain the converted coordinates.
;
; OPTIONAL KEYWORD INPUT:
;      OFFSET - 2 element vector giving the location of the image pixel (0,0) 
;               on the window display.   OFFSET can be positive (e.g if the 
;               image is centered in a larger window) or negative (e.g. if the
;               only the central region of an image much larger than the window
;               is being displayed. 
;               Default value is [0,0], or no offset.
;
;       ZOOM - Scalar specifying the magnification of the window with respect
;               to the image variable.
; OUTPUTS:
;      XTV,YTV - REAL*4 X and Y coordinates of the image corresponding to the
;            cursor position on the TV display.   Same number of elements as
;            XIM, YIM.
;
; NOTES:
;       The integer value of a pixel is assumed to refer to the *center*
;       of a pixel.
; REVISON HISTORY:
;       Adapted from MOUSSE procedure of the same name W. Landsman HSTX Mar 1996
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Properly include ZOOM keyword  W. Landsman   May 2000
;-
 On_error,2 

 if N_params() LT 2 then begin
        print,'Syntax - Zoom_XY, Xtv, Ytv, Xim, Yim, [ Offset=, Zoom = ]'
        return
 endif
    
 if N_elements(offset) NE 2 then offset = [0,0]
 if N_elements(zoom) NE 1 then zoom = 1

 cen =  (zoom-1)/2.

 xtv =  cen + zoom*(xim + offset[0] )
 ytv =  cen + zoom*(yim + offset[1] )

 if N_Params() LT 3 then begin
    xim = xtv  & yim = ytv
 endif                  

 return
 end                                    
