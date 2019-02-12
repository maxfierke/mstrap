module MStrap
  module Utils
    define_language_env Nodenv, :nodenv, :node
    define_language_env Pyenv,  :pyenv,  :python
    define_language_env Rbenv,  :rbenv,  :ruby
  end
end
