; Subroutine for extract_channels to extract an unindexed chan_type (eg. 
; 'fixed') from idata, which can be either 2D or 3D.  The parameters
; box_num and channel should have already been limited to the desired
; chan_type.

FUNCTION extract_unindexed_chan, idata, box_num, channel  
  nchan = n_e(box_num)
  
  idata_size = SIZE(idata)
  IF idata_size[0] EQ 2 THEN data = dblarr(nchan) ELSE $
     data = dblarr(nchan,n_e(idata[0,0,*]))
  
  for i=0,nchan-1 do $
     IF idata_size[0] EQ 2 THEN data[i] = idata[box_num[i],channel[i]] ELSE $
        data[i,*] = idata[box_num[i],channel[i],*]

  RETURN, data
END
  
