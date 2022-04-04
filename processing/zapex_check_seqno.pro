; NAME:
;      ZAPEX_CHECK_SEQNO
; PURPOSE:
;      Check a netCDF file that has been produced by converting
;      an APEX MBFITS file for consecutive sequence numbers. Return
;      a boolean good/bad value as well as bad indices via keyword
; INPUTS:
;      NCFILE = String of filename
;
; OPTIONAL OUTPUT KEYWORDS:
;      BAD_INDICES=indices where a sequence number has been skipped
;      SEQNO=matrix of seqeuence numbers
;      DSEQNO=derivative of SEQNO
;
; AUTHOR: Tom Downes (tpdownes@caltech.edu)
; DATE: December 2010

function zapex_check_seqno, ncfile, bad_indices=bad_indices, $
                            seqno=seqno, dseqno=dseqno

ncid = ncdf_open(ncfile)
vid = ncdf_varid(ncid, 'sequenceNumber')
ncdf_varget, ncid, vid, seqno
ncdf_close, ncid

sz = size(seqno, /dim)

case n_elements(sz) of
    1: begin
        nboards = 1
        nsamples = n_elements(seqno)
        dseqno = shift(seqno,-1) - seqno
        dseqno = dseqno[0:nsamples-2]
    end
    2: begin
        nboards = n_elements(seqno[*,0])
        nsamples = n_elements(seqno[0,*])
        dseqno = shift(seqno,0,-1) - seqno
        dseqno = dseqno[*,0:nsamples-2]
    end
    else: message, 'Screwy sequenceNumber variable'
endcase

good_indices = where(dseqno eq 1 or dseqno eq -9999, ngood, $
                     complement=bad_indices, ncomplement=nbad)

goodfile = nbad eq 0

if goodfile then begin
    message, ncfile + ' has all its UDP packets in order.', $
      /continue
endif else begin
    bad_indices = array_indices(dseqno, bad_indices)
    message, ncfile + ' is missing or has misordered UDP packets.', $
      /continue
endelse

return, goodfile

END
