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
    options["tray"] = build_tray(tray)
    post("/o/#{rid}", options).parsed_response
  end

  def self.find_items(section)
    items = []
    section.each do |item|
      if item["is_orderable"] == "1"
        if item["price"] != "0.00"
          items << item
        end
      elsif item["children"]
        items = items + find_items(item["children"])
      end
    end
    items
  end

  def self.build_tray(tray)
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
  
  def self.create_receipt(tray)
    purchased_hash = {}
    tray.each do |item|
      if purchased_hash[item["name"]]
        purchased_hash[item["name"]]["quantity"] += 1
      else
        purchased_hash[item["name"]] = {"name" => item["name"], "price" => item["price"], "quantity" => 1}
      end
    end
    purchased = []
    purchased_hash.each do |k, v|
      purchased << v
    end
    purchased
  end

  def self.create_meal(items, min, max)
    meal = []
    if items.all? { |item| item["price"].to_f > max }
      return []
    else
      while subtotal(meal) < min do
        total = subtotal(meal)
        item = item_in_range(items, min - total, max - total)
        if !item
          meal << items[Random.rand(items.length)]
        else
          meal << item
        end
      end
      while subtotal(meal) < max do
        if Random.rand(2) == 0
          return meal
        end
        total = subtotal(meal)
        item = item_in_range(items, 0, max - total)
        if !item
          return meal
        else
          meal << item
        end
      end
    end
  end

  def self.subtotal(items)
    sum = 0.0
    items.each do |item|
      sum += item["price"].to_f
    end
    sum
  end

  def self.item_in_range(items, min, max)
    possible = items.find_all do |item|
      price = item["price"].to_f
      price >= min && price <= max
    end
    if possible.length == 0
      nil
    else
      possible[Random.rand(possible.length)]
    end
  end
end
