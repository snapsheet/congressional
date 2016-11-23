require 'spec_helper'

class BookReportComplete < StatesmanPlus::State
end

class BookReportCreated < StatesmanPlus::State
  initial
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
      correct_states = [BookReportCreated, BookReportComplete]
      expect(report.state_machine.class.state_classes).to eq correct_states
      expect(report.states).to eq(correct_states.map {|s| s.name.underscore})
    end

    it 'can transition' do
      expect(report.current_state).to eq BookReportCreated
      report.transition_to BookReportComplete
      expect(report.current_state).to eq BookReportComplete
    end
  end
end
