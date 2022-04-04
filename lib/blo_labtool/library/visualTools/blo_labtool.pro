;+
;===========================================================================
;  NAME:
;               BLO_LABTOOL
;
;  DESCRIPTION:
;               Widget Utility to inspect laboratory bolometer data
;
;
;
;  USAGE:
;               blo_labtool
;
;  INPUT:
;               laboratory data file
;
;  OUTPUT:
;               on screen display and postscript plots
;
;  AUTHOR:
;               Bernhard Schulz (IPAC)
;
;  Edition History:
;
;  2002/08/26  B.Schulz  initial test version
;  2002/08/28  B.Schulz  first working display version
;  2002/08/29  B.Schulz  bugfix for Windows compatibility
;  2002/09/13  B.Schulz  allow automatic xtitle in plot
;  2002/09/24  B.Schulz  histogram function added
;  2002/10/02  B.Schulz  gains determination added
;  2002/10/03  B.Schulz  enabled multi file load/concat.
;  2002/10/07  B.Schulz  switched sine eval. added
;  2002/10/10  B.Schulz  added hourglass
;  2002/10/11  B.Schulz  file saving and colors added
;  2002/10/14  B.Schulz  file averaging on load enabled
;  2002/10/15  B.Schulz  interface change blo_load_multi.
;  2002/10/15  B.Schulz  blo_save_dialog extracted
;  2002/10/21  B.Schulz  logarithmic axes
;  2002/10/22  B.Schulz  file selection for print file
;  2002/11/12  B.Schulz  color postscript printing enabled
;  2003/01/17  B.Schulz  issued version 1.2
;  2003/01/27  B.Schulz  x/ytitle management changed
;  2003/01/30  B.Schulz  x/ytitle management changed
;  2003/02/03  B.Schulz  bugfix in calculate power spectrum
;  2003/02/03  B.Schulz  help updated, issued version 1.3
;  2003/02/27  B.Schulz  power units added
;  2003/02/28  B.Schulz  statistics button for range 0.5-10 on x-axis
;  2003/03/20  B.Schulz  automatic file recognition and nicolet file read
;  2003/03/21  B.Schulz  batch utility menu added
;  2003/04/24  B.Schulz  version 1.6
;  2003/05/14  B.Schulz  loadcurve batch removed, probl. w. envi.
;  2003/06/09  B.Schulz  deglitching in fourier transf. added
;  2003/06/13  B.Schulz  version 1.7 released
;  2003/10/08  L.Zhang   Add a filename label
;  2003/10/09  L.Zhang   Add a filename as an input paramemter.
;                        If filename is called with blo_labtool, the file will
;                        be loaded automatically
;  2003/10/14  L. Zhang  version 1.8 released
;  2003/10/27  L. Zhang  Add a new menu bar window which as one submenu
;  2003/10/31  L. Zhang  To make the blo_labtool dispay multi windows simoutaneously.
;                        Add another window menu and then one procedure to display
;                        the window
;  2004/02/26  B. Schulz Added buttons Select, UnselectAll, Current Col, and All Cols.
;  2004/02/27  B. Schulz Made 'Statistics All Channels' honor flag selections
;  2004/02/28  B. Schulz Conversions for time, signals, offsets etc. for SPIRE channels
;  2004/03/02  B. Schulz Bug in signal conversion fixed
;  2004/03/10  B. Schulz Help links fixed
;  2004/04/06  B. Schulz Offset addition implemented and bugfix in offset conversion
;  2004/07/18  B. Schulz bias addition and bugfixes
;  2004/07/21  B. Schulz load curve derivation added
;===========================================================================
;-

pro blo_labtool_event, event


@blo_flag_info


widget_control, get_uvalue = cm, event.top

ctrl  = cm[0]           ;structure for control parameters
bdata = *(cm[1])        ;structure for data
                        ; example structure is as follows:
   ;RUN_INFO        STRING    Array[4]
   ;SAMPLE_INFO     STRING    Array[7]
   ;COLNAME1        STRING    Array[49]
   ;COLNAME2        STRING    Array[49]
   ;PARAMLINE       STRING    Array[7]
   ;PTSPERCHAN      LONG             31736
   ;SCANRATEHZ      LONG                13
   ;SAMPLETIMES     LONG                 0
   ;DTIM            DOUBLE    Array[31736]
   ;DATA            DOUBLE    Array[49, 31736]
   ;UNCT            DOUBLE    Array[49, 31736]
   ;FLAG            INT       Array[49, 31736]

widg  = cm[2]           ;structure for widget IDs


widget_control, get_uvalue = uval, event.id

widget_control, get_value = val, event.id

cch = (*ctrl).cur_chan  ;put current channel into small variable name

if n_elements(uval) GT 0 then begin

 CASE uval OF
  'QUIT': widget_control, event.top, /destroy

  'LOADC': begin
                 ;load data (concatenate multiple)
     filelist = dialog_pickfile( /MULTIPLE_FILES, $
                                /READ, /MUST_EXIST, FILTER = '*.*', $
                                        GET_PATH=path, path=getenv('BLO_DATADIR'))
     blo_display_file, filelist, cm, dtim, data, run_info, $
               sample_info, paramline, colname1, colname2, evt=event

   end
  'LOADA': begin
     ;load data (average multiple)
     filelist = dialog_pickfile( /MULTIPLE_FILES, $
                          /READ, /MUST_EXIST, FILTER = '*.*', $
                                  GET_PATH=path, path=getenv('BLO_DATADIR'))

     blo_display_file, filelist, cm, dtim, data, run_info, $
           sample_info, paramline, colname1, colname2, /coadd, evt=event

   end
  'SAVE': begin
                 ;save data
           if cch GE 0 then begin
                   strng=''
                   blo_save_dialog, (*bdata).data, (*bdata).run_info, $
                                        (*bdata).sample_info, (*bdata).paramline, $
                              (*bdata).colname1, (*bdata).colname2
                   widget_control, event.top, /clear_events

           endif else strng = 'No file loaded yet!'
           if strng NE '' then x = dialog_message(strng, /information)
          end
  'SAVEF': begin

                 ;save data in FITS format
           if cch GE 0 then begin
                   strng=''
                   blo_save_dialog, (*bdata).data, (*bdata).run_info, $
                                        (*bdata).sample_info, (*bdata).paramline, $
                              (*bdata).colname1, (*bdata).colname2, /fits
                   widget_control, event.top, /clear_events

           endif else strng = 'No file loaded yet!'
           if strng NE '' then x = dialog_message(strng, /information)
          end
  'PRINT': begin
         blo_savename_dialog, fpath=getenv('BLO_DATADIR'), $
                extension='ps', prfile
                 if prfile NE '' then begin
                   set_plot, 'ps'
                   device, /color
                   device, filename=prfile
                   blo_redraw, ctrl, bdata, /ps, /printer
                   device, /close
                   if strlowcase(!version.os_family) EQ 'windows' then set_plot, 'win' $
                   else set_plot, 'x'
                   x = dialog_message('Plot in file: '+prfile, /information)
                 endif
            end

;Batch Utilities
  'FITSB':  begin

              bodac_fitsb_convert
              widget_control, event.top, /clear_events
            end
  'MULTIP': begin
             blo_multipowersp
             widget_control, event.top, /clear_events
            end

;Testing 10/27/03

;New Empty Window
 'NEW': begin
          blo_display_window
        end

