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

class Array
  def to_sym
    self.map {|c| c.name.underscore.to_sym}
  end
end

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

      # if active record is being used
      def before_save(*args) end

      # if active record is being used
      def after_save(*args) end

      def enter(*args) end

      def exit(*args) end
    end
  end
end
