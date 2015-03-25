#!/usr/bin/env ruby

require 'cinch'
require 'yaml'
require 'json'
require 'cgi'
require 'net/http'
require './lib/launcher'

config = YAML.load_file('config.yml')
launcher = Launcher.connect
config['nick'] = config.fetch("nick", "hwping")
config['server'] = config.fetch("server", "irc.freenode.net")
config['port'] = config.fetch("port", 6667)
config['channels'] = config.fetch("channels", [])
config['targets'] = config.fetch('targets', {})
config['auth_nicks'] = config.fetch('auth_nicks', [])

bot = Cinch::Bot.new do |bot|
  configure do |c|
    c.nick = config['nick']
    c.server = config['server']
    c.port = config['port']
    c.channels = config['channels'].map { |m| "\##{m}"}
  end

  on :channel, /^hwping,?\s+(.*)\s*/ do |e|
    next if unauthorized?(config["auth_nicks"], e)
    nick = e.message.sub(/^hwping\s+([^\s]+)\s*/, '\1')
    if bot.user_list.find(nick) && config['targets'].has_key?(nick)
      e.reply "Firing rocket at #{nick} in 5 seconds!"
      launcher.point_and_fire config['targets'][nick]
    else
      e.reply "Sorry, I can't ping #{nick}!"
    end
  end

  on :private, "help" do |e|
    next if unauthorized?(config["auth_nicks"], e)
    e.reply "Hardware Pinger"
    e.reply "Usage in channel: #{bot.nick} <target>"
    e.reply "Available commands in private:"
    e.reply "  help"
    e.reply "  fire"
    e.reply "  position"
    e.reply "  up|down|left|right <t>"
    e.reply "  reset"
    e.reply "  target list"
    e.reply "  target set <nick> <X> <Y>"
    e.reply "  target set <nick>"
    e.reply "  target get <nick>"
    e.reply "  target del <nick>"
  end

  on :private, "fire" do |e|
    next if unauthorized?(config["auth_nicks"], e)
    e.reply "Rocket launch initiated!"
    launcher.fire
  end

  on :private, "position" do |e|
    next if unauthorized?(config["auth_nicks"], e)
    p.reply launcher.position.join(" ")
  end

  on :private, /(up)|(down)|(left)|(right)/ do |e|
    next if unauthorized?(config["auth_nicks"], e)
    e.message.match(/((up)|(down)|(left)|(right)) (\d+)/) do
      launcher.send($1, $+)
      e.reply "Move finished!"
    end
  end

  on :private, "reset" do |e|
    next if unauthorized?(config["auth_nicks"], e)
    launcher.reset
    e.reply "Launcher set back to default position!"
  end

  on :private, "target list" do |e|
    next if unauthorized?(config["auth_nicks"], e)
    e.reply "Available targets: #{config['targets'].keys.join(', ')}"
  end

  on :private, /^target set ([0-9a-zA-Z_]+)( (\d)+ (\d)+)?$/ do |e|
    next if unauthorized?(config["auth_nicks"], e)
    nick = e.message.sub(/^target set ([0-9a-zA-Z_]+)( (\d)+ (\d)+)?$/, '\1')
    pos = e.message.match("\d+ \d+") ? [$1, $2] : launcher.position
    config['targets'][nick] = pos
    e.reply "Target saved!"
  end

  on :private, /^target get ([0-9a-zA-Z_]+)$/ do |e|
    next if unauthorized?(config["auth_nicks"], e)
    nick = e.message.sub(/^target get ([^\s]+)\s*/, '\1')
    if config['targets'].has_key? nick
      e.reply "Target's position: #{config['targets'][nick].join(' ')}"
    else
      e.reply "Unknown target!"
    end
  end

  on :private, /^target del ([0-9a-zA-Z_]+)$/ do |e|
    next if unauthorized?(config["auth_nicks"], e)
    nick = e.message.sub(/^target del ([^\s]+)\s*/, '\1')
    if config['targets'].has_key? nick
      config['targets'].delete nick
      e.reply "Target deleted!"
    else
      e.reply "Unknown target!"
    end
  end

end

# save configuration on exit
at_exit do
  File.open("config.yml", 'w') { |f| YAML.dump(config, f) }
end

# reply when unauthorized
def unauthorized? auth_nicks, event
  unless auth_nicks.include? event.user.to_s
    event.reply "Sorry, I can't help you!"
    return true
  end
  return false
end

bot.start
