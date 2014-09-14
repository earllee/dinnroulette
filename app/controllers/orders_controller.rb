require 'ordr_in'

class OrdersController < ApplicationController
  respond_to :json

  def create
    errors = check_params
    if errors.length
      render json: {danger: errors}
    else
      dl = OrdrIn.delivery_list(order_params)
      if dl.length == 0
        render json: {warning: "No delivery available."}
      else
        restaurant_summary = dl[Random.rand(dl.length)]
        restaurant = OrdrIn.restaurant(restaurant_summary["id"])
        items = OrdrIn.findItems(restaurant["menu"])
        if items.length == 0
          render json: {warning: "No items available."}
        else
          tray = []
          while subtotal(tray) < restaurant_summary["mino"] do
            tray << items[Random.rand(items.length)]
          end
          order = OrdrIn.order(restaurant["restaurant_id"], tray, order_params)
          if order["_err"] == "1"
            render json: {danger: "Order failed."}
          else
            render json: {name: item["name"], price: item["price"]}
          end
        end
      end
    end
  end

  private

  def subtotal(items)
    sum = 0.0
    items.each do |item|
      sum += item["price"].to_f
    end
    sum
  end

  def check_params
    errors = []
    ["first_name", "last_name", "addr", "city", "state", "zip", "phone", "em", "card_name", "card_number", "card_cvc", "card_expiry", "card_bill_addr", "card_bill_city", "card_bill_state", "card_bill_zip"].each do |param|
      if !order_params[param]
        errors << "Missing #{param}."
      end
    end
    errors
  end

  def order_params
    params.permit(:first_name, :last_name, :addr, :city, :state, :zip, :phone, :em, :card_name, :card_number, :card_cvc, :card_expiry, :card_bill_addr, :card_bill_city, :card_bill_state, :card_bill_zip)
  end

end
