module Utils

  def self.send(model, callback)
  # model -> Object (Block, User, ...)
  # callback -> ["method", params* ] ( ex: ["create", {name: "bot"}] )
  #
  #################
  # Usage example #
  #################
  #
  # args = {name: 1}
  #   # one object, simple json datatypes
  # callback = ['create', args]
  #   # 'create' is a method name for an object, but as a string
  #   # so callback can be safely serialized
  #
  # Worker.perform_async(callback)
  #
  # Utils.send(User, callback)
  #   # gives you `User.create(name: 1)`
  #
    model.__send__ *callback unless callback.nil?
  end

  def self.strip_if_leading_character(string, character)
  # string -> string ('@cats' or '#cats' or 'cats')
  # character -> string ('#' or '@')
    string[0] == character ? string[1..string.length] : string
  end

  def Utils.id_from_twitter_auth(user)
  # user => MetaTwitter::Auth.config
    user.access_token.split('-')[0]
  end

  def self.read_id_from_ENV
    Utils.id_from_twitter_auth(TwitterClient)
  end

end
