; $Id: column_xyouts.pro,v 1.2 2004/06/07 17:10:23 stoverp Exp $
; $Log: column_xyouts.pro,v $
; Revision 1.2  2004/06/07 17:10:23  stoverp
; Added keyword charthick.
;
; Revision 1.1  2003/11/14 20:09:58  stoverp
; Initial import
;
pro column_xyouts, array, ncols=ncols, yoff=yoff, bottom=bottom, color=color, _extra=_extra
; This procedure uses xyouts to print array onto the current graphics
; device in nice columns
; If array is 2D, it will be printed as is
; If array is 1D, use ncols to specify the # of column divisions - the
;   array will be printed column-wise with ncols columns

; 2003/11/14 PS Added to CVS

line_height = 400
nlines = 64
xmax = 20500
WHITE = 252
if(not keyword_set(color)) then color = 0
if(not keyword_set(yoff)) then yoff = 0
if(keyword_set(bottom)) then yoff = nlines - yoff

if(keyword_set(ncols)) then begin  ; Assume array is 1D list of strings to be printed in ncols columns
    xstep = xmax/ncols
    nrows = ceil(double(n_elements(array))/ncols)
    xpos = 0 
    ypos = nlines - yoff
    ystart = ypos

    for i=0,n_elements(array)-1 do begin
        xyouts,xpos*xstep,ypos*line_height,array[i],color=color,/dev, _extra=_extra
        ypos = ypos - 1
        if(ypos-nlines+yoff le -nrows) then begin
            xpos = xpos + 1
            ypos = ystart
        endif
    endfor
endif else begin  ; Assume array is 2D table of rows and columns
    ncols = n_elements(array[*,0])
    nrows = n_elements(array[0,*])
    xstep = xmax/ncols
    xpos = 0 

    ypos = nlines - yoff
    for j=0,nrows-1 do begin
        for i=0,ncols-1 do xyouts,i*xstep,ypos*line_height,array[i,j],color=color,/dev, _extra=_extra

        ypos = ypos - 1
        if(j eq nlines-1) then begin
            !p.multi = [0,1,1]
            plot,[0],/nodata,color=WHITE
            ypos = nlines - yoff
        endif
    endfor
endelse

end