;New duplicate window
 'CPYWIN': begin
      cmnew   = ptrarr(3)
      cmnew[0]= ptr_new(*cm[0])
      cmnew[1]= ptr_new(ptr_new())       ;make pointer to pointer
      if PTR_VALID(*cm[1]) then $
        *cmnew[1]=ptr_new(**cm[1])
      cmnew[2]=ptr_new(*cm[2])

      blo_labtool_widget, cmnew          ;construct labtool panel
      widget_control, /realize, (*cmnew[2]).base
      widget_control, (*cmnew[2]).draw, get_value = bdata
      (*cmnew[0]).wdraw = bdata
      xmanager, 'blo_labtool', (*cmnew[2]).base,  /NO_BLOCK
      blo_redraw, cmnew[0], *(cmnew[1])
      end

;Help
  'ABOUT': begin
           strng =   [ $
          (*cm[0]).progtitle, $
                'Data visualization tool for SPIRE', $
          'and HFI laboratory bolometer data.', $
          '', $
          'Author: Bernhard Schulz', $
          '(CALTECH/IPAC) 2002']
                x = dialog_message(strng, $
                        title = 'About this program', /information)
            end
  'HELP': begin
           CASE strlowcase(!VERSION.OS_FAMILY) OF
           'unix': $
             spawn, "netscape -remote 'openURL('$BLO_HELP_HTML'blo_labtool_main.html)' &"
           'windows': $
             spawn, "explorer "+getenv('BLO_HELP_HTML')+"blo_labtool_main.html"
           ELSE: x = dialog_message('Help feature not available for this OS!')
           ENDCASE
            end
  'SOFTW': begin
           CASE strlowcase(!VERSION.OS_FAMILY) OF
           'unix': $
             spawn, "netscape -remote 'openURL('$BLO_HELP_HTML'Bolo_Software_help.html)' &"
           'windows': $
             spawn, "explorer "+getenv('BLO_HELP_HTML')+"Bolo_Software_help.html"
           ELSE: x = dialog_message('Help feature not available for this OS!')
           ENDCASE
            end
  'DPUCLK': begin       ;DPUCLOCK conversion to seconds
              if cch GE 0 then begin
                if strpos((*bdata).colname2[0],'[s]') GE 0 then begin
                  answer = dialog_message('Units seem already to be [s]. Continue?',/default_no, /question)
                  if answer EQ 'No' then return
                endif
                ;frequ = 312.5 kHz ;verify in DPU design descr!!!!!
                (*bdata).data[0,*] = (*bdata).data[0,*]  / 312.5e3
                (*bdata).dtim = (*bdata).dtim  / 312.5e3
                (*bdata).colname1[0]= 'time'
                (*bdata).colname2[0]= '[s]'
                blo_redraw, ctrl, bdata
                print, 'done time conversion'
              endif
            end
  'BINSIG': begin       ;convert from raw signal to V all channels
              if cch GE 0 then begin
                nchan = n_elements((*bdata).data(*,0)) ;determine number of channels
              ;  mV=5000*raw/((2^16-1)*12*454)
                if strpos((*bdata).colname2[cch],'[V]') GE 0 then begin
                  answer = dialog_message('Units seem already to be [V]. Continue on all channels?',/default_no, /question)
                  if answer EQ 'No' then return
                endif
                for i=1,nchan-1 do begin
                 if (strlen(strtrim((*bdata).colname1[i],2)) EQ 6) AND $      ;convert only signals
                    strpos((*bdata).colname1[i],'BOL') GE 0 OR $
                    (strlen(strtrim((*bdata).colname1[i],2)) EQ 14) AND $      ;convert only signals
                    strpos((*bdata).colname1[i],'PHOT') GE 0 then begin
                   (*bdata).data[i,*] = 5.d * (*bdata).data[i,*]/((2.d^16.-1.d)*12.d*454.d)
                   (*bdata).colname2[i]= '[V]'
                 endif
                endfor
                blo_redraw, ctrl, bdata
                print, 'done signal conversion'
              endif
            end
  'MV2V': begin ;convert mV to V all channels
              if cch GE 0 then begin
                nchan = n_elements((*bdata).data(*,0))
                if strpos((*bdata).colname2[cch],'[V]') GE 0 then begin
                  answer = dialog_message('Units seem already to be [V]. Continue on all channels?',/default_no, /question)
                  if answer EQ 'No' then return
                endif
                for i=1,nchan-1 do begin
                 (*bdata).data[i,*] = (*bdata).data[i,*]/1000.
                 (*bdata).colname2[i]= '[V]'
                endfor
                blo_redraw, ctrl, bdata
                print, 'done signal conversion'
              endif
            end
  'OFFSETS': begin
              if cch GE 0 then begin
                nchan = n_elements((*bdata).data(*,0)) ;determine number of channels
             ;  offv(i,itg)=5000.0*(52428.8*off-16384.0)/((2^16.-1.)*12*454)
                if strpos((*bdata).colname2[cch],'[V]') GE 0 then begin
                  answer = dialog_message('Units seem already to be [V]. Continue on all channels?',/default_no, /question)
                  if answer EQ 'No' then return
                endif
                for i=1,nchan-1 do begin
                 if (strlen(strtrim((*bdata).colname1[i],2)) EQ 6) AND $      ;convert only signals
                    strpos((*bdata).colname1[i],'OFF') GE 0 OR $
                    (strlen(strtrim((*bdata).colname1[i],2)) EQ 10) AND $      ;convert only signals
                    strpos((*bdata).colname1[i],'PHOTOFF') GE 0 then begin
                   (*bdata).data[i,*] = 5. * (52428.8*(*bdata).data[i,*]-16384.0)/((2^16.-1.)*12.*454.)
                   (*bdata).colname2[i]= '[V]'
                 endif
                endfor
                blo_redraw, ctrl, bdata
                print, 'done signal conversion'
              endif
             end
  'ADDOFF': begin
              ; raw offset file addition to already converted signals
              if cch GE 0 then begin
                ;load offset data
                filelist = dialog_pickfile( $
                                /READ, /MUST_EXIST, FILTER = '*OFF.fits', $
                                        GET_PATH=path, path=getenv('BLO_DATADIR'))

                if filelist(0) NE '' then begin
                  widget_control, /hourglass
                  blo_load_multidata, filelist,  dtim, data, run_info, $
                       sample_info, paramline, colname1, colname2

                ;---------------------------------------------
                ;build translation table
                  nphot = 288 & nspec=72
                  photoff = strarr(nphot) & psigname = strarr(nphot)
                  specoff = strarr(nspec) & ssigname = strarr(nspec)
                  npsw = 144 & npmw = 96 & nplw = 48 & nssw = 48 & nslw = 24

                  for i=0, nphot-1 do begin
                    if i GE 0         AND i LE npsw-1           then $             ;1   to 144 SWARRAY
                       psigname[i]='PHOTSWARRAY'+string(i+1,form='(i3.3)')
                    if i GE npsw      AND i LE npsw+nplw-1      then $             ;145 to 192 LWARRAY
                       psigname[i]='PHOTLWARRAY'+string(i-npsw+1,form='(i3.3)')
                    if i GE npsw+nplw AND i LE npsw+nplw+npmw-1 then $             ;193 to 288 MWARRAY
                       psigname[i]='PHOTMWARRAY'+string(i-npsw-nplw+1,form='(i3.3)')
                    photoff[i]='PHOTOFF'+string(i+1,form='(i3.3)')
                  endfor

                  for i=0, nspec-1 do begin
                    if i GE 0         AND i LE nssw-1           then $             ;1   to 48 SWARRAY
                       ssigname[i]='SPECSWARRAY'+string(i+1,form='(i3.3)')
                    if i GE nssw      AND i LE nssw+nslw-1      then $             ;49 to  72 LWARRAY
                       ssigname[i]='SPECLWARRAY'+string(i-nssw+1,form='(i3.3)')
                    specoff[i]='SPECOFF'+string(i+1,form='(i3.3)')
                  endfor

                ;---------------------------------------------
                ; add offsets to signals only
                  nchan = n_elements((*bdata).data(*,0)) ;determine number of signal channels

                  for ichan=1,nchan-1 do begin

                    ix = where(psigname EQ (*bdata).colname1[ichan],cnt)        ;is channel signal?
                    if cnt GT 0 then begin
                      iy = where(colname1 EQ photoff[ix[0]],cnt)        ;is there a corresponding offset?

                      if cnt GT 0 then begin
                        offs = 5. * (52428.8 * data[iy[0],*] - 16384.0)/((2^16.-1.)*12.*454.)
                        toffs = data[0,*]

                        ;---------------------------------------------
                        ;fill offset times
                        nsig = n_elements((*bdata).data[ichan,*])
                        offs1 = dblarr(nsig)
                        tsig = (*bdata).data[0,*]
                        noffs = n_elements(offs)

                        offs1[0] = offs[0]
                        io = 1L ;offset array counter

                        for i=1L, nsig-1 do begin
                          if tsig[i] LT toffs[io] then begin
                            offs1[i] = offs1[i-1]
                          endif else begin
                            offs1[i] = offs[io]
                            while tsig[i] GE toffs[io] AND io LT noffs-1 do io = io + 1
                            if io GE noffs-1 then offs1[i] = offs[io]   ;if at end of offset array
                          endelse
                        endfor


                        (*bdata).data[ichan,*] = (*bdata).data[ichan,*] + offs1

                      endif else begin
                        message, /info, 'No corresponding offset channel '+photoff[ix[0]]+' found!'

                      endelse
                    endif

                  endfor ;nchan

                  blo_redraw, ctrl, bdata
                  print, 'done offset addition'

                endif   ;filelist

              endif   ;cch
             end
  'ADDBIAS': begin
              ; extract and add bias voltages from converted HK file
              if cch GE 0 then begin
                ;load HK data
               filelist = dialog_pickfile( $
                               /READ, /MUST_EXIST, FILTER = '*NHK.fits', $
                                       GET_PATH=path, path=getenv('BLO_DATADIR'))

                if filelist(0) NE '' then begin

                  widget_control, /hourglass
                  blo_load_multidata, filelist,  dtim, data, run_info, $
                       sample_info, paramline, colname1, colname2

                  ix = where(strpos((*bdata).colname1, 'PHOT') EQ 0 AND $
                             strpos((*bdata).colname1, 'ARRAY') EQ 6, cnt)
                  if cnt GT 0 then begin

                    biaslabel = 'P'+strmid((*bdata).colname1[ix[0]],4,2)+'BIAS'
                    ix = where(strpos(colname1, biaslabel) GE 0, cnt)

