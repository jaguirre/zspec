;; This routine jackknifes a spectra style variable (definined in
;; demod_and_diff3) and produced by save_spectra (vopt_spectra,
;; verr_spectra).  It takes spectra_in and multiplies half of
;; the nods for each demodulation & bolometer by -1, then uses
;; spectra_ave to average the nods together.  The resulting
;; spectra variable is returned.  This routine can pass any of 
;; spectra_ave's keywords to it using the _EXTRA keyword.  The 
;; style variable determines the jackknife method, described below.
;; pos_ind and neg_ind are optional arguments which after execution
;; contain the nod indicies for the points that were unchanged before
;; averaging and the points that were multiplied by -1 before 
;; averaging, respectively.

;; Jackknife methods:
;; style = 0: pos = first half, neg = second half
;;         1: pos = even nods, neg = odd nods
;;         2: pos = first & last quartile, 
;;            neg = second and third quartile
;;         3: pos = first & third quartile, 
;;            neg = second and last quartile
;;         4: pos = half of the nods, randomly selected
;;            neg = other half of nods
;; In general, the total number of nods in the output spectrum is less
;; than or equal to the total nods in the input spectrum and each output
;; spectrum will have an equal number of nods.  Therefore, for styles 0,
;; 1 at most one nod from the input spectum will be dropped and for
;; styles 2 and 3, up to three nods may be dropped so that all quartiles
;; have the same length.

;; HISTORY 01 JUN 07 BN Random mode (#4) now calls subroutine to 
;;                      randomize each channel with different
;;                      random splits; pos_ind & neg_ind are
;;                      set to -1 for this case.

FUNCTION spectra_jackknife, spectra_in, style, $
                            pos_ind, neg_ind, $
                            _EXTRA = EXTRA

; Check if style is set properly, if not, use style = 0
  CASE style OF
     0:chunks = 2
     1:chunks = 2
     2:chunks = 4
     3:chunks = 4
     4:BEGIN
        spectra_out = spectra_jackknife_rand(spectra_in,_EXTRA = EXTRA)
        pos_ind = -1
        neg_ind = -1
        RETURN, spectra_out
     END
     ELSE: BEGIN
        MESSAGE,/INFO,'Jackknife style not defined, using style = 0'
        style = 0
        chunks = 2
     END
  ENDCASE

  nnods_in = N_E(spectra_in.(0).(0)[0,*])
  nnods_use = chunks * FLOOR(nnods_in/chunks)

; Create nod indicies
  nnods_half = FLOOR(nnods_use/2)
  first_half = INDGEN(nnods_half)
  second_half = INDGEN(nnods_half)+nnods_half
  even_half = 2*first_half
  odd_half = 2*first_half + 1

  nnods_quart = FLOOR(nnods_use/4)
  first_quart = INDGEN(nnods_quart)
  second_quart = INDGEN(nnods_quart) + nnods_quart
  third_quart = INDGEN(nnods_quart) + 2*nnods_quart
  last_quart = INDGEN(nnods_quart) + 3*nnods_quart
        
; Create output spectra
  nbolos = N_E(spectra_in.(0).(0)[*,0])
  tags = TAG_NAMES(spectra_in)
  ntags = N_TAGS(spectra_in)
  subtags = TAG_NAMES(spectra_in.(0))
  FOR tag = 0, ntags - 1 DO BEGIN
     temp = CREATE_STRUCT(subtags[0],DBLARR(nbolos,nnods_use), $
                          subtags[1],DBLARR(nbolos,nnods_use), $
                          subtags[2],DBLARR(nbolos), $
                          subtags[3],DBLARR(nbolos), $
                          subtags[4],DBLARR(nbolos,nnods_use))
     IF tag EQ 0 THEN $
        out_spec = CREATE_STRUCT(tags[tag],temp) $
     ELSE out_spec = CREATE_STRUCT(out_spec,tags[tag],temp)
  ENDFOR

; Store input data into output spectra
  CASE style OF
     0: BEGIN
        pos_ind = first_half
        neg_ind = second_half
     END
     1: BEGIN
        pos_ind = even_half
        neg_ind = odd_half
     END
     2: BEGIN
        pos_ind = [first_quart,last_quart]
        neg_ind = [second_quart,third_quart]
     END
     3: BEGIN
        pos_ind = [first_quart,third_quart]
        neg_ind = [second_quart,last_quart]
     END
  ENDCASE

  FOR tag = 0, ntags - 1 DO BEGIN
     ; Sign flip the spec variables
     out_spec.(tag).(0)[*,pos_ind] = spectra_in.(tag).(0)[*,pos_ind]
     out_spec.(tag).(0)[*,neg_ind] = -1.D * spectra_in.(tag).(0)[*,neg_ind]

     ; Don't flip the errors
     out_spec.(tag).(1)[*,pos_ind] = spectra_in.(tag).(1)[*,pos_ind]
     out_spec.(tag).(1)[*,neg_ind] = spectra_in.(tag).(1)[*,neg_ind]
  ENDFOR

  spectra_ave, out_spec, _EXTRA = EXTRA

  RETURN, out_spec

END

