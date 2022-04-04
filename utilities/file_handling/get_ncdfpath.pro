; Returns full path to ncdf data file based on given year (4 digits), month, day and 
; observation number.  If the keyword EXISTS is set, then the routine will check if 
; the file exists and interrupt execution if it doesn't.

FUNCTION get_ncdfpath, year, month, day, obs_num, EXISTS = EXISTS
	main_data_dir = !zspec_data_root + PATH_SEP() + 'ncdf'
        date_str = STRING(year, F='(I04)') + STRING(month, F='(I02)') + STRING(day, F='(I02)')
	obs_str = STRING(obs_num, F='(I03)')
        path = main_data_dir + PATH_SEP() + date_str + PATH_SEP() + $
			date_str + '_' + obs_str + '.nc'

        IF (KEYWORD_SET(EXISTS) AND ~(FILE_TEST(path))) THEN BEGIN
           MESSAGE, /INFO, 'Data file does not exist here'
           MESSAGE, /INFO, path
           STOP
        ENDIF
           
        RETURN, path
END
