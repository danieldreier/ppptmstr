require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'fortune_gem'

require 'require_all'
require_all 'models'


module Authtools
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Fucking credentials, how do they work?"'
    headers['X-Consolation-Fortune'] = FortuneGem.give_fortune.gsub(/[^\w\ \.=\(\)\$\,\?\'\:]/, ' ')
    halt 401, "Not authorized\n"
  end

  def authorized?
    return false unless @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    return false unless @auth.provided? and @auth.basic? and @auth.credentials

    tenant_id_input = sanitize(@auth.credentials[0])
    api_key_input   = sanitize(@auth.credentials[1])

    return false unless tenant_id_input == params[:tenant_id]

    client = Riak::Client.new
    keyrepo = ApiKeyRepository.new(client)
    return false, "tenant not found" unless tenant = Tenant.new(tenant_id)
    return false, "api key not found" unless api_key = keyrepo.get(tenant_id: tenant_id_input, api_key_id: api_key_input)

    @auth.provided? and @auth.basic? and @auth.credentials and tenant.tenant_id == api_key.tenant_id and params[:tenant_id] == tenant_id_input
  end

  def sanitize_tenant(tenant_id)
    tenant_id.to_s.delete('^0-9')
  end

  def sanitize(string)
    string.to_s.delete('^A-Za-z0-9')
  end

end


class Ppptmstr < Sinatra::Base
  include Authtools

  not_found do
    protected!
    [404, '' ]
  end

  post '/tenant' do
#    protected!
    json_params = JSON.parse(request.env["rack.input"].read)
    halt 400, "full_name and email must be present in json request" unless json_params['full_name'].to_s.length > 5 and json_params['email'].to_s.length > 5

    new_tenant = Tenant.new
    new_tenant.full_name = json_params['full_name'].to_s
    new_tenant.email = json_params['email'].to_s

    # set up riak connection
    client = Riak::Client.new

    # persist tenant to riak
    tenant_repo = TenantRepository.new(client)
    tenant_repo.save(new_tenant)

    # create an initial api key and persist it to riak
    new_tenant_api_key =  ApiKey.new(tenant_id: new_tenant.tenant_id)
    keyrepo = ApiKeyRepository.new(client)
    keyrepo.save(new_tenant_api_key)

    # return a merged hash of new tenant and an api key
    new_tenant.to_hash.merge(new_tenant_api_key.to_hash)
  end

  delete '/:tenant_id' do |tenant_id|
#    protected!
    # set up riak connection
    client = Riak::Client.new
    TenantRepository.new(client).delete(new_tenant)
    [202, 'tenant queued for deletion' ]
  end

  get '/:tenant_id/master' do |tenant_id|
  # get a list of masters belonging to the user
    protected!
    Puppetmaster.list_masters(tenant_id: tenant_id).to_json
  end

  post '/:tenant_id/master' do |tenant_id|
    protected!
    json_params = JSON.parse(request.env["rack.input"].read)
    new_master = Puppetmaster.new(tenant_id: tenant_id)
    new_master.fqdn = json_params['fqdn'].to_s
    new_master.gitrepo = json_params['gitrepo'].to_s
    new_master.deploy
    new_master.to_hash.to_json
  end

  get '/:tenant_id/master/:uuid' do |tenant_id, uuid|
    # get info about a uuid
    protected!
    Puppetmaster.new(tenant_id: tenant_id, uuid: uuid).to_hash.to_json
  end

  delete '/:tenant_id/master/:uuid' do |tenant_id, uuid|
    protected!

    doomed_master = Puppetmaster.new(tenant_id: tenant_id, uuid: uuid)
    doomed_master.destroy
    doomed_master.to_hash.to_json
  end

  get '/:tenant_id/master/:uuid/keys' do |tenant_id, uuid|
    protected!
    Deploykey.list_keys(tenant_id: tenant_id, master_uuid: uuid).to_json
  end

  get '/:tenant_id/master/:master_uuid/keys/:key_uuid' do |tenant_id, master_uuid, key_uuid|
    protected!
    Deploykey.new(tenant_id: tenant_id, uuid: key_uuid, master_uuid: master_uuid).to_hash.to_json
  end

  post '/:tenant_id/master/:uuid/keys/:name' do |tenant_id, uuid, name|
    protected!
    new_key = Deploykey.new(tenant_id: tenant_id, master_uuid: uuid, name: name)
    new_key.save_to_db
    new_key.to_hash.to_json
  end

  delete '/:tenant_id/master/:master_uuid/keys/:key_uuid' do |tenant_id, master_uuid, key_uuid|
    protected!
    doomed_key = Deploykey.new(tenant_id: tenant_id, uuid: key_uuid, master_uuid: master_uuid)
    doomed_key.destroy
    doomed_key.to_hash.to_json
  end

end
