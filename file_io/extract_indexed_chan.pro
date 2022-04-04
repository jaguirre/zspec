; Subroutine for extract_channels to extract an indexed chan_type (eg. 
; 'optical') from idata, which can be either 2D or 3D.  Must
; pass complete type, seq_id, box_num & channel varibles read from
; bolo_config file to address idata properly.

FUNCTION extract_indexed_chan, idata, chan_type, $
                               type, seq_id, box_num, channel

  wh_type = where(type eq chan_type)
  
  nchan = n_e(wh_type)
  idata_size = SIZE(idata)
  IF idata_size[0] EQ 2 THEN data = dblarr(nchan) ELSE $
     data = dblarr(nchan,n_e(idata[0,0,*]))
  
  for i=0,nchan-1 do begin
     wh = where(type eq chan_type and seq_id eq i)
     IF idata_size[0] EQ 2 THEN data[i] = idata[box_num[wh],channel[wh]] ELSE $
        data[i,*] = idata[box_num[wh],channel[wh],*]
  endfor
  
  RETURN, data
END
