;+
;===========================================================================
;  NAME: 	      
;		      blo_read_channel_name
;
;  DESCRIPTIO:        
;		      Read channel name file
; 
;  USAGE: 	      
;                     blo_read_channel_name, filename, 	     $
;		      path=path, replaced_channel=replaced_channel, $	
;	              channel_name=channel_name,unit=unit,	    $	
;		      convert_flag=convert_flag 		     	
;  INPUT:	
;    filename  	      A string contains the channel name file. If not sepecified, 
;                     the default name ChannelName.txt will be used
;
;  KEYWORDS:
;    path  	      A string variable containing the file path
;    replaced_channel An integer array containing the replaced channel index
;		  	
;    channel_name     A string array containing the new channel names
;		 
;    unit  	      A string arrays containing the unit of each channel
;    convert_flag     A character array contains the coverting flag.
;		 
;  AUTHOR:            
;	   	      L. Zhang
;  
;  Edition History
;
;  Date		Programmer  Remarks
;  2003/07/30:  L. Zhang    initial testing version
;===========================================================================
;-
PRO blo_read_channel_name, filename, path=path, replaced_channel=replaced_channel, $
        channel_name=channel_name,unit=unit, convert_flag=convert_flag
  
   if not keyword_set(path) then path = getenv('BLO_CHAN_NAME')
   if n_params() EQ 0 then filename = 'ChannelName.txt'
   a = findfile(path + filename)

   if a EQ '' then a = findfile(path + 'ChannelName.txt')

   if a EQ '' then a = findfile(getenv('BLO_CHAN_NAME') + 'ChannelName.txt')
    
    
   if a EQ '' then begin 
      message, /info, "ChannelName file nonexistent!"
      stop
   endif else begin
     readcol, a, replaced_channel, channel_name, unit, convert_flag, delimit=',', $
       format='(i, a, a, a)', /silent
   endelse
   
   for i=0, n_elements(channel_name) -1  do begin
       channel_name[i] = strtrim(channel_name[i], 2)
       unit[i] = strtrim(unit[i], 2)
       convert_flag[i] = strtrim(convert_flag[i], 2)
   endfor
   return


end
