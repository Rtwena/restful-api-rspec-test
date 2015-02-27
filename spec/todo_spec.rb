require 'spec_helper'
require 'httparty'
require 'yaml'

describe "ToDo" do
  let(:url) {url = "http://lacedeamon.spartaglobal.com/todos/"}
  describe "get response from todos collection" do
    it "should GET 200 'OK'" do
      rget = HTTParty.get url

      expect(rget.code).to eq(200)
      expect(rget.message).to eq("OK")
    end
  end
  describe "create/delete item" do
    it "should POST data into collection" do
      rpost = HTTParty.post url, query:{title: 'newthing!', due: '2015-01-25'}
      rdel = HTTParty.delete url + "#{rpost["id"]}"

      expect(rpost.code).to eq(201)
      expect(rpost.message).to eq("Created")
    end
    it "should DELETE item" do
      rpost = HTTParty.post url, query:{title: 'newthing!', due: '2015-01-25'}
      rdelete = HTTParty.delete url + "#{rpost["id"]}"

      expect(rdelete.code).to eq(204)
      expect(rdelete.message).to eq("No Content")
    end
  end
  describe 
end 


#r = HTTParty.get "http://lacedeamon.spartaglobal.com/todos#{response[0]["id"]}"
