function make_obsnum_str, min

minstr = strcompress(min,/rem)
;if (min lt 1000) then minstr = '0'+strcompress(min,/rem)
if (min lt 100) then minstr = '0'+strcompress(min,/rem)
if (min lt 10) then minstr = '00'+strcompress(min,/rem)

return,minstr

end
