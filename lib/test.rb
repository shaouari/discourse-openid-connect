class FinalDestination::Resolver
    module OpenIdResolverLookup
        def self.lookup(addr, timeout: nil)
            super(addr,20);                
        end
    end
    prepend OpenIdResolverLookup
end
