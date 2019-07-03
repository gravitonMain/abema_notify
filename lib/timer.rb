class Timer
  def initialize at_time = nil
    @at = at_time
  end
  
  def run at_time = nil, &block
    @at = at_time if at_time
    sec = @at - Time.now
    Thread.new do
      sleep sec
      block.call
    end
  end
end
