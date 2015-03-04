require 'spec_helper'
require 'httparty'
require 'yaml'

describe "ToDo" do
  let(:url) {"http://lacedeamon.spartaglobal.com/todos/"}
  let(:new_item) {HTTParty.post url, query:{title: 'newthing!', due: '2015-01-25'}}
  describe "get response from todos collection" do
    it "should GET 200 'OK'" do
      rget = HTTParty.get url

      expect(rget.code).to eq(200)
      expect(rget.message).to eq("OK")
    end
  end
  describe "create/delete item" do
    it "should POST data into collection" do
      rpost = new_item
      #Expectations
      expect(rpost.code).to eq(201)
      expect(rpost.message).to eq("Created")
      #Teardown
      rdel = HTTParty.delete url + "#{rpost["id"]}"
    end
    it "should DELETE item" do
      rpost = new_item
      rdelete = HTTParty.delete url + "#{rpost["id"]}"
      #Expectations
      expect(rdelete.code).to eq(204)
      expect(rdelete.message).to eq("No Content")
      expect((HTTParty.get url + "#{rpost["id"]}").code).to eq(404)
      expect((HTTParty.get url + "#{rpost["id"]}").message).to eq("Not Found")
    end
    it "should allow multiple data input from a yaml file" do
      data = YAML.load(File.open('data/todo.yml'))
      responses = []
      data["items"].each do |item|
        responses << (HTTParty.post url, query:{title: item["title"], due: item["due"]})
      end

      responses.each do |response|
        #Expectations
        expect(response.code).to eq(201)
        expect(response.message).to eq("Created")
        #Teardown
        HTTParty.delete url + "#{response["id"]}"
      end
    end
    it "should allow changing of an existing item using PUT" do
      rpost = new_item
      rput = HTTParty.put url + "#{rpost["id"]}", query:{title: 'newerthing', due: '2014-01-25'}
      #Expectations
      expect(rput.code).to eq(200)
      expect(rput.message).to eq("OK")
      expect((HTTParty.get url + "#{rpost["id"]}")["title"]).to eq("newerthing")
      #Teardown
      rdel = HTTParty.delete url + "#{rpost["id"]}"
    end
    it "should allow changing of an existing item using PATCH" do
      rpost = new_item
      rpatch = HTTParty.patch url + "#{rpost["id"]}", query:{title: 'newerthing'}
      #Expectations
      expect(rpatch.code).to eq(200)
      expect(rpatch.message).to eq("OK")
      expect((HTTParty.get url + "#{rpost["id"]}")["title"]).to eq("newerthing")
      #Teardown
      rdel = HTTParty.delete url + "#{rpost["id"]}"
    end
  end
  describe "Nagative tests" do
    it "should not allow deleteing a collection" do
      rdelete = HTTParty.delete url
      #Expectations
      expect(rdelete.code).to eq(405)
      expect(rdelete.message).to eq("Method Not Allowed")
    end
    it "should not allow POST in the wrong format" do
      rpost = HTTParty.post url, query:{title: "check", due: "incorrect format"}
      #Expectations
      expect(rpost.code).to eq(500)
      expect(rpost.message).to eq("Internal Server Error")
    end
    it "should not allow deleteing an item that doesn't exist" do
      rdelete = HTTParty.delete url + "1"
      #Expectations
      expect(rdelete.code).to eq(404)
      expect(rdelete.message).to eq("Not Found")
    end
    it "should not allow missing date parameter during POST" do
      rpost = HTTParty.post url, query:{title: "title"}
      #Expectations
      expect(rpost.code).to eq(422)
      expect(rpost.message).to eq("Unprocessable Entity")
    end
    it "should not allow missing date parameter during PUT" do
      rpost = new_item
      rput = HTTParty.put url + "#{rpost["id"]}", query:{title: 'newerthing'}
      #Expectations
      expect(rput.code).to eq(422)
      expect(rput.message).to eq("Unprocessable Entity")
      #Teardown
      rdel = HTTParty.delete url + "#{rpost["id"]}"
    end
    it "should not allow POST on an existing item" do
      rpost = new_item
      rpost2 = HTTParty.post url + "#{rpost["id"]}", query:{title: 'newerthing', due: '2015-01-25'}
      #Expectations
      expect(rpost2.code).to eq(405)
      expect(rpost2.message).to eq("Method Not Allowed")
      #Teardown
      rdel = HTTParty.delete url + "#{rpost["id"]}"
    end
    it "should not allow POST ontop of a non-existing item" do
      rpost = HTTParty.post url + "1"
      #Expectations
      expect(rpost.code).to eq(405)
      expect(rpost.message).to eq("Method Not Allowed")
    end
    it "should not GET an item that doesnt exist" do
      rget = HTTParty.get url + "1"
      #Expectations
      expect(rget.code).to eq(404)
      expect(rget.message).to eq("Not Found")
    end
  end
end 
