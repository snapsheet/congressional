require 'descendants_tracker'

require_relative "assistance/string"
require_relative "assistance/array"

module StatesmanPlus
  class State
    extend DescendantsTracker

    def initialize(*args) end

    class << self
      def to_sym
        self.name.underscore.to_sym
      end

      def initial
        @initial_state = true
      end

      def initial?
        @initial_state == true
      end

      def to(args)
        @to_states = args
      end

      def to_states
        @to_states.map{|sym| sym.to_s.pascal.constant}
      end

      def before_save(*args) end

      def after_save(*args) end

      def enter(*args) end

      def exit(*args) end
    end
  end
end
