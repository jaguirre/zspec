; This routine will make an identification of the plot with the username
; and the date
pro plot_id

user=getenv("USER")

id= strtrim(user,2)+ ' - ' + !STIME

x0 = 0.98  & y0=0.02
xyouts,x0,y0,id,alignment=1.0,charsize=0.6,/norm

return
end
