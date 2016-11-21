require 'spec_helper'

class EstimateComplete < StatesmanPlus::State
end

class EstimateCreated < StatesmanPlus::State
  to EstimateComplete
end

class BookReport
  include StatesmanPlus::Mechanize
end

describe StatesmanPlus do
  it 'has a version number' do
    expect(StatesmanPlus::VERSION).not_to be nil
  end

  context "states will create a machine for included classes" do
    report = new BookReport
    it 'does something useful' do
    end
  end
end
