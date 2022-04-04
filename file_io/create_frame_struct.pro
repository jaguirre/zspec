function create_frame_struct, def_file

readcol,def_file,comment=';',format='(A,I,A)',$
  var_type, n_array, var_name, /silent

fieldcount = long(n_e(var_type))

typecodes = intarr(fieldcount)
for i=0,fieldcount-1 do begin
    case var_type[i] of 
        'double' : typecodes[i] = (size(double(0.)))[1]
        'int' : typecodes[i] = (size(long(0.)))[1]
        'char' : typecodes[i] = (size(byte(0.)))[1]
    endcase
endfor

struct = create_struct(

if (nframes eq 1) then begin

    offsets = replicate('>0', fieldcount)
    
    numdims = lonarr(fieldcount)
    numdims[where(n_array gt 1)] = 1
    
    dimensions = strarr(fieldcount,8)
    dimensions[where(numdims eq 1),0] = n_array[where(numdims eq 1)]
    
    reverseflags = bytarr(fieldcount,8)
    
    absoluteflags = bytarr(fieldcount)
    
    returnflags = intarr(fieldcount) + 1
    
    verifyflags = intarr(fieldcount)
    
    dimallowformulas = intarr(fieldcount) + 1
    
    offsetallowformulas = intarr(fieldcount) + 1
    
    verifyvals = replicate('', fieldcount)

endif else begin

    

endelse

; Create the structure that read_binary needs
binary_struct = create_struct('version', 1.0, $
                              'templatename', 'rpc', $
                              'endian', endian, $
                              'fieldcount', fieldcount, $
                              'typecodes', typecodes, $
                              'names', var_name, $
                              'offsets', offsets, $
                              'numdims', numdims, $
                              'dimensions', dimensions, $
                              'reverseflags', reverseflags, $
                              'absoluteflags', absoluteflags, $
                              'returnflags', returnflags, $
                              'verifyflags', verifyflags, $
                              'dimallowformulas', dimallowformulas, $
                              'offsetallowformulas', offsetallowformulas, $
                              'verifyvals', verifyvals $
                             )

return,binary_struct

end
