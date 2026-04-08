class EventBus
  def initialize
    $event_bus = self
    @listeners = Hash.new { |h, k| h[k] = [] }
  end

  def subscribe(event_name, owner = nil, &code_block)
    @listeners[event_name] << { owner: owner, block: code_block }
  end

  def publish(event_name, payload = {})
    return unless @listeners[event_name]
    @listeners[event_name].each { |listener| listener[:block].call(payload) }
  end

  def unsubscribe_owner(owner)
    @listeners.each_value { |listener| listener.reject! { |h| h[:owner] == owner } }
  end


end