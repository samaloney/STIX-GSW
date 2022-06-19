;+
;
; name:
;       stx_read_aux_fits
;
; :description:
;    Read the values contained in an auxiliary fits file and returns a correponding 'stx_aux_data' structure
;
;
; :categories:
;    fits, io
;
; :params:
;    fits_path : in, required, type="string"
;                the path of the FITS file to be read. Passed through to mrdfits.
;
;
; :keywords:
;
;    primary_header : out, type="string array"
;               an output float value;
;
;    data_header : out, type="string array"
;              The header of the data extension of the auxiliary file
;
;    data_str : out, type="structure"
;              The contents of the data extension of the auxiliary file
;
;    control_header : out, type="string array"
;                The header of the control extension of the auxiliary file
;
;    control_str : out, type="structure"
;               The contents of the control extension of the auxiliary file
;               
;    idb_version_header : out, type="string array"
;               The header of the idb version extension of the auxiliary file
;               
;    idb_version_str : out, type="structure"
;               The contents of the idb version extension of the auxiliary file
;
; :returns:
;
;    a 'stx_aux_data' structure containing the values read from an auxiliary fits file
;
; :examples:
;
;    stx_read_aux_fits, fits_path, aux_data=aux_data
;
; :history:
;
;    May 1, 2022: Massa P. (MIDA, Unige), created
;
;-

pro stx_read_aux_fits, fits_path, aux_data=aux_data, primary_header = primary_header, data_str = data, data_header = data_header, control_str = control, $
  control_header= control_header, idb_version_str = idb_version, idb_version_header = idb_version_header 

  !null       = stx_read_fits(fits_path, 0, primary_header,  mversion_full = mversion_full)
  control     = stx_read_fits(fits_path, 'control', control_header, mversion_full = mversion_full)
  data        = stx_read_fits(fits_path, 'data', data_header, mversion_full = mversion_full)
  idb_version = stx_read_fits(fits_path, 'idb_versions', idb_version_header, mversion_full = mversion_full)
  
  ;**** Read the values that are closer to 'time_in'
  n_time_steps = n_elements(data)
  aux_data = replicate(stx_aux_data(),  n_time_steps)
  
  aux_data.time_utc                   = data.time_utc
  aux_data.spice_disc_size            = data.spice_disc_size
  aux_data.y_srf                      = data.y_srf
  aux_data.z_srf                      = data.z_srf
  aux_data.solo_loc_carrington_lonlat = data.solo_loc_carrington_lonlat
  aux_data.solo_loc_carrington_dist   = data.solo_loc_carrington_dist
  aux_data.solo_loc_heeq_zxy          = data.solo_loc_heeq_zxy
  aux_data.roll_angle_rpy             = data.roll_angle_rpy
  
;  ;Select the time closer to 'time_in'
;  dummy_min = min(abs(anytim(time_data) - anytim(time_in)), ind_min)
;  
;  
;  
;  ; Aspect solution
;  Y_SRF = data[ind_min].Y_SRF
;  Z_SRF = data[ind_min].Z_SRF
;  ;Apparent solar radius (arcsec)
;  RSUN = data[ind_min].spice_disc_size
;  ;Roll angle (degrees)
;  ROLL_ANGLE = data[ind_min].ROLL_ANGLE_RPY[0]
;  ;Pitch (arcsec)
;  PITCH = data[ind_min].ROLL_ANGLE_RPY[1] * 3600.
;  ;Yaw (arcsec)
;  YAW = data[ind_min].ROLL_ANGLE_RPY[2] * 3600.
;  ;L0 (degrees)
;  L0 = data[ind_min].solo_loc_carrington_lonlat[0]
;  ;B0 (degrees)
;  B0 = data[ind_min].solo_loc_carrington_lonlat[1]
;  
;  aux_data = {Y_SRF: Y_SRF, $
;              Z_SRF: Z_SRF, $
;              RSUN: RSUN, $
;              ROLL_ANGLE: ROLL_ANGLE, $
;              PITCH: PITCH, $
;              YAW: YAW, $
;              L0: L0, $
;              B0: B0}
              

end