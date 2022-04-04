; This will read in a whole observation worth of RPC files and extract
; the parameter (or parameters) named in params.  The requested parameter(s)
; will be returned in a structure where the tags have the same name(s).   
; The data is trimmed based on the UTC time code indicated in the obs_def
; file. If ALL_PARAMS is
; set then params is ignored and all data in the RPC files will be returned.
; If keyword AZEL_OFFSETS is set, then params is ignored and the azimuth_offset
; and elevation_offset tags are returned.  
;
; Can decompress gziped rpc files and skip over missing rpc files.  If all 
; rpc files are missing, then -1 is returned.
;
; Updated to make params an optional argument.  if ALL_PARAMS and 
; AZEL_OFFSETS are not set, but params isn't present, then all params
; will be returned.  Also added _EXTRA keyword to pass keywords to
; read_rpc (DEF_FILE, USE_FILE & HDR_FILE).

FUNCTION get_rpc_params, year, month, day, obsnum, params, $
                         ALL_PARAMS = ALL_PARAMS, $
                         AZEL_OFFSETS = AZEL_OFFSETS, quiet = quiet, $
                         _EXTRA = EXTRA

  obsdef = read_obsdef(year,month,day,obsnum)
  
  nrpc = obsdef.min[1] - obsdef.min[0] + 1

  firstfile = 0
  FOR i = 0, nrpc-1 DO BEGIN
     rpcfile = get_rpcpath(year,month,day,obsdef.min[0] + i)
     IF FILE_TEST(rpcfile) THEN BEGIN
        if ~KEYWORD_SET(quiet) then $
           MESSAGE, /INFO, 'Reading rpc file: ' + rpcfile
        IF firstfile EQ 0 THEN BEGIN
           rpcdata = read_rpc(rpcfile, _EXTRA = EXTRA) 
           firstfile = 1
        ENDIF ELSE BEGIN
           rpcdata = [rpcdata,read_rpc(rpcfile, _EXTRA = EXTRA)]
        ENDELSE
     ENDIF ELSE IF FILE_TEST(rpcfile + '.gz') THEN BEGIN
        MESSAGE, /INFO, 'Compressed rpc file: ' + rpcfile
        MESSAGE, /INFO, 'Unzipping, reading and recompressing.'
        SPAWN, 'gunzip ' + rpcfile + '.gz'
        IF firstfile EQ 0 THEN BEGIN
           rpcdata = read_rpc(rpcfile, _EXTRA = EXTRA) 
           firstfile = 1
        ENDIF ELSE BEGIN
           rpcdata = [rpcdata,read_rpc(rpcfile, _EXTRA = EXTRA)]
        ENDELSE
        SPAWN, 'gzip ' + rpcfile
     ENDIF ELSE BEGIN
        MESSAGE, /INFO, 'Missing rpc file: ' + rpcfile
        MESSAGE, /INFO, 'Skipping to next file'
        IF (i EQ nrpc-1) AND (firstfile EQ 0) THEN BEGIN
           MESSAGE, /INFO, 'No rpc files found.  Returning -1'
           RETURN, -1
        ENDIF
     ENDELSE
  ENDFOR

; Get trimming range (include one sample pads at begining & end if possible)
  uttime = rpcdata.coordinated_universal_time*3600.
  trim = WHERE(uttime GT obsdef.utc[0] AND uttime LT obsdef.utc[1],ntrim)
  IF trim[0] GT 0 THEN trim = [trim[0]-1,trim] & ntrim = N_E(trim)
  IF trim[ntrim - 1] LT N_E(uttime) - 1 THEN $
     trim = [trim, trim[ntrim-1]+1] & ntrim = N_E(trim)

  ntags = N_TAGS(rpcdata)
  tag_names = TAG_NAMES(rpcdata)
  dims = INTARR(ntags)
  FOR i = 0, ntags - 1 DO dims[i] = (SIZE(rpcdata.(i)))[0]

  CASE 1 OF
     ; First check if ALL_PARAMS is set, if yes then return all rpc tag
     KEYWORD_SET(ALL_PARAMS): getparams = tag_names
     ; Next check if AZEL_OFFSETS is set, then only return those offsets
     KEYWORD_SET(AZEL_OFFSETS): getparams = $
        ['AZIMUTH_OFFSET','ELEVATION_OFFSET']
     ; Next check if the params argument is not present
     ; If not, return all tags
     (N_PARAMS() EQ 4): getparams = tag_names
     ; Otherwise, use the params argument (must be uppercase) 
     ELSE: getparams = STRUPCASE(params)
  ENDCASE


  wh_arr = where_arr(tag_names,getparams,nfound)
  IF nfound EQ 0 THEN MESSAGE, 'No tags found.  Stopping.'
  IF nfound NE N_E(getparams) THEN $
     MESSAGE, /INFO, 'Not all tags found.  Returning only the ones which exist.'

  FOR i = 0, nfound - 1 DO BEGIN
     currind = wh_arr[i]
     IF i EQ 0 THEN BEGIN
        CASE dims[currind] OF
           1: outdata = CREATE_STRUCT(tag_names[currind],$
                                      (rpcdata.(currind))[trim])
           2: outdata = CREATE_STRUCT(tag_names[currind],$
                                      (rpcdata.(currind))[*,trim])
        ENDCASE
     ENDIF ELSE BEGIN
        CASE dims[currind] OF
           1: outdata = CREATE_STRUCT(outdata, tag_names[currind],$
                                      (rpcdata.(currind))[trim])
           2: outdata = CREATE_STRUCT(outdata, tag_names[currind],$
                                      (rpcdata.(currind))[*,trim])
        ENDCASE
     ENDELSE
  ENDFOR

  RETURN, outdata
END
