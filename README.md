# hwping
IRC bot for HW pinging with the Dream Cheeky Thunder missile launcher.

## Installation
The bot was tested on **ruby 2.0.0-p643**, but it should work with other versions. It uses `libusb` for the USB communication and `cinch` as the IRC client.
```bash
gem install hwping
```

## Usage
```bash
hwping [options]
```

### Configuration
The bot uses `./config.yml` as a configuration file, which is automatically saved upon exit. An alternative configuration file can be specified with the `-c/--config-file` argument.

The default settings are those:

```yaml
---
nick: hwping
server: irc.freenode.net
port: 6667
channels: # an array of channels to listen without the beginning # symbol
  - hwping-test
auth_nicks: # an array of nicks to obey
targets: # a hash in {nick => [x, y]} format specifying the possible targets
```

### Channel message commands:
- `hwping <nick>` - fire a rocket at &lt;nick&gt; when he has been set as a target and is present in the channel's user list

### Private message commands:
- `help` - displays a help text
- `fire` - fires a rocket
- `reset` - resets the launcher into the default position (bottom-left)
- `position` - returns the actual position of the rocket launcher
- `<direction> <ms>` - rotates the launcher into the given direction (up, down, left, right) for the given milliseconds
- `target list` - displays the list of the available targets
- `target get <nick>` - displays the coordinates of &lt;nick&gt;
- `target del <nick>` - deletes the coordinates of &lt;nick&gt;
- `target set <nick>` - sets the coordinates of &lt;nick&gt; to the actual position
- `target set <nick> <X> <Y>` - sets the coordinates of &lt;nick&gt; to right(X), up(Y)

## TODO
- Listen to a nick other than `hwping`
- High-precision timer for better positioning
- Event-based solution instead of threads
- Add a superuser to modify the list of authorized users during runtime

## License
This project is released under the GPLv2 license.

## Credits
The launcher code in `lib/hwping/launcher.rb` was inspired by [robhurring/thunder](https://github.com/robhurring/thunder).

