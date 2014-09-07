require 'sinatra'
require 'sinatra/base'
require 'json'

class Ppptmstr < Sinatra::Base

  not_found do
    [404, '' ]
  end

  get '/master' do
    [{
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

  post '/master' do
    {
      "uuid"    => "193627c9-eb95-417b-bc59-5ae69b0dd146",
      "fqdn"    => "production.example.com",
      "gitrepo" => "https://github.com/githubtraining/hellogitworld.git",
      "status"  => "provisioning"
    }.to_json

  end

  get '/master/:uuid' do |uuid|
    {
      "uuid"    => uuid,
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700",
      "fqdn"    => "puppetmaster.example.com",
      "gitrepo" => "https://github.com/githubtraining/hellogitworld.git",
      "status"  => "running"
    }.to_json
  end

  delete '/master/:uuid' do |uuid|
    {
      "uuid"      => uuid,
      "created"   => "Sat, 06 Sep 2014 10:00:22 -0700",
      "destroyed" => "Sat, 06 Sep 2014 10:00:22 -0700",
      "fqdn"      => "puppetmaster.example.com",
      "status"    => "terminating"
    }.to_json
  end

  get '/master/:uuid/keys' do |uuid|
    [{
      "name"    => "dc1-prod",
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700"
    },
    {
      "name"    => "dc2-prod",
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700"
    }].to_json
  end

  get '/master/:uuid/keys/:name' do |uuid, name|
    {
      "name"    => name,
      "created" => "Sat, 06 Sep 2014 10:00:22 -0700"
    }
  end

  post '/master/:uuid/keys/:name' do |uuid, name|
    {
      "name"       => name,
      "created"    => "Sat, 06 Sep 2014 10:00:22 -0700",
      "secret_key" => "1k1Z1pT2t3heX939xa7uDE4EeISBL69Z"
    }.to_json
  end

  delete '/master/:uuid/keys' do |uuid, name|
    {
      "name"      => "dc3-staging",
      "created"   => "Sat, 06 Sep 2014 10:00:22 -0700",
      "destroyed" => "Sat, 06 Sep 2014 15:07:18 -0700"
    }.to_json
  end

end
