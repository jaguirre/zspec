pro draw_map, ra1, ra2, ra3, dec1, dec2, dec3, src_flag = src_flag,$
              legend = legend, source_list = source_list, $
              search_rad = search_rad

ptg_src_file = !zspec_pipeline_root+'/pointing/guidestar/submm_pointing_sources_edited.txt'

ra_field = ten(ra1,ra2,ra3)
dec_field = ten(dec1,dec2,dec3)

if (not(keyword_set(search_rad))) then search_rad = 20

xrange = [-search_rad,search_rad]
yrange = [-search_rad,search_rad];[dec_field-20,dec_field+20]

field_file = [ra1,ra2,ra3,dec1,dec2,dec3]

; Plot, and read 
radec_plot, $
  ptg_src_file, field_file, ra_0, $
  src_flag = src_flag, $
  xrange = xrange, $
  yrange = yrange, $
  legend = legend, $
  sources = sources, $
  field_name = ' '
;  no_2500mjy = no_2500mjy, $
;  no_500mjy = no_500mjy, $
;  no_100mjy = no_100mjy, $
;  title = title, $
;  ps_file = ps_file, $
;  fields = fields, $
;  noplot = noplot


readcol,ptg_src_file,format='(A,F,F,F,F,F,F)',$
  name_ptg,ra1,ra2,ra3,dec1,dec2,dec3,comment=';',/sil

ra_ptg = tenv(ra1,ra2,ra3)
dec_ptg = tenv(dec1,dec2,dec3)

dist = geodesic_distance(ra_field,dec_field,sources.ra,sources.dec)

srt = sort(dist)

wh_source_list = where(dist[srt] le search_rad)

if (wh_source_list[0] eq -1) then source_list = '' else begin

    n_source = n_e(wh_source_list)

    source_list = strarr(n_source)

    for i=0,n_source-1 do begin
    
        source_list[i] = $
          string($
                  name_ptg[srt[i]],ra1[srt[i]],ra2[srt[i]],ra3[srt[i]],$
                  dec1[srt[i]],dec2[srt[i]],dec3[srt[i]],dist[srt[i]],$
                  format='(A25,"   ",I2," ",I2," ",F5.2," ",'+$
                  'I3," ",I2," ",F5.2,"   ",F7.2)')
    
    endfor

endelse

end

PRO guidestar_event, event

common stupid, last_src_val, last_lgd_val

; Every time an event is triggered, tell me what the panel state is
;message,/info,'An event was generated'
;help,event,/str

; Find the user value of the widget where the event occured
WIDGET_CONTROL, event.id, GET_UVALUE = eventval		
;print,eventval

; Always read in current state of form
widget_control,widget_info(event.top,find='ra1'),get_value=ra1
widget_control,widget_info(event.top,find='ra2'),get_value=ra2
widget_control,widget_info(event.top,find='ra3'),get_value=ra3
widget_control,widget_info(event.top,find='dec1'),get_value=dec1
widget_control,widget_info(event.top,find='dec2'),get_value=dec2
widget_control,widget_info(event.top,find='dec3'),get_value=dec3
widget_control,widget_info(event.top,find='search_rad'),get_value=search_rad
; And the current state of the toggles
widget_control,widget_info(event.top,find='Source'),get_value=src_flag
widget_control,widget_info(event.top,find='Legend'),get_value=lgd_flag

;help,src_flag
;help,lgd_flag

; Defaults
draw = 0

case eventval of

    'ra1' : draw = 1
    'ra2' : draw = 1
    'ra3' : draw = 1

    'dec1' : draw = 1
    'dec2' : draw = 1
    'dec3' : draw = 1  

    'search_rad' : draw = 1

    'Source' : begin
;        message,/info,'Diddling source labels'
        draw = 1
        src_flag = event.value
    end

    'Legend' : begin
;        message,/info,'Diddling legend state'
        draw = 1
        lgd_flag = event.value
    end  

    'Done' : WIDGET_CONTROL, event.TOP, /DESTROY
        
    else : return
    
endcase

if (draw) then begin
    
;    print,'Plotting'

