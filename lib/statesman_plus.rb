require "statesman_plus/version"
require "statesman"

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def pascal
    self.gsub(/^\w/, &:upcase).
    gsub(/_+([a-z])/, &:upcase).
    gsub(/_+/,'')
  end

  def constant
    Object.const_get(self)
  end
end

module StatesmanPlus
  class State
    class << self
      def to(*args)
        puts args
      end

      def enter(reference)
      end

      def before_save(reference, from)
      end

      def after_save(reference, from)
      end

      def exit(reference, from)
      end
    end
  end

  module Mechanize
    def self.included(base)
      # if active record is being used
      # and not already being included
      # include Statesman::Adapters::ActiveRecordQueries

      # create the transition class
      # unless the transition is explicitly defined
      Object.const_set(
        "#{base.name}Transition",
        Class.new {
          # if active record is being used
          # include Statesman::Adapters::ActiveRecordTransition
        }
      )

      # if active record is being used
      # and not already being included
      # has_many (base.name.underscore+"_transitions").to_sym

      # create the state machine class based on states
      # unless the state machine is explicitly defined
      Object.const_set(
        "#{base.name}StateMachine",
        Class.new {
          include Statesman::Machine
        }
      )

      # Initialize the newly created state machine
      def state_machine
        @state_machine ||= "#{base.name}StateMachine".constant.new(
          base,
          transition_class: "#{base.name}Transition".constant,
          association_name: :transitions
        )
      end
    end
  end
end
