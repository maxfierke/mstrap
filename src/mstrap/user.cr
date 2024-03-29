module MStrap
  class User
    @name : String
    @email : String
    @github : String?

    # Returns name of user
    getter :name

    # Returns email address of user
    getter :email

    # Returns GitHub user account
    getter :github

    def initialize(user : Defs::UserDef)
      @name = user.name || ""
      @email = user.email || ""
      @github = user.github
    end

    def initialize(@name, @email, @github = nil)
    end
  end
end