;    help,src_flag
;    help,lgd_flag
    
    draw_map, ra1, ra2, ra3, $
      dec1, dec2, dec3, src_flag = src_flag, $
      legend = lgd_flag,source_list=source_list,$
      search_rad = search_rad

    widget_control,widget_info(event.top,find='nearby'),set_value=source_list
    
endif

END  

pro guidestar

common stupid, last_src_val, last_lgd_val

; Initialize the state of the "src" plotting variable
last_src_val = 0
last_lgd_val = 0

base = WIDGET_BASE(/row,tit='GuideStar: a Catalog of mm Pointing Sources')
draw = WIDGET_DRAW(base, XSIZE = 512, YSIZE = 512)

form = widget_base(base,/COLUMN)

target = widget_label(form,/align_center,value='Target Coordinates')

ra_base = widget_base(form,/column)
ra_label = widget_label(ra_base,/align_center,value='RA (J2000)')

ra_entry = widget_base(ra_base,/row,frame=1)

ra1 = cw_field(ra_entry,/row,/integer,/return_events,$
               title='h',uname='ra1',uvalue='ra1',value=12,xsize=2)

ra2 = cw_field(ra_entry,/row,/integer,/return_events,$
               title='m',uname='ra2',uvalue='ra2',value=0,xsize=2)

ra3 = cw_field(ra_entry,/row,/float,/return_events,$
               title='s',uname='ra3',uvalue='ra3',value=0.0,xsize=4)

dec_base = widget_base(form,/column)
dec_label = widget_label(dec_base,/align_center,value='Dec (J2000)')

dec_entry = widget_base(dec_base,/row,frame=1)

dec1 = cw_field(dec_entry,/row,/integer,/return_events,$
               title='d',uname='dec1',uvalue='dec1',value=12,xsize=2)

dec2 = cw_field(dec_entry,/row,/integer,/return_events,$
               title='m',uname='dec2',uvalue='dec2',value=0,xsize=2)

dec3 = cw_field(dec_entry,/row,/float,/return_events,$
               title='s',uname='dec3',uvalue='dec3',value=0.0,xsize=4)

search_base = widget_base(form,/column)
search_label = widget_label(search_base,/align_center,value='Search Radius')
search_label2 = widget_label(search_base,/align_center,value='(degrees)')

search_rad = cw_field(search_base,/row,/floating,/return_events,$
                      uname='search_rad',uvalue='search_rad',$
                      value=10.0,tit='')

;[, /ALL_EVENTS] [, /COLUMN] [, FIELDFONT=font] [, /FLOATING | , /INTEGER | , /LONG | , /STRING] [, FONT=string] [, FRAME=pixels] [, /NOEDIT] [, /RETURN_EVENTS] [, /ROW] [, STRING=string] [, TAB_MODE=value] [, TEXT_FRAME=pixels] [, TITLE=string] [, UNAME=string] [, UVALUE=value] [, VALUE=value] [, XSIZE=characters] [, YSIZE=lines] ) 

; Various plotting options
options_base = widget_base(form,/column,frame=1)
source = $
  widg_onoff(options_base,uvalue='Source',uname='Source',label='Source Name')
legend = $
  widg_onoff(options_base,uvalue='Legend',uname='Legend',label='Legend')

done = widget_button(form, value='Done',uvalue='Done') 

; Set up the output window
src_list = widget_base(base,/column,frame=1)
src_label = widget_label(src_list,/align_center,$
                         value='Closest Pointing Sources')
src_label2 = $
  widget_label(src_list,/align_center,$
               value = string('Source Name','RA (J2000)','Dec (J2000)',$
                              'Dist (deg)',$
                              format='(A25,"   ",A12," ",A13,"   ",A10)'))

nearby = $
  widget_text(src_list,frame=1,xsize=60,ysize=20,/scroll,$
              value = ' ',$
              uvalue='nearby',uname='nearby')

WIDGET_CONTROL, base, /REALIZE 
widget_control, ra_base, /realize
widget_control, options_base, /realize
;widget_control, legend, /realize
widget_control, src_list, /realize

; Get the index for the widget_draw window and use that for graphics output
WIDGET_CONTROL, draw, GET_VALUE = index
WSET, index

XMANAGER, 'guidestar', base, EVENT_HANDLER = 'guidestar_event', no_block = 1

end
