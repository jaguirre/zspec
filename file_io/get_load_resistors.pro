; This function gets the sum of the pair of load resistors for the requested
; channel type (either 'all', 'optical', 'dark', or 'fixed').  The 'all' 
; channel type returns all the load resistors in a 2D array with 
; dimensions [box,chan] while the other channel types look for that type 
; in the bolo_config_file.  Resistances are returned in units of MOhms

FUNCTION get_load_resistors, chan_type, $
                             bolo_config_file = bolo_config_file
  ; Read load_resistors.txt
  readcol, !ZSPEC_PIPELINE_ROOT + PATH_SEP() + 'file_io' + $
           PATH_SEP() + 'load_resistors.txt', $
           COMMENT = ';', $
           FORMAT = '(I,A,A,I,F,F,F)', $
           box_id, fo_board, fo_conn, chan, rl1, rl2, rload

  ; Reformat rload into 2D array
  rload_reform = FLTARR(10,24)
  FOR i=0, N_E(box_id) - 1 DO rload_reform(box_id[i],chan[i]) = rload[i]

  ; Extract desired channel type
  CASE chan_type OF
     'all': rload_return = rload_reform
     ELSE: rload_return = extract_channels(rload_reform,chan_type,$
                                          BOLO_CONFIG_FILE = bolo_config_file)
  ENDCASE

  RETURN, rload_return
END  
