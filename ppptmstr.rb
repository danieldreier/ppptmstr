require 'sinatra'
require 'sinatra/base'
require 'json'


module Authtools
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Fucking credentials, how do they work?"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['123', 'admin'] and params[:tenant_id] == @auth.credentials[0]
  end
end


class Ppptmstr < Sinatra::Base
  include Authtools

#  before do
#  end
#  use Rack::Auth::Basic, "Restricted Area" do |username, password|
#    username == 'admin' and password == 'admin'
#  end
  not_found do
    [404, '' ]
  end

  get '/:tenant_id/master' do |tenant_id|
    protected!
    # get a list of masters belonging to the user
    # probably from some kind of DB
    error 401 unless params[:tenant_id].to_s == "123"
    [{
      "tenant_id" => tenant_id,
      "uuid"   => "34378253-2009-4085-a687-8252a8d0014d",
      "fqdn"   => "mymaster.example.com",
      "status" => "running"
    }, {
      "uuid"   => "ee03ffd8-2c65-4fa3-9309-fdbe64afa84f",
      "fqdn"   => "testbox.dev.example.com",
      "status" => "provisioning"
    }, {
      "uuid"   => "413f77df-9568-49b3-9e29-f65016b0b524",
      "fqdn"   => "connor.example.com",
      "status" => "terminated"
    }].to_json
  end

  post '/:tenant_id/master' do |tenant_id|
    protected!
    # generate a UUID, do basic validation of inputs, and submit a provision
    # request to a queue
    {
      "uuid"    => "193627c9-eb95-417b-bc59-5ae69b0dd146",
      "fqdn"    => "production.example.com",
      "gitrepo" => "https://github.com/githubtraining/hellogitworld.git",
      "status"  => "provisioning"
    }.to_json

  end

  get '/:tenant_id/master/:uuid' do |tenant_id, uuid|
    protected!
    # get info about a uuid
    # from some kind of DB
    {
      "uuid"    => uuid,
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700",
      "fqdn"    => "puppetmaster.example.com",
      "gitrepo" => "https://github.com/githubtraining/hellogitworld.git",
      "status"  => "running"
    }.to_json
  end

  delete '/:tenant_id/master/:uuid' do |tenant_id, uuid|
    protected!
    # do basic validation, update server status to terminating in a database
    # (locking, basically), then submit a delete request to a queue
    {
      "uuid"      => uuid,
      "created"   => "Sat, 06 Sep 2014 10:00:22 -0700",
      "destroyed" => "Sat, 06 Sep 2014 10:00:22 -0700",
      "fqdn"      => "puppetmaster.example.com",
      "status"    => "terminating"
    }.to_json
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
