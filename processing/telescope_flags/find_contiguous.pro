function find_contiguous, indices_in

; Given an input array of (increasing) indices, such as those returned
; by a where statement, find sections which increase uniformly with no
; gaps, and return a structure containing as many elements as there
; are separate chunks of contiguous indices.

; To implement this quickly, use fin_diff to find stretches which are
; increasing by 1

indices = long(indices_in)

dindices = fin_diff(indices)

brk = where(dindices ne 1)
; Don't allow the first index to be 0
whnonzero = where(brk ne 0)
if (whnonzero[0] ne -1) then $
  brk=brk[whnonzero] $
else $
  message,'Cannot find first index.'

nbrk = n_e(brk)
nchunks = n_e(brk)+1

; Deal with the first chunk
if (brk[0] ne -1) then begin
    nbrk = n_e(brk)
    nchunks = n_e(brk)+1
    chunks = $
      create_struct('sec'+make_padded_num_str(0,3),indices[0:brk[0]-1])
endif else begin
    chunks = create_struct('sec'+make_padded_num_str(0,3),indices)
    nchunks = 1
endelse

; Deal with the middle chunks
for i_struct = 1,nchunks-2 do begin

    chunks = $
       create_struct(chunks, $
                     'sec'+make_padded_num_str(i_struct,3),$
                     indices[brk[i_struct-1]:brk[i_struct]-1])

endfor 

; Deal with the last chunk
if (nchunks gt 1) then $
  chunks = $
  create_struct(chunks,$
                'sec'+make_padded_num_str(nchunks-1,3),$
                indices[brk[nbrk-1]:*])

temp = create_struct('i',0L,$
                     'f',0L)

n = n_tags(chunks)
out = replicate(temp,n)

for i=0,n-1 do begin
    out[i].i = min(chunks.(i))
    out[i].f = max(chunks.(i))
endfor

;return,chunks

return,out

end
