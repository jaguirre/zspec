; set environment variable for bolo_library
; This file should be edited by the user and renamed
; to match the specific directory setup
; This is the Unix/Linux version
;
pro envimrspock
setenv, 'BLO_ROOT=/home/spirebolo/bolo_software/'                ;root directory
setenv, 'BLO_HELP_HTML='+getenv('BLO_ROOT')+'documents/helpDocuments/'    ;help directory
setenv, 'BLO_DATADIR=/data1/SPIRE_PFM_PLW/'                         ;data directory
setenv, 'BLO_DASGDIR=/data1/SPIRE_PFM_PLW/'                         ;DASGains file path
end