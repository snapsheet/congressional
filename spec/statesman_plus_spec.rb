require 'spec_helper'

class BookReportComplete < StatesmanPlus::State
  initial
end

class BookReportCreated < StatesmanPlus::State
  to BookReportComplete
end

class BookReport
  include StatesmanPlus::Mechanize
end

########

describe StatesmanPlus do
  it 'has a version number' do
    expect(StatesmanPlus::VERSION).not_to be nil
  end

  context "states will create a machine for included classes" do
    report = BookReport.new

    it 'has its states' do
      expect(report.states).to eq [BookReportCreated, BookReportComplete]
    end

    it 'can transition' do
      report.state_machine.transition_to(:estimate_complete)
    end
  end
end
