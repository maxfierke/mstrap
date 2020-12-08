module MStrap
  # Date and time when binary was compiled
  COMPILED_AT = {{`date -u`.chomp.stringify}}

  # Git revision
  REVISION = {{`git describe --long --dirty`.chomp.stringify}}

  # `mstrap` version
  VERSION = "0.2.6"
end
