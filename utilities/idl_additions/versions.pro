function versions, file, no_idl=no_idl
; $Log: versions.pro,v $
; Revision 1.1  2003/11/19 22:04:24  stoverp
; Initial import
;
; $Id: versions.pro,v 1.1 2003/11/19 22:04:24 stoverp Exp $
;
; Searches IDL_PATH for .pro files with the same name, and returns a
; string array containing the paths to each

;file:    search for this file only (optional)
;no_idl:  ignore repeats within the IDL distribution(s)

common USER_COMMON

; Trim off '.pro' extension if necessary
if(keyword_set(file)) then begin
    ntemp = strlen(file)
    if (ntemp ge 4) then begin
        if (strmid(file,ntemp-4,4) eq '.pro') then begin
            file_in = strmid(file,0,ntemp-4)
        endif
    endif
endif

path_temp = str_sep(!PATH,IDL_PATHSEP)

for k=0,n_e(path_temp)-1 do begin 
   search_in = path_temp[k] + IDL_FILESEP + (keyword_set(file) ? file : '*') + '.pro'
   if(keyword_set(no_idl) and strpos(search_in, 'idl_5') ge 0) then continue  ; Ignoring routines from IDL distribution

   paths = findfile(search_in)
   if(strlen(paths[0]) eq 0) then continue  ; No IDL routines in this directory, try again

   if(n_e(files) eq 0) then files = paths else files = [files,paths]
endfor

files = files[uniq(files)]  ; Filter out full path repeats (which are due to redundancy in IDL_PATH)

if(n_e(files) gt 1) then begin  ; Only one file?  Can't have duplicates!
    filenames = strarr(n_e(files))
    for i=0,n_e(files)-1 do filenames[i] = strmid(files[i], rstrpos(files[i],'/')+1) ; Trim off directories
    sorted_idx = sort(filenames)
    filenames = filenames[sorted_idx]
    files = files[sorted_idx]
    uniq_idx = uniq(filenames)
    uniq_idx_shift = [-1,uniq_idx]
    diff = uniq_idx-uniq_idx_shift
    multiples = where(diff gt 1,nmult)

    if(nmult gt 0) then begin  ; If we have no duplicates, skip next section
        not_uniq = uniq_idx[multiples]
        diff_not_uniq = diff[multiples]
        
        for i=0,n_elements(not_uniq)-1 do $
          if(n_e(mult_files) eq 0) then mult_files = files[not_uniq[i]-diff_not_uniq[i]+1:not_uniq[i]] else $
          mult_files = [mult_files,files[not_uniq[i]-diff_not_uniq[i]+1:not_uniq[i]]]
    endif
endif else mult_files = ''

return, mult_files

end
