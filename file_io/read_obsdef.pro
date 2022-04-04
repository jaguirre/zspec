; this function reads an obs_def file and returns the data contained therein
; as a four tag structure (.num, .min, .samp, .utc).  The latter 
; three tags are two element vectors.

FUNCTION read_obsdef, year, month, night, obsnum
; Create path to file  
  ncpath = get_ncdfpath(year,month,night,obsnum)
  ncdir = FILE_DIRNAME(ncpath)
  obsdef_path = ncdir + PATH_SEP() + STRING(obsnum, F='(I03)') + $
                '_obs_def.txt'
  compressed = 0
  IF ~FILE_TEST(obsdef_path) THEN BEGIN
     IF FILE_TEST(obsdef_path+'.gz') THEN BEGIN
        MESSAGE, /INFO, 'Obs def file compressed'
        SPAWN, 'gunzip ' + obsdef_path + '.gz'
        compressed = 1
     ENDIF ELSE BEGIN
        MESSAGE, 'Obs def file not found: ' + obsdef_path
     ENDELSE 
  ENDIF
     
; Open and read data from file
  obsnum_file = 0L
  obsmin = LONARR(2)
  obssamp = LONARR(2)
  obsutc = DBLARR(2)

  OPENR, lun, obsdef_path, /GET_LUN
  READF, lun, obsnum_file, FORMAT = '(I10)'
  READF, lun, obsmin, FORMAT = '(2I10)'
  READF, lun, obssamp, FORMAT = '(2I10)'
  READF, lun, obsutc, FORMAT= '(2D10.2)'
  
  CLOSE, lun
  FREE_LUN, lun

  IF compressed EQ 1 THEN SPAWN, 'gzip ' + obsdef_path

  RETURN, CREATE_STRUCT('num',obsnum_file,$
                        'min',obsmin,$
                        'samp',obssamp,$
                        'utc',obsutc)
END
