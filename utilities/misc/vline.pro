pro vline,value,click=click,_extra=extra_keywords

if !y.type eq 1 then ycrange=10.^!y.crange else ycrange=!y.crange

if (keyword_set(click)) then begin
    cursor,value,y
endif


for i=0,n_elements(value)-1 do begin
plots,[value[i],value[i]],[ycrange],_extra=extra_keywords
endfor

end
