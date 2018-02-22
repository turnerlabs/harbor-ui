<select_barge>
  <div class="col s12 card blue-grey darken-1" if="{info !== false}">
      <div class="card-content white-text">
          Only select a Barge if you don't want to use the default Barge, <strong>{ defaultBarge }</strong>.
      </div>
  </div>
  <select class="barge-select" onchange={ pickBarge } style="width: 100%" disabled>
      <option each="{ barge in barges }"
              selected="{ parent.provider.barge === barge }"
              value="{ barge }">{ barge }</option>
  </select>

  <script>

      var self = this,
          d = utils.debug,
          currentBarge;

      self.defaultBarge = window.config.default_barge;
      self.barges = window.config.barges.split(',');

      pickBarge(evt) {
          var val = $(evt.target).val();
          var page = location.hash.indexOf('shipyard') !== -1 ? 'shipyard' : 'bridge';

          self.provider.barge = val;
          self.update();

          RiotControl.trigger('send_metric', page + '.changeBarge')
          if (self.callback) {
              self.callback();
          }
      }

      RiotControl.on('allow_barge_change', function (allowBargeChange) {
          d('select_barge::allow_barge_change', allowBargeChange);
          $('.barge-select').attr('disabled', !allowBargeChange);
      });

      self.on('update', function() {
          self.provider = self.opts.provider;
          self.callback = self.opts.callback;
          self.info = self.opts.info;

          if (!$('.barge-select').hasClass('select2-hidden-accessible') || currentBarge !== self.provider.barge) {
               currentBarge = self.provider.barge;

               // push barge if not present on supplied barges list
               if (self.barges.indexOf(currentBarge) === -1) {
                   self.barges.push(currentBarge);
               }

               setTimeout(function() {
                   $('.barge-select').select2();
               }, 100);
          }
      });
  </script>
</select_barge>
