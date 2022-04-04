;+
;===========================================================================
;  NAME:
;                  BLO_REDRAW
;
;  DESCRIPTION:
;                  Draw data according to control parameters
;                  works with devices 'x', 'win', and 'ps'
;
;  USAGE:
;                  blo_redraw, ctrl, bdata, ps=ps
;
;  INPUT:
;       ctrl       Control data structure
;       bdata      Lab data structure
;
;  OUTPUT:
;                  on screen display and postscript plots
;
;  KEYWORDS:
;       ps         if set foreground color is black instead of white
;                  and yellow will be replaced by blue
;
;  AUTHOR:
;                  Bernhard Schulz (IPAC)
;
;
;  Edition History:
;
;  26/08/2002   initial test version                            B.Schulz
;  28/08/2002   first working display version                   B.Schulz
;  29/08/2002   bugfix for Windows compatibility                B.Schulz
;  13/09/2002   xtitle automatic from ctrl                      B.Schulz
;  11/10/2002   colors added                                    B.Schulz
;  21/10/2002   logarithmic axes                                B.Schulz
;  12/11/2002   ps keyword for postscript added                 B.Schulz
;  16/01/2003   bugfix for y-log scaling display                B.Schulz
;  27/01/2003   title control via colname1/2 only               B.Schulz
;  27/02/2003   power units added                               B.Schulz
;  11/08/2003   xmargin on left side of plot increased.
;               tick label format of y-axis changed             B.Schulz
;
;  10/31/03     Use wset to set up the current window to draw   L. Zhang
;               plots
;  12/19/03     Add keyword printer. If set, the plot will send to the
;               postscript file.
;  2003/07/18   for times > 1e9 offset removal for display      B. Schulz
;===========================================================================
;-

pro blo_redraw, ctrl, bdata, ps=ps, printer=printer


if (*ctrl).cur_chan LT 0 then return

@blo_flag_info

if keyword_set(ps) then begin
  fgnd_color = blo_color_get('black')   ;foreground
  data_color = blo_color_get('navy')    ;data
  mean_color = blo_color_get('blue')    ;average line
  medi_color = blo_color_get('green')   ;median line
  stdv_color = blo_color_get('magenta') ;standard deviation
  desl_color = blo_color_get('red')     ;deselected data
endif else begin
  fgnd_color = blo_color_get('white')   ;foreground
  data_color = blo_color_get('yellow')  ;data
  mean_color = blo_color_get('aqua')    ;average line
  medi_color = blo_color_get('cyan')    ;median line
  stdv_color = blo_color_get('magenta') ;standard deviation
  desl_color = blo_color_get('red')     ;deselected data
endelse

;----------------------------
; autoscaling

ix = where(((*bdata).flag((*ctrl).cur_chan,*) AND $  ;select valid and scale
   (NOT F_ERR_INVALID)) EQ 0,cnt)

if cnt GT 1 then begin
  ymin = min((*bdata).data((*ctrl).cur_chan,ix))
  ymax = max((*bdata).data((*ctrl).cur_chan,ix))
endif else begin
  ymin = min((*bdata).data((*ctrl).cur_chan,*))
  ymax = max((*bdata).data((*ctrl).cur_chan,*))
endelse

if (*ctrl).xlnlg GT 0 then begin                ;fix to y-scale only data with positive x coordinates
                                                ;if x-logscaling is selected
    if cnt GT 1 then begin
      ixx = where((*bdata).dtim(ix) GT 0, cnt1)
      if cnt1 GT 0 then ymax = max((*bdata).data((*ctrl).cur_chan,ix[ixx]))
    endif else begin
      ixx = where((*bdata).dtim GT 0, cnt1)
      if cnt1 GT 0 then ymax = max((*bdata).data((*ctrl).cur_chan,ixx))
    endelse
endif


deltay = ymax - ymin

vymin = min((*bdata).data((*ctrl).cur_chan,*))
vymax = max((*bdata).data((*ctrl).cur_chan,*))
vdeltay = ymax - ymin


if (*ctrl).scale EQ 0 AND ((*ctrl).disp EQ 0 OR cnt LT 2) then begin    ;scale new if reset
  (*ctrl).xmin = min((*bdata).dtim)
  (*ctrl).xmax = max((*bdata).dtim)
  (*ctrl).ymin = ymin - 0.3*vdeltay
  (*ctrl).ymax = ymax + 0.3*vdeltay
