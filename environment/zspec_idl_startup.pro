; $Id$ 
; $Log$
;+
; NAME:
;	zspec_idl_startup
;
; PURPOSE:
;       Standard zspec startup -- makes sure zspec_svn directory
;       is prepended to path, runs routines to define a number of
;       common blocks, starts journaling, sets up astrolib.
;
; CALLING SEQUENCE:
;       @zspec_idl_startup
;
; COMMON BLOCKS:
;
; NOTES:
;       Since this routine is part of the cvs distribution, it won't
;       necessary be in your idl path when you start idl.  There
;       are two ways to remedy this:
;       1) If you do not have your own startup.pro:
;          In your .cshrc or equivalent
;          define the environment variable IDL_STARTUP to point
;          at this routine
;          e.g.: 
;       setenv IDL_STARTUP ~/zspec_cvs/environment/zspec_idl_startup.pro
;          That's it -- when you start IDL, this routine will automatically
;          be run.
;       2) If you have your own startup.pro:
;          Presumably you have already defined the environment variable
;          IDL_STARTUP to point at your startup.pro;
;          e.g.:
;                setenv IDL_STARTUP ~/idl/startup.pro
;          Then, in your startup.pro, add the line 
;             @~/zspec_cvs/environment/zspec_idl_startup
;
; MODIFICATION HISTORY:
;       2003/12/04 SG Adapted from observer startup.pro
;       2005/04/24 SG Kill journaling.
;
;       2006/08/23 BN Added default data path
;	2009/04/11 LE Added default path for telescope_tests
;-

;common ZSPEC_COMMON, ZSPEC_PIPELINE_ROOT

; define Zspec root path
ZSPEC_PIPELINE_ROOT = getenv('HOME') + path_sep() + 'zspec_svn'
defsysv,'!zspec_pipeline_root',ZSPEC_PIPELINE_ROOT

; define Zspec RADEX modeling root path
ZSPEC_MODELING_ROOT = getenv('HOME')+ path_sep() + 'zspec_modeling_svn'
defsysv,'!zspec_modeling_root',ZSPEC_MODELING_ROOT

; define default data path
ZSPEC_DATA_ROOT = GETENV('HOME') + PATH_SEP() + 'data' + PATH_SEP() + 'observations'
DEFSYSV, '!zspec_data_root', ZSPEC_DATA_ROOT

; define default telescope data path
ZSPEC_TELESCOPE_ROOT = GETENV('HOME') + PATH_SEP() + 'data' + PATH_SEP() + 'telescope_tests'
DEFSYSV, '!zspec_telescope_root', ZSPEC_TELESCOPE_ROOT

; prepend zspec_cvs
!PATH = expand_path('+' + ZSPEC_PIPELINE_ROOT) $
  + path_sep(/search_path) $
  + expand_path('+' + ZSPEC_MODELING_ROOT) $
  + path_sep(/search_path) $
  + expand_path('+' + '/home/kilauea/zspec/software_scratch') $
  + path_sep(/search_path) + !PATH

; increase command history buffer
; now obsolete
;!EDIT_INPUT = 100

; setup non-standard system variables for astro library
astrolib

; Set up colors for plotting
device, true_color = 24, retain = 2, decompose = 0
red = [0,1,1,0,0,1]
green = [0,1,0,1,0,1]
blue = [0,1,0,0,1,0]
if not strcmp(getenv('DISPLAY'),'') then $
   tvlct, 255*red, 255*green, 255*blue






