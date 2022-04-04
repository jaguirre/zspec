pro fittable_tex,source,fitfile,texfile,nodate=nodate, graphics=graphics

;+
; NAME:
;   FITTABLE_TEX
;
; PURPOSE:
;   Create a .tex document based on the results of a line fit
;   using zilf.
;
; CALLING SEQUENCE:
;   fittable,source,fitfile,texfile,/nodate (keywords optional)
;
; INPUTS:
;   source = the name of the source.
;
;   fitfile = the name (and path) of the .sav file output by zilf.
;
;   texfile = the name (and path) of the .tex file to be written by this routine.
;             YOU WILL BE PROMPTED TO OVERWRITE IF THE .TEX FILE ALREADY EXISTS.
;
; KEYWORDS:
;  /nodate tells the routine not to print the date/timestamp in the document,
;        if you believe that it completely ruins the aesthetics of the table.
;
; OUTPUTS:
;  A .tex file with 2 tables.  The first table is of the line fits, and contains
;  the species name, transition, rest freq, observed freq, flux in Jy km/s and K km/s
;  and the signal to noise.  The second table contains the other parameters of the fit.
;  The document should be able to run through LaTeX as it is.
;
; SPECIAL ROUTINES USED:
;   Species_tex gives the species in latex format.  If the species is not in
;   the case structure of species_tex, it is just output as regular text.
;
; RESTRICTIONS:
;  Compatible with zilf at least as of 5/14/09.  Not compatible with output
;  from older fitting routines.
;  If 2 columns of the fit.summary variable run into one another (usually not 
;  a problem), that line will be displayed as an error.
;
; PROCEDURE:
;  Restore the .sav file, check if the .tex file exists and if it does ask
;  to overwite.  Then setup the .tex file.  Before outputting table 1, convert
;  species and transition to latex format, and also calculate flux in K km/s.
;  Then output table 1 and table 2, finish up the .tex document and close.
;
; EXAMPLE:
;   fittable_tex,'NGC1068','~/Somewhere/NGC1068_fit.sav','~/Somewhere/fittable.tex'
;
; MODIFICATION HISTORY:
;   Written by JRK 5/14/09
;   5/27/09 JRK: Now converts to K km/s using zspec_jytok routine.
;                Also, there is no longer a default directory, the full
;                path must be specified (or you must be in the directory
;                of the files).
;-

;___________________________________________________________________________
; OPEN FILES

; Restore the fit.
  restore,fitfile

; Open the .tex file for editing.  Check if overwriting.
; Need to expand if '~/blah' is used
  testtexfile=strsplit(texfile,'/',/EXTRACT)
  if testtexfile[0] EQ '~' then texfile=expand_tilde(texfile)
 
  quiz=file_search(texfile)
  
  if quiz eq texfile then begin  ; Check if want to overwrite.
      if ~keyword_set(graphics) then begin ;Use command line if a text argument was given. 
          response=''
          read, 'Latex file already exists.  Overwrite?  (Y/N) ',response
          if (response EQ 'y') or $
            (response EQ 'Y') or $
            (response EQ 'Yes') or $
            (response EQ 'yes') then begin ; Overwrite.
              openw,ounit,texfile,/GET_LUN    
          endif else begin      ; Don't overwrite.
              message,'Not overwriting.  Try again with a different filename.'
              return
          endelse
      endif else begin
          result=dialog_message('Latex file already exists. Overwrite?', dialog_parent=graphics,$
                                /question)
          if result eq 'Yes' then openw,ounit,texfile,/GET_LUN $
          else begin
              a=dialog_message('Not overwriting.  Try again with a different filename.', $
                               dialog_parent=graphics, /information)
              return
          endelse
      endelse
  endif else begin    ; If it doesn't exist, just write it!
     openw,ounit,texfile,/GET_LUN  
  endelse
  
; Some useful things
  nlines=n_e(fit.summary)-2
  gone=WHERE(fit.flags EQ 0,ngone)
  
;___________________________________________________________________________
; BAREBONES LATEX HEADERS, BEGIN THE DOCUMENT

  printf,ounit,'\documentclass[fullpage]{article}'
  printf,ounit,'\usepackage{fullpage}'  

  printf,ounit,'\begin{document}'
  printf,ounit,'\title{'+source+'}'
  printf,ounit,''

