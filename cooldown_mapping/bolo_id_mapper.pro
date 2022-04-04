;; This function takes an array data (with dimensions box x channel x (N), 
;; where N is optional) and returns a rearranged array of equivalent size.  
;; The elements of the returned array are remapped based on the bolo_id from 
;; cooldown_in to cooldown_out.  Assuming the input data was taken during 
;; cooldown_in, the returned data will have elements moved to the box and 
;; channel for each bolometer from cooldown_out.  This function uses 
;; cooldownXXX_config.txt files and can only map cooldowns for which those 
;; files exist (currently cooldowns 17-18, 21-25, 28-30).  Unused_bolo_ids
;; is optional and, if present, upon returning it will contain an M x 3 
;; element array, where M is the number of bolo_ids present in cooldown_in
;; but not in cooldown_out.  For each missing bolometer, it reports
;; the bolo_id, box & channel numbers.  If a (box,chan) pair is not
;; referenced in cooldown_in then that element (or N elements) is not
;; moved by this function.  However, for bolo_ids referenced in cooldown_out
;; but not in cooldown_in, the corresponding elements are reset to 0.
;;
;; NOTES: in the cooldownXXX_config.txt files, boloID   NX -> 100X
;;                                                    TXXX -> 2XXX
;;                                                      DX -> 3XXX

FUNCTION bolo_id_mapper, cooldown_in, cooldown_out, data, $
                         unused_bolo_ids

; read in cooldown config files
  CD_config_root = !ZSPEC_PIPELINE_ROOT + PATH_SEP() + $
                   'cooldown_mapping' 
  CD_in_name = 'cooldown' + STRING(cooldown_in, F='(I03)') + '_config.txt'
  CD_out_name = 'cooldown' + STRING(cooldown_out, F='(I03)') + '_config.txt'

  readcol, CD_config_root + PATH_SEP() + CD_in_name, $
            boloid_in, box_in, chan_in, COMMENT = '#', FORMAT = 'I,I,I'
  readcol, CD_config_root + PATH_SEP() + CD_out_name, $
            boloid_out, box_out, chan_out, COMMENT = '#', FORMAT = 'I,I,I'

  outdata = data
  datasize = SIZE(data)

  nunused = 0

  FOR bin = 0, N_E(boloid_in) - 1 DO BEGIN
     bout = WHERE(boloid_out EQ boloid_in[bin], count)
     CASE count OF
        1: BEGIN
           CASE datasize[0] OF
              2: outdata[box_out[bout],chan_out[bout]] = $
                 data[box_in[bin],chan_in[bin]]
              3: outdata[box_out[bout],chan_out[bout],*] = $
                 data[box_in[bin],chan_in[bin],*]
              ELSE: MESSAGE, 'data for rearranging is not ' + $
                             'properly sized.  Stopping'
           ENDCASE
        END
        0: BEGIN
           MESSAGE,/INFO, 'Bolo ID ' + STRING(boloid_in[bin], F='(I0)') + $
                   ' not found in output cooldown config file.'
           IF nunused EQ 0 THEN $
              UNUSED_BOLO_IDS = $
              [boloid_in[bin],box_in[bin],chan_in[bin]] $
           ELSE UNUSED_BOLO_IDS = $
              [[UNUSED_BOLO_IDS],$
               [boloid_in[bin],box_in[bin],chan_in[bin]]]
           nunused += 1
        END
        ELSE: MESSAGE,'Too many instances of bolo_id ' + $
                      STRING(boloid_in[bin], F='(I0)') + ' in ' + $
                      CD_out_name + '.  Stopping.'
     ENDCASE
  ENDFOR

  IF nunused EQ 0 THEN UNUSED_BOLO_IDS = -1

  FOR bout = 0, N_E(boloid_out) - 1 DO BEGIN
     bin = WHERE(boloid_in EQ boloid_out[bout], count)
     IF count EQ 0 THEN BEGIN
        MESSAGE,/INFO, 'Bolo ID ' + STRING(boloid_out[bout], F='(I0)') + $
                ' not found in input cooldown config file' + $
                '.  Resetting those elements in output array'
        CASE datasize[0] OF
           2: outdata[box_out[bout],chan_out[bout]] = 0
           3: outdata[box_out[bout],chan_out[bout],*] = 0
           ELSE: MESSAGE, 'data for rearranging is not ' + $
                          'properly sized.  Stopping'
        ENDCASE
     ENDIF
  ENDFOR
     
  RETURN, outdata
END
