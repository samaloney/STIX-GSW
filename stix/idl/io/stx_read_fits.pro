;+
;
; name:
;       stx_read_fits
;
; :description:
;    Wrapper for mrdfits which handles some STIX specific FITS requirements.
;
;
; :categories:
;    fits, io
;
; :params:
;    fits_path : in, required, type="string"
;                the path of the FITS file to be read. Passed through to mrdfits.
;
;    extension : in, required, type="string" or "int"
;                The extension name or number to be read out. Passed through to mrdfits.
;
;    header    : out, type="string array"
;                The header of the requested extension
;
;
; :keywords:
;
;    silent : in, type="int", default="0"
;             If set prevents informational messages being displayed. Passed through to mrdfits.
;
; :returns:
;
;    fits_data a structure contining the FITS data for the requested extension.
;
; :examples:
;
;    data = stx_read_fits( fits_path, 'data', header, silent=1)
;
; :history:
;
;    09-Nov-2021 - ECMD (Graz), initial release
;
;-
function stx_read_fits, fits_path, extension, header, silent = silent

  default, silent, 0

  mversion_full = mrd_version()
  mversion = mversion_full.split('\.')

  fits_data = mrdfits( fits_path, extension, header, silent = silent, /unsigned )

  if ~(fix(mversion[0]) ge 2 and fix(mversion[1]) ge 27) then begin 
    ;corrections needed depend on version of mrdfits being called  

    message,'Check you have the up to date version of mrdfits compiled',/info
    message,'Avaliable at: https://github.com/wlandsman/IDLAstro/blob/master/pro/mrdfits.pro',/info
    
    header_str = fitshead2struct( header )
    zero_offsets = header.contains('TZERO')
    idx_zero_offsets = where(zero_offsets eq 1, n_zero_offsets)

    if n_zero_offsets ne 0 then begin

      data_tag_names = tag_names(fits_data)

      for i =0,n_zero_offsets-1 do begin
        remaining_offset = header_str.(idx_zero_offsets[i])  
        if remaining_offset eq 0 then continue ;some offsets present in the FITS file will already be applied 
        
        header_zero = strsplit(header(idx_zero_offsets[i]), /ex)
        variable_number = strsplit(header_zero[0],'TZERO',/ex)
        header_type_mask = header.contains('TTYPE'+variable_number)
        
        idx_type = where(header_type_mask eq 1, n_zero_offsets)
        if n_zero_offsets ne 1 then message, 'Multiple keywords found corresponding to ' + 'TTYPE'+variable_number
        ;For a given offset there should only be one FITS keyword with that type

        idx_data_to_shift = where(strupcase(data_tag_names) eq strupcase(header_str.(idx_type)), valid)
        if valid ne 1 then message, 'Multiple corresponding tags for '+ header_str.(idx_type) +' found in structure'
        ;For a given offset there should only be one corresponding tag in the data structure 
        
        offset_data =  ulong64(fits_data.(idx_data_to_shift)) + remaining_offset
        fits_data =  rep_tag_value(fits_data, offset_data, data_tag_names[idx_data_to_shift])

      endfor
    endif

  endif


  return, fits_data
end