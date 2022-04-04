;Gets the box/channel number for a given freqid.

function freqid2boxchan, freqid, bolo_config_file=bolo_config_file

w=where(freqid lt 0 or freqid ge 160, count)

if count gt 0 then begin
    print, 'Invalid freqid. Must be between 0 and 159'
    return, -1
endif

if not(keyword_set(bolo_config_file)) then $
  bolo_config_file=getenv('HOME')+'/zspec_svn/file_io/bolo_config_dec06.txt' 

readcol,bolo_config_file, $
  comment=';', format='(I, I, A, I, I)', $
  box_num, channel, type, flags, seq_id, /silent

n=n_e(freqid)
boxchan=lonarr(n,2)

for i=0,n-1 do begin

    wh = where(seq_id eq freqid[i])
    boxchan[i,0] = box_num[wh] 
    boxchan[i,1] = channel[wh]

endfor

return,boxchan

end
