require "final_destination"

class FinalDestination::Resolver
    module OpenIdResolverLookup
        def lookup(addr, timeout: nil)
            Rails.logger.debug("======== OpenIdResolverLookup Override =========")
            super(addr,20);                
        end
    end
    prepend OpenIdResolverLookup
end
