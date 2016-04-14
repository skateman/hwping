require 'hwping/webcam.so'

module HWPing
  class Webcam
    def initialize(options = {})
      @dir = options.fetch('path', './tmp')
      @path = 'image.jpg'
    end

    def save
      write(File.join(@dir, @path))
      @path
    end

    def self.panorama(images, options = {})
      pano = stitch(images)
      pano.instance_variable_set(:@dir, options.fetch('path', './tmp'))
      pano.instance_variable_set(:@path, 'image.jpg')
      pano
    end
  end
end
