; Convert a 1-d index of a 2-d array to x and y positions in the array
; (in the form [x,y], as a 2xN array)
; Useful for getting image coordinates from the 1-d indices returned by where
function coord_2d, index, nx

return, transpose([[index mod nx], [index / nx]])

end