print, biaslabel, dtim[0]-(*bdata).dtim[0]

                    if cnt GT 0 then begin
                      hkbias = reform(data[ix[0],*])    ;extract bias column
                      hktime = reform(dtim)             ;extract time column
                      biasunit = colname2[ix[0]]        ;bias units

                      n_colname1 = [(*bdata).colname1,biaslabel] ;add label
                      n_colname2 = [(*bdata).colname2,biasunit]  ;add unit

                      bolo_time_expnd, (*bdata).dtim, hktime, ixout

                      ix = where(ixout GE 0, cnt)
                      if cnt GT 2 then begin

                        n_data = [(*bdata).data, transpose(hkbias[ixout])]

                        blo_replace_buffer, cm, (*bdata).dtim, n_data, [(*cm[0]).filename,(*bdata).run_info], $
                                        (*bdata).sample_info, (*bdata).paramline, $
                                        n_colname1, n_colname2

                        widget_control, (*cm(2)).slid, $          ;set new slider range
                          set_slider_max=n_elements((**cm[1]).data[*,0])-1, set_value = 1
                      endif else begin
                        x = dialog_message('No overlap in timelines!', /information)
                      endelse
                    endif else begin
                      message, /info, 'Bias voltage found in file'
                    endelse

                  endif

                endif   ;filelist

              endif   ;cch
             end

  'STAT': begin

           if cch GE 0 then begin

           ix = blo_validdat(bdata, cch, cnt)   ;select valid data
             if cnt GT 1 then begin
               dat = (*bdata).data(cch,ix)
               npnt = n_elements(dat)

               strng =   [((*bdata).colname1(cch)), $
                    '#points: '+string(npnt), $
                    'Avg:     '+string(mean(dat)), $
                    'Stdev:   '+string(stdev(dat)), $
                    'Stdevmn: '+string(stdev(dat)/sqrt(npnt)), $
                    'Max:     '+string(max  (dat)), $
                    'Median:  '+string(median(dat)), $
                    'Min:     '+string(min  (dat))]
             endif else strng = 'Not enough valid datapoints!'
           endif  else strng = 'No file loaded yet!'

           x = dialog_message(strng, $
                        title = 'Statistics', /information)

            end
  'NSEAVG': begin

            tchan = 0   ;time channel
            strng = ''
            if cch GE 0 then begin
              widget_control, /hourglass

              nform1 = '(a5,x,a15,x,a4,x,a7,x,a13,  x,a13,  x,a13,  x,a13,  x,a13)'
              nform2 = '(i5,x,a15,x,a4,x,i7,x,g13.5,x,g13.5,x,e13.5,x,g13.5,x,g13.5)'
              nform3 = '(i5,x,a15,x,a4,x,i7,x,a13,  x,a13,  x,a13,  x,a13,  x,a13)'

              txtoffs = 5
              nrows = n_elements((*bdata).data(*,0))  ;number of channels
              textarr = strarr(nrows + txtoffs)
              textarr[0] = (*ctrl).progtitle + ' ' + 'All Channel Statistics'
              textarr[2] =  strjoin((*bdata).run_info, ', ')
              textarr[3] =  'Output generated: '+systime()
              textarr[4] = string('Chan.', 'Name', 'Unit', '# Elem', 'From', 'To', 'Avg', 'Stdev', 'Stdevmn', form=nform1)

              for cch0 = 1, nrows-1 do begin

                ix = blo_validdat(bdata, cch0, cnt)   ;select valid data

                if cnt GT 1 then begin
                  cname  = (*bdata).colname1[cch0]
                  cunit  = (*bdata).colname2[cch0]
                  dat    = reform((*bdata).data(cch0,ix))
                  npnt   = n_elements(dat)
                  fromx  = min((*bdata).data(tchan,ix))
                  tox    = max((*bdata).data(tchan,ix))
                  Avg    = mean(dat)
                  Stdv   = stdev(dat)
                  Stdvmn = stdev(dat)/sqrt(npnt)
                  textarr(cch0+txtoffs) = string(cch0, cname, cunit, npnt,fromx,tox,avg,stdv,stdvmn,form=nform2)
                endif else $
                  textarr(cch0+txtoffs) = string(cch0, cname, cunit, cnt,'-', '-', '-', '-',   '-',form=nform3)
              endfor

              blo_textout, textarr, title='Statistics of selected data '

            endif  else strng = 'No file loaded yet!'

            if strng NE '' then x = dialog_message(strng, $
                        title = 'Statistics', /information)


            end

  'POWER': blo_labtool_fourier, bdata, cch, cm, event

  'POWERDG': blo_labtool_fourier, bdata, cch, cm, event, /deglitch

  'FOURIER':  blo_labtool_fourier, bdata, cch, cm, event, /nopower

  'FOURIERDG':  blo_labtool_fourier, bdata, cch, cm, event, /nopower, /deglitch

  'HISTO': begin

              widget_control, /hourglass
           if cch GE 0 then begin
                   strng=''
             ix = where(((*bdata).flag(cch,*) AND $     ;select valid and scale
                           (NOT F_ERR_INVALID)) EQ 0,cnt)
             volts = reform((*bdata).data(cch,ix))      ;get volts

             if cnt GT 1 then begin
               question = 'Transfer result into main display buffer?'

                blo_disp_histogram,(*bdata).data, cch, categ, histog, $
                                        question=question

                        if question EQ 'Yes' then begin
                          nn = n_elements((**cm[1]).colname1)
                          (**cm[1]).colname1[0] = 'Signal'
                          (**cm[1]).colname2[0] = '[V]'
                          for i=1, nn-1 do  (**cm[1]).colname1[i] = 'Counts'+'_'+strtrim(string(i),2)
                          for i=1, nn-1 do  (**cm[1]).colname2[i] = ' '
                          (*bdata).run_info[0] = 'Histogram: '+(*bdata).run_info[0]
                          blo_replace_buffer, cm, categ, histog, [(*cm[0]).filename,(*bdata).run_info], $
                                        (*bdata).sample_info, (*bdata).paramline, $
                                        (*bdata).colname1, (*bdata).colname2

               endif

             endif else strng = 'Not enough valid datapoints!'

           endif  else strng = 'No file loaded yet!'
              widget_control, event.top, /clear_events

           if strng NE '' then x = dialog_message(strng, /information)

            end
  'GAINS': begin
           if cch GE 0 then begin
                   strng=''
                widget_control, /hourglass
             blo_gains, (*bdata).data
                widget_control, event.top, /clear_events
           endif  else strng = 'No file loaded yet!'
           if strng NE '' then x = dialog_message(strng, /information)
            end
  'GAINSSWSINE': begin
           if cch GE 0 then begin
                   strng=''
                widget_control, /hourglass
             blo_gains, (*bdata).data, /switchsine
                widget_control, event.top, /clear_events
           endif  else strng = 'No file loaded yet!'
           if strng NE '' then x = dialog_message(strng, /information)
            end
  'LDCNV': blo_labtool_loadc, bdata, cch, cm, event

  'BACK': begin

            if cch GT 0 THEN BEGIN
               (*ctrl).cur_chan = (*ctrl).cur_chan - 1
               widget_control, set_value = (*ctrl).cur_chan, (*widg).slid
                  widget_control, (*widg).labl1, $                ;change description
                  set_value= 'Channel: '+(*bdata).colname1((*ctrl).cur_chan) + $
                 ' ' + (*bdata).colname2((*ctrl).cur_chan)  ,$
                 /dynamic_resize
               blo_redraw, ctrl, bdata

            endif

          end
  'NEXT': begin
        if (*ctrl).cur_chan GE 0 then begin
             if (*ctrl).cur_chan LT n_elements((*bdata).data(*,0))-1 $
             THEN BEGIN
                  (*ctrl).cur_chan = (*ctrl).cur_chan + 1
                 widget_control, set_value = (*ctrl).cur_chan, (*widg).slid
                    widget_control, (*widg).labl1, $            ;change description
                set_value= 'Channel: '+(*bdata).colname1((*ctrl).cur_chan) + $
               ' ' + (*bdata).colname2((*ctrl).cur_chan)  ,$
               /dynamic_resize
              blo_redraw, ctrl, bdata
          endif
        endif
          end
  'SLIDER': begin
           if (*ctrl).cur_chan GE 0 THEN BEGIN
             (*ctrl).cur_chan = val
                   widget_control, (*widg).labl1, $             ;change description
                set_value= 'Channel: '+(*bdata).colname1((*ctrl).cur_chan) + $
               ' ' + (*bdata).colname2((*ctrl).cur_chan)  ,$
               /dynamic_resize
             blo_redraw, ctrl, bdata
        endif
            end
  'FREE':   begin
             (*ctrl).scale = 0
             blo_redraw, ctrl, bdata
            end
  'UP':     begin
             (*ctrl).scale = 1
             len = ((*ctrl).ymax - (*ctrl).ymin)
             (*ctrl).ymin = (*ctrl).ymin + len / 3d
             (*ctrl).ymax = (*ctrl).ymax + len / 3d
             blo_redraw, ctrl, bdata
            end
  'DOWN': begin
             (*ctrl).scale = 1
             len = ((*ctrl).ymax - (*ctrl).ymin)
             (*ctrl).ymin = (*ctrl).ymin - len / 3d
             (*ctrl).ymax = (*ctrl).ymax - len / 3d
             blo_redraw, ctrl, bdata
            end
  'RIGHT':     begin
             (*ctrl).scale = 1
             len = ((*ctrl).xmax - (*ctrl).xmin)
             (*ctrl).xmin = (*ctrl).xmin + len / 3d
             (*ctrl).xmax = (*ctrl).xmax + len / 3d
             blo_redraw, ctrl, bdata
            end
  'LEFT': begin
             (*ctrl).scale = 1
             len = ((*ctrl).xmax - (*ctrl).xmin)
             (*ctrl).xmin = (*ctrl).xmin - len / 3d
             (*ctrl).xmax = (*ctrl).xmax - len / 3d
             blo_redraw, ctrl, bdata
            end
  'ZOOM_IN': begin
             (*ctrl).scale = 1
             (*ctrl).zoom = 1           ;activate zoom
             (*ctrl).flagging = 0       ;deactivate flagging

            end
  'ZOOM_OUT': begin
            (*ctrl).zoom = 0            ;deactivate zoom in
             (*ctrl).scale = 1
             len = (*ctrl).xmax - (*ctrl).xmin
             center = (*ctrl).xmin + len*0.5d
             (*ctrl).xmin = center - len * 1.05d
             (*ctrl).xmax = center + len * 1.05d
             len = ((*ctrl).ymax - (*ctrl).ymin)
             center = (*ctrl).ymin + len*0.5d
             (*ctrl).ymin = center - len * 1.05d
             (*ctrl).ymax = center + len * 1.05d
             blo_redraw, ctrl, bdata
            end
  'ALL':   begin
             (*ctrl).disp = 0
             blo_redraw, ctrl, bdata
            end
  'VALID':    begin
             (*ctrl).disp = 1
             blo_redraw, ctrl, bdata
            end
  'SELECT': begin
             (*ctrl).zoom = 0
             CASE (*ctrl).flagging OF
               0: (*ctrl).flagging = 3
               else:
             ENDCASE
          end
  'HIDE': begin
             (*ctrl).zoom = 0
             CASE (*ctrl).flagging OF
               0: (*ctrl).flagging = 1
               else:
             ENDCASE
          end
  'UNHIDE': begin
             CASE (*ctrl).flagging OF
               0: (*ctrl).flagging = 2
               else:
             ENDCASE
            end
  'UNHIDEALL': begin
             nchan = n_elements((*bdata).data(*,0)) ;determine number of channels
             time =  (*bdata).dtim
             if (*ctrl).allcol GT 0 then chlst = indgen(nchan) $
             else chlst = [cch]
             for i=0, n_elements(chlst)-1 do $
               (*bdata).flag(chlst[i],*) = (*bdata).flag(chlst[i],*)  AND (NOT F_AUTODISC AND NOT F_MANDISC)
             blo_redraw, ctrl, bdata
            end
  'CURCOL': begin
             (*ctrl).allcol = 0
          end
  'ALLCOL': begin
             (*ctrl).allcol = 1
             end
  'DOTS': begin
             (*ctrl).symb = 0
             blo_redraw, ctrl, bdata
          end
  'SYMBOLS': begin
               (*ctrl).symb = 1
               blo_redraw, ctrl, bdata
             end
  'LINES': begin
               (*ctrl).symb = 2
               blo_redraw, ctrl, bdata
             end


