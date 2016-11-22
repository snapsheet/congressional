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

module StatesmanPlus::Mechanize
  def state_machine
    @state_machine ||= "#{self.class}StateMachine".constant.new(
      self,
      transition_class: "#{self.class}Transition".constant,
      association_name: :transitions
    )
  end

  def states
    self.state_machine.class.states
  end

  def self.included(base)
    # enable if active record is being used
    # include Statesman::Adapters::ActiveRecordQueries

    define_transition_class base
    define_state_machine_class base
    # set_state_machine_relations base

    # class << base
    #   alias_method :__new, :new
    #   def new(*args)
    #     e = __new(*args)
    #     e.after_init
    #     e
    #   end
    # end

    # if active record is being used
    # and not already being included
    # has_many (base.name.underscore+"_transitions").to_sym
  end

  def self.define_state_machine_class(base)
    # create the state machine class based on states
    # unless the state machine is explicitly defined
    Object.const_set(
      "#{base.name}StateMachine",
      Class.new {
        include Statesman::Machine

        self.define_singleton_method :states do
          @states ||= StatesmanPlus::State.descendants.select { |child| (/^#{base.name}/ =~ "#{child}") == 0}
        end

        before_transition do |reference, transition|
          "#{reference.state_machine.class}::#{reference.state_machine.current_state.pascal}".constant.exit(reference)
        end

        after_transition do |reference, transition|
          "#{reference.state_machine.class}::#{reference.state_machine.current_state.pascal}".constant.enter(reference)
        end
      }
    )
  end
  private_class_method :define_state_machine_class

  def self.set_state_machine_relations(base)
    state_machine_class = "#{base.name}StateMachine".constant

    state_machine_class.states.each do |state_class|
      state_sym = state_class.name.underscore.to_sym
      to_states_sym = state_class.to_states.map {|c| c.name.underscore.to_sym} if state_class.to_states.any?
      if state_class.initial?
        state_machine_class.state state_sym, initial: true
      else
        state_machine_class.state state_sym
      end

      state_machine_class.transition from: state_sym, to: to_states_sym if to_states_sym.any?
    end
  end
  private_class_method :set_state_machine_relations

  def self.define_transition_class(base)
    # create the transition class
    # unless the transition is explicitly defined
    Object.const_set(
      "#{base.name}Transition",
      Class.new {
        # if active record is being used
        # include Statesman::Adapters::ActiveRecordTransition
        # belongs_to base.name.underscore.to_sym, inverse_of: (base.name.underscore+"_transitions").to_sym
      }
    )
  end
  private_class_method :define_transition_class

  def self.transition_class
    "#{base.name}Transition".constant
  end
  private_class_method :transition_class

  def self.initial_state
    "#{base.name}StateMachine".constant.initial_state
  end
  private_class_method :initial_state
end
