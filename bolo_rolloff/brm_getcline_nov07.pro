FUNCTION brm_getcline_nov07, ERROR = ERROR
  file = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + 'bolo_rolloff' + $
         PATH_SEP() + 'fit_data' + PATH_SEP() + 'cline_combine_nov07.txt'
  READCOL, file, freqid, cline, cline_err, $
           FORMAT = 'I,F,F', COMMENT = '#'
  ERROR = cline_err
  RETURN, cline
END
