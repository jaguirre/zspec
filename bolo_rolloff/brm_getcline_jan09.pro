FUNCTION brm_getcline_jan09, ERROR = ERROR
  file = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + 'bolo_rolloff' + $
         PATH_SEP() + 'fit_data' + PATH_SEP() + 'cline_combine_jan09.txt'
  READCOL, file, freqid, cline, cline_err, $
           FORMAT = 'I,F,F', COMMENT = '#'
  ERROR = cline_err
  RETURN, cline
END
