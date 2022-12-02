require "final_destination"

class FinalDestination::Resolver
    module OpenIdResolverLookup
        def lookup(addr, timeout: nil)
            Rails.logger.warn "======== OpenIdResolverLookup Override ========="
            timeout = 1
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
    end
    singleton_class.prepend OpenIdResolverLookup
end
