;+
; NAME:
;	PLOT_INTENSITY_BAR
;
; PURPOSE:
;       Displays an intensity bar for an image's color range on a PS
;       device
;
; CATEGORY:
;       Pretty mapping
;
; CALLING SEQUENCE:
;       PLOT_INTENSITY_BAR, Legend_text
;
; INPUTS:
;       Legend_text:    A 2-element string array -- 
;                       [Value string for starting color,
;                        Value string for ending color]
;                       For example, ['-3.0 mJy','3.0 mJy']
;
; KEYWORD PARAMETERS:
;       START_COLOR:       Index into current color table for low end of
;                          color bar  (default is 0)
;       END_COLOR:         Index into current color table for high end of
;                          color bar  (default is 255)
;       LOC:               2-element array for bottom-left corner of
;                          bar in inches -- [x,y]  (default is [1.,1.])
;       SIZE:              2-element array for width & height of
;                          bar in inches -- [width,height]
;                          (default is [2.,.25])
;       _EXTRA:            User-specified keywords to XYOUTS (formats
;                          the legend text)
; OUTPUTS:
;       This procedure displays a color-intensity bar on the current graphics
;       device, although it's recommended you set that device to PS
;       for the sizing to work properly.
;
; MODIFICATION HISTORY:                     
;      2004/03/18 PS Created
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro plot_intensity_bar, legend_text, start_color=start_color, end_color=end_color, _extra=_extra, offset=offset, size=size, label_offset=label_offset

I2C = 2540  ; Inches to .001 centimeters

if(not keyword_set(start_color)) then start_color = 0
if(not keyword_set(end_color)) then end_color = 255
if(not keyword_set(offset)) then offset = [1.,1.]
if(not keyword_set(size)) then size = [2.,.25]
if(not keyword_set(label_offset)) then label_offset = -.4

color_indices = indgen(end_color-start_color+1)+start_color
tv, reform(color_indices,n_e(color_indices),1), offset[0], offset[1], xsize=size[0], ysize=size[1], /inches
xyouts,I2C*(offset[0]+label_offset),I2C*(offset[1]-.2),legend_text[0],/dev,_extra=_extra 
xyouts,I2C*(offset[0]+size[0]+label_offset),I2C*(offset[1]-.2),legend_text[1],/dev,_extra=_extra 

end
