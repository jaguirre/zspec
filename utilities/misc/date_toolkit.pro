;+
; NAME:
;       date_toolkit
;
; PURPOSE:
;       convert between various date formats used in
;       spt_analysis code, with optional addition/subtraction
;
; CATEGORY:
;
; CALLING SEQUENCE:
;       result=date_toolkit(date,'format',[addition,'units'])
;
; INPUTS:
;       date - a date in one of the following formats:
;              archive: 'DD-MMM-YYYY:HH:MM:SS'
;              file: 'YYYYMMDD_HHMMSS'
;              array: [Y,M,D,H,M,S]
;              logentry: YYMMDD HH:MM:SS
;              julian: double precision non-red julian date
;              'now' (use the current time)
;              'mjd': modified julian date
;       
;       format - a string specifying the desired output format:
;                arc[ive] file  arr[ary] jul[ian] log[entry]
;                defaults to archive
;
; OPTIONAL INPUTS:
;       addition  - the number of UNITS to add, pos or neg float
;       
;       units - a string specifying the units to be added:
;               seconds, minutes, hours, days, weeks,
;               months, years
;
; KEYWORD PARAMETERS:
;       
; OUTPUTS:
;       The date converted to the format specified by FORMAT
;
; OPTIONAL OUTPUTS:
;
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;       uses goddard astrolib routines
;
; PROCEDURE:
;
; EXAMPLE:
;
;  print,date_toolkit('27-Apr-2008:03:04:05','arc',8,'days')
;     -> 04-May-2008:03:04:05
;  print,date_toolkit('04-May-2008:03:04:05','file')
;     -> 20080404_030405
;  print,date_toolkit('20080404_030405','arr')
;     -> 2008       4       4       3       4       5
;  print,date_toolkit([2008l,4,4,3,4,5],'jul'),format='(d16.8)'
;     -> 2454560.62783565
;  print,date_toolkit(2454560.62783565d0,'arch',-8*24,'hours')
;     -> 27-Apr-2008:03:04:05
;       
;  print,date_toolkit('now','log',-2,'day')
;     ->080312 15:56:59
;  print,date_toolkit('now','mjd')
;     ->54544.634
;
;      
;
; MODIFICATION HISTORY:
;       2009/04/29 - Define NOW as utc, to match archive files.
;       
;       Wed Mar 19 15:20:27 2008, Erik Shirokoff <shiro@berkeley.edu>
;       added MJD type - thanks JV.
;
;       Fri Mar 14 15:53:37 2008, Erik Shirokoff <shiro@berkeley.edu>
;       moved "log" to "file" format, added log format for log entries
;
;       first write
;       Mon Feb 11 11:14:10 2008, Erik Shirokoff
;       <shiro@berkeley.edu>
;-


function date_toolkit,input,outformat,add0,units

