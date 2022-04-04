;+
;===========================================================================
;  NAME: 
;		  BODAC_FITSB_CONVERT
;
;  DESCRIPTION:   
;		  Convert proprietary Bodac file format into common binary
; 		  table FITS format for noise data
;
;  USAGE: 
;		  BODAC_FITSB_CONVERT
;
;  INPUT:
;    filename	  to be selected online by widget
;
;  OUTPUT:	
;    		  File content will be coded as binary tables.
;    		  Units and column names follow the standard FITS 
;		  definition.
;		    
;
;  KEYWORDS:
;     retain 	  If set, the old way to generate channel name will be used,
;                 i.e. Chan 1-2, Chan 1-3 ..etc.
;
;  AUTHOR: 
;		  Bernhard Schulz (IPAC)
;
;  Uses:
;    astrolib Jan 2003 or later
;	us_daylswitch.pro
;	blo_sepfilepath.pro
;	blo_sepfileext.pro
;	blo_noise_read_binary.pro
;
;  Remarks:
;	uses logical 'BLO_DATADIR' as starting point for file search
;
;
;
;  Edition History:
;
;  2002/12/04  B. Schulz  initial test version
;  2002/12/05  B. Schulz  brush up, more comments
;  2002/12/10  B. Schulz  colname/unitline fixed
;  2002/12/11  B. Schulz  time conv. PST to UT
;  2002/12/11  B. Schulz  primary FITS array inst. of bin table
;  2003/01/27  B. Schulz  blo_hfi_noise_read renamed to blo_noise_read_binary
;                         and rename to bodac_fitsb_convert
;  2003/01/31  B. Schulz  function for directory separator and parameter passing
;                         through strarr
;  2003/03/20  B. Schulz  added nicolet ASCII file reading capability
;  2003/03/21  B. Schulz  hourglass added
;  2003/08/05  L. Zhang   Translate the new channel name according to Yin's
;                         request.  Add dasgain keyword to the fits header
;  2003/08/08  B. Schulz  fixed temperature conversion bug
;  2003/08/11  B. Schulz  accept filelist instead of dialog
;  2003/09/10  L. Zhang   fixed the temperature bugs
;  2003/12/23  L. Zhang   remove the retain keyword. Instead, determing
;                         changeChannelName by looking for ChannelName.txt and 
;                         applyDasgain by looking for DASgains.txt file.  
;                         The purpose of change is to enable using blo_labtool 
;                         to convert without any input txt files.
;                         
;;===========================================================================
;-
;pro bodac_fitsb_convert,  filelist, retain=retain
pro bodac_fitsb_convert,  filelist

if n_params() NE 1 then $
  filelist = dialog_pickfile( /MULTIPLE_FILES, $
                            /READ, /MUST_EXIST, FILTER = '*.*', $
                            GET_PATH=path, path=getenv('BLO_DATADIR'))