;>>>>>>>>>>>>>>>>>>>>>>>>>>
  'NOERR': begin
             (*ctrl).plerr = 0
             blo_redraw, ctrl, bdata
          end
  'PLERR': begin
               (*ctrl).plerr = 1
               blo_redraw, ctrl, bdata
             end
  'XAXLIN': begin
             (*ctrl).xlnlg = 0
             blo_redraw, ctrl, bdata
          end
  'XAXLOG': begin
               (*ctrl).xlnlg = 1
               blo_redraw, ctrl, bdata
             end
  'YAXLIN': begin
             (*ctrl).ylnlg = 0
             blo_redraw, ctrl, bdata
          end
  'YAXLOG': begin
               (*ctrl).ylnlg = 1
               blo_redraw, ctrl, bdata
             end
  'DEGL': begin
               widget_control, /hourglass

               vt_verify_degl_par, ctrl, widg

               flag  = (*bdata).flag(cch,*)
               time  = (*bdata).stim
               slope = (*bdata).slop(cch,*)


               ;degl_no2, time, slope, flag, (*ctrl).param , sm_slope=sm_slope
               ;(*bdata).flag(cch,*) = flag
               ;(*ctrl).s_smooth((cch),*) = sm_slope
               ;(*ctrl).s_flag(cch) = 1

