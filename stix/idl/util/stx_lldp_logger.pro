pro stx_lldp_logger, log, level, _extra=_extra
    default, log, ''
    default, level, 'INFO'
    
    t_stamp = anytim(systime(/utc, /sec), /ccsd)
    
    print, t_stamp+' - ['+strupcase(string(level))+'] - '+log
end 