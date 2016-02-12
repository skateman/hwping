require 'cinch'

module HWPing
  class Bot
    MESSAGES = {
      :unauthorized => "Sorry, you're unauthorized to use this bot!",
      :firing       => 'Firing rocket in 5 seconds!',
      :notarget     => 'Unknown target!',
      :fire         => 'Rocket launch initiated!',
      :reset        => 'Launcher set back to default position!',
      :position     => 'Current position: %d %d',
      :target_list  => 'Available targets: %s',
      :target_get   => "Target's position: %d %d",
      :target_del   => 'Target successfully deleted!',
      :target_set   => "Target's position saved at: %d %d",
      :move         => 'Move operation finished!',
      :badcommand   => "Unknown command, type 'help' for further information!",
      :help         => "Hardware Pinger\n
        Usage in a channel: hwping <target>\n
        Available commands in private:\n
          help\n
          fire\n
          position\n
          up|down|left|right\n
          reset\n
          target list\n
          target set <nick> <right> <up>\n
          target get <nick>\n
          target del <nick>\n"
    }.freeze

    # Initialize a bot and return with its Cinch instance
    def initialize(handler, config = {})
      @bot = Cinch::Bot.new do
        configure do |c|
          c.nick     = config.nick
          c.server   = config.server
          c.port     = config.port
          c.channels = config.channels.map { |m| "\##{m}" }
        end

        # For channel mesages, just reply with the matching message
        on :channel, /^hwping/ do |e|
          r = handler.channel(e)
          e.reply(MESSAGES[r])
        end

        # For private messages, build a reply message from the format strinc and the passed variables
        on :private do |e|
          (r, *f) = handler.private(e)
          e.reply(MESSAGES[r] % f)
        end
      end
    end

    # Start the bot
    def start
      @bot.start
    end

    # Stop the bot
    def stop
      @bot.quit
    end
  end
end
