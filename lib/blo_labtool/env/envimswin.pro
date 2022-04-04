; set environment variable for bolo_library
; This file should be edited by the user and renamed
; to match the specific directory setup
; This is the MS-Windows version
;
pro envimswin
setenv, 'BLO_ROOT=D:\data1\bolo_software\'    ;root directory
setenv, 'BLO_HELP_HTML='+getenv('BLO_ROOT')+'documents\helpDocuments\'   ;help directory
setenv, 'BLO_DATADIR=D:\project\spire\CQM_tests\'                                ;data directory
setenv, 'BLO_DASGDIR=D:\project\spire\CQM_tests\'                                ;DASGains file path
end
