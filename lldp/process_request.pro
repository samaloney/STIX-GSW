;; Do the actual processing, using output_dir also for scratch
;;
PRO process_request, input_dir, output_dir

  ; initialize environment
  stx_lldp_init_environment
  
  request = file_basename(input_dir)
  
  stx_lldp_logger, "PROCESSING: "+request

  ; We get back "obt_start" which is the first OBT in the "current day".
  ;
  process_telemetry, input_dir, output_dir, stream=stream,$
    obt_start=obt_start, obt_end=obt_end


  stx_lldp_logger
  stx_lldp_logger, "Pretending to be done"
  stx_lldp_logger
  stx_lldp_logger, "Coarse OBT start: " + obt_start
  stx_lldp_logger, "Coarse OBT end  : " + obt_end
  stx_lldp_logger, "Duration (secs) : " + obt_end-obt_start
  stx_lldp_logger
;  help, obt_start, obt_end
  obt_beg = obt_start

  stx_lldp_logger, 'Making dummy fits file using OBT_BEG = OBT start'
  ;obt_beg = trim(obt_start, '(I010)')

  svn_number = svn_number()
  stx_lldp_logger, 'SVN number = '+trim(svn_number)
  aux_dir = input_dir + "/auxiliary"
  filename = aux_dir + "/filtered_tmtc.bin"
  tmtc_reader = stx_telemetry_reader(stream=stream)
  
  ; create emtpy lists, in case no data are returned
  asw_ql_lightcurve = list()
  asw_ql_flare_flag_location = list()

  ; create lightcurve and flare_flag_location
  tmtc_reader->getdata, solo_packets = solo_packets_r, statistics = statistics, $
    asw_ql_lightcurve=asw_ql_lightcurve, $
    asw_ql_flare_flag_location=asw_ql_flare_flag_location
  
  ;create lightcurve fits file(s)
  file_nr=0
  first_run=1
  foreach lightcurve, asw_ql_lightcurve do begin
    
    cur_time = anytim(!stime, /ccsds)
    tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 2)+strmid(cur_time, 11, 2)+strmid(cur_time, 14, 2)

    
    file_lighcurve = output_dir+'/solo_LL01_stix-lightcurve_'+trim(string(obt_beg))+'_'+trim(string(file_nr))+'.fits'
    if first_run then begin
      file_lighcurve = output_dir+'/solo_LL01_stix-lightcurve_'+trim(string(obt_beg, format='(I010)'))+'-'+trim(string(obt_end, format='(I010)'))+'V'+tstamp+'C.fits'
      first_run=0
    endif
    err=stx_asw2fits(lightcurve,file_lighcurve,obt_beg=obt_beg,obt_end=obt_end, history=trim(svn_number))
    if err eq 0 then fail=1
  endforeach
  
  ;create flare_flag_location fits file(s)
  file_nr=0
  first_run=1
  foreach flare, asw_ql_flare_flag_location do begin
    
    cur_time = anytim(!stime, /ccsds)
    tstamp = strmid(cur_time, 0, 4)+strmid(cur_time, 5, 2)+strmid(cur_time, 8, 2)+strmid(cur_time, 11, 2)+strmid(cur_time, 14, 2)
    
    file_flare_flag = output_dir+'/solo_LL01_stix-flareinfo_'+trim(obt_beg)+'_'+trim(file_nr)+'.fits'
    if first_run then begin
      file_flare_flag = output_dir+'/solo_LL01_stix-flareinfo_'+trim(string(obt_beg, format='(I010)'))+'-'+trim(string(obt_end, format='(I010)'))+'V'+tstamp+'C.fits'
      first_run=0
    endif
    err=stx_asw2fits(flare,file_flare_flag,obt_beg=obt_beg,obt_end=obt_end,history=trim(svn_number))
    if err eq 0 then fail=1
  endforeach

  fail = 0
END
