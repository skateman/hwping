module HWPing
  class Config

    attr_reader   :server
    attr_reader   :port
    attr_reader   :nick
    attr_reader   :channels
    attr_reader   :auth
    attr_accessor :targets

    def initialize(hash = {})
      @server   = hash.fetch(:server,   'irc.freenode.net')
      @port     = hash.fetch(:port,     6667)
      @nick     = hash.fetch(:nick,     'hwping')
      @channels = hash.fetch(:channels, ['hwping-test'])
      @auth     = hash.fetch(:auth    , [])
      @targets  = hash.fetch(:targets,  [])
    end

    def to_hash
      Hash[instance_variables.map { |name| [name[1..-1], instance_variable_get(name)] }]
    end
  end
end