;_________________________________________________________________________
; TABLE 1: THE LINE FITS

  ;Setup the table.

  caption='Z-Spec Detections in '+source
  
  printf,ounit,''
  printf,ounit,'\begin{table}'
  printf,ounit,'   \centering'
  printf,ounit,'   \caption{'+caption+'}\label{table:fit}'
  printf,ounit,'   \smallskip'
  
  printf,ounit,'   \begin{tabular}{c c c c c c c}'
  printf,ounit,'   \hline'
  printf,ounit,'   Species & Transition & $\nu_{rest}$ & $\nu_{obs}$ & \multicolumn{2}{c}{Flux} & S/N'+'\\'
  printf,ounit,'           &            & [Ghz]       & [Ghz]     & [Jy km/s] & [K km/s] & \\'
  printf,ounit,'   \hline'
  
  ; The meat of the table
  for i=0, nlines-1 do begin      ; Print 1 line per, erm, line.
 
     ; Is the "summary" the only place that the flux is saved?  Gah.
     line=strsplit(fit.summary[i+2],' ',/EXTRACT)
     if n_e(line) NE 5 then begin     ; Problem line
       MESSAGE,'An error occured!  See .tex document comments.',/INFORMATIONAL
       printf,ounit,'% Line below did not print.'
       printf,ounit,'% Likely because transition is > 11 characters'
       printf,ounit,'% or some other column is running into another.'
       printf,ounit,'Error: & see & .tex & doc & comments & &\\'
     endif else begin                 ; 
     
       ; Convert to K km/s
          fluxK=DOUBLE(line[2])
          freq=DOUBLE(fit.centers[i])
          fluxK=zspec_jytok(fluxK,freq)
          fluxK=STRING(fluxK,Format='(D0.2)')
          
       ; Get the species and transitions in Latex format
         species=species_tex(line[0])
         trans=transition_tex(line[1])
         
       ; Create the table line and print to the file.
         string=species+' & '$                    ; Species
         +trans+' & '$                           ; Transition
         +STRING(fit.xall.line_freqs[i],Format='(D0.2)')+' & '$  ; Rest frequency
         +STRING(fit.centers[i],Format='(D0.2)')+' & '$        ; Observed frequency
         +line[2]+' & '$         ; Flux Jy km/s
         +fluxK+' & '$         ; Flux K km/s
         +line[4]+'\\'           ; S/N
         printf,ounit,string
       
     endelse 
     
  endfor  ; Looped over all spectral lines.
  
  ; Close out the table.
  printf,ounit,'   \hline'
  printf,ounit,'   \end{tabular}'
  printf,ounit,'\end{table}'
  printf,ounit,''

;_________________________________________________________________________
; TABLE 2: EVERYTHING ELSE

; Setup this table.
  printf,ounit,''
  printf,ounit,'\begin{table}'
  printf,ounit,'   \centering'
  printf,ounit,'   \caption{Fit Parameters}\label{table:params}'
  printf,ounit,'   \smallskip'
  
  printf,ounit,'   \begin{tabular}{r l}'
  printf,ounit,'   \hline'
  printf,ounit,'   Parameter & Value \\'
  printf,ounit,'   \hline'
  
; Print useful stuff.
  printf,ounit,'Reduced chi squared & '+STRING(fit.redchi,Format='(D0.3)')+'\\'
  printf,ounit,'Degrees of freedom & '+STRING(fit.dof,Format='(I0.0)')+'\\'
  printf,ounit,'Channels excluded from fit & '+STRING(ngone,Format='(I0.0)')+'\\\\'
  
  printf,ounit,'Continuum type & '+fit.xall.cont+'\\'
  printf,ounit,'Amplitude & '+STRING(fit.camp,Format='(D0.4)')+$
     ' $\pm$ '+STRING(fit.caerr,Format='(D0.4)')+'\\'
  printf,ounit,'Exponent & '+STRING(fit.cexp,Format='(D0.4)')+$
      ' $\pm$ '+STRING(fit.ceerr,Format='(D0.4)')+'\\\\'

; Generally the line widths will be all the same, however
; in case they are fit differently...
; In the future the wtable=1 could be used to indicate that
; the program should make a separate table of all the widths.

; Test if all line widths are the same.
  unique=fit.width[UNIQ(fit.width, SORT(fit.width))]

; Now print
  if n_e(unique) EQ 1 then begin
      printf,ounit,'Line width & '+STRING(fit.width[0],Format='(D0.1)')+$
                    ' $\pm$ '+STRING(fit.widtherr[0],Format='(D0.1)')+' km/s \\\\'
      wtable=0
  endif else begin
      printf,ounit,'Line widths & WARNING: Varies\\\\'
      wtable=1
  endelse

; Same deal for redshift.
; Test if all line widths are the same.
  unique=fit.redshift[UNIQ(fit.redshift, SORT(fit.redshift))]

; Now print
  if n_e(unique) EQ 1 then begin
      printf,ounit,'Redshift & '+STRING(fit.redshift[0],Format='(D0.4)')+$
                    ' $\pm$ '+STRING(fit.zerr[0],Format='(D0.4)')+'\\'
                    
     ; Want to also report z in km/s
     c=2.99792458e5
     zkms=c*fit.redshift[0]
     zkmserr=c*fit.zerr[0]
     
     printf,ounit,' & '+STRING(zkms,Format='(D0.1)')+$
                    ' $\pm$ '+STRING(zkmserr,Format='(D0.1)')+' km/s \\\\'
                    
      rtable=0
  endif else begin
      printf,ounit,'Redshifts & WARNING: Varies\\\\'
      rtable=1
  endelse
  
  ; Also include the date this table was made, unless told not to.
  if ~keyword_set(nodate) then printf,ounit,'Date of table & '+systime()+'\\'
  
; Close out the table  
  printf,ounit,'   \hline'
  printf,ounit,'   \end{tabular}'
  printf,ounit,'\end{table}
  printf,ounit,''

;_________________________________________________________________________
; CLEAN UP.

  printf,ounit,''
  printf,ounit,'\end{document}'
  
  free_lun,ounit
  
  Message,'.tex file complete and located at',/INFORMATIONAL
  Message,texfile,/INFORMATIONAL

end
