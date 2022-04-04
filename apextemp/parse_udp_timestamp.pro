function parse_udp_timestamp, timestamp

; t is an nbyte (usually 26?) by nbox by ntod array.  Convert to
; something fucking useful.
sz = size(timestamp)
if sz[0] eq 3 then begin
    ntod = n_e(timestamp[0,0,*])
    nbox = 10

    jd = dblarr(nbox,ntod)

    for b = 0,nbox - 1 do begin
        for t = 0L,ntod-1 do begin
            tmp = string(timestamp[*,b,t])
            tmp2 = strsplit(tmp,'T',/extract)
            date = tmp2[0]
            tmp3 = strsplit(date,'-',/extract)
            year = long(tmp3[0])
            month = long(tmp3[1])
            day = long(tmp3[2])
            time = tmp2[1]
            tmp4 = strsplit(time,':',/extract)
            hour = tmp4[0]
            minute= tmp4[1]
            second = tmp4[2]
            jd[b,t] = julday(month,day,year,hour,minute,second)
        endfor
    endfor
    
endif else if sz[0] eq 2 then begin

    ntod = n_e(timestamp[0,*])

    jd = dblarr(ntod)
    good = lonarr(ntod)+1

    for t = 0L,ntod-1 do begin
        tmp = string(timestamp[*,t])
; Jesus f-ing Lord.  Blank timestamps?
        if (tmp ne '') then begin
            tmp2 = strsplit(tmp,'T',/extract)
            date = tmp2[0]
            tmp3 = strsplit(date,'-',/extract)
            year = long(tmp3[0])
            month = long(tmp3[1])
            day = long(tmp3[2])
            time = tmp2[1]
            tmp4 = strsplit(time,':',/extract)
            hour = tmp4[0]
            minute= tmp4[1]
            second = tmp4[2]
            jd[t] = julday(month,day,year,hour,minute,second)
        endif else begin
            good[t] = 0
        endelse
    endfor

    jd = jd[where(good)]

endif

return, jd

end
