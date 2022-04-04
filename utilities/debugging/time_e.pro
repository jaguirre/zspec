pro time_e, t0, t1=t1

t1 = systime(/sec)-t0

print,strcompress(systime(/sec)-t0,/rem)+' sec.'

end
