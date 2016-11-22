module StatesmanPlus
  class State
    class << self
      def descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def initial
        @initial_state = true
      end

      def initial?
        @initial_state == true
      end

      def to(*args)
        @to_states = args
      end

      def to_states
        @to_states
      end

      # if active record is being used
      def before_save(reference, from) end

      # if active record is being used
      def after_save(reference, from) end

      def enter(reference, from) end

      def exit(reference, from) end
    end
  end
end
