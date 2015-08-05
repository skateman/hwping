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
          if @targets.include?($1)
            @launcher.point_and_fire(@targets[$1])
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
        when "fire"
          @launcher.fire
          return [:fire]
        when "position"
          return @launcher.position.unshift(:position)
        when "help"
          return [:help]
        when "reset"
          @launcher.reset
          return [:reset]
        when "target list"
          return [:target_list, @targets.keys.join(', ')]
        when /^target set ([^\s]+)( (\d+) (\d+))?$/
          @targets[$1] = $2 ? [$3.to_i, $4.to_i] : @launcher.position
          return [:target_set, @targets[$1]].flatten
        when /^target ((get)|(del)) ([^\s]+)$/
          if @targets.has_key?($+)
            if $1 == "del"
              @targets.delete($+)
              return [:target_del]
            else
              return [:target_get, @targets[$+]].flatten
            end
          else
            return [:notarget]
          end
        when /^((up)|(down)|(left)|(right)) (\d+)$/
          @launcher.send($1, $+.to_i)
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
      return false
    end
  end
end
