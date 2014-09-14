import Ember from "ember";

export default Ember.ObjectController.extend({
  cFirstName: null,
  cLastName: null,
  cAddress: null,
  cCity: null,
  cState: null,
  cZip: null,
  cPhone: null,
  cEmail: null,
  cCardName: null,
  cCardNumber: null,
  cCode: null,
  cExpires: null,
  cBillingAddress: null,
  cBillingCity: null,
  cBillingState: null,
  cBillingZip: null,

  actions: {
    orderFood: function() {
      $.ajax({
        url: ENV.orderURL,
        type: 'POST',
        data: {
          first_name: cFirstName,
          last_name: cLastName,
          addr: cAddress,
          city: cCity,
          state: cState,
          zip: cZip,
          phone: cPhone,
          em: cEmail,
          card_name: cCardName,
          card_number: cCardNumber,
          card_cvc: cCode,
          card_expiry: cExpires,
          card_bill_addr: cBillingAddress,
          card_bill_city: cBillingCity,
          card_bill_state: cBillingState,
          card_bill_zip: cBillingZip,
        }
      });
    },
  },
});
