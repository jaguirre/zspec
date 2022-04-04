pro time_s, message, t0, no_sticky = no_sticky

if keyword_set(no_sticky) then begin

    print, message
    t0 = systime(/sec)

endif else begin

    print, message, format = '(a,$)'
    t0 = systime(/sec)

endelse

end
