; USE WITH CAUTION - DOES NOT WORK WITH ALL POSSIBLE STUCTURES.

; This function is useful, but only works on structures which are made up
; of elements that can be concatenated using the following syntax:
; outstruct.tagN = [struct1.tagN,struct2.tagN].
; Typically that would be 1D vectors or single values, though the single
; values in the input structures would be joined into a two element vector
; in the output stucture, which may not be desireable.

FUNCTION concat_struct, struct1, struct2
  ntags1 = N_TAGS(struct1)
  ntags2 = N_TAGS(struct2)
  IF ntags1 NE ntags2 THEN $
     MESSAGE, 'Unequal numbers of tags in the two structures.  ABORT'

  ntags = ntags1
  tagnames = TAG_NAMES(struct1)
  
  outstruct = CREATE_STRUCT(tagnames[0],[struct1.(0),struct2.(0)])
  FOR tag = 1, ntags-1 DO $
     outstruct = CREATE_STRUCT(outstruct,$
                               tagnames[tag],[struct1.(tag),struct2.(tag)])

  RETURN, outstruct
END
