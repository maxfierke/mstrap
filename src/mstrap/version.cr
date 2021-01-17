module MStrap
  # Date and time when binary was compiled
  COMPILED_AT = {{`date -u`.chomp.stringify}}

  # `mstrap` version
  VERSION = "0.2.8"
end
