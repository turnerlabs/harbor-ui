<select_provider>
    <h5>{ selectedProvider }</h5>
    <p><strong>Select New Provider:</strong></p>
    <select class="provider-select" onchange="{ changeProvider }" style="width: 100%" disabled>
        <option each="{ provider in providers }"
                selected="{ selectedProvider === provider }"
                value="{ provider }">{ provider }</option>
    </select>

    <script>
    var self = this,
        d = utils.debug;

    self.providers = window.config.providers.split(',');
    self.defaultProvider = window.config.default_provider;
    self.selectedProvider;

    changeProvider(evt) {
        var val = $(evt.target).val();
        var page = location.hash.indexOf('shipyard') !== -1 ? 'shipyard' : 'bridge';

        d('select_provider::changeProvider', val);
        RiotControl.trigger('send_metric', page + '.changeProvider');
    }

    self.on('mount', function () {
        setTimeout(function() {
            $('.provider-select').select2();
        }, 100);
    });

    RiotControl.on('command_bridge_loaded', function () {
        d('select_provider::command_bridge_loaded', self.opts)
        self.selectedProvider = self.opts.provider;
    });

    RiotControl.on('allow_barge_change', function (allowBargeChange) {
        d('select_provider::allow_barge_change', allowBargeChange);
        $('.provider-select').attr('disabled', !allowBargeChange);
    });

    </script>
</select_provider>
