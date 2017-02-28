require "statesman"
require_relative "assistance/string"
require_relative "assistance/array"

module StatesmanPlus::Mechanize
  def state_machine
    @state_machine ||= "#{self.class}StateMachine".constant.new(
      self
    )
  end

  def states
    self.state_machine.class.states
  end

  def current_state
    self.state_machine.current_state.pascal.constant unless self.state_machine.current_state.nil?
  end

  def transition_to?(state)
    self.state_machine.transition_to? state.to_sym
  end

  def transition_to!(state)
    self.state_machine.transition_to! state.to_sym
  end

  def transition_to(state)
    self.state_machine.transition_to state.to_sym
  end

  def self.included(base)
    include Statesman::Adapters::ActiveRecordQueries

    define_transition_class base
    define_state_machine_class base
    set_state_machine_relations base

    has_many (base.name.underscore+"_transitions").to_sym if self.respond_to? :has_many
    before_save :send_before_save, :if => Proc.new { |e| e.changed? } if self.respond_to? :before_save
    after_save :send_after_save, :if => Proc.new { |e| e.changed? } if self.respond_to? :after_save
  end

  def self.define_state_machine_class(base)
    Object.const_set(
      "#{base.name}StateMachine",
      Class.new {
        include Statesman::Machine

        def reload_state_machine
          @state_machine = self.class.state_machine_class.new(self, transition_class: self.class.transition_class)
        end

        def send_before_save
          self.send_state_machine_event('before_save')
        end

        def send_after_save
          self.send_state_machine_event('after_save')
        end

        def send_state_machine_event(name, attempts = 5)
          begin
            ActiveRecord::Base.transaction do
              self.reload_state_machine.send(name)
            end
          rescue Statesman::TransitionConflictError, ActiveRecord::RecordNotUnique => e
            # TransitionConflictError due to race condition.
            # One example is delayed jobs running at the same time.
            # If this happens, retry the event so it is captured in the correct state.
            if attempts > 0
              Rails.env.warning("TransitionConflictError OR RecordNotUnique OCCURRED. Retrying => #{e.message}")
              self.send_state_machine_event(name, attempts - 1)
            else
              raise e
            end
          rescue ActiveRecord::StatementInvalid => e
            if (e.message =~ /Deadlock/) && (attempts > 0)
              Rails.env.warning("DEADLOCK OCCURRED. Retrying => #{e.message}")
              self.send_state_machine_event(name, attempts - 1)
            else
              raise e
            end
          end
        end

        def before_save
          self.current_state.before_save
        end

        def after_save
          self.current_state.after_save
        end

        # def method_missing(name, *args, &block)
        #   self.current_state.send(name, self.object, *args) if self.current_state.respond_to? name
        # end

        self.define_singleton_method :state_classes do
          StatesmanPlus::State.descendants.select {|state| state.constituents.include? base.to_s.underscore.to_sym}
        end

        before_transition do |reference, transition|
          "#{reference.state_machine.class}::#{reference.state_machine.current_state.pascal}".constant.exit(reference, transition)
        end

        after_transition do |reference, transition|
          "#{reference.state_machine.class}::#{reference.state_machine.current_state.pascal}".constant.enter(reference, transition)
        end
      }
    )
  end
  private_class_method :define_state_machine_class

  def self.set_state_machine_relations(base)
    state_machine_class = "#{base.name}StateMachine".constant

    state_machine_class.state_classes.each do |state_class|
      if state_class.initial?
        state_machine_class.state state_class.to_sym, initial: true
      else
        state_machine_class.state state_class.to_sym
      end
    end

    state_machine_class.state_classes.each do |state_class|
      unless state_class.to.nil? || state_class.to.empty?
        state_machine_class.transition from: state_class.to_sym, to: state_class.to.to_sym
      end
    end
  end
  private_class_method :set_state_machine_relations

  def self.define_transition_class(base)
    transition_class = Class.new {}
    if defined? ActiveRecord::Base
      transition_class = Class.new(ActiveRecord::Base) {
        include Statesman::Adapters::ActiveRecordTransition if self.respond_to? :serialize
        if self.respond_to? :belongs_to
          belongs_to base.name.underscore.to_sym, inverse_of: (base.name.underscore+"_transitions").to_sym
        end
      }
    end

    Object.const_set("#{base.name}Transition", transition_class)
  end
  private_class_method :define_transition_class

  def self.transition_class
    "#{base.name}Transition".constant
  end

  def self.initial_state
    "#{base.name}StateMachine".constant.initial_state
  end
end
