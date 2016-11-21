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

      # if active record is being used
      def before_save(reference, from) end

      # if active record is being used
      def after_save(reference, from) end

      def enter(reference, from) end

      def exit(reference, from) end
    end
  end

  module Mechanize
    def self.included(base)
      # create the transition class
      # unless the transition is explicitly defined
      Object.const_set(
        "#{base.name}Transition",
        Class.new {
          # if active record is being used
          # include Statesman::Adapters::ActiveRecordTransition
        }
      )

      # create the state machine class based on states
      # unless the state machine is explicitly defined
      Object.const_set(
        "#{base.name}StateMachine",
        Class.new {
          include Statesman::Machine

          before_transition do |reference, transition|
            "#{reference.state_machine.class}::#{reference.state_machine.current_state.pascal}".constant.exit(reference)
          end

          after_transition do |reference, transition|
            "#{reference.state_machine.class}::#{reference.state_machine.current_state.pascal}".constant.enter(reference)
          end
        }
      )

      # if active record is being used
      # and not already being included
      # has_many (base.name.underscore+"_transitions").to_sym
    end

    def tofu
      "yummy"
    end

    def state_machine
      @state_machine ||= "#{self.name}StateMachine".constant.new(
        self,
        transition_class: "#{self.name}Transition".constant,
        association_name: :transitions
      )
    end
  end
end
