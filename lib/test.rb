require "final_destination"

class FinalDestination::Resolver
  @mutex = Mutex.new
  def self.lookup(addr, timeout: nil)
    Rails.logger.warn "======== OpenIdResolverLookup Override ========="
    timeout = 30
    @mutex.synchronize do
      @result = nil

      @queue ||= Queue.new
      @queue << ""
      ensure_lookup_thread

      @lookup = addr
      @parent = Thread.current

      # This sleep will be interrupted by the lookup thread
      # if completed within timeout
      sleep timeout
      if !@result
        @thread.kill
        @thread.join
        @thread = nil
        if @error
          @error.backtrace.push(*caller)
          raise @error
        else
          raise Timeout::Error
        end
      end
      @result
    end
  end

  private

  def self.ensure_lookup_thread
    return if @thread&.alive?

    @thread = Thread.new do
      while true
        @queue.deq
        @error = nil
        begin
          @result = Addrinfo.getaddrinfo(@lookup, 80, nil, :STREAM).map(&:ip_address)
        rescue => e
          @error = e
        end
        @parent.wakeup
      end
    end
    @thread.name = "final-destination_resolver_thread"
  end
end
