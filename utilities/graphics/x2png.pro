;$Id: x2png.pro,v 1.5 2002/10/11 16:15:13 jjbezair Exp $
;$Log: x2png.pro,v $
;Revision 1.5  2002/10/11 16:15:13  jjbezair
;fixed runtime errors in new version of make_madcap_input_1day_fast.pro
;changed color flag in x2png to work on seaborg
;
;Revision 1.4  2002/09/26 21:28:09  jaguirre
;Committing some IDL routines to remove the signal correlated with the
;dark channel from the optical channels.  The main routine is
;remove_c6_corr.pro, which calls str and rbrfft.  Apparently I also
;modified fastlomb, the IDL implementation of the Lomb periodogram and
;fsd_model8_healpix.
;
;Revision 1.3  2002/08/13 02:56:34  jjbezair
;added galaxy flag to map, fixed up call_gri...
;
;Revision 1.2  2002/05/28 22:11:25  jaguirre
;Added color keyword to allow color captures; if both color and reverse are
;set, reverse is ignored.
;
;Revision 1.1  2002/05/28 17:29:46  jjbezair
;x2png writes a png file of the current plotting window
;
pro x2png,filename,reverse=reverse,color=color

if keyword_set(color) then begin
  ;  !p.background = !white
    p = tvrd(true=1)
endif else begin
    p = tvrd()
endelse
if(keyword_set(reverse)) then begin
    if (not(keyword_set(color))) then begin
        w = where(p eq 255)
        b = where(p eq 0)
        p[w] = 0
        p[b] = 255
    endif else begin
        n = n_e(p)
        i = lindgen(n/3l)*3l
        w = where(p[i] eq 255 and p[i+1] eq 255 and p[i+2] eq 255)
        b = where(p[i] eq 0 and p[i+1] eq 0 and p[i+2] eq 0)
        p[w*3l] = 0
        p[w*3l+1l] = 0
        p[w*3l+2l] = 0
        p[b*3l] = 255
        p[b*3l+1l] = 255
        p[b*3l+2l] = 255
    endelse
endif
write_png,filename,p


end
