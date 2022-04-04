function get_bolo_flags, bolo_config_file = bolo_config_file

if not(keyword_set(bolo_config_file)) then $
  bolo_config_file=getenv('HOME')+'/zspec_svn/file_io/bolo_config.txt' 

; Read in the configuration file.
readcol,bolo_config_file, $
  comment=';', format='(I, I, A, I, I)', $
  box_num, channel, type, flags, seq_id, /silent

type = strlowcase(type)

wh_opt = where(type eq 'optical')

nbolos = n_e(wh_opt)

bolo_flags = intarr(nbolos)

for i=0,nbolos-1 do begin

    wh = where(type eq 'optical' and seq_id eq i)

    bolo_flags[i] = flags[wh]

endfor

return, bolo_flags

end
