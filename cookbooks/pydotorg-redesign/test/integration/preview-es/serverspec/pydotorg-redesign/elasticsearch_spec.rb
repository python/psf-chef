require 'spec_helper'

describe 'pydotorg-redesign::elasticsearch' do
  it 'will run elasticsearch as a service' do
    service('elasticsearch').should be_enabled
  end

  it 'will run be running ok' do
    command("curl -s -XGET 'http://localhost:9200/_status' | grep ok").should return_exit_status 0
  end 

  it 'will be running with 256m max' do
    command('ps aux | grep elas | grep mx256m').should return_exit_status 0
  end
end

