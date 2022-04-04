; The original of this, get_channels, worked on ncdf files rather than data.
; Very irritating, as this is exactly what I was complaining about with
; Bolocam.  This function takes sin and cos and tells you what's what.

; This function returns nbolos (either 160, 20, or 12) x ntod.  If you
; give two arguments (cos and sin), it assumes you want the quadrature
; sum.  If just one, you get only that argument.  
; 
; After 10/16/2006 change, if cos is only two dimensional, then the
; returned array is a 1D vector with either 160, 20, or 12 elements.
;
; EDITS:   2006_08_24 BN Eliminated deglitching & mean subtraction
;          2006_10_16 BN cos can now be 2D (box,chan) or 3D (box,chan,ntod)
;                        added new chan_types 'unused' and 'therm'
;                        updated 'dark' type for new bolo_config_file format
;                            which doesn't number each dark channel
;                        created subroutines to do sorting

function extract_channels, cos, sin, $
                           chan_type, $
                           bolo_config_file = bolo_config_file
                          
nparams = n_params()

case nparams of 
    2: begin
        idata = cos
        chan_type = sin
    end
    3: begin
        idata = sqrt(cos^2 + sin^2)
        chan_type = chan_type
    end
    else: message,'Number of calling parameters must be 2 or 3'
endcase

if not(keyword_set(bolo_config_file)) then $
  bolo_config_file=getenv('HOME')+'/zspec_svn/file_io/bolo_config_apr07.txt'  

readcol,bolo_config_file, $
  comment=';', format='(I, I, A, I, I)', $
  box_num, channel, type, flags, seq_id, /silent

type = strlowcase(type)

case chan_type of
    'optical': begin
       data = extract_indexed_chan(idata,chan_type,$
                                   type,seq_id,box_num,channel)
    end
    'fixed': begin
        wh = where(type eq chan_type and seq_id eq -1)
        data = extract_unindexed_chan(idata,box_num[wh],channel[wh])
    end
    'dark': begin
        wh = where(type eq chan_type and seq_id eq -1)
        data = extract_unindexed_chan(idata,box_num[wh],channel[wh])
    end
    'unused': begin
        wh = where(type eq chan_type and seq_id eq -1)
        data = extract_unindexed_chan(idata,box_num[wh],channel[wh])
    end
    'therm': begin
        wh = where(type eq chan_type and seq_id eq -1)
        data = extract_unindexed_chan(idata,box_num[wh],channel[wh])
    end
    else: begin
        message,/info,'Channel type not recognized'
        return, -1
    end
endcase

return, data

end