print, "Insert deglitcher!!!!"



               blo_redraw, ctrl, bdata

               widget_control, event.top, /clear_events

             end
  'DEGA': begin
               widget_control, /hourglass

               vt_verify_degl_par, ctrl, widg

               n = n_elements((*bdata).slop(*,0))       ;number of pixels
               for p = 0, n-1 do begin
                flag  = (*bdata).flag(p,*)
                time  = (*bdata).stim
                slope = (*bdata).slop(p,*)
                ;degl_no2, time, slope, flag, (*ctrl).param , sm_slope=sm_slope
                (*bdata).flag(p,*) = flag
                (*ctrl).s_smooth(p,*) = sm_slope
                (*ctrl).s_flag(p) = 1

                ;       if p EQ cch then sm_slope1 = sm_slope
               endfor

               blo_redraw, ctrl, bdata
               widget_control, event.top, /clear_events
             end
  'RBASEL': begin
               widget_control, /hourglass

               vt_verify_degl_par, ctrl, widg

               flag  = (*bdata).flag(cch,*)
               time  = (*bdata).stim
               slope = (*bdata).slop(cch,*)

               mksbasel, time, slope, flag, (*ctrl).param , sm_slope, /remove

               (*bdata).slop((cch),*) = slope

               (*ctrl).s_smooth((cch),*) = sm_slope
               (*ctrl).s_flag(cch) = 1

               blo_redraw, ctrl, bdata

               widget_control, event.top, /clear_events

             end
  'DRAW': begin

             if event.type EQ 0 AND $
                (event.press AND 04b) EQ 4  THEN begin  ;shortcut for hide with
                (*ctrl).zoom = 0                        ;right mouse button
                (*ctrl).flagging = 1
             endif


             IF (*ctrl).flagging GT 0 OR (*ctrl).zoom GT 0 THEN BEGIN

               CASE event.type OF
;-------------------------------------------
;Button Press
                0: begin
                     (*ctrl).cx1 = event.x      ;save first coord.
                     (*ctrl).cy1 = event.y
                     (*ctrl).cx2 = event.x      ;initialise previous coord.
                     (*ctrl).cy2 = event.y
                     (*ctrl).rect = 1           ;activate rectangle
                   end

;-------------------------------------------
;Mouse Motion
                2: begin
                     IF (*ctrl).rect GT 0 THEN BEGIN
                       blo_coor2data, [(*ctrl).cx1,(*ctrl).cx2], $
                                     [(*ctrl).cy1,(*ctrl).cy2], x, y
                       blo_plrect, x, y, ctrl, color=blo_color_get('black'), linestyle=1                ;erase last
                       (*ctrl).cx2 = event.x    ;store coord. for next event
                       (*ctrl).cy2 = event.y
                       blo_coor2data, [(*ctrl).cx1,(*ctrl).cx2], $
                                     [(*ctrl).cy1,(*ctrl).cy2], x, y
                       blo_plrect, x, y, ctrl, color=blo_color_get('sky'), linestyle=1  ;draw new
                     ENDIF
                   end

;-------------------------------------------
;Button Release
                1: begin
                     blo_coor2data, [(*ctrl).cx1,(*ctrl).cx2], $
                                   [(*ctrl).cy1,(*ctrl).cy2], x, y
                     blo_plrect, x, y, ctrl, color=blo_color_get('black'), linestyle=1  ;erase last

                     blo_coor2data, [(*ctrl).cx1,event.x], $
                                   [(*ctrl).cy1,event.y], x, y

                     x = x + (*ctrl).xoffset    ;add time offset if necessary

                     IF (*ctrl).flagging GT 0 THEN BEGIN

                       CASE (*ctrl).flagging OF
                         1: begin
                            unhide = 0               ;for hide button
                         end
                         2: begin
                            unhide = 1          ;for unhide button
                         end
                         3: begin
                            unhide = 2          ;for select button
                         end
                       ENDCASE
                       blo_flagrect, x, y, bdata, cch, unhide=unhide, allcol=(*ctrl).allcol
                       (*ctrl).flagging = 0     ;deactivate flagging

                     ENDIF ELSE BEGIN
                       blo_zoomin, x, y, ctrl
                       (*ctrl).zoom = 0         ;deactivate zooming
                     ENDELSE

                     blo_redraw, ctrl, bdata
                     (*ctrl).rect = 0           ;deactivate rectangle
                   end


                else:
               ENDCASE
;-------------------------------------------

             ENDIF


          end

;>>>>>>>>>>>>>
 ELSE:
 ENDCASE

endif

return
end



;-------------------------------------------------------

pro blo_mk_powersp, time, data, chan, ScanRateHz, $
                        frequ, fftout, $
                        nopower=nopower, deglitch=deglitch

volts = data(chan,*)    ;pick channel
nvolts = n_elements(volts)
nchan = n_elements(data(*,0))   ;number of channels

blo_noise_powersp_f, volts, nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch

nfrequ = n_elements(stransf)
frequ = findgen(nfrequ)*ScanRateHz/(nfrequ*2+1)
fftout = dblarr(nchan, nfrequ)      ;calculate all powerspectra if yes

for i=0, nchan-1 do begin
  blo_noise_powersp_f, data(i,*), nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch
 ;blo_noise_powerspec, data(i,*), nvolts, ScanRateHz, stransf, nopower=nopower, deglitch=deglitch
  fftout(i,*) = stransf
endfor

end

;---------------------------------------------------------

pro blo_labtool_fourier, bdata, cch, cm, event, nopower=nopower, deglitch=deglitch

@blo_flag_info

widget_control, /hourglass

