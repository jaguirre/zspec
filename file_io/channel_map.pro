; Try to make a decent bolometer configuration file

readcol,'/home/zspec/zspec_svn/file_io/ElecConfigCharts.txt', $
  comment=';', format='(I, I, A, I, I)', $
  box_num, channel, type, flag, seq_id, /silent

type = strlowcase(type)

; Convert Bret's boxes to Matt's boxes
box_num = 8 - box_num + 1

readcol,'/home/zspec/zspec_svn/file_io/flags.txt', $
  comment=';', format='(I, I, I)', $
  box_num_fl, channel_fl, flag_fl, /silent

bolo_flag = intarr(n_e(box_num_fl))

; Need to convert box number, channel number to bolometer number
for i=0,n_e(box_num_fl)-1 do begin

    wh = where(box_num eq box_num_fl[i] and $
               channel eq channel_fl[i])

    bolo_flag[wh] = flag_fl[i]

endfor

openw,lun,'/home/zspec/zspec_svn/file_io/bolo_config.txt',/get_lun

for i=0,n_e(box_num_fl)-1 do begin
    
    printf, lun, format='(I10, I10, A10, I10, I10)', $
      box_num[i], channel[i], type[i], bolo_flag[i], seq_id[i]

endfor

close, lun
free_lun, lun

end
