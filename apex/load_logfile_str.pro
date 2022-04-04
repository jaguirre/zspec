;===============================================================================================
; THIS FUNCTION CONVERTS THE SAVED LOG FILE OBTAINED FROM
; SEARCHSCANSDB INTO A FITS FILE
;===============================================================================================
; Created on Nov-2012 by Edo Ibar while at APEX
;
; check array "div" which defines the column at which each parameter
; is separated from each other. It might change in future updates of
; the SEARCHSCANSDB program.
;
; Added to SVN by JRK 12/3/12, it was convert_logfile_into_fitsfile but
;  I modified it to be just load_logfile_str, because now it just
;  loads the structure (thought it can also be used to save as a .fits file).


function load_logfile_str, filename, output_file

;; Input log file to be converted into a fits file
if ~keyword_set(filename) then filename = !zspec_pipeline_root+'/apex/save_search_ZSPEC.dat'
if ~keyword_set(output_file) then output_file = !zspec_pipeline_root+'/apex/save_search_ZSPEC.fits'

;------------------------------------------------------------------------------------------------
; create format readout
;------------------------------------------------------------------------------------------------
; These are the column marks used to divide the log file (done by eye)
div = [22,  45,  55,  80,  94,  106,  118,  130,  145,  155,  164,  175,  190,  205,  215,  225,  235,  245,  255,  266,  286,  311,  333,  513,  614]
; This is to create the format 
for k=0, n_elements(div)-1 do begin
    if k eq 0 then begin
        format_auto = "(a"+strcompress(div[k]-1,/remove_all)+",1x, "
;        print, div[k]-1 
      endif else begin
          if k eq n_elements(div)-1 then begin
              format_auto = format_auto + "a"+strcompress((div[k]-div[k-1])-1,/remove_all)+",1x)"
          endif else begin
              format_auto = format_auto + "a"+strcompress((div[k]-div[k-1])-1,/remove_all)+",1x, "
          endelse
;          print, (div[k]-div[k-1])-1
    endelse
endfor
;print, format_auto
;stop
format = format_auto


;------------------------------------------------------------------------------------------------
; extract variables
;------------------------------------------------------------------------------------------------
n_lines = file_lines(filename)

hea1 = " "  & hea2 = " "  & hea3 = " "  & hea4 = " "  & hea5 = " " 
hea6 = " "  & hea7 = " "  & hea8 = " "  & hea9 = " "  & hea10 = " "
hea11 = " " & hea12 = " " & hea13 = " " & hea14 = " " & hea15 = " "
hea16 = " " & hea17 = " " & hea18 = " " & hea19 = " " & hea20 = " "
hea21 = " " & hea22 = " " & hea23 = " " & hea24 = " " & hea25 = " "

val1 = " "  & val2 = " "  & val3 = " "  & val4 = " "  & val5 = " " 
val6 = " "  & val7 = " "  & val8 = " "  & val9 = " "  & val10 = " "
val11 = " " & val12 = " " & val13 = " " & val14 = " " & val15 = " "
val16 = " " & val17 = " " & val18 = " " & val19 = " " & val20 = " "
val21 = " " & val22 = " " & val23 = " " & val24 = " " & val25 = " "

var1  = replicate(" ", n_lines-7) 
var2  = replicate(" ", n_lines-7)
var3  = replicate(" ", n_lines-7)
var4  = replicate(" ", n_lines-7)
var5  = replicate(" ", n_lines-7)
var6  = replicate(" ", n_lines-7)
var7  = replicate(" ", n_lines-7) 
var8  = replicate(" ", n_lines-7)
var9  = replicate(" ", n_lines-7) 
var10 = replicate(" ", n_lines-7) 
var11 = replicate(" ", n_lines-7)
var12 = replicate(" ", n_lines-7)
var13 = replicate(" ", n_lines-7)
var14 = replicate(" ", n_lines-7)
var15 = replicate(" ", n_lines-7)
var16 = replicate(" ", n_lines-7)
var17 = replicate(" ", n_lines-7)
var18 = replicate(" ", n_lines-7)
var19 = replicate(" ", n_lines-7)
var20 = replicate(" ", n_lines-7)
var21 = replicate(" ", n_lines-7)
var22 = replicate(" ", n_lines-7)
var23 = replicate(" ", n_lines-7)
var24 = replicate(" ", n_lines-7)
var25 = replicate(" ", n_lines-7)

; Go throughout the file
line = " "
cnt = 0
openr, lun, filename, /get_lun
for k=0, n_lines-1 do begin
    readf, lun, line
    if (k eq 0) or (k eq 2) or (k gt n_lines-5) then begin
;        print, "UNO  ", line
    endif else begin
        if k eq 1 then begin
            header = line
;            print,  header
            reads, line, $
              hea1,  hea2,  hea3,  hea4,  hea5, $
              hea6,  hea7,  hea8,  hea9,  hea10, $
              hea11, hea12, hea13, hea14, hea15, $
              hea16, hea17, hea18, hea19, hea20, $
              hea21, hea22, hea23, hea24, hea25, $
              format=format
        endif
        if k ge 3 then begin
