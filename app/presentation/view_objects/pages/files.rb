# frozen_string_literal: true

require_relative 'page'

module Views
  class Files < Page
    attr_reader :root, :state, :credit_share

    def initialize(appraisal, updated_at, root = nil)
      super(appraisal, updated_at)
      @root = root.nil? ? folder : folder_filter.find_folder(root)
      @state = 'folder'
      if @root.nil?
        @root = folder_filter.find_file(root)
        @state = 'file'
      end
    end

    def a_board
      title = 'Breakdown Information'
      elements = [size_infos, structure_infos, quality_infos, ownership_infos]
      Element::Board.new(title, elements)
    end

    def b_board
      title = 'Files Ownership'
      elements = [break_down]
      Element::Board.new(title, elements)
    end

    def c_board
      title = 'Folder/File Progress'
      elements = [progress]
      Element::Board.new(title, elements)
    end

    def folder_tree
      Element::FolderTree.new(folder, project_owner, project_name, name)
    end

    def charts_update(params)
      between = params['between']&.split('_')
      unit = params['unit'] || 'day'
      [progress(unit, between)]
    end

    def break_down
      labels = []
      dataset = contributors.each_with_object({}) { |c, hash| hash[c.email_id] = [] }
      if folder?
        files = folder_filter.files(nil, root)
        files.each do |file|
          labels << file.file_path.filename
          dataset.each do |k, _|
            dataset[k] << file.line_percentage[k].to_i
          end
        end
      else
        labels << root.file_path.filename
        dataset.each do |k, _|
          dataset[k] << root.line_percentage[k].to_i
        end
      end
      options = { stacked: true, legend: true, title: 'code ownership', color: 'contributors' }
      Chart.new(labels, dataset, options, 'bar', 'break_down')
    end

    def progress(unit = 'day', between = nil)
      selected_commits = commits_filter.by(unit, between)
      selected_commits = commits_filter.by_path(name, nil, unit, between) if name != 'root'
      labels = selected_commits.map(&:date)
      max = selected_commits.map(&:total_addition_credits).max
      dataset = contributor_ids.each_with_object([]) do |email_id, result|
        selected_commits = commits_filter.by(unit, between, email_id)
        selected_commits = commits_filter.by_path(name, email_id, unit, between) if name != 'root'
        result << {
          "#{email_id} addition" => selected_commits.map(&:total_addition_credits),
          "#{email_id} deletion" => selected_commits.map { |c| c.total_deletion_credits * -1 }
        }
      end
      # dataset = {
      #   addition: commits.map(&:total_addition_credits),
      #   deletion: commits.map { |c| c.total_deletion_credits * -1 }
      # }

      options = { legend: true, color: 'multiple', title: 'folder/file progress',
                  x_type: 'time', time_unit: 'day', y_min: max * -1, stacked: true,
                  multiple: true }
      Chart.new(labels, dataset, options, 'bar', 'progress')
    end

    def size_infos
      infos = []
      infos << { name: 'Line of Code', number: root.total_line_credits }
      infos << { name: 'Number of SubFolders', number: subfolders.count }
      infos << { name: 'Number of Files', number: files.count }
      SmallTable.new('Size', infos)
    end

    def structure_infos
      infos = []
      methods_count = methods.select do |method|
        %w[def defs].include?(method.type)
      end.count
      block_count = methods.select do |method|
        method.type == 'block'
      end.count
      infos << { name: 'Number of Method', number: methods_count }
      infos << { name: 'Number of Block', number: block_count }
      Element::SmallTable.new('Structure', infos)
    end

    def quality_infos
      infos = []
      infos << { name: 'Avg. Complexity', number: avg_complexity }
      infos << { name: 'Number of Code Style Offense', number: offense_count }
      infos << { name: 'Number of Documentation', number: documentation_count }
      infos << { name: 'Test Coverage', number: "#{test_coverage}%" }
      Element::SmallTable.new('Quality', infos)
    end

    def ownership_infos
      infos = contributors.map do |c|
        {
          name: c.email_id,
          number: "#{root.line_percentage[c.email_id].to_i}%"
        }
      end
      Element::SmallTable.new('Ownership', infos)
    end

    def avg_complexity
      if folder?
        root.average_complexity.round
      else
        return '-' if root.complexity.nil?

        root.complexity.average.round
      end
    end

    def offense_count
      if folder?
        folder_filter.total_offenses(nil, root).count
      else
        return 0 if root.idiomaticity.nil?

        root.idiomaticity.offense_count
      end
    end

    def documentation_count
      root.credit_share.quality_credit['documentation_credits'].values.sum.round
    end

    def test_coverage
      return '-' unless test_coverage?

      if folder?
        (root.test_coverage * 100).round
      else
        return '-' if root.test_coverage.nil?

        (root.test_coverage.coverage * 100).round
      end
    end

    def methods
      if folder?
        folder_filter.all_methods(nil, root)
      else
        root.to_h[:methods]
      end
    end

    def subfolders
      if folder?
        root.subfolders
      else
        []
      end
    end

    def files
      if folder?
        folder_filter.files(nil, root)
      else
        [root]
      end
    end

    def name
      if state == 'folder'
        @root.path.empty? ? 'root' : @root.path
      else
        path = @root.file_path
        "#{path.directory}#{path.filename}"
      end
    end

    def folder?
      state == 'folder'
    end

    def page
      'files'
    end

    def days_count
      new_commits = commits_filter.by('day')
      new_commits = commits_filter.by_path(name, nil) if name != 'root'
      commits_filter(new_commits).all_dates.count
    end

    def first_date
      new_commits = commits_filter.by('day')
      new_commits = commits_filter.by_path(name, nil) if name != 'root'
      commits_filter(new_commits).all_dates.first.strftime('%Y/%m/%d')
    end

    def last_date
      new_commits = commits_filter.by('day')
      new_commits = commits_filter.by_path(name, nil) if name != 'root'
      commits_filter(new_commits).all_dates.last.strftime('%Y/%m/%d')
    end
  end
end
