function read_plog, filename, n2xfer = n2xfer, $
                    get_file_size = get_file_size

forward_function decode_100mas, decode_10ms

; Define a buffer that's the size of a typical 1 minute file, if not
; otherwise defined
if (not(keyword_set(n2xfer))) then n2xfer = 78000L

; Allocate a read buffer
buffer = lonarr(n2xfer)

; Read in the data
openr,unit,/get_lun,filename,/rawio,/swap_if_little_endian
readu,unit,buffer,transfer_count = nxfer
close,unit
free_lun,unit

if (nxfer ne n2xfer) then begin
    message,/info,$
      'Requested '+strcompress(n2xfer,/rem)+' words but only read '+$
      strcompress(nxfer,/rem)+' words'
    message,/info,$
      filename
endif

if (keyword_set(get_file_size)) then return, nxfer

; Variable type definitions
dbl = double(0)
flt = 0.
lon = long(0)
ulon = ulong(0)
int = (intarr(1))[0]

; This is the frame, as defined in plog-export.h
nbytes = 52L
nwords = nbytes/4L
data_frame = create_struct('epoch', dbl, $
                           'ticks', dbl, $
                           'observing', int, $
                           'nodding', int, $
                           'equatorial_offset', int, $
                           'off_beam', int, $
                           'on_beam', int, $
                           'chopping', int, $
                           'tracking', int, $
                           'acquired', int, $
                           'scanning', int, $
                           'transited', int, $
                           'celestial', int, $
                           'sidereal_time', dbl, $
                           'right_ascension', dbl, $
                           'declination', dbl, $
                           'parallactic_angle', dbl, $
                           'x_offset', dbl, $
                           'y_offset', dbl, $
                           'azimuth', dbl, $
                           'elevation', dbl, $
                           'azimuth_error', dbl, $
                           'elevation_error', dbl)
;                           'flags', intarr(32), $


; Cast the data to double and decode
nsamp = nxfer/nwords
data = replicate(data_frame, nsamp)

; This is going to need some work.  Something more systematic will
; have to be done about this.
flags = intarr(32,nsamp)

indx = lindgen(nsamp)*nwords

data[*].epoch = buffer[indx]
data[*].ticks = buffer[indx+1]/100.d
flags = dectobin32(buffer[indx+2])
data[*].observing = reform(flags[8,*])
data[*].nodding = reform(flags[9,*])
data[*].equatorial_offset = reform(flags[16,*])
data[*].off_beam = reform(flags[21,*])
data[*].on_beam = reform(flags[22,*])
data[*].chopping = reform(flags[23,*])
data[*].tracking = reform(flags[27,*])
data[*].acquired = reform(flags[28,*])
data[*].scanning = reform(flags[29,*])
data[*].transited = reform(flags[30,*])
data[*].celestial = reform(flags[31,*])
data[*].sidereal_time = decode_10ms(buffer[indx+3]) * 24.d
data[*].right_ascension = decode_10ms(buffer[indx+4]) * 24.d
data[*].declination = decode_100mas(buffer[indx+5]) * 360.d
data[*].parallactic_angle = decode_100mas(buffer[indx+6]) * 360.d
data[*].x_offset = buffer[indx+7]/10.d
data[*].y_offset = buffer[indx+8]/10.d
data[*].azimuth = decode_100mas(buffer[indx+9]) * 360.d
data[*].elevation = decode_100mas(buffer[indx+10]) * 360.d
data[*].azimuth_error = buffer[indx+11] / 10.d
data[*].elevation_error = buffer[indx+12] / 10.d

return, data

end
