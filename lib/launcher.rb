# Inspired by https://github.com/robhurring/thunder/blob/master/lib/launcher.rb
require 'libusb'

class Launcher

  DeviceNotFoundError = Class.new(IOError)

  DEVICE = {
    :vendor_id  => 0x2123,
    :product_id => 0x1010
  }

  COMMANDS = {
    :down  => 0x01,
    :up    => 0x02,
    :left  => 0x04,
    :right => 0x08,
    :fire  => 0x10,
    :stop  => 0x20,
    :on    => 0x01,
    :off   => 0x00
  }

  TARGETS = {
    :launcher => 0x02,
    :led      => 0x03
  }

  REQUEST_TYPE  = 0x21
  REQUEST       = 0x09

  def self.connect
    usb = LIBUSB::Context.new
    launcher = usb.devices(
      idVendor: DEVICE[:vendor_id],
      idProduct: DEVICE[:product_id]
    ).first

    raise DeviceNotFoundError, 'Launcher was not found.' if launcher.nil?
    new(launcher)
  end

  def initialize(device)
    @device = device
    @handle = @device.open
    @handle.detach_kernel_driver(0) if @handle.kernel_driver_active?(0)
    @x = 0
    @y = 0
  end

  def point_and_fire(arr)
    led(:on)
    reset
    right arr[0]
    up arr[1]
    fire
    led(:off)
  end

  def position
    [@x, @y]
  end

  def led(status)
    send! :led, status
  end

  def fire
    send! :launcher, :fire
    Kernel.sleep 4.5
  end

  def reset
    down(1000)
    left(6000)
    @x = 0
    @y = 0
  end

  def move(direction, duration)
    send! :launcher, direction
    Kernel.sleep duration.to_f / 1000
    send! :launcher, :stop
    update_pos direction, duration
  end

  [:up, :down, :left, :right].each do |direction|
    define_method direction do |duration|
      move direction, duration
    end
  end


private
  def send!(target, command)
    payload = build_payload(target, COMMANDS[command.to_sym])

    @handle.control_transfer(
      bmRequestType: REQUEST_TYPE,
      bRequest: REQUEST,
      wValue: 0,
      wIndex: 0,
      dataOut: payload,
      timeout: 0
    )
  end

  def build_payload(target, command)
    [TARGETS[target], command, 0, 0, 0, 0, 0, 0].pack('CCCCCCCC')
  end

  def update_pos(direction, value)
    value = value.to_i
    case direction
    when :up
      @y = [1000, @y + value].min
    when :down
      @y = [0, @y - value].max
    when :right
      @x = [6000, @x + value].min
    when :left
      @x = [0, @x - value].max
    end
  end
end
