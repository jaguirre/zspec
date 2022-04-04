FUNCTION get_ncdfpath_jan07, day, obs_num, EXISTS = EXISTS
  RETURN, get_ncdfpath(2007,01,day,obs_num,EXISTS = EXISTS)
END
