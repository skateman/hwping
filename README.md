# hwping
IRC bot for HW pinging with the Dream Cheeky Thunder missile launcher.

## Installation
The bot was tested on ruby 2.0.0-p643, but it should work with other versions.
```bash
cp config_sample.yml config.yml
bundle install
```

### Configuration
The bot uses `config.yml` as a configuration file, which is automatically saved upon exit. It has some default settings, so it will even run without it. For all available settings see the `config_sample.yml` file.

## Usage
```bash
bundle exec ruby hwping.rb
```
It's important that the bot will react only when an authorized user (specified in the configuration file) sends him a message!

### Channel message commands:
- `hwping <nick>` - fire a rocket at &lt;nick&gt; when he has been set as a target and is present in the channel's user list
- `hwping joke` - calls the api from icndb.com to tell a random fact about &lt;botnick&gt;

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
- Specify different configuration file using an argument
- Add a superuser to modify the list of authorized users during runtime
- Convert to gem with `$PATH` executable
- Tests & travis compatibility

## Credits
The launcher code in `lib/launcher.rb` was inspired by [robhurring/thunder](https://github.com/robhurring/thunder).
