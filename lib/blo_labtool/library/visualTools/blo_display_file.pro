;+
;===========================================================================
;  NAME:
;                   blo_display_file
;
;  DESCRIPTION:
;                   display the loaded file on the screen
;
;  USAGE:
;                   blo_display_file, filename
;
;;  INPUT:
;     filelist      (array of strings) filenames to load
;     dtim          (array double) new x axis of data array
;     data          (array double) 2 dim data array
;     run_info      (string) first file header line
;     sample_info   (string array) new sample info
;     paramline     (string array)  new parameter line
;     colname1      (string array)  new channel names
;     colname2      (string array) new channel units
;

;  OUTPUT:
;                   Diagram display on screen
;
;  KEYWORDS:
;     coadd         (int) if set multiple files are coadded and averaged
;     evt           If set, the widget_control event will be called
;
;  AUTHOR:
;                   L. Zhang
;
;  Edition History
;
;  Date         Programmer      Remarks
;  2003/10/09   L. Zhang        Initial test version
;  2004/07/18   B. Schulz       filename remebering added, redraw removed, time offset
;
;===========================================================================
;-

PRO blo_display_file, filelist, cm, dtim, data, run_info, $
     sample_info, paramline, colname1, colname2, coadd=coadd, evt=evt

     if filelist(0) NE '' then begin

       widget_control, /hourglass


       if keyword_set(coadd) then begin
           blo_load_multidata, filelist,  dtim, data, run_info, $
                    sample_info, paramline, colname1, colname2, $
                    /coadd
       endif else begin
           blo_load_multidata, filelist,  dtim, data, run_info, $
                       sample_info, paramline, colname1, colname2
       endelse

       (*cm[0]).filename = run_info[0]   ;remember filename for later

       if dtim[0] GT 1e9 then begin      ;define time offset for display
         (*cm[0]).xoffset = dtim[0]
         (*cm[0]).xoffstr = tai2utc(dtim[0],/ECS)
       endif

       if n_elements(data) GT 1 then $
          blo_replace_buffer, cm, dtim, data, run_info, $
                          sample_info, paramline, colname1, colname2

       if keyword_set(evt) then begin
          widget_control, evt.top, /clear_events
       endif

     endif


END
