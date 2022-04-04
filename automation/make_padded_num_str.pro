function make_padded_num_str, min, places

minstr = strcompress(min,/rem)

num = 10.^(places-1.)

while (num gt 1) do begin

    if (min lt num) then minstr = '0'+minstr
    num = num/10L

endwhile

return,minstr

end
