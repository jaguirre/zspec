; Get the mbfits list
restore,'/home/local/zspec/mbfits/mbfits_catalog_20130529.sav'

; This is some serious bullshit
name = 'Mars'
len = strlen(name)
wh_mars = where(strcmp(mbfits.source,name,len,/fold) and $
                mbfits.year eq 2012)

; Let's just blast through the Mars reductions and see where it
; fails.

nmars = n_e(wh_mars)
processed = intarr(nmars)
bugger = 0

for i = 0,nmars-1 do begin

    catch,bugger
    if bugger ne 0 then begin
        i=i+1
        bugger = 0
    endif else begin
        zapex,mbfits[wh_mars[i]].scannum,1,2
        processed[i] = 1
    endelse

endfor

; How were we making calibrated Mars spectra?
; Where is the calibration?

end
