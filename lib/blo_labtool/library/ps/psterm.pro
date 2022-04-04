;-------------------------------------------------------------
;+
; NAME:
;       PSTERM
; PURPOSE:
;       Terminate postscript plotting and send plots to printer.
; CATEGORY:
; CALLING SEQUENCE:
;       psterm
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;		  /ANGSTROEM octal code 341 is replaced by letter angstroem
;         /PLOT sends output to printer.
;         FILE='filename' copies ps-file to the given filename
; OUTPUTS:
; COMMON BLOCKS:
;       ps_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;       IAAW, 1991  - Adapt for Inst. of Astron. & Astrophys. Wuerzburg
;       Reinhold Kroll, 19.Sep.1991 - Include HP PaintJet (#6)
;		Keyword Angstroem added by Juergen Hofmann, 26.Mar.1992
;       Ghostscript 2.4 support by Reinhold Kroll 24.Apr.92
;	Adaption for IAC, Reinhold Kroll, 22.12.93
;	noplot keyword changed to print, Bernhard Schulz 11.04.2000
;-
;-------------------------------------------------------------
 
	pro psterm, q, help=hlp, print=print, file=file, angstroem=angst
 
	common ps_com, dname, xthick, ythick, pthick, pfont, pid, psfile
		
	on_error,2
 
	if keyword_set(hlp) then begin
	  print,' Terminate postscript plotting and send plots to printer.'
	  print,' psterm'
	  print,'   No arguments.  Plot is shown with gv (ghostview)'
	  print,' Keywords:
	  print,'   /ANGSTROEM octal code 341 is replaced by letter angstroem.'
	  print,'   /PRINT Plots are sent to the printer that'
	  print,'   was selected with psinit.  See psinit.'
	  print,'   FILE=filename  copies postscript file to filename'
	  return
	endif
 
	if !d.name ne 'PS' then begin
		print,' Not in postscript mode. (try PSINIT !)'
		return
	endif

	device,/close
 
;	PS-header for redefining fonts
	if keyword_set(angst) then begin
		
	red_font1="%!\012"
	red_font1=red_font1+"%Redefine Fonts, including letter angstroem\012"
	red_font1=red_font1+"% by Juergen Hofmann 24.3.1992\012"
	red_font1=red_font1+"/newfont 256 array def\012"
	red_font1=red_font1+" 0 1 255 {newfont exch /.notdef put} for\012"
	red_font1=red_font1+"StandardEncoding newfont copy pop\012"
	red_font1=red_font1+"newfont 225 /Aring put            % oktal 341\012"
	red_font1=red_font1+"%Now redefine all dict's\012"
	red_font1=red_font1+"%Helvetica\012"
	red_font1=red_font1+"/Helvetica findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Helvetica newdict definefont pop\012"
	red_font1=red_font1+"%Helvetica-Bold\012"
	red_font1=red_font1+"/Helvetica-Bold findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Helvetica-Bold newdict definefont pop\012"
	red_font1=red_font1+"%Helvetica-Narrow\012"
	red_font1=red_font1+"/Helvetica-Narrow findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Helvetica-Narrow newdict definefont pop\012"
	red_font1=red_font1+"%Helvetica-Narrow-BoldOblique\012"
	red_font1=red_font1+"/Helvetica-Narrow-BoldOblique findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Helvetica-Narrow-BoldOblique newdict definefont pop\012"
	red_font1=red_font1+"%Times-Roman\012"
	red_font1=red_font1+"/Times-Roman findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Times-Roman newdict definefont pop\012"
	red_font1=red_font1+"%Times-BoldItalic\012"
	red_font1=red_font1+"/Times-BoldItalic findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Times-BoldItalic newdict definefont pop\012"
	red_font1=red_font1+"%Courier\012"
	red_font1=red_font1+"/Courier findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font1=red_font1+"		{pop pop}\012"
	red_font1=red_font1+"		ifelse\012"
	red_font1=red_font1+"	}forall\012"
	red_font1=red_font1+"newdict /Encoding newfont put\012"
	red_font1=red_font1+"/Courier newdict definefont pop\012"
	red_font1=red_font1+"%Courier-Oblique\012"
	red_font1=red_font1+"/Courier-Oblique findfont\012"
	red_font1=red_font1+"dup length dict /newdict exch def\012"
	red_font1=red_font1+"	{1 index /FID ne\012"
	red_font1=red_font1+"		{newdict 3 1 roll put}\012"
	red_font="		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/Courier-Oblique newdict definefont pop\012"
	red_font=red_font+"%Platino-Roman\012"
	red_font=red_font+"/Platino-Roman findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/Platino-Roman newdict definefont pop
	red_font=red_font+"%Platino-Italic\012"
	red_font=red_font+"/Platino-Italic findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/Platino-Italic newdict definefont pop\012"
	red_font=red_font+"%Platino-BoldItalic\012"
	red_font=red_font+"/Platino-BoldItalic findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/Platino-BoldItalic newdict definefont pop\012"
	red_font=red_font+"%Platino-Bold\012"
	red_font=red_font+"/Platino-Bold findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"/Platino-Bold newdict definefont pop\012"
	red_font=red_font+"%AvantGarde-Book\012"
	red_font=red_font+"/AvantGarde-Book findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/AvantGarde-Book newdict definefont pop\012"
	red_font=red_font+"%NewCenturySchlbk-Roman\012"
	red_font=red_font+"/NewCenturySchlbk-Roman findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/NewCenturySchlbk-Roman newdict definefont pop\012"
	red_font=red_font+"%NewCenturySchlbk-Bold\012"
	red_font=red_font+"/NewCenturySchlbk-Bold findfont\012"
	red_font=red_font+"dup length dict /newdict exch def\012"
	red_font=red_font+"	{1 index /FID ne\012"
	red_font=red_font+"		{newdict 3 1 roll put}\012"
	red_font=red_font+"		{pop pop}\012"
	red_font=red_font+"		ifelse\012"
	red_font=red_font+"	}forall\012"
	red_font=red_font+"newdict /Encoding newfont put\012"
	red_font=red_font+"/NewCenturySchlbk-Bold newdict definefont pop\012"

;	Now change PS-Font for Angstroem

	print," code 341 is replaced by angstroem"
	openw,unit,"tmp_idl.ps",/get_lun
	printf,unit,red_font1
	printf,unit,red_font
	close,unit
	free_lun,unit
	spawn,/sh, 'cat >> tmp_idl.ps <'+psfile
	spawn,/sh, 'mv tmp_idl.ps '+psfile

	endif 
;
	if keyword_set(print) then begin

          print," Plot sent to postscript printer ",pid 
	  command='lpr -P'+pid + ' ' + psfile
;	  print,command
          spawn,/sh, command

	endif

;case num of
;0:    begin
;          print," Plot sent to postscript printer #0 ." 
;          spawn,/sh, 'lpr -Plw1 ' + psfile
;      end
;1:    begin
;          print," Plot sent to postscript printer #1 ." 
;          spawn,/sh, 'lpr -Plw1 ' + psfile
;      end
;2:    begin
;          print," Plot sent to postscript printer #1 ." 
;          spawn,/sh, 'lpr -Plw2 ' + psfile
;      end
;3:    begin
;          print," Plot sent to postscript printer #1 ." 
;          spawn,/sh, 'lpr -Plw3 ' + psfile
;      end
;4:    begin
;          print," Plot sent to postscript printer #1 ." 
;          spawn,/sh, 'lpr -Plw4 ' + psfile
;      end
;6:    begin
;          print," Plot sent to HP PaintJet XL via GhostScript ." 
;          spawn,/sh, '/usr/local/bin/gs -q -dNOPAUSE -sDEVICE=paintjet ' + $
;                     '-sOUTPUTFILE=\|lpr\ -Ppj ' + psfile + ' quit.ps'
;      end
;else: begin
;          print,' Unknown printer number ',num
;          goto,reset
;      end
;endcase

reset: ;
	if not keyword_set(file) and $
	   not keyword_set(print) then begin
	  spawn,/sh, 'gv '+psfile
	endif

	if keyword_set(file) then begin
		spawn,/sh, 'mv '+psfile+' '+file+' 2>&1', errmsg
		if errmsg(0) ne '' then begin
			file=psfile
			print,errmsg
		endif
                print, " Postscript file saved in  " + file + " ."
	endif else begin
		spawn,/sh, 'rm ' + psfile
	endelse
 
      	set_plot, dname 
	!x.thick = xthick
	!y.thick = ythick
	!p.thick = pthick
	!p.font = pfont
 
	return
	end
