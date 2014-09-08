require 'sinatra'
require 'sinatra/base'
require 'json'
require 'require_all'

require_all 'models'

module Authtools
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Fucking credentials, how do they work?"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    tenant_id = sanitize(@auth.credentials[0])
    api_key   = sanitize(@auth.credentials[1])

    @current_tenant = Tenant.new(tenant_id)
    @current_tenant.authenticate!(api_key)
    @auth.provided? and @auth.basic? and @auth.credentials and @current_tenant.authenticated? and params[:tenant_id] == tenant_id
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
    [404, '' ]
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
    [{
      "name"    => "dc1-prod",
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700"
    },
    {
      "name"    => "dc2-prod",
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700"
    }].to_json
  end

  get '/:tenant_id/master/:uuid/keys/:name' do |tenant_id, uuid, name|
    protected!
    {
      "name"    => name,
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700"
    }
  end

  post '/:tenant_id/master/:uuid/keys/:name' do |tenant_id, uuid, name|
    protected!
    {
      "name"       => name,
      "created"    => "Sat, 06 Sep 2014 10:00:22 -0700",
      "secret_key" => "1k1Z1pT2t3heX939xa7uDE4EeISBL69Z"
    }.to_json
  end

  delete '/:tenant_id/master/:uuid/keys' do |tenant_id, uuid, name|
    protected!
    {
      "name"      => "dc3-staging",
      "created"   => "Sat, 06 Sep 2014 10:00:22 -0700",
      "destroyed" => "Sat, 06 Sep 2014 15:07:18 -0700"
    }.to_json
  end

end
