function fft_shift, in_arr, reverse = reverse

; $Id: fft_shift.pro,v 1.5 2004/03/31 19:58:06 jaguirre Exp $
; $Log: fft_shift.pro,v $
; Revision 1.5  2004/03/31 19:58:06  jaguirre
; Fixed another idiot problem.
;
; Revision 1.4  2004/03/31 19:55:00  jaguirre
; Fixed stupid error trapping.
;
; Revision 1.3  2004/03/31 19:14:15  jaguirre
; Added functionality for 2D FFT arrays.  Can shift in either direction
; (to DC at the center, or from DC at the center).
;
;+
; NAME:
;    fft_shift
;
; PURPOSE:
;    Shifts a standard fft output array so frequencies are in ascending
;    order (does not wrap)
;
; CALLING SEQUENCE:
;    out_arr = fft_shift(in_arr)
;    
; INPUTS:
;    in_arr = input array -- either a fourier spectrum output by fft, or
;             the frequency array output by fft_mkfreq
;
; OUTPUTS:
;    out_arr = input array shifted to right so it begins with the 
;              component corresponding to the most negative frequency
;
; REVISION HISTORY:
;    2001/02/26 SG
;    2002/01/02 SG Had bug in case of even number of points -- 
;                  was shifting by 1 too few bins.
;    2003/10/31 SG Cancel that -- I was shifting by correct number of
;                  points.  The operation here exactly cancels the 
;                  operation in fft_mkfreq.
;-

if (n_params() lt 1) then begin
   message, 'Not enough arguments'
   return, -1
endif

sz = size(in_arr)
dim = sz[0]

if (dim ne 1 and dim ne 2) then begin
    message, 'Input array must be either 1 or 2 dimensional'
    return,-1
endif

if (dim eq 1) then begin

    npts = n_elements(in_arr)
    if (npts mod 2) eq 0 then begin
        nshift = long(npts/2.)-1
    endif else begin
        nshift = long( (npts-1)/2. )
    endelse

    out_arr = shift(in_arr, nshift)

endif

if (dim eq 2) then begin

; Does the dorky shift on a 2d FFT.  The assumption is that you are
; shifting from an ordering with DC in the corner to DC in the center.
; Setting reverse does the opposite.

    nx = n_e(in_arr[*,0])
    ny = n_e(in_arr[0,*])

    if (nx mod 2) eq 0 then begin
        nshift_x = long(nx/2.)-1
    endif else begin
        nshift_x = long( (nx-1)/2. )
    endelse
    if (ny mod 2) eq 0 then begin
        nshift_y = long(ny/2.)-1
    endif else begin
        nshift_y = long( (ny-1)/2. )
    endelse
    
    if (keyword_set(reverse)) then begin
        nshift_x = -nshift_x
        nshift_y = -nshift_y
    endif

    out_arr = shift(in_arr, [nshift_x, nshift_y])

endif

return, out_arr

end
