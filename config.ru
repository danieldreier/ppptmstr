# Run app using rackup -p 4567

require './ppptmstr'

use Rack::Reloader
run Ppptmstr
