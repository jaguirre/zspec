pro tau_concat,begin_date,end_date,textfilename

for datestr=begin_date,end_date do begin

    date=datestr
    date=string(datestr,format='(i8)')

    file=!zspec_pipeline_root+'/weather/tau_225_may2007/'+ $
      strcompress(date)+'.dat'

    readcol,file,ut,tau,error,format='(f2.3,f1.3,f1.3)'

        temp_result=strarr(5,n_e(ut))
        temp_result[0,*]=date
        temp_result[1,*]=ut
        temp_result[2,*]=tau
        temp_result[3,*]=error
        temp_result[4,*]=1

        if datestr eq begin_date then $
          result=temp_result else $
          result=[[result],[temp_result]]

    endfor

textfilename=!zspec_pipeline_root+'/weather/'+textfilename
openw,lun,textfilename,/get_lun
printf,lun,result
free_lun,lun

stop

end