if filelist(0) NE '' then begin
  
  widget_control, /hourglass

  nfiles = n_elements(filelist)
  
  ;check whether the ChannelName.txt file exists. If not, the program 
  ;will not apply name replacements
  blo_sepfilepath, filelist[0], fname, path
  
  changeChannelName=1
  channelNameFile=findfile(path+'ChannelName.txt', count=counter)
  if (counter eq 0 ) then begin
      changeChannelName=0 
      print, '***********************************WARNING*******************************************'
      message,  '"ChannelName.txt" file not found, Channel names will not be replaced', /continue
      print, '*************************************************************************************'
  endif else begin 
      blo_read_channel_name, path=path, replaced_channel=replaced_channel, $		   		
      channel_name=channel_name, unit=unit, convert_flag=convert_flag		   	   
  endelse

  ;Check whether DASGains.txt exist
  applyDasgain=1
  dgains = blo_read_dasgains(path=path)	 
  ix = where(dgains eq 1, cnt)  					 	
  if (cnt eq n_elements(dgains) ) then  applyDasgain=0 ;no gain if applyDasgain=0
										     
  										    

  for ifile=0, nfiles-1 do begin

    blo_sepfilepath, filelist[ifile], fname, path

    blo_noise_read_auto, path+fname, run_info, sample_info, $
         colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
         paramline=paramline, data=data               ;read data
 
      
     ncol = n_elements(data(*,0))       ;determine number of columns
    
     if ( applyDasgain eq 1 ) then begin 
       for i=1, ncol-1 do begin 		     
              data[i, *] = data[i, *]/dgains[i-1]    
        					     
       endfor					     
     endif 
  ;-----------------------------------------------------
    ;convert only if correct original Bodac format

     if strmid(run_info[0],1,1) EQ '/' OR strmid(run_info[0],2,1) EQ '/' then begin

      	 blo_sepfileext, fname, name, extension
      	 extension = 'fits'

      	 nrow = n_elements(data(0,*))
 
         
      	 if strlowcase(colname1[ncol-1]) EQ strlowcase(colname2[ncol-1]) then begin
      	       colname2 = replicate('[Volts]', ncol)
      	       colname2[0]	= '[sec]'
      	       colname2[ncol-2] = '[Kelvin]'
      	       colname2[ncol-3] = '[Kelvin]'
      	       colname2[ncol-4] = '[Kelvin]'
      	       colname1[0]	= 'TIME'
      	       colname1[ncol-1] = 'BIAS'
      	       colname1[ncol-2] = 'ULTRCOLD'
      	       colname1[ncol-3] = 'INTRCOOL'
      	       colname1[ncol-4] = 'T_L4HE'
      	 endif
       	
	 if (changeChannelName eq 1) then begin  	      ; Use the new column names
  
      	     colname1[replaced_channel] = channel_name
      	     colname2[replaced_channel] = unit
      	
	 endif 
        
         if (applyDasgain eq 1 AND changeChannelName eq 1 ) then begin 							     
      	      for j=0, n_elements(replaced_channel) -1 do begin 				    
      	 	     SWITCH strtrim(strlowcase(convert_flag[j]),2) of
      	 		   'intrcool': begin
      	 				    data[replaced_channel[j], *] =  $
      	 				    blo_lakeshore(data[replaced_channel[j], *], /ic)
      	 				    colname2[replaced_channel[j]] = '[Kelvin]'
      	 				    break
      	 				end
      	 		   'ultracold': begin
      	 				    data[replaced_channel[j], *] =  $
      	 				    blo_lakeshore(data[replaced_channel[j], *])
      	 				    colname2[replaced_channel[j]] = '[Kelvin]'
      	 				    break
      	 				end
      	 		   'coldfinger': begin
                                            
      	 				    data[replaced_channel[j], *] =  $
      	 				    blo_lakeshore( data[replaced_channel[j], *], /grt)
      	 				    colname2[replaced_channel[j]] = '[Kelvin]'
      	 				    break
      	 				  end
      	 		    'n':      break
 
      	 	    ELSE:      begin
      	 			      error_message='Invalid convert flag: ' + convert_flag[j]+ $
      	 			      ' the program will stop!!!'
      	 			      message, error_message
      	 			      break
      	 			end
 
      	 	    ENDSWITCH
 
      	     endfor										    
 	     blo_noise_write_bfits, path+blo_getdirsep()+name+'.'+extension, $   
    			      run_info, sample_info, paramline, $	        
    			      colname1, colname2, data, /dasgains	        
    	     message, /info, filelist(ifile)+': Converted to FITS binary table.' 
       								        
    	 endif else begin 						        
     	    blo_noise_write_bfits, path+blo_getdirsep()+name+'.'+extension, $   
    			      run_info, sample_info, paramline, $	        
    			      colname1, colname2, data			        
    	    message, /info, filelist(ifile)+': Converted to FITS binary table.' 
        								        
	 endelse							        
	  
    endif else begin
      
      message, /info, filelist(ifile)+': No original BoDAC File header! No output produced.'
    
    endelse
  
  endfor    ;filelist

endif else begin
  message, /info, 'No File selected!'
endelse
  
end
