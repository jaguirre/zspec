function recent_phase, source=source, quiet=quiet

;;
; This function returns the filename of the most recent
; chopper-bolometer phase SAV file.  The program can search for any
; user-provided source, although URANUS is the default.
;
; Note that this returns the most recently *processed* file, which
; isn't necessarily the most recent observation.
; 
; created 09Jan2011, RK.
;;

if n_elements(source) eq 0 then source = 'Uranus'

dir = '/home/zspec/data/observations/apexnc/'+source+'/'
spawn,'ls -rt '+dir+'**chopphase.sav',list
nlist = n_elements(list)
output = list[nlist-1]
output = strmid(output,strpos(output,'/',/reverse_search)+1)

if ~keyword_set(quiet) then begin
    print,'----------------------------'
    for i=0,nlist-1 do print,list[i]
    print,'----------------------------'
    print,'Using: ',output
    print,' '
endif


return,output
end
