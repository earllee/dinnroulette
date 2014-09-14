require 'ordr_in'

class OrdersController < ApplicationController
  respond_to :json

  def create
    # check all params there
    errors = check_params
    if errors.length != 0
      render json: {danger: errors}
      return
    end
    # grab possible restaurants
    initial_dl = OrdrIn.delivery_list(order_params)
    if initial_dl.length == 0
      render json: {warning: "No delivery available."}
      return
    end
    # filter out too expensive minimums
    dl = []
    initial_dl.each do |restaurant|
      if order_params["max"].to_f > restaurant["mino"].to_f
        dl << restaurant
      end
    end
    if dl.length == 0
      render json: {warning: "No delivery available below that maximum."}
      return
    end
    tray = []
    tries = 0
    while tray.length == 0 do
      if tries > 5
        render json: {warning: "Please raise your maximum."}
        return
      end
      # grab random restaurant
      restaurant_summary = dl[Random.rand(dl.length)]
      restaurant = OrdrIn.restaurant(restaurant_summary["id"])
      items = OrdrIn.find_items(restaurant["menu"])
      if items.length == 0
        render json: {warning: "No items available."}
        return
      end
      min = (restaurant_summary["mino"].to_f > order_params["min"].to_f) ? restaurant_summary["mino"].to_f : order_params["min"].to_f
      tray = OrdrIn.create_meal(items, min, order_params["max"].to_f)
      tries += 1
    end
    order = OrdrIn.order(restaurant["restaurant_id"], tray, order_params)
    if order["_err"] == "1"
      render json: {danger: "Order failed."}
      return
    end
    receipt = OrdrIn.create_receipt(tray)
    render json: receipt
  end

  private

  def check_params
    errors = []
    ["first_name", "last_name", "addr", "city", "state", "zip", "phone", "em", "card_name", "card_number", "card_cvc", "card_expiry", "card_bill_addr", "card_bill_city", "card_bill_state", "card_bill_zip", "min", "max"].each do |param|
      if !order_params[param]
        errors << "Missing #{param}."
      end
    end
    errors
  end

  def order_params
    params.permit(:first_name, :last_name, :addr, :city, :state, :zip, :phone, :em, :card_name, :card_number, :card_cvc, :card_expiry, :card_bill_addr, :card_bill_city, :card_bill_state, :card_bill_zip, :min, :max)
  end

end
