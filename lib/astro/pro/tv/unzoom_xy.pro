pro unzoom_xy,xtv,ytv,xim,yim,OFFSET=offset, ZOOM = zoom
;+
; NAME:
;      UNZOOM_XY
; PURPOSE:
;      Converts X, Y position on the image display to the the X,Y position 
;      on the corresponding image array.  (These  positions are identical 
;      only for an unroamed, unzoomed image with with pixel (0,0) of the 
;      image placed at position (0,0) on the TV.)
;
; CALLING SEQUENCE:
;      UNZoom_XY, Xtv,Ytv,Xim,Yim, [ OFFSET =, ZOOM = ]   
;
; INPUTS:
;      XTV - Scalar or vector giving X position(s) as read on the image
;            display (e.g. with CURSOR,XTV,YTV,/DEVICE)
;      XTV - Scalar or vector giving Y position(s) on the image display.
;      If only 2 parameters are supplied then XTV and YTV will be modfied
;      on output to contain the image array coordinates.
;
; OPTIONAL KEYWORD INPUT:
;      OFFSET - 2 element vector giving the location of the image pixel (0,0) 
;               on the window display.   OFFSET can be positive (e.g if the 
;               image is centered in a larger window) or negative (e.g. if the
;               only the central region of an image much larger than the window
;               is being displayed. 
;               Default value is [0,0], or no offset.
; OUTPUTS:
;      XIM,YIM - X and Y coordinates of the image corresponding to the
;            cursor position on the TV display.
; NOTES:
;       The integer value of a pixel is assumed to refer to the *center*
;       of a pixel.
; REVISON HISTORY:
;       Adapted from MOUSSE procedure  W. Landsman       March 1996
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Proper handling of offset option          S. Ott/W. Landsman May 2000
;-

 On_error,2

 if N_params() LT 2 then begin
        print,'Syntax - UNZOOM_XY, xtv, ytv, xim, yim, [OFFSET= ,ZOOM = ]'
        return
 endif
    
 if N_elements(offset) NE 2 then offset = [0,0] 
 if N_elements(zoom) NE 1 then zoom = 1

 cen =  (zoom-1)/2.
 xim =  float((xtv-cen)/zoom) - offset[0]/float(zoom)
 yim =  float((ytv-cen)/zoom) - offset[1]/float(zoom)
 if N_Params() LT 3 then begin
   xtv = xim & ytv = yim
 endif

return
end                                    

