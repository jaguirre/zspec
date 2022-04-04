pro hline,value,click=click,_extra = extra_keywords

if !x.type eq 1 then xcrange=10.^!x.crange else xcrange=!x.crange

if (keyword_set(click)) then begin
    cursor,x,value
endif

for i=0,n_elements(value)-1 do begin

    plots,[xcrange],[value[i],value[i]],_extra = extra_keywords

endfor

end
