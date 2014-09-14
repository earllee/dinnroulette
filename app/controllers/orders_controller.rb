require 'ordr_in'

class OrdersController < ApplicationController
  respond_to :json

  def create
    tray = make_order()
    if tray.kind_of?(Array)
      receipt = OrdrIn.create_receipt(tray)
      render json: receipt, status: :ok
    else
      render json: tray, status: :unprocessable_entity
    end
  end

  def auth
    tray = make_order()
    if tray.kind_of?(Array)
      session = Session.create({order: OrdrIn.parse_order(tray)})
      render json: {token: session.token}, status: :created
    else
      render json: tray, status: :unproccessable_entity
    end
  end

  def verify
    session = Session.find_by(token: auth_params["token"])
    if session
      if auth_params["order"] == session.order
        session.destroy
        render json: {success: "Authorized."}, status: :ok
      else
        render json: {danger: "Order does not match."}, status: :unauthorized
      end
    else
      render json: {danger: "Invalid token."}, status: :unauthorized
    end
  end

  private

  def make_order
    # check all params there
    errors = check_params
    if errors.length != 0
      return {danger: errors}
    end
    # grab possible restaurants
    initial_dl = OrdrIn.delivery_list(order_params)
    if initial_dl.length == 0
      return {warning: "No delivery available."}
    end
    # filter out too expensive minimums
    dl = []
    initial_dl.each do |restaurant|
      if order_params["max"].to_f > restaurant["mino"].to_f
        dl << restaurant
      end
    end
    if dl.length == 0
      return {warning: "No delivery available below that maximum."}
    end
    tray = []
    tries = 0
    while tray.length == 0 do
      if tries > 5
        return {warning: "Please raise your maximum."}
      end
      # grab random restaurant
      restaurant_summary = dl[Random.rand(dl.length)]
      restaurant = OrdrIn.restaurant(restaurant_summary["id"])
      items = OrdrIn.find_items(restaurant["menu"])
      if items.length == 0
        return {warning: "No items available."}
      end
      min = (restaurant_summary["mino"].to_f > order_params["min"].to_f) ? restaurant_summary["mino"].to_f : order_params["min"].to_f
      tray = OrdrIn.create_meal(items, min, order_params["max"].to_f)
      tries += 1
    end
    order = OrdrIn.order(restaurant["restaurant_id"], tray, order_params)
    if order["_err"] == "1"
      return {danger: "Order failed."}
    end
    tray
  end

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

  def auth_params
    params.permit(:token, :order)
  end

end
