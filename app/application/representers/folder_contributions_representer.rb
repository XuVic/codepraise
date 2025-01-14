# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'contributor_representer'
require_relative 'credit_share_representer'
require_relative 'file_contributions_representer'
require_relative 'line_contribution_representer'

module CodePraise
  module Representer
    # Represents folder summary about repo's folder
    class FolderContributions < Roar::Decorator
      include Roar::JSON

      property :path
      property :total_line_credits
      property :total_method_credits
      property :total_offenses
      property :total_test_expectation
      property :total_documentation
      property :line_percentage
      property :any_subfolders?
      property :any_base_files?
      property :average_complexity
      property :test_coverage
      property :credit_share, extend: Representer::CreditShare, class: OpenStruct
      collection :base_files, extend: Representer::FileContributions, class: OpenStruct
      collection :subfolders, extend: Representer::FolderContributions, class: OpenStruct
      collection :contributors, extend: Representer::Contributor, class: OpenStruct
    end
  end
end
