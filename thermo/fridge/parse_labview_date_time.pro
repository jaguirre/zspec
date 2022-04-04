function parse_labview_date_time, string, from_start = from_start, $
                                  hours = hours, minutes = minutes, $
                                  seconds = seconds
                                  

; The LabView data and time field comes out in a way that's not that
; useful for plotting.  So, this function converts a vector of strings
; in the format M/D/Y H:M:S XM to the Julian day.

nstring = n_e(string)
jultime = dblarr(nstring)
clock24 = dblarr(nstring)

for i=0L,n_e(string)-1 do begin

    temp = strsplit(string[i],' ',/extract)
;    print,temp
; Parse the date
    date = strsplit(temp[0],'/',/extract)
    month = double(date[0])
    day = double(date[1])
    year = double(date[2])
; Parse the time
    time = strsplit(temp[1],':',/extract)
    hour = double(time[0])
    minute = double(time[1])
    second = double(time[2])
; Change to 24 hour clock
    if (time[0] ne '12' and temp[2] eq 'PM') then begin
        hour = hour + 12.
    endif 
    if (time[0] eq '12' and temp[2] eq 'AM') then $
      hour = hour - 12.d
;    print,month,day,year,hour,minute,second
    clock24[i] = ten(hour,minute,second)
    jultime[i] = julday(month,day,year,hour,minute,second)

;    blah = ''
;    read,blah

endfor

if (keyword_set(from_start)) then begin 
    jultime = jultime - jultime[0]
; Default comes out in DAYS.  Convert to other units if requested
    if (keyword_set(hours)) then jultime = jultime * 24.d
    if (keyword_set(minutes)) then jultime = jultime * 24.d * 60.d
    if (keyword_set(seconds)) then jultime = jultime * 24.d * 3600.d
endif

return, jultime

end
