;+
;===========================================================================
;  NAME:
;                  BODAC_LOADC_CONVERT
;
;  DESCRIPTION:
;                  Convert selected list of original Bodac loadcurve files
;                  (binary or fits format) into processed loadcurve products.
;
;  USAGE:
;                  BODAC_LOADC_CONVERT
;
;  INPUT:
;
;                  filename to be selected online by widget
;                  can be either FITS or bin-file.
;
;  OUTPUT:
;                  Time column is removed and data for the same bias level
;                  is averaged.
;                  File content will be coded as FITS binary tables.
;                  Units and column names follow the standard FITS definition.
;                  The first column contains the bias voltage while the following
;                  columns contain the voltages measured directly at the bolometer.
;                  File will also contain errors indicated by titles starting
;                  with 'ERR '.
;
;  KEYWORDS:
;     all                  If set, all the chennels will be converted to load curve fits files
;     temperature_channel  (string) name of temperature channel. Default is 'ULTRACOLD'
;     ubiasoffs            (float) offset voltage to be added to bias voltage [V]
;
;  AUTHOR:
;                  Bernhard Schulz (IPAC)
;
;
;  Uses:
;       astrolib Jan 2003 or later
;       us_daylswitch.pro
;       blo_sepfilepath.pro
;       blo_sepfileext.pro
;       blo_noise_read_binary.pro
;
;  Remarks:
;       uses logical 'BLO_DATADIR' as starting point for file search
;
;  Edition History:
;
;  Date        Programmer  Remarks
;  2003/03/12  B. Schulz   initial test version
;                          conv. from bodac_fitsb_convert.pro
;  2003/03/14  B. Schulz   first working version for FITS and bin-files
;  2003/03/19  B. Schulz   correct handling of arbitrary step averaging
;  2003/03/20  B. Schulz   read all 3 filetypes
;  2003/03/21  B. Schulz   hourglass added
;  2003/08/04  B. Schulz   changes to bias plateaux discrimination and
;                          gain conversion corrected (nogains keyword)
;  2003/08/12  L. Zhang    Removed all the dasgains related codes
;  2003/08/13  L. Zhang    Add an input parameter, filename
;                          the program was changed to reaad the new fits file
;  2003/08/13  L. Zhang    Add a keyword all to control how many channel
;                          to process
;  2003/08/15  L. Zhang    fix the problem with finding discrete bias plateaux
;
;  2003/09/08  L. Zhang    fix the bug at "clean out glitch" block  and fix
;                          the other bug at the "clean steps that have the
;                          same average within errors" block
;  2003/12/16  L. Zhang    remove the filename parameter
;                          add a filelist parameter which contains all
;                          the input *.bin files
;  2004/02/04  B. Schulz   fixed problem with missing path for search for
;                          selected channel file if keyword filename is set
;  NOTE:                   The SelectedChannel.txt file has to be in the
;                          data directory
;  2004/03/11  B. Schulz   another fix for the bias plateaux discrimination
;  2004/04/12  L. Zhang    add temperature_channel keyword
;  2004/06/03  B. Schulz   changed blo_read_selected_channel interface
;  2004/06/09  B. Schulz   ubiasoffs keyword added
;  2004/07/23  B. Schulz   routine bodac_seploadc separated
;===========================================================================
;-
pro bodac_loadc_convert,  filelist,  all=all, temperature_channel=temperature_channel, $
                          ubiasoffs=ubiasoffs

if n_params() NE 1 then $
   filelist = dialog_pickfile( /MULTIPLE_FILES, $
                            /READ, /MUST_EXIST, FILTER = '*.fits', $
                            GET_PATH=path, path=getenv('BLO_DATADIR'))

if NOT keyword_set(ubiasoffs) then ubiasoffs = 0.0


if filelist(0) NE '' then begin

  widget_control, /hourglass

  nfiles = n_elements(filelist)
  for ifile=0, nfiles-1 do begin        ;start converting file list

    ;read file
    blo_noise_read_auto, filelist(ifile),run_info, sample_info, $
       colname1, colname2, PtsPerChan, ScanRateHz, SampleTimeS, $
       paramline=paramline, data=data, dasgains=dasgains

    ;filter the unused channels
    if keyword_set(all) then begin

        bias_channel='BIAS'
        if NOT keyword_set(temperature_channel) then $
            temperature_channel='ULTRACOLD'

    endif else begin

       if keyword_set(filelist) then $
          blo_sepfilepath, filelist(ifile), fname, path

       blo_read_selected_channel, colname1, channel_index, $
          path=path,channel_name=channel_name, $
          temperature_channel=temperature_channel, bias_channel=bias_channel

       ;first column of data is time
       channel_index=[0, channel_index]
       data=data[channel_index, *]
       colname1=colname1[channel_index]
       colname2=colname2[channel_index]

    endelse

    ncol = n_elements(data(*,0))       ;determine number of columns

    ;-----------------------------------------------------
    ;convert only if correct original Bodac format

    if strmid(run_info[0],1,1) EQ '/' OR strmid(run_info[0],2,1) EQ '/' $
;       and strpos(strlowcase(run_info[0]),'loadc') GE 0
    then begin

      blo_sepfilepath, filelist(ifile), fname, path
      blo_sepfileext, fname, name, extension
      extension = 'fits'

      nrow = n_elements(data(0,*))

      bodac_seploadc, colname1, colname2, bias_channel, data, colname11, colname12, data1, ubiasoffs=ubiasoffs


    ;-----------------------------------------------------


      blo_noise_write_bfits, path+blo_getdirsep()+name+'_lc'+'.'+extension, $
                        run_info, sample_info, paramline, $
                        colname11, colname12, data1, /loadcrv, /dasgains, $
                        temperature_channel=temperature_channel,          $
                        bias_channel=bias_channel
      message, /info, filelist(ifile)+': Converted to FITS binary table.'

    endif else begin
      message, /info, filelist(ifile)+': No original BoDAC File header! No output produced.'
    endelse
  endfor    ;filelist

endif else begin
  message, /info, 'No File selected!'
endelse


end
