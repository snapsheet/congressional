module StatesmanPlus
  class State
    class << self
      def descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def initial(*args) end
      def to(*args) end

      # if active record is being used
      def before_save(reference, from) end

      # if active record is being used
      def after_save(reference, from) end

      def enter(reference, from) end

      def exit(reference, from) end
    end
  end
end
