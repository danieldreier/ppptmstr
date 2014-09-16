# A simple class that can function as the base class for provisioners
# provisioners create/destroy puppetmasters so that the backend for how
# masters are provided can be modular

# These will be async operations in all but the most trivial provisioners
# methods returning true means that the request to provision, not that
# the request was necessarily successful.

class Puppetmaster::Provisioner
  attr_accessor :name, :provisioner_type

  def create(puppetmaster:, apikey:)
    # return true if successful, false if unsuccessful
    # raise errors as necessary; calls to provision should be wrapped in try/catch
    nil
  end

  def update(puppetmaster:, apikey:)
    # return true if successful, false if unsuccessful
    # raise errors as necessary; calls to provision should be wrapped in try/catch
    nil
  end

  def delete(puppetmaster:, apikey:)
    # return true if successful, false if unsuccessful
    # raise errors as necessary; calls to provision should be wrapped in try/catch
    nil
  end

  def status(puppetmaster:, apikey:)
    # expected to query a monitoring backend to provide live status of master availability
    # returns a hash of:
    # { :status => status, :detail => message }
    # options for status must include:
    # - :available
    # - :unavailable
    # - :provisioning
    # - :deploying
    # - :deprovisioning
    # - :error
    # - :unknown
    nil
  end

end
