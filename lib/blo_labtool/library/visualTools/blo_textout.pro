;+
;===========================================================================
;
;  NAME:
;                 BLO_TEXTOUT
;
;  DESCRIPTION:
;                 Create text widget and display array of strings
;
;  USAGE:
;                 blo_textout, text
;
;  INPUT:
;       text      (array strings) text to display
;
;  OUTPUT:
;                 on screen display of text in window
;
;  KEYWORDS:
;       group    (integer) group leader of widget
;       title    (string) widget title
;
;  AUTHOR:
;                 Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  02/10/2002   initial test version                    B.Schulz
;
;
;===========================================================================
;-

pro blo_textout_event, event

widget_control, event.id, get_uvalue=uval

case uval of

  'QUIT': widget_control, event.top, /destroy

endcase

end

;-------------------------------------------------
; Main routine

pro blo_textout, text, title=title, group=group


IF not keyword_set(title) THEN title='Text Display'


if keyword_set(group) then modal = 1 else modal = 0

wbase = widget_base( title=title, /column, modal=modal, group=group )


wbase1 = widget_base( wbase, /row )
wfile  = widget_button( wbase1, value="File", /menu )
wquit  = widget_button( wfile, value="Quit", uvalue="QUIT" )

length = n_elements(text) < 32  ; maximum of 32 lines
wbase2 = widget_text( wbase, xsize=80, ysize=length, $
       /scroll, value=text)

widget_control, wbase, /realize, set_uvalue=text
xmanager, no_block=1, "blo_textout", wbase, group=group

end
