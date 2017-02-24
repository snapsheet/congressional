require 'spec_helper'


class BookReportCreated < StatesmanPlus::State
  initial
  to [:book_report_complete, :book_report_cancelled]
end

class BookReportComplete < StatesmanPlus::State
  to [:book_report_cancelled]
end

class BookReportCancelled < StatesmanPlus::State
  to [:book_report_complete]
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
      correct_states = [BookReportCreated, BookReportComplete, BookReportCancelled]
      state_names = correct_states.map {|s| s.name.underscore}
      expect(report.state_machine.class.state_classes - correct_states).to eq []
      expect(correct_states - report.state_machine.class.state_classes).to eq []
    end

    it 'can transition' do
      expect(report.current_state).to eq BookReportCreated
      report.transition_to BookReportComplete
      expect(report.current_state).to eq BookReportComplete
    end
  end
end
