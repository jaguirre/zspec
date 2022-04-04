pro check_info,files,exists=exists,read=read,write=write,directory=directory,noexist=noexist,cont=cont,status=status

;this procedure checks whether a file exists, is readable, or is writable
;031105 GL - created
;031106 GL - added multiple file capability, cont and status

status=1

nfiles=n_elements(files)

;loop over files
for i_file=0L,nfiles-1L do begin
	file=files(i_file)

	;get info
	info=file_info(file)
	
	;give error messages
	if keyword_set(exists) and info.exists eq 0 then begin
		message,cont=cont,string(file)+' does not exist!'
		status=-1
	endif
	if keyword_set(noexist) and info.exists eq 1 then begin
		message,cont=cont,string(file)+' already exists -- use overwrite keyword!'
		status=-1
	endif
	if keyword_set(read) and info.read eq 0 then begin
		message,cont=cont,string(file)+' is not readable!'
		status=-1
	endif
	if keyword_set(write) and info.write eq 0 then begin
		message,cont=cont,string(file)+' is not writeable!'
		status=-1
	endif
	if keyword_set(directory) and info.directory eq 0 then begin
		message,cont=cont,string(file)+' is not a valid directory!'
		status=-1
	endif
endfor

return
end
