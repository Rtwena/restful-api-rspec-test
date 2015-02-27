require 'spec_helper'
require 'httparty'
require 'yaml'

describe "ToDo" do

  let(:url) {url = "http://lacedeamon.spartaglobal.com/todos"}
  it "Should get 200 'OK'" do
    rget = HTTParty.get url + "/300"

    expect(rget.code).to eq(200)
    expect(rget.message).to eq("OK")
  end
end
