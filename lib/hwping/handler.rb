module HWPing
  class Handler
    # Set up the handler with the configuration
    def initialize(launcher, config)
      @targets    = config.targets
      @auth       = config.auth
      @nick       = config.nick
      @launcher   = launcher
    end

    # If the event happened in a channel, return just with a symbol
    def channel(event)
      if event.message =~ /^hwping,?\s+(.*)\s*$/
        if authorized?(event.user.to_s)
          if @targets.include?(Regexp.last_match(1))
            @launcher.point_and_fire(@targets[Regexp.last_match(1)])
            return :firing
          else
            return :notarget
          end
        else
          return :unauthorized
        end
      end
    end

    # If the event happened in a private window, return with an array
    def private(event)
      if authorized?(event.user.to_s)
        case event.message
        when 'fire'
          @launcher.fire
          return [:fire]
        when 'position'
          return @launcher.position.unshift(:position)
        when 'help'
          return [:help]
        when 'reset'
          @launcher.reset
          return [:reset]
        when 'target list'
          return [:target_list, @targets.keys.join(', ')]
        when /^target set ([^\s]+)( (\d+) (\d+))?$/
          @targets[Regexp.last_match(1)] = begin
            if Regexp.last_match(2)
              [Regexp.last_match(3).to_i, Regexp.last_match(4).to_i]
            else
              @launcher.position
            end
          end
          return [:target_set, @targets[Regexp.last_match(1)]].flatten
        when /^target ((get)|(del)) ([^\s]+)$/
          if @targets.key?($+)
            if Regexp.last_match(1) == 'del'
              @targets.delete($+)
              return [:target_del]
            else
              return [:target_get, @targets[$+]].flatten
            end
          else
            return [:notarget]
          end
        when /^((up)|(down)|(left)|(right)) (\d+)$/
          @launcher.send(Regexp.last_match(1), $+.to_i)
          return [:move]
        else
          return [:badcommand]
        end
      else
        return [:unauthorized]
      end
    end

    private

    def authorized?(nick)
      @auth.each do |user|
        return true if user =~ /^#{nick}(?:\b?|\S?)/
      end
      false
    end
  end
end
