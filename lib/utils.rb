module Utils

  def self.send(model, callback)
  # model -> Object (Block, User, ...)
  # callback -> ["method", params* ] ( ex: ["create", {name: "bot"}] )
    model.__send__ *callback unless callback.nil?
  end

  def self.strip_if_leading_character(string, character)
  # string -> string ('@cats' or '#cats' or 'cats')
  # character -> string ('#' or '@')
    string[0] == character ? string[1..string.length] : string
  end

  def self.id_from_access_token(user)
  # user => MetaTwitter::Auth.config
    user.access_token.split('-')[0]
  end

  def self.read_id_from_ENV
    Utils.id_from_access_token(TwitterClient)
  end

end
