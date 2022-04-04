pro truncate, filename, nyquist=nyquist, trunc=trunc, sec_trunc=sec_trunc, mirror_position=mirror_position
    ; This procedure takes a sav file from a FTS scan and truncates the interferograms.
    ; This is accomplished by examining an electronics channel into which a position signal
    ; is stored.  The voltage of this signal changes every 10 cm of travel.  By examining
    ; where this occurs, it is possible to use it as criteria for throwing away portions
    ; of the interferogram from before and after the scan started and ended.  We can also calculate
    ; the number of samples per cm and with a velocity of 1 cm/s, calculate the number of samples
    ; per second, which allows us to determine the Nyquist frequency.


    ; Input Parameters:
    ; filename         -FTS scan to be restored
    ; nyquist          -Calculated nyquist frequency.  Stores value (not a keyword)
    ;                   this is the highest frequency calculated in the FFT.
    ; Trunc            -Array in which truncated interferograms are stored
    ; sec_trunc        -Independent variable of time
    ; mirror_position  -Array of position values, found from converting samples to distance traveled by
    ;                   moving mirror of FTS

    ; Define Constants:
    logic_int=10.0     ; Interval between blips in digital logic signal in units of cm
    c=2.998e10         ; Speed of light in cm/s


    ; Restore desired file:
    restore,filename

    ; Subtract a mean off of the digital logic signal
    ; Digital logic signal is stored in structure data.cos[9,18,*].
    ; Mean subtract the data so the logic signal oscillates between positive
    ; and negative:
    sub=data.cos[9,18,*]-mean(data.cos[9,18,*])

    ; Here we test to see where the blips in the digital logic signal occur.
    ; This is done by seeing where signal transitions between positive and negative
    ; We then truncate the data stream accordingly.
    trans=intarr(17)       ; Sample where transition occurs
    delta=intarr(16)       ; Number of samples between transitions
    for i=0,n_elements(trans)-2 do begin
        if ((i) mod 2) eq 0 then begin
           dig_logic=where(sub[trans[i]:*] LE 0)
           delta[i]=dig_logic[0]
           trans[i+1]=dig_logic[0]+trans[i]
        endif else begin
           dig_logic=where(sub[trans[i]:*] GE 0)
           delta[i]=dig_logic[0]
           trans[i+1]=dig_logic[0]+trans[i]
        endelse
    endfor

    ; Reform delta to include only data points of interest
    delta=reform(delta[1:n_elements(delta)-1])

    ; Find mean and standard deviation
    delta_av=mean(delta)
    delta_stddev=stddev(delta)

    ; Determine sample interval and Nyquist Frequency of interferogram
    samples_per_cm=delta_av/logic_int
    nyquist=(samples_per_cm*c)/4/1.e9   ; Divide by 10^9 to get in units of GHz

    ; Truncate data- Throw away data from before and after the scan
    ; Full interferograms are stored in structure vchannel
    trunc=vchannel(*,*,trans[1]-delta_av:trans[16]+delta_av/2)
    sec_trunc=seconds(trans[1]-delta_av:trans[16]+delta_av/2)
    mirror_position=findgen(n_elements(trunc[1,1,*]))/samples_per_cm
end