if cch GE 0 then begin
  strng=''
  ix = blo_validdat(bdata, cch, cnt)   ;select valid data

  if cnt GT 0 then begin

    blo_mk_powersp, (*bdata).dtim[ix], (*bdata).data[*,ix], cch, $
     (*bdata).ScanRateHz, frequ, fftout, $
        nopower=nopower, deglitch=deglitch

    cmnew   = ptrarr(3)                ;prepare structure for new widget
    cmnew[0]= ptr_new(*cm[0])          ;copy control stuff
    cmnew[1]= ptr_new(ptr_new())       ;make pointer to pointer
    *cmnew[1]=ptr_new(**cm[1])         ;copy data
    cmnew[2]=ptr_new(*cm[2])           ;copy widget stuff
    blo_labtool_widget, cmnew          ;construct labtool panel
    widget_control, /realize, (*cmnew[2]).base
    widget_control, (*cmnew[2]).draw, get_value = wdraw1
    (*cmnew[0]).wdraw = wdraw1
    xmanager, 'blo_labtool', (*cmnew[2]).base,  /NO_BLOCK

    colname1 = (**cm[1]).colname1  &  colname2 = (**cm[1]).colname2     ;replace names/units
    blo_ch2fftunits, colname1, colname2, /nopower
  ;  (**cmnew[1]).colname1 = colname1  & (**cmnew[1]).colname2 = colname2

    if keyword_set(nopower) then $
    (**cmnew[1]).run_info[0] = 'Fourier: '+(**cmnew[1]).run_info[0] else $
    (**cmnew[1]).run_info[0] = 'PowSpec: '+(**cmnew[1]).run_info[0]

    (*cmnew[0]).xoffset = 0    ;reset time offset
    (*cmnew[0]).xoffstr = ''

    blo_replace_buffer, cmnew, frequ, fftout, [[(*cmnew[0]).filename],(**cmnew[1]).run_info], $
                             (**cmnew[1]).sample_info, (**cmnew[1]).paramline, $
                             colname1, colname2

  endif
endif  else strng = 'No file loaded yet!'

widget_control, event.top, /clear_events

if strng NE '' then x = dialog_message(strng, /information)

end


;---------------------------------------------------------

pro blo_labtool_loadc, bdata, cch, cm, event

@blo_flag_info

widget_control, /hourglass

if cch GE 0 then begin
  strng=''

  ix = blo_validdat(bdata, cch, cnt)   ;select valid data
  biaslabel = 'BIAS'
  ix0 = where(strpos(strupcase((*bdata).colname1), biaslabel) GE 0, cnt0)
  biaslabel = (*bdata).colname1[ix0[0]]

  if cnt GT 0 AND cnt0 GT 0 then begin

    bodac_seploadc, (*bdata).colname1, (*bdata).colname2,  biaslabel, (*bdata).data[*,ix], $
                    colname11, colname12, data1

    cmnew   = ptrarr(3)                ;prepare structure for new widget
    cmnew[0]= ptr_new(*cm[0])          ;copy control stuff
    cmnew[1]= ptr_new(ptr_new())       ;make pointer to pointer
    *cmnew[1]=ptr_new(**cm[1])         ;copy data
    cmnew[2]=ptr_new(*cm[2])           ;copy widget stuff

    blo_labtool_widget, cmnew          ;construct labtool panel
    widget_control, /realize, (*cmnew[2]).base
    widget_control, (*cmnew[2]).draw, get_value = wdraw2
    (*cmnew[0]).wdraw = wdraw2
    xmanager, 'blo_labtool', (*cmnew[2]).base,  /NO_BLOCK

    (*cmnew[0]).xoffset = 0    ;reset time offset
    (*cmnew[0]).xoffstr = ''
    paramline = [string(n_elements(data1[0,*])), ((**cmnew[1]).paramline)[1:*] ]

    blo_replace_buffer, cmnew, data1[0,*], data1, [[(*cmnew[0]).filename], (**cmnew[1]).run_info], $
                             (**cmnew[1]).sample_info, paramline, $
                             colname11, colname12

  endif
endif  else strng = 'No file loaded yet!'
widget_control, event.top, /clear_events

if strng NE '' then x = dialog_message(strng, /information)

end


;---------------------------------------------------------
; Construct new labtool panel

pro blo_labtool_widget, cm

;---------------------------------
; construct window


(*cm[2]).base  = WIDGET_BASE(TITLE=(*cm[0]).progtitle,/row, uvalue=cm, mbar=bar);
(*cm[2]).menu1 = WIDGET_BUTTON(bar, value = 'File', /MENU)
(*cm[2]).menu11 = WIDGET_BUTTON((*cm[2]).menu1, value = 'Load (concat)', UVALUE = 'LOADC')
(*cm[2]).menu15 = WIDGET_BUTTON((*cm[2]).menu1, value = 'Load (average)', UVALUE = 'LOADA')
(*cm[2]).menu15 = WIDGET_BUTTON((*cm[2]).menu1, value = 'Save FITS', UVALUE = 'SAVEF')
(*cm[2]).menu14 = WIDGET_BUTTON((*cm[2]).menu1, value = 'Save Binary', UVALUE = 'SAVE')
(*cm[2]).menu12 = WIDGET_BUTTON((*cm[2]).menu1, value = 'Print', UVALUE = 'PRINT')
(*cm[2]).menu13 = WIDGET_BUTTON((*cm[2]).menu1, value = 'Quit', UVALUE = 'QUIT')

(*cm[2]).menu5 = WIDGET_BUTTON(bar, value = 'Conversions', /MENU)
(*cm[2]).menu51 = WIDGET_BUTTON((*cm[2]).menu5, value = 'Signals raw to [V]',     UVALUE = 'BINSIG')
(*cm[2]).menu52 = WIDGET_BUTTON((*cm[2]).menu5, value = 'Time DPUCLOCK to [sec]', UVALUE = 'DPUCLK')
(*cm[2]).menu53 = WIDGET_BUTTON((*cm[2]).menu5, value = 'Signals [mV] to [V]',    UVALUE = 'MV2V')
(*cm[2]).menu54 = WIDGET_BUTTON((*cm[2]).menu5, value = 'Offsets raw to [V]',     UVALUE = 'OFFSETS')
(*cm[2]).menu55 = WIDGET_BUTTON((*cm[2]).menu5, value = 'Add Offset File to Signal', UVALUE = 'ADDOFF')
(*cm[2]).menu56 = WIDGET_BUTTON((*cm[2]).menu5, value = 'Add Bias column from file', UVALUE = 'ADDBIAS')

(*cm[2]).menu2 = WIDGET_BUTTON(bar, value = 'Processing', /MENU)
(*cm[2]).menu21 = WIDGET_BUTTON((*cm[2]).menu2, value = 'Statistics', UVALUE = 'STAT')
(*cm[2]).menu26 = WIDGET_BUTTON((*cm[2]).menu2, value = 'Statistics All Channels', UVALUE = 'NSEAVG')
(*cm[2]).menu22 = WIDGET_BUTTON((*cm[2]).menu2, value = 'FFT', /MENU)
(*cm[2]).menu221 = WIDGET_BUTTON((*cm[2]).menu22, value = 'Power spectrum', UVALUE = 'POWER')
(*cm[2]).menu222 = WIDGET_BUTTON((*cm[2]).menu22, value = 'Fourier spectrum', UVALUE = 'FOURIER')
(*cm[2]).menu223 = WIDGET_BUTTON((*cm[2]).menu22, value = 'Power spectrum + deglitch', UVALUE = 'POWERDG')
(*cm[2]).menu224 = WIDGET_BUTTON((*cm[2]).menu22, value = 'Fourier spectrum + deglitch', UVALUE = 'FOURIERDG')
(*cm[2]).menu24 = WIDGET_BUTTON((*cm[2]).menu2, value = 'Histogram', UVALUE = 'HISTO')
(*cm[2]).menu27 = WIDGET_BUTTON((*cm[2]).menu2, value = 'Loadcurve', UVALUE = 'LDCNV')
(*cm[2]).menu23 = WIDGET_BUTTON((*cm[2]).menu2, value = 'Gains', UVALUE = 'GAINS')
(*cm[2]).menu25 = WIDGET_BUTTON((*cm[2]).menu2, value = 'Gains (Switched Sine)', UVALUE = 'GAINSSWSINE')

