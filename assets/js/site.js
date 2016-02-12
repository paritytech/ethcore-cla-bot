(function() {
  $(function() {
    var $button = $('button[type=submit]'),
        $form   = $('form'),
        $message= $('.message')
        $inputs = $('input:not([type="hidden"])', $form);

    $inputs.on('change', function(){
      setTimeout(function(){
        console.log($('input.valid', $form).size(), $inputs.size())
        if($('input.valid', $form).size() === $inputs.size()){
          $button.removeAttr('disabled');
        }else{
          $button.attr('disabled', 'disabled');
        }
      }, 100)
    })
    .on('keyup', function(){
      $(this).trigger('change');
    })

    $form.submit(function(e) {
      $button.attr('disabled', 'disabled').removeClass('red green').text('Submitting...');
      $.ajax({
        type: 'POST',
        url: '/form',
        data: $form.serialize(),
        success: function(data, textStatus, jqXHR) {
          $button.text('Thanks for your submission')
          $message.text('Check the github issue for updates.');
        },
        error: function(error, textStatus, jqXHR) {
          console.log(error)
          $button.removeAttr('disabled').text('Something went wrong').addClass('red')
          $message.text('Please try again later.');
        }
      });
      e.preventDefault();
    });
  });

}).call(this);
