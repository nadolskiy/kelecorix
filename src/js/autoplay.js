 // Example without autoplay
  $(window).load(function() {
    $('#ca-container').contentcarousel();
  });

  $(function() {
    $('.banner').unslider({
      speed: 700,               //  The speed to animate each slide (in milliseconds)
      delay: 5000,              //  The delay between slide animations (in milliseconds)
      complete: function() {},  //  A function that gets called after every slide animation
      keys: true,               //  Enable keyboard (left, right) arrow shortcuts
      dots: true,               //  Display dot navigation
      fluid: true              //  Support responsive design
    });
  });