;            print, line
;        print, strlen(line)
            reads, line, $
              val1,  val2,  val3,  val4,  val5, $
              val6,  val7,  val8,  val9,  val10, $
              val11, val12, val13, val14, val15, $
              val16, val17, val18, val19, val20, $
              val21, val22, val23, val24, val25, $
              format=format

;            print, $
;              val1, " ", val2, " ", val3, " ", val4, " ", val5, " ",$
;              val6, " ", val7, " ", val8, " ", val9, " ", val10, " ",$
;              val11, " ", val12, " ", val13, " ", val14, " ", val15, " ",$
;              val16, " ", val17, " ", val18, " ", val19, " ", val20, " ", $
;              val21, " ", val22, " ", val23, " ", val24;, " ", val25,
;              " "
            var1[cnt]  = val1
            var2[cnt]  = val2
            var3[cnt]  = val3
            var4[cnt]  = val4
            var5[cnt]  = val5
            var6[cnt]  = val6
            var7[cnt]  = val7
            var8[cnt]  = val8
            var9[cnt]  = val9
            var10[cnt] = val10
            var11[cnt] = val11
            var12[cnt] = val12
            var13[cnt] = val13
            var14[cnt] = val14
            var15[cnt] = val15
            var16[cnt] = val16
            var17[cnt] = val17
            var18[cnt] = val18
            var19[cnt] = val19
            var20[cnt] = val20
            var21[cnt] = val21
            var22[cnt] = val22
            var23[cnt] = val23
            var24[cnt] = val24
            var25[cnt] = val25

            cnt = cnt+1
;            print, cnt, n_lines-7
        endif
    endelse
endfor
free_lun, lun

hea1 = strcompress(hea1,/remove_all)
hea2 = strcompress(hea2,/remove_all)
hea3 = strcompress(hea3,/remove_all)
hea4 = strcompress(hea4,/remove_all)
hea5 = strcompress(hea5,/remove_all)
hea6 = strcompress(hea6,/remove_all)
hea7 = strcompress(hea7,/remove_all)
hea8 = strcompress(hea8,/remove_all)
hea9 = strcompress(hea9,/remove_all)
hea10 = strcompress(hea10,/remove_all)
hea11 = "Az";strcompress(hea11,/remove_all)
hea12 = "El";strcompress(hea12,/remove_all)
hea13 = strcompress(hea13,/remove_all)
hea14 = strcompress(hea14,/remove_all)
hea15 = strcompress(hea15,/remove_all)
hea16 = strcompress(hea16,/remove_all)
hea17 = strcompress(hea17,/remove_all)
hea18 = strcompress(hea18,/remove_all)
hea19 = strcompress(hea19,/remove_all)
hea20 = strcompress(hea20,/remove_all)
hea21 = strcompress(hea21,/remove_all)
hea22 = strcompress(hea22,/remove_all)
hea23 = strcompress(hea23,/remove_all)
hea24 = strcompress(hea24,/remove_all)
hea25 = strcompress(hea25,/remove_all)

;YYYYMMDDTHHMMSS
;ProjectID
;Scan
;SourceName
;ScanType
;Receiver
;Backend
;Frequency
;Line
;PWV
;Az
;El
;RA
;Dec
;CA
;IE
;FocusX
;FocusY
;FocusZ
;Duration
;Switchingmode
;Reference
;JulianDate
;Scancommand
;Scancomments

logfile = {YYYYMMDDTHHMMSS: val1,$
           ProjectID:       val2,$
           Scan:           0L,$
           SourceName:      val4,$
           ScanType:        val5,$
           Receiver:        val6,$
           Backend:         val7,$
           Frequency:      0.0,$
           Line:            val9,$
           PWV:            0.0,$
           Az:             0.0,$
           El:             0.0,$
           RA:              val13,$
           Dec:             val14,$
           CA:             0.0,$
           IE:             0.0,$
           FocusX:         0.0,$
           FocusY:         0.0,$
           FocusZ:         0.0,$
           Duration:       0L,$
           Switchingmode:   val21,$
           Reference:       val22,$
           JulianDate:      val23,$
           Scancommand:     val24,$
           Scancomments:    val25}

; Replicate the basic structure to the length of the dataset
logfile = replicate(logfile, n_lines-7)

; Define each of the structure variables
logfile.YYYYMMDDTHHMMSS  = var1
logfile.ProjectID        = var2
logfile.Scan             = long(var3)
logfile.SourceName       = var4
logfile.ScanType         = var5
logfile.Receiver         = var6
logfile.Backend          = var7
logfile.Frequency        = double(var8)
logfile.Line             = var9
logfile.PWV              = double(var10)
logfile.Az               = double(var11)
logfile.El               = double(var12)
logfile.RA               = var13
logfile.Dec              = var14
logfile.CA               = double(var15)
logfile.IE               = double(var16)
logfile.FocusX           = double(var17)
logfile.FocusY           = double(var18)
logfile.FocusZ           = double(var19)
logfile.Duration         = long(var20)
logfile.Switchingmode    = var21
logfile.Reference        = var22
logfile.JulianDate       = var23
logfile.Scancommand      = var24
logfile.Scancomments     = var25

;; Save structure as a fits file
mwrfits, logfile, output_file, /create

return, logfile
end
