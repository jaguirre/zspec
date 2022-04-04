;+
;NAME
; run_calib_apex
;PURPOSE
; To reduce a calibration observation of a bright souce
;  (Neptune, Uranus, Mars, etc.) and plot the resulting
;  spectrum.  Only runs on APEX data
;USAGE
; run_calib_apex, scannum, proj, date, source, [chopnum=chopnum]
;INPUTS
; scannum   The scan number of the observation.  Scalar integer
; proj      The project used ('ATLAS','HERMES','SPT')
; date      The date of the observation ymd (i.e., 20110507)
; source    Which source ('Uranus','Neptune','Mars')
;OPTIONAL INPUTS
; chopnum   Scan number of chop file.  Otherwise simply uses
;            the scan itself
;SIDE EFFECTS
; Will create a coadd file source_date.txt
;MODIFICATION HISTORY
; Author: Alex Conley, May 2011
;-

PRO run_calib_apex, scannum, proj, date, source, CHOPNUM=chopnum

  COMPILE_OPT IDL2, STRICTARRSUBS

  IF N_ELEMENTS(chopnum) EQ 0 THEN chopnum = 1
  
  CASE proj OF 
      'SPT' : 
      'HERMES' :
      'ATLAS' :
      'INFANTE' :
      'JOHANSSON' :
      'CASASSUS' :
      ELSE : MESSAGE,"Unknown project: " + proj
  ENDCASE

  neptune = 0b
  uranus = 0b
  mars = 0b
  CASE STRLOWCASE(source) OF
      'neptune' : neptune=1b
      'uranus'  : uranus=1b
      'mars'    : mars=1b
      ELSE : MESSAGE,"Unknown calibration source "+mars
  ENDCASE

  ;;Turn date into string if necessary
  IF SIZE( date, /TNAME ) EQ 'STRING' THEN sdate = STRTRIM(date,2) ELSE $
    sdate = STRING(date,FORMAT='(I8)')

  ;;Make the text file
  sourcebase = source + '_' + sdate +'.txt'
  outfile = '/home/zspec/zspec_svn/processing/spectra/coadd_lists/'+$
    sourcebase
  OPENW,unit,outfile,/GET_LUN
  PRINTF,unit,source
  PRINTF,unit,''
  PRINTF,unit,0.0,FORMAT='(F-0.1)'
  PRINTF,unit,''
  PRINTF,unit,sdate,scannum,1,chopnum,FORMAT='(A0,2X,I0,2X,I3,2X,I0)'
  FREE_LUN,unit
  
  ;;reduce data
  run_zapex,sourcebase,PROJ=proj
  uber_spectrum,sourcebase,/APEX,SAVEFILE=savefile,/ignore_cal_corr

  ;;And plot
  ;;we have to strip off most of the path from savefile
  pos = STRSPLIT(savefile,'/')
  IF N_ELEMENTS(pos) LT 2 THEN $
    MESSAGE,"Error encountered parsing savefile name"
  pfile = STRMID( savefile, pos[N_ELEMENTS(pos)-2] )
  PLOT_UBER_SPECTRUM_JK,pfile,MARS=mars,NEPTUNE=neptune,URANUS=uranus,/plot_sig

END
