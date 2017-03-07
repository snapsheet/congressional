require 'spec_helper'


class Created < Congressional::State
  initial

  constituents :book_report
  to [:complete, :cancelled]
end

class Complete < Congressional::State
  constituents :book_report
  to [:cancelled]
end

class Cancelled < Congressional::State
  constituents :book_report
  to [:complete]
end

class BookReport
  include Congressional::Mechanize
end

class Course
end

########

describe Congressional do
  it 'has a version number' do
    expect(Congressional::VERSION).not_to be nil
  end

  context "states will create a machine for included classes" do
    report = BookReport.new

    it 'has its states' do
      correct_states = [Created, Complete, Cancelled]
      expect(report.state_machine.class.state_classes - correct_states).to eq []
      expect(correct_states - report.state_machine.class.state_classes).to eq []
    end

    it 'can transition' do
      expect(report.current_state).to eq Created
      report.transition_to Complete
      expect(report.current_state).to eq Complete
    end
  end
end
