module MStrap
  class User
    @name : String
    @email : String
    @github : String

    # Returns name of user
    getter :name

    # Returns email address of user
    getter :email

    # Returns GitHub user account
    getter :github

    def initialize(user : Defs::UserDef)
      @name = user.name.not_nil!
      @email = user.email.not_nil!
      @github = user.github.not_nil!
    end

    def initialize(@name, @email, @github)
    end
  end
end
