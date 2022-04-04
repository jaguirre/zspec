ltime = findgen(13)+18.

plot_srces_azza,'example_source_list.txt',ltime,2009,4,15, $
  ps_file = 'example_visibility_plot.eps', $
  /legend,/left,/mars,/uranus,/neptune,/jupiter ;/sun,/moon

end
