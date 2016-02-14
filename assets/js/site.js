(function() {
  $(function() {
    var $button = $('button[type=submit]'),
        $form   = $('form'),
        $message= $('.message')
        $inputs = $('input:not([type="hidden"])', $form);

    $inputs.trigger('change')
    $inputs.on('change', function(){
      setTimeout(function(){
        if($('input.valid', $form).size() === $inputs.size() && !$button.hasClass('complete')){
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
      e.preventDefault();
      $button.attr('disabled', 'disabled').removeClass('red green').text('Submitting...');
      $.ajax({
        type: 'get',
        url: '/sign?' + $form.serialize(),
        success: function(data, textStatus, jqXHR) {
          $button.addClass('complete')
          if(data === 'No Auth'){
            alert("You have been logged out. Retying...")
            window.location = '/auth/github'
          }else{
            $button.text('Thanks for your submission')
            $message.html('Please update your pull request by adding the comment: <code>[clabot:check]</code>.');
          }
        },
        error: function(error, textStatus, jqXHR) {
          $button.removeAttr('disabled').text('Something went wrong').addClass('red')
          $message.text('Please try again later.');
        }
      });
      e.preventDefault();
    });
  });

}).call(this);
