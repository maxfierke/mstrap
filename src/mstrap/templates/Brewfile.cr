module MStrap
  # :nodoc:
  module Templates
    class Brewfile
      ECR.def_to_s "#{__DIR__}/Brewfile.ecr"
    end
  end
end