;;CONSTANTS
monstr=['Fibble','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;;January is not the 0th month.

;;FORMATS:
; 0 - 02-Jan-2008:03:04:05 - archive 
; 1 - 20080102_030405 - (log)file
; 2 - [2008,1,2,3,4,5] - array
; 3 - Julian date - julian
; 4 - log entry
; 5 - now
; 6 - mjd (JD - 2400000.5)

;;CHOOSE AN INPUT FORMAT
inkey=-1
if n_elements(input) eq 6 then inkey=2 else begin
   if stregex(input,'^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}',/bool) then inkey=0
   if stregex(input,'^[0-9]{8}_[0-9]{6}',/bool) then inkey=1
   if stregex(input,'^[0-9]{6} [0-9]{2}:[0-9]{2}:[0-9]{2}',/bool) then inkey=4
   if stregex(input,'^now',/bool) then inkey=5
   if (size(input,/type) eq 4) or (size(input,/type) eq 5) then begin ;jul or mjd
      ;;SPT is unlikely to be taking data in 1800 years
      if input ge (365d0*2000d0) then inkey=3 else inkey=6
   endif
endelse


outkey=0 ; default to archive format
if n_elements(outformat) gt 0 then begin
;;Choose an output format
   if (size(outformat))[n_elements(size(outformat))-2] eq 2 then outkey=outformat else begin 
      if stregex(outformat,'^arc',/bool,/fold) then outkey=0
      if stregex(outformat,'^fil',/bool,/fold) then outkey=1
      if stregex(outformat,'^arr',/bool,/fold) then outkey=2
      if stregex(outformat,'^jul',/bool,/fold) then outkey=3
      if stregex(outformat,'^log',/bool,/fold) then outkey=4
      if stregex(outformat,'^mjd',/bool,/fold) then outkey=6
   endelse
endif
;;FOR EVERYTHING EXCEPT JULIAN, FIRST CONVERT TO AN ARRAY FORMAT
darr=intarr(6)  ;; year,month,day,hour,minute,sec

case inkey of
   0: begin ;archive format
      darr[0]=long(strmid(input,7,4)) ; year
      darr[1]=long(where(strmatch(monstr,strmid(input,3,3)))) ;month
      darr[2]=long(strmid(input,0,2));//day
      darr[3]=long(strmid(input,12,2))
      darr[4]=long(strmid(input,15,2))
      darr[5]=long(strmid(input,18,2))
      jd=julday(darr[1],darr[2],darr[0],darr[3],darr[4],darr[5]) ;mdyhms
      end
   1: begin ; logfile format
      darr[0]=strmid(input,0,4) ;year
      darr[1]=strmid(input,4,2) ;month
      darr[2]=strmid(input,6,2) ;day
      darr[3]=strmid(input,9,2) ;hour
      darr[4]=strmid(input,11,2) ;min
      darr[5]=strmid(input,13,2) ;sec
      jd=julday(darr[1],darr[2],darr[0],darr[3],darr[4],darr[5]) ;mdyhms
   end
   2: begin                     ; array format
      darr=long(input)
   end
   3: begin                     ;julian
      jd=double(input)
      ;;don't do anything!
   end
   4: begin ; logfile format
      darr[0]='20'+strmid(input,0,2) ;year
      darr[1]=strmid(input,2,2) ;month
      darr[2]=strmid(input,4,2) ;day
      darr[3]=strmid(input,7,2) ;hour
      darr[4]=strmid(input,10,2) ;min
      darr[5]=strmid(input,13,2) ;sec
      jd=julday(darr[1],darr[2],darr[0],darr[3],darr[4],darr[5]) ;mdyhms
   end
   5: begin                     ; NOW!
      jd=systime(/julian,/utc)
   end
   6: begin
      jd=double(input)+2400000.5d0
      end
endcase

;;FOR NON 3 OR 5 FORMATS, TURN OUT NEW ARRAY INTO
;;JULIAN.



;;DO WE WANT TO DO MATH ON OUR DATE?
if keyword_set(add0) then begin
;;;ADD A GIVEN NUMBER OF UNITS, CONVERTING EVERYTHING TO
;;;DAYS SINCE WE'LL BE DOING MATH WITH JULIANS
   if stregex(units,'^s',/bool) then add=add0/(60d0*60d0*24d0)
   if stregex(units,'^mi',/bool) then add=add0/(60d0*24d0)
   if stregex(units,'^h',/bool) then add=add0/24d0
   if stregex(units,'^w',/bool) then add=add0*7d0
   if stregex(units,'^mo',/bool) then add=add0*30d0 ;what is a month?  This is close.
   if stregex(units,'^y',/bool) then add=add0*365d0
   if stregex(units,'^d',/bool) then add=add0
   jd=jd+add
endif

caldat,jd,omonth,oday,oyear,ohour,ominute,osecond
darr=long([oyear,omonth,oday,ohour,ominute,osecond])


;;NOW CONVERT BACK TO THE FORMAT OF OUR CHOICE


;   stop
;;FORMATS:
; 0 - 02-Jan-2008:03:04:05 - archive 
; 1 - 20080102_030405 - (log)file
; 2 - [2008,1,2,3,4,5] - array
; 3 - Julian date - julian
; 4 - log entry
; 6 - mjd
case outkey of
   0:begin ; archive
      output=strn(darr[2],format='(i2.2)')+'-'+ $
             monstr[darr[1]]+'-'+$
             strn(darr[0],format='(i4.4)')+':'+$
             strn(darr[3],format='(i2.2)')+':'+$
             strn(darr[4],format='(i2.2)')+':'+$
             strn(darr[5],format='(i2.2)')
   end
   1:begin ; logfile
      output=strn(darr[0],format='(i4.4)')+$
             strn(darr[1],format='(i2.2)')+$
             strn(darr[2],format='(i2.2)')+'_'+$
             strn(darr[3],format='(i2.2)')+$
             strn(darr[4],format='(i2.2)')+$
             strn(darr[5],format='(i2.2)')

   end
   2:begin ; array
      output=darr
   end
   3:begin ;julian
      output=jd
   end
   4:begin ; log entry
      output=strmid(strn(darr[0],format='(i4.2)'),2,2)+$
             strn(darr[1],format='(i2.2)')+$
             strn(darr[2],format='(i2.2)')+' '+$
             strn(darr[3],format='(i2.2)')+':'+$
             strn(darr[4],format='(i2.2)')+':'+$
             strn(darr[5],format='(i2.2)')

   end
   6:begin ;mjd
      output=jd-2400000.5d0
   end

endcase


return,output
   
   
end

