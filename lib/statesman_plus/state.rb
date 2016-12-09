require_relative "assistance/string"
require_relative "assistance/array"

module StatesmanPlus
  class State
    def initialize(*args) end

    class << self
      def to_sym
        self.name.underscore.to_sym
      end

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

      def before_save(*args) end

      def after_save(*args) end

      def enter(*args) end

      def exit(*args) end
    end
  end
end
