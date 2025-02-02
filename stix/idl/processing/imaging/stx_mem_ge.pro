FUNCTION stx_mem_ge,vis,imsize,pixel,aux_data,silent=silent, total_flux=total_flux, percent_lambda=percent_lambda

  ; wrapper around MEM_GE
  ; output map structure has north up
  ;
  ; 10-Sep-2021: Paolo Massa: first version
  
  default, percent_lambda, stx_mem_ge_percent_lambda(stx_vis_get_snr(vis))
  default, silent, 0

  if ~keyword_set(total_flux) then total_flux=vis_estimate_flux(vis, imsize[0]*pixel[0], silent=silent) ;estimate of the total flux of the image
  mem_ge_im = mem_ge(vis, total_flux, percent_lambda=percent_lambda, imsize=imsize, pixel=pixel, silent=silent, makemap=0)
  mem_ge_map = make_map(mem_ge_im)
  this_estring=strtrim(fix(vis[0].energy_range[0]),2)+'-'+strtrim(fix(vis[0].energy_range[1]),2)+' keV'
  mem_ge_map.ID = 'STIX MEM_GE '+this_estring+': '
  mem_ge_map.dx = pixel[0]
  mem_ge_map.dy = pixel[1]
  
  this_time_range=stx_time2any(vis[0].time_range,/vms)
     
  mem_ge_map.time = anytim((anytim(this_time_range[1])+anytim(this_time_range[0]))/2.,/vms)
  mem_ge_map.DUR = anytim(this_time_range[1])-anytim(this_time_range[0])
  
  ;rotate map to heliocentric view
  mem__ge_map=mem_ge_map
  mem__ge_map.data=rotate(mem_ge_map.data,1)
  
  ; Compute the mapcenter
  this_mapcenter = vis[0].xyoffset + aux_data.stx_pointing

  mem__ge_map.xc = this_mapcenter[0]
  mem__ge_map.yc = this_mapcenter[1]
  mem__ge_map=rot_map(mem__ge_map,-aux_data.ROLL_ANGLE,rcenter=[0.,0.])
  mem__ge_map.ROLL_ANGLE = 0.
  add_prop,mem__ge_map,rsun = aux_data.RSUN
  add_prop,mem__ge_map,B0   = aux_data.B0
  add_prop,mem__ge_map,L0   = aux_data.L0
  
  return,mem__ge_map

END