;+
;=============================================================================
; 
;  NAME: 
;		     	  blo_read_selected_channel				 
;
;
;  DESCRIPTION: 
;		     	  Read the selectedChannels.txt file to get the list	 
;    		     	  of selected channel labels				 
; 
;  USAGE: 
;		     	  blo_read_selected_channels, colname1, channel_index, $
;				filename=filename, path=path, channel_name=channel_name,  $
;			        temperature_channel=temperature_channel, bias_channel=bias_channel
; 
;  INPUT:
;     colname1    	  A string array containg all the column names (input)
;
;  OUTPUT:
;     channel_index  	  An integer array containing the selected channel index
;		
;  KEYWORDS:
;     filename       	  A string containing the selected channels file name
;
;     path  	  	  The path where the file containing the selected 
;                 	  (input) is located
;
;     channel_name   	  (output) A string array containing the selected channel names
;		
;     temperature_channel (output) A string containg the temperature channel label
;		
;     bias_channel        (output) A string containg the bias channel label
;		
;		  
;  Author: 	
;		          Lijun Zhang
;
;  Edition History
;
;  Date		Programmer  Remarks
;  2003/08/12   L. Zhang    initial testing version
;  2004/06/03   B. Schulz   changed interface
;  
;============================================================================
;-
PRO blo_read_selected_channel, colname1, channel_index, $
	filename=filename, path=path, channel_name=channel_name,  $
        temperature_channel=temperature_channel, bias_channel=bias_channel
  

   if n_params() LT 1 then colname1 = ''
   
   if not keyword_set(path) then path = getenv('BLO_SELECTED_CHANNEL')

   if not keyword_set(filename) then filename = 'SelectedChannel.txt'

   infile = findfile(path + filename)

   if infile EQ '' then infile = findfile(path + 'SelectedChannel.txt')

   if infile EQ '' then infile = findfile(getenv('BLO_SELECTED_CHANNEL') + 'SelectedChannel.txt')
    
   
   if infile EQ '' then begin 
      message, /info, " SelectedChannel.txt file nonexistent!"
      stop
   endif else begin
     readcol, infile, channel_name, format='(a)', /silent
   endelse
   
   ;Search for Temperature and Bias
   
   nchannel=n_elements(channel_name)
   for i=0, nchannel -1  do begin
       channel_name[i] = strtrim(channel_name[i], 2)
       
   endfor

   for i=0, nchannel -1  do begin
       pos=strpos(channel_name[i], '=')
       if (pos ne -1 ) then  begin
          keyword=strmid(channel_name[i], 0,  pos)
          keyword=strtrim(keyword)
          value=strmid(channel_name[i],pos+1)
          
          if (strcmp(keyword, 'TC', /fold_case)) then begin
              temperature_channel=value
          endif else begin
              if (strcmp(keyword, 'BIAS')) then bias_channel=value
          endelse
          channel_name[i]=value
        endif
   endfor
   channel_index = intarr(nchannel)
  
   for i=0, nchannel-1 do begin
      ix = where( strpos(strupcase(colname1), strupcase(channel_name[i])) eq 0, cnt ) 
      if (cnt gt 1) then $
           message, 'Duplicated channel label found in the .fits file, program exits!'  $
      else $
         if (i eq 0 ) then channel_index = ix  else channel_index = [channel_index, ix]
      
   endfor
    
    
END
