module HWPing
  class HWPing
    attr_reader :bot

    def initialize(config = {})
      @config = Config.new(config)
      @launcher = Launcher.connect
      @handler = Handler.new(@launcher, @config)
      @bot = Bot.new(@handler, @config)
    end

    def start
      @bot.start
    end

    def stop
      @bot.stop
    end

    # Return the configuration hash for an export
    def config
      @config.to_hash
    end
  end
end