endif

if (*ctrl).scale EQ 0 AND (*ctrl).disp EQ 1 AND cnt GE 2 then begin ;scale valid only
  (*ctrl).xmin = min((*bdata).dtim(ix))
  (*ctrl).xmax = max((*bdata).dtim(ix))
  (*ctrl).ymin = ymin - 0.3*deltay
  (*ctrl).ymax = ymax + 0.3*deltay
endif


;--------------------------------------------------
; set limits for positive data in log plots: x-axis

if (*ctrl).xlnlg GT 0 AND (*ctrl).xmin LE 0 then begin  ;any negative values in log plot ?

  if (*ctrl).disp EQ 1 then begin                                       ;scale valid only

    if cnt GE 1 then begin                                              ;any valid data to show?
      ix1 = where((*bdata).dtim(ix) GT 0, cnt1)
      if cnt1 GE 1 then (*ctrl).xmin = min((*bdata).dtim(ix(ix1))) $
      else                  (*ctrl).xmin = 0.1                  ;some default value for min
    endif

  endif else begin                                                              ;scale all

    ix1 = where((*bdata).dtim GT 0,cnt1)                        ; any data above zero ?
    if cnt1 GT 0 then (*ctrl).xmin = min((*bdata).dtim(ix1)) $
    else                          (*ctrl).xmin = 0.1                    ;some default value for min

  endelse

  if (*ctrl).xmax LE 0 then (*ctrl).xmax = 1.0          ;soem default value for max
endif

;--------------------------------------------------
; set limits for positive data in log plots: y-axis

if (*ctrl).ylnlg GT 0 AND (*ctrl).ymin LE 0 then begin  ;any negative values in log plot ?

  if (*ctrl).disp EQ 1 then begin                                       ;scale valid only

    if cnt GE 1 then begin                                              ;any valid data to show?
      ix1 = where((*bdata).data((*ctrl).cur_chan,ix) GT 0, cnt1)
      if cnt1 GE 1 then (*ctrl).ymin = min((*bdata).data((*ctrl).cur_chan,ix(ix1))) $
      else                  (*ctrl).ymin = 0.1                  ;some default value for min
    endif

  endif else begin                                                              ;scale all

    ix1 = where((*bdata).data((*ctrl).cur_chan,*) GT 0,cnt1)                    ; any data above zero ?
    if cnt1 GT 0 then (*ctrl).ymin = min((*bdata).data((*ctrl).cur_chan,ix1)) $
    else                          (*ctrl).ymin = 0.1                    ;some default value for min
  endelse

  if (*ctrl).ymax LE 0 then (*ctrl).ymax = 1.0          ;soem default value for max
endif


;--------------------------------------------------
;plot all valid ones

if cnt GT 0 then begin

  time  = (*bdata).dtim(ix)
  volts = (*bdata).data((*ctrl).cur_chan,(ix))
  err   = (*bdata).unct((*ctrl).cur_chan,(ix))
  if cnt EQ 1 THEN BEGIN
    time  = [time,time]
    volts = [volts,volts]
    err   = [err,err]
  endif


 if !version.os_family EQ 'ps' then wset, (*ctrl).wdraw

;To have more than one windows simultaneously, set the current window as the
; plot desitination
  ;wset, (*ctrl).wdraw

  if NOT keyword_set(printer) then wset, (*ctrl).wdraw
  case (*ctrl).symb of
    0: begin
        plotsym = 3
        plotlinestyle = 0
       end
    1: begin
        plotsym = 6
        plotlinestyle = 0
       end
    2: begin
        plotsym = 3
        plotlinestyle = 0
       end

  endcase

