# frozen_string_literal: true

require_relative 'route_helper/init.rb'

Dir.glob("#{__dir__}/*.rb").each do |file|
  require file
end

require_relative 'routes/init.rb'