(*cm[2]).menu3 = WIDGET_BUTTON(bar, value = 'Batch Utilities', /MENU)
(*cm[2]).menu31 = WIDGET_BUTTON((*cm[2]).menu3, value = 'Convert Files to FITS table', UVALUE = 'FITSB')
(*cm[2]).menu32 = WIDGET_BUTTON((*cm[2]).menu3, value = 'Multi Power Spectrum from Files', UVALUE = 'MULTIP')

(*cm[2]).menu4 = WIDGET_BUTTON(bar, value = 'Windows', /MENU)
(*cm[2]).menu41 = WIDGET_BUTTON((*cm[2]).menu4, value = 'New blo_labtool window', UVALUE='NEW')
(*cm[2]).menu42 = WIDGET_BUTTON((*cm[2]).menu4, value = 'Copy of blo_labtool window', UVALUE='CPYWIN')


(*cm[2]).help1 = WIDGET_BUTTON(bar, value = 'Help', /MENU, /HELP)
(*cm[2]).help11 = WIDGET_BUTTON((*cm[2]).help1, value = 'Help', UVALUE = 'HELP')
(*cm[2]).help13 = WIDGET_BUTTON((*cm[2]).help1, value = 'Software', UVALUE = 'SOFTW')
(*cm[2]).help12 = WIDGET_BUTTON((*cm[2]).help1, value = 'About', UVALUE = 'ABOUT')

(*cm[2]).lcol  = WIDGET_BASE((*cm[2]).base,/column)
(*cm[2]).rcol  = WIDGET_BASE((*cm[2]).base,/column)

(*cm[2]).labl0  = WIDGET_LABEL((*cm[2]).lcol,  value='')

(*cm[2]).labl  = WIDGET_LABEL((*cm[2]).lcol, $
                value='No file loaded yet!')

(*cm[2]).labl1  = WIDGET_LABEL((*cm[2]).lcol, value='')

(*cm[2]).draw  = WIDGET_DRAW((*cm[2]).lcol,xsize=800,ysize=512, $
                uvalue='DRAW', /BUTTON_EVENTS, /MOTION_EVENTS)


;---------------------------------

(*cm[2]).slidb = WIDGET_BASE((*cm[2]).lcol,/row, /align_center)

(*cm[2]).back  = WIDGET_BUTTON((*cm[2]).slidb, value='Back', uvalue='BACK')
(*cm[2]).slid  = WIDGET_SLIDER((*cm[2]).slidb, title='Channel',uvalue='SLIDER', $
                            value=1,min=0,max=1)
(*cm[2]).next  = WIDGET_BUTTON((*cm[2]).slidb, value='Next', uvalue='NEXT')


;---------------------------------


(*cm[2]).navi   = WIDGET_BASE((*cm[2]).rcol,/column, /frame, /align_center)
w1              = WIDGET_LABEL((*cm[2]).navi, VALUE = 'Navigate')

(*cm[2]).up     = WIDGET_BUTTON((*cm[2]).navi, VALUE = 'Up',    UVALUE = 'UP')
(*cm[2]).lrbut  = WIDGET_BASE((*cm[2]).navi,/row, /align_center)
(*cm[2]).left   = WIDGET_BUTTON((*cm[2]).lrbut, VALUE = 'Left',  UVALUE = 'LEFT')
(*cm[2]).right  = WIDGET_BUTTON((*cm[2]).lrbut, VALUE = 'Right', UVALUE = 'RIGHT')

(*cm[2]).down   = WIDGET_BUTTON((*cm[2]).navi, VALUE = 'Down',  UVALUE = 'DOWN')

(*cm[2]).bzoom  = WIDGET_BASE((*cm[2]).navi, /row, /align_center)
(*cm[2]).zin    = WIDGET_BUTTON((*cm[2]).bzoom, VALUE = 'Zoom In',  UVALUE = 'ZOOM_IN')
(*cm[2]).zout   = WIDGET_BUTTON((*cm[2]).bzoom, VALUE = 'Zoom Out',  UVALUE = 'ZOOM_OUT')


(*cm[2]).scal   = WIDGET_BASE((*cm[2]).rcol, /row,/frame,/align_center)
w1              = WIDGET_LABEL((*cm[2]).scal, VALUE = 'Scaling')
(*cm[2]).free   = WIDGET_BUTTON((*cm[2]).scal, VALUE = 'Free',   UVALUE = 'FREE')


(*cm[2]).disp   = WIDGET_BASE((*cm[2]).rcol, /col,/frame)
w1              = WIDGET_LABEL((*cm[2]).disp, VALUE = 'Display')

(*cm[2]).xdisp  = WIDGET_BASE((*cm[2]).disp, /row, /exclusive)
(*cm[2]).all    = WIDGET_BUTTON((*cm[2]).xdisp, VALUE = 'All',  UVALUE = 'ALL')
(*cm[2]).valid  = WIDGET_BUTTON((*cm[2]).xdisp, VALUE = 'Valid Only',  UVALUE = 'VALID')

(*cm[2]).xsymb  = WIDGET_BASE((*cm[2]).disp, /row, /exclusive)
(*cm[2]).dots   = WIDGET_BUTTON((*cm[2]).xsymb, VALUE = 'Dots'   ,  UVALUE = 'DOTS')
(*cm[2]).symb   = WIDGET_BUTTON((*cm[2]).xsymb, VALUE = 'Symbols',  UVALUE = 'SYMBOLS')
(*cm[2]).lines  = WIDGET_BUTTON((*cm[2]).xsymb, VALUE = 'Lines',    UVALUE = 'LINES')

(*cm[2]).xperr  = WIDGET_BASE((*cm[2]).disp, /row, /exclusive)
(*cm[2]).noerr  = WIDGET_BUTTON((*cm[2]).xperr, VALUE = 'No Errorbars'   ,  UVALUE = 'NOERR')
(*cm[2]).plerr  = WIDGET_BUTTON((*cm[2]).xperr, VALUE = 'Errorbars',  UVALUE = 'PLERR')

(*cm[2]).xlnlg  = WIDGET_BASE((*cm[2]).disp, /row, /exclusive)
(*cm[2]).xlin   = WIDGET_BUTTON((*cm[2]).xlnlg, VALUE = 'X-axis lin',  UVALUE = 'XAXLIN')
(*cm[2]).xlog   = WIDGET_BUTTON((*cm[2]).xlnlg, VALUE = 'X-axis log',  UVALUE = 'XAXLOG')
(*cm[2]).ylnlg  = WIDGET_BASE((*cm[2]).disp, /row, /exclusive)
(*cm[2]).ylin   = WIDGET_BUTTON((*cm[2]).ylnlg, VALUE = 'Y-axis lin',  UVALUE = 'YAXLIN')
(*cm[2]).ylog   = WIDGET_BUTTON((*cm[2]).ylnlg, VALUE = 'Y-axis log',  UVALUE = 'YAXLOG')

(*cm[2]).bflag  = WIDGET_BASE((*cm[2]).rcol, /col, /align_center,/frame)

w1              = WIDGET_LABEL((*cm[2]).rcol, VALUE = '  ')
(*cm[2]).quit   = WIDGET_BUTTON((*cm[2]).rcol, VALUE = 'Quit', UVALUE = 'QUIT')

