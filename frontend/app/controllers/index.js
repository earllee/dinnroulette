import Ember from "ember";

export default Ember.ObjectController.extend({
  cFirstName: 'Earl',
  cLastName: 'Lee',
  cAddress: '345 Temple Street',
  cCity: 'New Haven',
  cState: 'CT',
  cZip: '06520',
  cPhone: '2403617479',
  cEmail: 'earl.lee@yale.edu',
  cCardName: 'Earl\'s Black Card',
  cCardNumber: '4242 5555 4242 5555',
  cCode: '555',
  cExpires: '01/18',
  cBillingAddress: '109 Grove Street',
  cBillingCity: 'New Haven',
  cBillingState: 'CT',
  cBillingZip: '06520',

  actions: {
    orderFood: function() {
      $.ajax({
        url: 'http://localhost:7000/orders',
        type: 'POST',
        crossDomain: true,
        xhrFields: {
          withCredentials: true
        },
        data: {
          first_name: this.get('cFirstName'),
          last_name: this.get('cLastName'),
          addr: this.get('cAddress'),
          city: this.get('cCity'),
          state: this.get('cState'),
          zip: this.get('cZip'),
          phone: this.get('cPhone'),
          em: this.get('cEmail'),
          card_name: this.get('cCardName'),
          card_number: this.get('cCardNumber'),
          card_cvc: this.get('cCode'),
          card_expiry: this.get('cExpires'),
          card_bill_addr: this.get('cBillingAddress'),
          card_bill_city: this.get('cBillingCity'),
          card_bill_state: this.get('cBillingState'),
          card_bill_zip: this.get('cBillingZip'),
        },
        complete: function(payload) {
          console.log(payload);
        },
      });
    },
  },
});
