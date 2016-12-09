class Array
  def to_sym
    self.map {|c| c.name.underscore.to_sym}
  end
end