(*cm[2]).dasel  = WIDGET_BASE((*cm[2]).bflag, /row, /align_center)
(*cm[2]).hide   = WIDGET_BUTTON((*cm[2]).dasel, VALUE = 'Hide',    UVALUE = 'HIDE')
(*cm[2]).unhide = WIDGET_BUTTON((*cm[2]).dasel, VALUE = 'Unhide',  UVALUE = 'UNHIDE')
(*cm[2]).dasel2 = WIDGET_BASE((*cm[2]).bflag, /row, /align_center)
(*cm[2]).select = WIDGET_BUTTON((*cm[2]).dasel2, VALUE = 'Select',    UVALUE = 'SELECT')
(*cm[2]).unhideall = WIDGET_BUTTON((*cm[2]).dasel2, VALUE = 'Unhide All',  UVALUE = 'UNHIDEALL')
(*cm[2]).dasel3 = WIDGET_BASE((*cm[2]).bflag, /row, /align_center, /exclusive)
(*cm[2]).curcol = WIDGET_BUTTON((*cm[2]).dasel3, VALUE = 'current Col.',  UVALUE = 'CURCOL')
(*cm[2]).allcol = WIDGET_BUTTON((*cm[2]).dasel3, VALUE = 'all Cols.',  UVALUE = 'ALLCOL')

if PTR_VALID(*(cm[1])) then $
  widget_control, (*cm(2)).slid, $          ;set new slider range
    set_slider_max=n_elements((**cm[1]).data[*,0])-1, set_value = 1


;-----------------------------------------
;Initialise radio buttons

widget_control, set_button=1, (*cm[2]).free
widget_control, set_button=1, (*cm[2]).all
widget_control, set_button=1, (*cm[2]).lines
widget_control, set_button=1, (*cm[2]).noerr
widget_control, set_button=1, (*cm[2]).xlin
widget_control, set_button=1, (*cm[2]).ylin
widget_control, set_button=1, (*cm[2]).curcol

;-----------------------------------------
; Initialise flags

(*cm[0]).zoom = 0
(*cm[0]).rect = 0
(*cm[0]).symb = 2
(*cm[0]).disp  = 0
(*cm[0]).allcol  = 0

return
end




;---------------------------------------------------------
;  This procedure is contructing the main plot windows and
;  all the widgets.  If it is called with a file, the file
;  will be loaded and displayed on the screen
;
;---------------------------------------------------------
PRO blo_display_window, filename

;---------------------------------
;initialize color table

blo_color_init


;---------------------------------
; define control structures

  ctrl = {                            $
        cur_chan:-1,                  $ ;currently drawn measurement (-1 = no meas.)
        xmin:0.d,                     $ ;min. of xrange
        xmax:0.d,                     $ ;max. of xrange
        ymin:0.d,                     $ ;min. of yrange
        ymax:0.d,                     $ ;max. of yrange
        xoffset:0.d,                  $ ;zeropoint of x-axis (time)
        xoffstr:'',                   $ ;xoffset translated to date if >1e9
        scale:0,                      $ ;scaling: 0=free, 1=fixed
        disp:0d,                      $ ;display: 0=all, 1=valid only
        plerr:0,                      $ ;plot errors: 0=no, 1=yes
        symb:0,                       $ ;data display: 0=dots, 1=symbols, 2=lines
        xlnlg:0,                      $ ;x-axis scale: 0=linear, 1=logarithmic
        ylnlg:0,                      $ ;y-axis scale: 0=linear, 1=logarithmic
        flagging:0,                   $ ;flagging state: 0=inactive, 1=hide, 2=unhide, 3=select
        allcol:0,                     $ ;apply flagging to channels, 0=current channel, 1=all channels
        cx1:0,                        $ ;cursor x position at button press
        cy1:0,                        $ ;cursor y position at button press
        cx2:0,                        $ ;previous cursor x position
        cy2:0,                        $ ;previous cursor y position
        rect:0,                       $ ;rectangle state: 0=inactive, 1= activated
        zoom:0,                       $ ;zoom state: 0=inactive, 1=zoom activated
        wdraw:0,                      $ ;draw window number for wset()
        progtitle:'Blo_LabTool V1.9', $ ;program name for display
        filename:''                   $ ;filename to be displayed
        }
;---------------------------------


  widg = {          $
        base:0L,    $   ;structure for all widget id's
        menu1:0L,   $
        menu11:0L,  $
        menu12:0L,  $
        menu13:0L,  $
        menu14:0L,  $
        menu15:0L,  $
        menu18:0L,  $
        menu2:0L,   $
        menu21:0L,  $
        menu22:0L,  $
        menu221:0L,  $
        menu222:0L,  $
        menu223:0L,  $
        menu224:0L,  $
        menu23:0L,  $
        menu24:0L,  $
        menu25:0L,  $
        menu26:0L,  $
        menu27:0L,  $
        menu3:0L,  $
        menu31:0L,  $
        menu32:0L,  $
        menu4:0L,   $
        menu41:0L,  $
        menu42:0L,  $
        menu5:0L,   $
        menu51:0L,  $
        menu52:0L,  $
        menu53:0L,  $
        menu54:0L,  $
        menu55:0L,  $
        menu56:0L,  $
        help1:0L,   $
        help11:0L,  $
        help12:0L,  $
        help13:0L,  $
        lcol:0L,    $
        rcol:0L,    $
        labl0:0L,   $  ;LZ 10/8/03 add one more label
        labl:0L,    $
        labl1:0L,   $
        draw:0L,    $
        slidb:0L,   $
        back:0L,    $
        slid:0L,    $
        next:0L,    $
        degl_b:0L,  $
        degl_b1:0L, $
        degl_b2:0L, $
        degl_b3:0L, $
        degl_b4:0L, $
        nsig1:0L,   $
        delta_t:0L, $
        nsig2:0L,   $
        niter:0L,   $
        navi:0L,    $
        exit:0L,    $
        quit:0L,    $
        up:0L,      $
        lrbut:0L,   $
        left:0L,    $
        right:0L,   $
        down:0L,    $
        scal:0L,    $
        xscal:0L,   $
        free:0L,    $
        fixed:0L,   $
        bzoom:0L,   $
        zin:0L,     $
        zout:0L,    $
        disp:0L,    $
        xdisp:0L,   $
        all:0L,     $
        valid:0L,   $
        bflag:0L,   $
        dasel:0L,   $
        hide:0L,    $
        unhide:0L,  $
        dasel2:0L,  $
        select:0L,  $
        unhideall:0L,$
        dasel3:0L,  $
        curcol:0L,  $
        allcol:0L,  $
        xsymb:0L,   $
        dots:0L,    $
        symb:0L,    $
        lines:0L,   $
        xperr:0L,   $
        noerr:0L,   $
        plerr:0L,   $
        xlnlg:0L,   $
        xlin:0L,    $
        xlog:0L,    $
        ylnlg:0L,   $
        ylin:0L,    $
        ylog:0L,    $
        clip:0L,    $
        basel:0L,   $
        degl:0L,    $
        dega:0L,    $
        rbasel:0L}

cm   = ptrarr(3)
cm[0]= ptr_new(ctrl)
cm[1]= ptr_new(ptr_new())       ;make pointer to pointer
cm[2]= ptr_new(widg)


blo_labtool_widget, cm          ;construct labtool panel

;-----------------------------------------
; Draw window

widget_control, /realize, (*cm[2]).base


widget_control, (*cm[2]).draw, get_value = bdata
(*cm[0]).wdraw = bdata

xmanager, 'blo_labtool', (*cm[2]).base,  /NO_BLOCK

;LZ 10/08/03  load the file at starting
if ( N_PARAMS() eq 1 ) then begin

      filelist=[filename]
      blo_display_file, filelist, cm, dtim, data, run_info, $
        sample_info, paramline, colname1, colname2
endif

END


;---------------------------------------------------------
; Main routine
;---------------------------------------------------------
PRO blo_labtool, filename

    if ( N_PARAMS() eq 1 ) then begin
       blo_display_window, filename
    endif else begin
       blo_display_window
    endelse

END



