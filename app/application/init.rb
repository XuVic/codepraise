# frozen_string_literal: true

folders = %w[values decorators forms representers services controllers]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
