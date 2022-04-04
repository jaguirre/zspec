ltime = findgen(10)+10.

plot_srces_azza,'dsphs.txt',ltime,2013,9,26, $
  ps_file = 'dsphs.eps', $
  lat = ten(38,25,59), long = 360-ten(79,50,23), tz = 4, $
  /legend,/left,/sun;,/mars,/uranus,/neptune,/jupiter ;/sun,/moon

end
