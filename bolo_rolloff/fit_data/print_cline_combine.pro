pro print_cline_combine,infile,outfile

data_file=!zspec_pipeline_root+'/bolo_rolloff/fit_data/'+outfile

readcol,infile,freqid,cline,avephi,cline_err,avephierr,$
  format='(I5,F0.8,F0.8,F0.8,F0.8)'

comment='# freqid, cline[pF], cline_err'

forprint,freqid,cline,cline_err,textout=data_file,comment=comment

end
