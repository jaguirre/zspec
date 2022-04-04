;October 2008 LE

;This program loads a few colors so you have more options than just
;red, green, blue, and yellow.  It's basically copied straight out
;of an IDL reference manual.


pro load_fav_colors,bottom=bottom,names=names

if (n_e(bottom) eq 0) then bottom=0

red=[0,255,0,255,0,255,0,255,$
     0,255,255,112,219,127,0,255]
grn=[0,0,255,255,255,0,0,255,$
     0.187,127.219,112,127,163,171]
blu=[0,255,255,0,0,0,255,255,$
     115,0,127,147,219,127,255,127]
tvlct,red,grn,blu,bottom

names=['black',$
       'magenta',$
       'cyan',$
       'yellow',$
       'green',$
       'red',$
       'blue',$
       'white',$
       'navy',$
       'gold',$
       'pink',$
       'aquamarine',$
       'orchid',$
       'grey',$
       'sky',$
       'beige']
     
end
