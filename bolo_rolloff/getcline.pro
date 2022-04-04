FUNCTION getcline, month, year, night, ERROR = ERROR, return_file=return_file
  
CASE 1 OF
    month EQ 4 AND year EQ 2006:BEGIN
          file = 'cline_combine_apr06.txt'
      END
      month EQ 12 AND year EQ 2006:BEGIN
          file = 'cline_combine_dec06.txt'
      END
      month EQ 1 AND year EQ 2007:BEGIN
          file = 'cline_combine_dec06.txt'
      END
      month EQ 4 AND year EQ 2007:BEGIN
          file = 'cline_combine_spr07.txt'
      END
      month EQ 5 AND year EQ 2007:BEGIN
          file = 'cline_combine_spr07.txt'
      END
      month EQ 11 AND year EQ 2007:BEGIN
          file = 'cline_combine_nov07.txt'
      END
      month EQ 12 AND year EQ 2007:BEGIN
          file = 'cline_combine_nov07.txt'
      END
      year EQ 2008: begin
          file = 'cline_combine_nov07.txt'
      END
      month EQ 1 AND year EQ 2009:BEGIN
          file = 'cline_combine_jan09.txt'
      END
      month EQ 2 AND year EQ 2009:BEGIN
          file = 'cline_combine_feb09.txt'
      END
      month EQ 3 AND year EQ 2009:BEGIN
          file = 'cline_combine_feb09.txt'
      END 
            month EQ 11 AND year EQ 2009:BEGIN
          file = 'cline_combine_nov09.txt'
          MESSAGE,/info,'Using cline from Nov 2009'
      END 
            month EQ 12 AND year EQ 2009:BEGIN
          file = 'cline_combine_nov09.txt'
          MESSAGE,/info,'Using cline from Nov 2009'
      END 
      month EQ 3 AND year EQ 2010 and night LE 12:BEGIN
          file = 'cline_combine_mar10_r1.txt'
      END
      month EQ 3 AND year EQ 2010 and night LE 22 and night ge 18:BEGIN
          file = 'cline_combine_mar10_r2.txt'
      END
      month EQ 3 AND year EQ 2010 and night GT 22:BEGIN
          file = 'cline_combine_mar10_r3.txt'
      END
           month EQ 4 AND year EQ 2010 and night LE 2:BEGIN
          file = 'cline_combine_mar10_r3.txt'
          MESSAGE,/info,'Using cline from March 2010'
      END
      	month GT 4 AND month LT 7 and year EQ 2010:BEGIN
      	file = 'cline_combine_may10.txt'
      	MESSAGE,/info,'Using cline from May 2010'
      END
;        month GE 10 AND month LE 11 and year EQ 2010:BEGIN
;      	file = 'cline_combine_oct2010.txt'
;      	MESSAGE,/info,'Using cline from Fall 2010'
;      END
;        month EQ 12 AND year EQ 2010:BEGIN
;      	file = 'cline_combine_jan2011.txt'
;      	MESSAGE,/info,'Using cline from Winter 2011'
;      END
;        month EQ 1 AND year EQ 2011:BEGIN
;      	file = 'cline_combine_jan2011.txt'
;      	MESSAGE,/info,'Using cline from Winter 2011'
;      END
      ELSE: begin
          file = 'cline_combine_jan2011.txt'
          MESSAGE,/info,'Using cline from Winter 2011'
      end
  END

  if keyword_set(return_file) then return, file
filename = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + 'bolo_rolloff' + $
         PATH_SEP() + 'fit_data' + PATH_SEP() + file
  READCOL, filename, freqid, cline, cline_err, $
           FORMAT = 'I,F,F', COMMENT = '#'
  ERROR = cline_err
  RETURN, cline
END
