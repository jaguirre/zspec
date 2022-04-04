; This is the inverse function to get_ncdfpath.  It takes a string path 
; argument and extracts from the filename at the end of the path
; the year, month, night, and observation number in the filename.
;
; EXAMPLE: if ncfile = /foo/bar/20060416_001.nc then the returned structure
; will have the following tags: year = 2006, month = 4, night = 16 
; and obsnum = 1.  If the filename does not have the form YYYYMMDD_OOO then
; the output will probably not be what is expected.

FUNCTION get_ncdfnums, ncfile
  year = 0L
  month = 0L
  night = 0L
  obsnum = 0L
  name = FILE_BASENAME(ncfile)
  READS, STRMID(name,0,4), year
  READS, STRMID(name,4,2), month
  READS, STRMID(name,6,2), night
  READS, STRMID(name,9,3), obsnum

  RETURN, CREATE_STRUCT('year',year,$
                        'month',month,$
                        'night',night,$
                        'obsnum',obsnum)
END
