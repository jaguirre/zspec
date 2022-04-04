pro run_plot_srces_azza, yyyy, mm, ddstart, ltstart, ltend, sources_file, $
                         sources_file_dir = sources_file_dir, $
                         outdir = outdir, $
                         min_flux = min_flux, ps_stub = $
                         ps_stub

; $Id: run_plot_srces_azza.pro,v 1.2 2007/04/03 17:49:19 golwala Exp $
; $Log: run_plot_srces_azza.pro,v $
; Revision 1.2  2007/04/03 17:49:19  golwala
; 2007/04/03 SG Added planet flags to call to plot_srces_azza.
;
; Revision 1.1  2004/04/22 14:28:57  jaguirre
; First commit of SG's observing plan software.  Routines to visualize
; the sources and fields in the catalogs directory.
;

print,'Archive version'

if (n_params() ne 6) then begin
    message, /info, 'requires six calling parameters'
    print,'                 YYYY: desired year in four digit format'
    print,'                   MM: desired month in numeric format'
    print,'              DDSTART: desired day on which observations start'
    print,'              LTSTART: starting local time'
    print,'                LTEND: ending local time'
    print,'         SOURCES_FILE: file containing source information'
    return
endif

; Default directory to find the sources file is the current one
if (keyword_set(sources_file_dir)) then $
  sources_file_dir = sources_file_dir else $
  sources_file_dir = ''

; Default output directory is the current one
if (keyword_set(outdir)) then outdir = outdir else $
  outdir = ''

; Default min_flux is 0.0, i.e., all sources are plotted
if (keyword_set(min_flux)) then min_flux = min_flux else $
  min_flux = 0.0

; Default ps_stub is sources_file, minus any extension, plus an underscore
if (keyword_set(ps_stub)) then ps_stub = ps_stub else begin
    extpos = strpos(sources_file,'.')
    if (extpos[0] ne -1) then ps_stub = strmid(sources_file,0,extpos)+'_' $
      else ps_stub = sources_file+'_'
endelse

if (ltend lt ltstart) then ltend = ltend + 24
nlt = ltend-ltstart+1
ltime = indgen(nlt) + ltstart
dd = ddstart + ltime/24

ps_file = string(format = '(%"%s%s%4d%2.2d%2.2d.eps")', $
                 outdir, ps_stub, yyyy, mm, ddstart)
plot_srces_azza, sources_file_dir+sources_file, ltime, yyyy, mm, ddstart, $
  min_flux = min_flux, ps_file = ps_file, /sun, /moon, /mars, /uranus, /neptune

for k = 0, nlt-1 do begin
   ps_file = string(format = '(%"%s%s%4d%2.2d%2.2d_%2.2d00.eps")', $
                    outdir, ps_stub, yyyy, mm, dd[k], ltime[k] mod 24)
   plot_srces_azza, sources_file_dir+sources_file, $
     ltime[k] mod 24, yyyy, mm, dd[k], $
     min_flux = min_flux, ps_file = ps_file, /sun, /moon, /mars, /uranus, /neptune
endfor

end
