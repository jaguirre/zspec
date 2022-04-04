pro plot_circles, radius, x, y, astro_orient=astro_orient, $
                  xrange=xrange, yrange=yrange, label_circles=label_circles, $
                  ct=ct, _extra=extra

if(keyword_set(xrange)) then begin
    x_plot=x-xrange[0]
    xmax=xrange[1]-xrange[0]
    
    if(keyword_set(astro_orient)) then x_plot=xmax-x_plot
endif else x_plot=x

if(keyword_set(yrange)) then y_plot=y-yrange[0] else y_plot=y

; Save current color table, load in new one
if(keyword_set(ct)) then begin
    old_ct=fltarr(!D.TABLE_SIZE,3)
    tvlct,/get,old_ct
    tvlct,ct
endif

tvcircle,radius,x_plot,y_plot,_extra=extra

if(keyword_set(label_circles)) then begin
    if((size(label_circles,/dim))[0] eq 0) then $
      labels=num_to_str(indgen(n_e(x))+1) else $
      labels=label_circles
    xyouts,x_plot+radius+1,y_plot,labels,_extra=extra
endif

; Restore old color table
if(keyword_set(ct)) then tvlct,old_ct

end
