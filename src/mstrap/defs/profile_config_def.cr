module MStrap
  module Defs
    class ProfileConfigDef
      YAML.mapping(
        name: {
          type: String,
          nilable: false
        },
        path: {
          type: String,
          nilable: true,
          default: nil
        },
        revision: {
          type: String,
          nilable: true,
          default: nil
        },
        url: {
          type: String,
          nilable: true,
          default: nil
        }
      )
    end
  end
end
