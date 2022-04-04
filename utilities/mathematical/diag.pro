; $Id: diag.pro,v 1.3 2002/10/10 19:17:25 jaguirre Exp $
; $Log: diag.pro,v $
; Revision 1.3  2002/10/10 19:17:25  jaguirre
; Added serious error checking to diag.pro.  Now checks that input is a
; scalar or vector of an appropriate data type and returns a matrix of
; that same type.
;

function diag, vector

; Makes a diagonal matrix out of a vector, taking its type from the
; type of the passed vector.

sz = size(vector)
nsz = n_e(sz)
dim = sz[0]
if ((dim ne 0) and (dim ne 1)) then begin
    print,'Input to DIAG must be a vector'
    return,-1
endif

type = sz[nsz-2]
n = sz[nsz-1]

case type of
    0: begin
        print,'Data type of vector is undefined.'
        return,-1
    end
    1: matrix = bytarr(n,n)
    2: matrix = intarr(n,n)
    3: matrix = lonarr(n,n)
    4: matrix = fltarr(n,n)
    5: matrix = dblarr(n,n)
    6: matrix = complexarr(n,n)
    9: matrix = dcomplexarr(n,n)
    else : begin
        print,'Data type of vector is inappropriate for DIAG.'
        return,-1
    end
endcase
    
i = lindgen(n)

matrix[i,i] = vector

return, matrix

end
