<add-variable>
    <div class="addConfigurationBox row">
        <div class="col s2">
            <input type="checkbox"
                   id="hidden_checkbox_{location}_{index}"
                   onclick="{setHidden}"
                   checked="{checked: hidden}" />
            <label for="hidden_checkbox_{location}_{index}">Hidden:</label>

            <input type="checkbox"
                id="discover_checkbox_{location}_{index}"
                onclick="{setDiscover}"
                checked="{checked: type == 'discover'}" />
            <label for="discover_checkbox_{location}_{index}">Discover:</label>
        </div>
        <div class="col s4">
            Key: <input type="text" name="configKey" placeholder="Variable Name" onkeyup="{ forceUppercase }" />
        </div>
        <div class="col s6">
            <span>Value:</span> <input type="text" name="configValue" placeholder="Variable Value" />
        </div>
        <p class="right"><button class="btn" onclick={ addConfig }>Add Variable</button></p>
    </div>

    <script>
        var self = this,
            d = utils.debug;

        self.hidden = false;
        self.discover = false;

        forceUppercase(evt) {
            var ele = $(evt.target),
                txt = ele.val();

            ele.val(txt.replace('-', '_').toUpperCase());
        }

        addConfig(evt) {
            var key   = self.configKey.value,
                value = self.configValue.value,
                envVar;

            if (key && value) {
                envVar = {name: key.toUpperCase(), value: value, type: getType(self.type, self.hidden, self.discover)};
                self.configKey.value = '';
                self.configValue.value = '';
            }

            d('common/add-variable::addConfig', envVar, self.opts);
            if (self.opts.where == 'shipyard') {
                RiotControl.trigger('shipyard_add_envvar', envVar);
            } else {
                RiotControl.trigger('shipit_added_var', envVar, self.opts);
            }
        }

        setHidden(evt) {
            toggleOther(evt.target.id);
            self.hidden = !self.hidden;
        }

        setDiscover(evt) {
            toggleOther(evt.target.id);
            self.discover = !self.discover;
        }

        function toggleOther(id) {
            var parts = id.split('_'),
                type = parts[0] == 'hidden' ? 'discover' : 'hidden',
                loc = parts[2],
                idx = parts[3],
                other = $('#' + [type, 'checkbox', loc, idx].join('_')),
                checked = other.prop('checked');

            if (checked) {
                other.prop('checked', false);
            }
        }

        function getType(type, hidden, discover) {
            if (hidden) {
                return 'hidden';
            } else if (discover) {
                return 'discover';
            } else {
                return 'basic';
            }
        }

        self.on('update', function() {
            self.identifier = self.opts.location;
            self.list = self.opts.list;
            self.location = self.opts.location;
            self.index = self.opts.index || 0;
            self.type = self.opts.type || 'basic';
        });
    </script>
</add-variable>
