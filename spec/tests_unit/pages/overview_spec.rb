# frozen_string_literal: true

require_relative '../../helpers/appraisal_helper.rb'

describe Views::Overview do
  before do
    appraisal = AppraisalHelper.build_appraisal
    @page = Views::PageFactory.create_page(appraisal, 'overview')
  end

  it 'debugging' do
    binding.pry
  end

  describe '#a_board' do
    it 'should have some elements' do
      _(@page.a_board.elements).wont_be_empty
      _(@page.a_board.elements[:elements].map(&:to_element)).wont_be_empty
    end
  end

  describe '#b_board' do
    it 'should have some elements' do
      _(@page.b_board.elements).wont_be_empty
      _(@page.b_board.elements.map(&:to_element)).wont_be_empty
    end
  end

  describe '#c_board' do
    it 'should have some elements' do
      _(@page.c_board.elements).wont_be_empty
      _(@page.c_board.elements[:elements].map(&:to_element)).wont_be_empty
    end
  end

  describe '#d_board' do
    it 'should have some elements' do
      _(@page.d_board.elements).wont_be_empty
      _(@page.d_board.elements.map(&:to_element)).wont_be_empty
    end
  end
end