; get axis titles -----------------
  if strlowcase(strcompress((*bdata).colname1[0], /rem)) EQ $
     strlowcase(strcompress((*bdata).colname2[0], /rem)) then begin
    xtitle = 'Time [s]'
    if strpos(strlowcase((*bdata).colname1[0]), 'freq') GE 0 then  xtitle = 'Frequ [Hz]'
    if strpos(strlowcase((*bdata).colname1[0]), 'sign') GE 0 then  xtitle = 'Signal [V]'
  endif else begin
    xtitle =   (*bdata).colname1[0]+' '+(*bdata).colname2[0]
  endelse
  if (*ctrl).xoffset GT 0 then xtitle = xtitle + ' ('+(*ctrl).xoffstr+')'

  if strlowcase(strcompress((*bdata).colname1[(*ctrl).cur_chan], /rem)) EQ $
     strlowcase(strcompress((*bdata).colname2[(*ctrl).cur_chan], /rem)) then begin
    ytitle = 'Signal [V]'
    if strpos(strlowcase((*bdata).colname1[(*ctrl).cur_chan]), 'pow') GE 0 then  ytitle = 'Power [V/sqrt(Hz)]'
    if strpos(strlowcase((*bdata).colname1[(*ctrl).cur_chan]), 'count') GE 0 then  ytitle = 'Counts'
  endif else begin
    ytitle =   (*bdata).colname1[(*ctrl).cur_chan]+' '+(*bdata).colname2[(*ctrl).cur_chan]
  endelse

  plot, xrange=[(*ctrl).xmin,(*ctrl).xmax]-(*ctrl).xoffset, $
        yrange=[(*ctrl).ymin,(*ctrl).ymax], $
        xstyle=3, ystyle=3, $
        xlog=(*ctrl).xlnlg, ylog=(*ctrl).ylnlg, $
        time, volts, $
        psym=plotsym, $
        title='Channel # '+string((*ctrl).cur_chan, format='(I3)'), $
        xtitle=xtitle, ytitle=ytitle, symsize=0.5, $
        color = fgnd_color, /nodata, $
        xmargin=[16,3], ytickformat='(g0.5)'

  oplot, $
        time-(*ctrl).xoffset, volts, $
        psym=plotsym, symsize=0.5, $
     color = data_color

  if (*ctrl).plerr EQ 1 and cnt GT 0 then begin
    !p.color = data_color
    errplot, time-(*ctrl).xoffset, volts-err, volts+err
  endif

  if (*ctrl).symb EQ 2 then $
    oplot, time-(*ctrl).xoffset, volts, $
       linestyle=plotlinestyle, color = data_color

  mn1 = mean(volts) & sg1 = sigma(volts) & md1 = median(volts)
  fromto = [(*ctrl).xmin, (*ctrl).xmax]
  oplot, fromto-(*ctrl).xoffset, [mn1,mn1], linestyle=2, color = mean_color
  oplot, fromto-(*ctrl).xoffset, [mn1-sg1,mn1-sg1], linestyle=1, color = stdv_color
  oplot, fromto-(*ctrl).xoffset, [mn1+sg1,mn1+sg1], linestyle=1, color = stdv_color
  oplot, fromto-(*ctrl).xoffset, [md1,md1], linestyle=3, color = medi_color


endif

;---------------------------------
; plot all invalid ones

if (*ctrl).disp EQ 0 then begin

 ix = where(((*bdata).flag((*ctrl).cur_chan,*) AND $
        (F_AUTODISC OR F_MANDISC)) GT 0,cnt)

 if cnt GT 0 then begin
  time  = (*bdata).dtim(ix)
  volts = (*bdata).data((*ctrl).cur_chan,(ix))
  err   = (*bdata).unct((*ctrl).cur_chan,(ix))

  if cnt EQ 1 THEN BEGIN
    time  = [time,time]
    volts = [volts,volts]
    err   = [err,err]
  ENDIF

  oplot, time-(*ctrl).xoffset, volts, psym=7, color=desl_color          ;color=118
 endif
endif

;---------------------------------
; plot initially invalid ones

if (*ctrl).disp EQ 0 then begin

 ix = where(((*bdata).flag((*ctrl).cur_chan,*) AND $
        (F_SIG_INVALID)) GT 0,cnt)
 if cnt GT 0 then begin
  time  = (*bdata).dtim(ix)
  volts = (*bdata).data((*ctrl).cur_chan,(ix))
  err   = (*bdata).unct((*ctrl).cur_chan,(ix))

  if cnt EQ 1 THEN BEGIN
    time  = [time,time]
    volts = [volts,volts]
    err   = [err,err]
  ENDIF

 oplot, time-(*ctrl).xoffset, volts, psym=5, symsize=0.8, color=blo_color_get('BLUE')           ;119
 endif

endif

;if (*ctrl).plerr EQ 1 and cnt GT 0 then begin
;  oploterr, time, volts, err, 3, color = 118
;endif
;stop

end


