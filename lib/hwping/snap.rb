require 'opencv'

module HWPing
  class Snap
    include OpenCV

    attr_reader :img

    def initialize(options = {})
      format = options.fetch('format', 'jpg')
      @dir = options.fetch('base', './tmp')
      @path = "image.#{format}"

      c = CvCapture.open
      c.width = options.fetch('width', 640)
      c.height = options.fetch('height', 480)

      @img = c.query
      c.close
    end

    def self.snap(options = {})
      new(options).save
    end

    def save
      @img.save(File.join(@dir, @path))
      @path
    end
  end
end
