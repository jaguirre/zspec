;; This function takes path (which is a full path to a file), strips off 
;; any and all suffixes and replaces them with newsuffix.
;;
;; If path = '/happy/go/lucky/sunny_day.foo.bar' and newsuffix = 'silly', 
;; then this function will return '/happy/go/lucky/sunny_day.silly'.
;; If newsuffix = '.silly', then the output is the same.  If 
;; newsuffix = '_chilly.willy, then you get 
;; '/happy/go/lucky/sunny_day_chilly.willy'
;;
;; HISTORY 2006_08_25 BN Inital Version
;;         2006_09_12 BN Added parsing of newsuffix so that if it has
;;                       a period within, no additional periods are
;;                       added
;;         2012_12_18 KSS Fixed bug in renaming file if it has a
;;         period in the basename.

FUNCTION change_suffix, file, newsuffix

; Check if file has a path, or is just a filename
IF STRMATCH(file,'*'+PATH_SEP()+'*') THEN BEGIN
   path = FILE_DIRNAME(file, /MARK_DIRECTORY)
ENDIF ELSE BEGIN
   path = ''
ENDELSE

; Get just the base file name (no suffix)
file_split = STRSPLIT(FILE_BASENAME(file),'.',/EXTRACT)
nstr = n_e(file_split)
base = strjoin(file_split[0:nstr-2],'.')
;base = (STRSPLIT(FILE_BASENAME(file),'.',/EXTRACT))[0]

; If newsuffix has a period in it, then don't add an additional period between
; base & newsuffix.  If there isn't a period in newsuffix, then include one.
IF STRMATCH(newsuffix,'*.*') THEN $
   newsuffix_out = newsuffix $
ELSE newsuffix_out = '.' + newsuffix

RETURN, path + base + newsuffix_out

END
