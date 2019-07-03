module ObJson
  def method_missing(method, *args)
    return super unless self.respond_to?(:key?) and self.respond_to?(:[])
    if self.key? method
      self[method]
    elsif self.key? method.to_s
      self[method.to_s]
    else
      super
    end
  end
end

