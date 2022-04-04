; Returns full path to ncdf data file based on given year (4 digits), 
; month, day and 
; relative UT minute (time in minutes from UT midnight).  
; If the keyword EXISTS is set, then the routine 
; will check if 
; the file exists and interrupt execution if it doesn't.

FUNCTION get_rpcpath, year, month, day, ut_min, EXISTS = EXISTS
	main_data_dir = !zspec_data_root + PATH_SEP() + 'rpc'
        date_str = STRING(year, F='(I04)') + $
                   STRING(month, F='(I02)') + STRING(day, F='(I02)')
	utm_str = STRING(ut_min, F='(I04)')
        path = main_data_dir + PATH_SEP() + date_str + PATH_SEP() + $
			date_str + '_' + utm_str + '_rpc.bin'

        IF (KEYWORD_SET(EXISTS) AND ~(FILE_TEST(path))) THEN BEGIN
           MESSAGE, /INFO, 'Data file does not exist here'
           MESSAGE, /INFO, path
           STOP
        ENDIF
           
        RETURN, path
END
