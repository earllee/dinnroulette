require 'httparty'

class OrdrIn
  include HTTParty
  headers 'X-NAAMA-CLIENT-AUTHENTICATION' => "id=\"#{ENV['ORDRIN_KEY']}\", version=\"1\""
  format :json
  
  def self.delivery_list(options)
    self.base_uri 'https://r-test.ordr.in'
    get("/dl/ASAP/#{options['zip']}/#{options['city']}/#{URI::escape(options['addr'])}").parsed_response
  end
  
  def self.restaurant(id)
    self.base_uri 'https://r-test.ordr.in'
    get("/rd/#{id}").parsed_response
  end

  def self.order(rid, tray, options)
    self.base_uri 'https://o-test.ordr.in'
    options["tip"] = "0.00"
    options["delivery_date"] = "ASAP"
    options["tray"] = tray
    post("/o/#{rid}", options).parsed_response
  end

  def self.findItems(section)
    items = []
    section.each do |item|
      if item["is_orderable"] == "1"
        if item["price"] != "0.00"
          items << item
        end
      elsif item["children"]
        items = items + findItems(item["children"])
      end
    end
    items
  end

  def build_tray(tray)
    tray_hash = {}
    tray.each do |item|
      if tray_hash[item["id"]]
        tray_hash[item["id"]] += 1
      else
        tray_hash[item["id"]] = 1
      end
    end
    str = ""
    tray.each do |id, count|
      if str != ""
        str += "+"
      end
      str += "#{id}/#{count}"
    end
    str
  end
end
