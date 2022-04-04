; Improvements:

; Need to check sequence number 

; Should leave open the possibility of recording (or checking) other
; box information

; Speed up!

; Sort data by type

function read_bze, filename, nbox, ac_bolos = bolos, dc_bolos = $
                   dc_bolos, seq_num = seq_num, seconds = seconds, $
                   def_file = def_file, $
                   bolo_config_file = bolo_config_file, new = new, $
                   old = old, $
                   nframes = nframes, utc = utc, $
                   be_careful = be_careful, loadcurve = loadcurve

; The loadcurve data is (currently 06/07/29) unique in that it DOESN'T
; have the timestamp.  The loadcurve keyword is a work-around to avoid
; having to change the bzed we're using and still be able to use this
; (newer) version of read_bze.

;message,/info,'Variable new set to '+strcompress(new,/rem)

time_s,'Timing read_bze ... ',t1,/no_sticky

; File containing the definition of the BZE frame
if not(keyword_set(def_file)) then begin
    def_file = $
      !zspec_pipeline_root+'/file_io/bze_def_20060412.txt'
   if(keyword_set(new)) then begin
       def_file = $
         !zspec_pipeline_root+'/file_io/bze_def_post_20050607.txt'
   endif 
   if (keyword_set(old)) then begin
       def_file = $
         !zspec_pipeline_root+'/file_io/bze_def_pre_20050607.txt'
   endif
   if (keyword_set(loadcurve)) then begin
       def_file = $
         !zspec_pipeline_root+'/file_io/bze_def_loadcurve_20060728.txt'
   endif    
endif

; Mapping of box #, channel # to bolometer
; Default should be the latest
if not(keyword_set(bolo_config_file)) then $
  bolo_config_file=!zspec_pipeline_root+'/file_io/bolo_config_apr07.txt'  

; Read in the frame definition
readcol,def_file,comment=';',format='(A,I,A)',$
  var_type, n_array, var_name,/silent

; Read in the configuration file.  You need this to sort out which are the
; optical bolometers.
readcol,bolo_config_file, $
  comment=';', format='(I, I, A, I, I)', $
  box_num, channel, type, flags, seq_id, /silent

; Specify the number of bytes for each variable
nbytes_var = lonarr(n_e(var_type))
for i=0,n_e(var_type)-1 do begin
    case var_type[i] of 
        'double' : nbytes_var[i] = 8L*n_array[i]
        'int' : nbytes_var[i] = 8L*n_array[i]
        'char' : nbytes_var[i] = 1L*n_array[i]
    endcase
endfor

; Define a structure so that read_binary can read the file
;binary_template = create_binary_template(def_file)

; Create a template structure by reading the first frame of the file
;data_template = read_binary(filename,template=binary_template)

;ntags = n_tags(data_template)
nbytes_per_frame = long(total(nbytes_var)) 
help,nbytes_per_frame

openr,unit,filename,/get_lun,/rawio,/swap_if_big_endian

; Figure out how many bytes in the data file
nbytes = (fstat(unit)).size

; Figure out how many frames are in the data
if ( (nbytes mod nbytes_per_frame) ne 0) then begin
    message,/info,$
    'Data file does not contain an integral number of data frames.'
    if (keyword_set(be_careful)) then begin
        message,/info,'Returning with an empty structure.'
        sc = create_struct('sin',dblarr(nbox,24),'cos',dblarr(nbox,24))
        data_out = replicate(sc, 1)
        data_out.cos = -1
        data_out.sin = -1
        return,data_out
    endif
    message,/info,'Assuming you know what you''re doing and continuing'
endif ;else begin
nframes = nbytes / nbytes_per_frame
;endelse

nbox = long(nbox)
;if keyword_set(new) then ntod = nframes else ntod = nframes / nbox
ntod = nframes
if (keyword_set(old)) then ntod = nframes / nbox
sc = create_struct('sin',dblarr(nbox,24),'cos',dblarr(nbox,24))
data_out = replicate(sc, ntod)
seq_num = lonarr(nbox,ntod)
seconds = dblarr(ntod)
utc = dblarr(ntod)

sec = dblarr(1)
seq = lonarr(1)
s = dblarr(24)
c = dblarr(24)

time_s,'Reading data and sorting ... ', t0
for i=0L,ntod-1 do begin
    if keyword_set(new) then begin
        readu,unit,sec
        seconds[i] = sec
    endif
; Default behavior for new timestamping
    if (not(keyword_set(old)) and not(keyword_set(new)) $
        and not(keyword_set(loadcurve))) then begin
        readu,unit,sec
        utc[i] = sec
        readu,unit,sec
        seconds[i] = sec
    endif
    for j=0,nbox-1 do begin
        readu,unit,seq
        readu,unit,s
        readu,unit,c
        seq_num[j,i] = seq
        data_out[i].sin[j,*] = s
        data_out[i].cos[j,*] = c
    endfor
endfor
time_e,t0

close,unit
free_lun,unit

type = strlowcase(type)

wh_opt = where(type eq 'optical')

nbolos = n_e(wh_opt)

;bolo_flags = intarr(nbolos)
bolos = dblarr(2,nbolos,ntod)
ac_bolos = bolos
dc_bolos = bolos 

time_s,'Getting optical channels ... ',t0
for i=0,nbolos-1 do begin

    wh = where(type eq 'optical' and seq_id eq i)
    bolos[0,i,*] = data_out.cos[box_num[wh],channel[wh]]
    bolos[1,i,*] = data_out.sin[box_num[wh],channel[wh]]

; Don't subtract off the mean, since we're going to use quadrature
;    ac_bolos[0,i,*] = bolos[0,i,*]; - mean(bolos[0,i,*])
;    ac_bolos[1,i,*] = bolos[1,i,*]; - mean(bolos[1,i,*])
    
;    dc_bolos[0,i,*] = smooth(bolos[0,i,*],min([n_e(bolos[0,i,*]),11]))
;    dc_bolos[1,i,*] = smooth(bolos[1,i,*],min([n_e(bolos[0,i,*]),11]))

endfor

time_e, t0

time_e,t1

return, data_out



end
