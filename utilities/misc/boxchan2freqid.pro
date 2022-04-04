; Searches through the bolo_config file to match a box number between
; 1 and 8 and channel number between 0 and 23 with the appropriate
; frequency id.

function boxchan2freqid, ibox, ichan, $
                         bolo_config_file = bolo_config_file

; Doesn't make sense to pass non-integer values, but just in case
box = long(ibox)
chan = long(ichan)

whbadbox = where(box lt 1 or box gt 8)

if (whbadbox[0] ne -1) then begin
    message,/info,'Box number is out of range.'
    return,-1
endif

whbadchan = where(chan lt 0 or chan gt 23)

if (whbadchan[0] ne -1) then begin
    message,/info,'Channel number is out of range.'
    return,-1
endif

if not(keyword_set(bolo_config_file)) then $
  bolo_config_file=getenv('HOME')+'/zspec_svn/file_io/bolo_config_dec06.txt'  

readcol,bolo_config_file, $
  comment=';', format='(I, I, A, I, I)', $
  box_num, channel, type, flags, seq_id, /silent

n = n_e(box)

if (n ne n_e(chan)) then $
  message,'Must give same number of box and channel numbers.'

freqid = lonarr(n)

for i=0,n-1 do begin

    wh = where(box_num eq box[i] and channel eq chan[i])
    freqid[i] = seq_id[wh]

endfor

return,freqid

end
