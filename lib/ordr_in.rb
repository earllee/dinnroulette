require 'httparty'

class OrdrIn
  include HTTParty
  base_uri 'https://r-test.ordr.in'
  headers 'X-NAAMA-CLIENT-AUTHENTICATION' => "id=\"#{ENV['ORDRIN_KEY']}\", version=\"1\""
  format :json
  
  def self.delivery_list(options)
    get("/dl/ASAP/#{options['zip']}/#{options['city']}/#{URI::escape(options['address'])}").parsed_response
  end
  
  def self.restaurant(id)
    get("/rd/#{id}").parsed_response
  end

  def self.order(options)
    options["tip"] = "0.00"
    options["delivery_date"] = "ASAP"
    post("/o/#{options['rid']}", options).parsed_response
  end

  def self.findItems(section)
    items = []
    section.each do |item|
      if item["is_orderable"] == "1"
        if item["price"] != "0.00"
          items << item
        end
      elsif item["children"]
        items + findItems(item["children"])
      end
    end
    items
  end
end
