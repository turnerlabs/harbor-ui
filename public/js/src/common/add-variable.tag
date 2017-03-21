<add-variable>
    <div class="addConfigurationBox row">
        <div class="col s2">
            <input type="radio"
                id="basic_radio_{location}_{index}"
                name="radio_{location}_{index}"
                onclick="{setType}"
                value="basic"
                class="with-gap" />
            <label for="basic_radio_{location}_{index}">Basic</label>

            <input type="radio"
                id="hidden_radio_{location}_{index}"
                name="radio_{location}_{index}"
                onclick="{setType}"
                value="hidden"
                class="with-gap" />
            <label for="hidden_radio_{location}_{index}">Hidden <i class="tiny material-icons" title="Hidden Env Var">lock</i></label>

            <input type="radio"
                id="discover_radio_{location}_{index}"
                name="radio_{location}_{index}"
                onclick="{setType}"
                value="discover"
                class="with-gap" />
            <label for="discover_radio_{location}_{index}">Discover <i class="tiny material-icons" title="Hidden Env Var">visibility</i></label>
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

        self.storedType;

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
                envVar = {name: key.toUpperCase(), value: value, type: self.storedType || 'basic'};
                self.configKey.value = '';
                self.configValue.value = '';

                d('common/add-variable::addConfig', envVar, self.opts);
                if (self.opts.where == 'shipyard') {
                    RiotControl.trigger('shipyard_add_envvar', envVar);
                } else {
                    RiotControl.trigger('shipit_added_var', envVar, self.opts);
                }
            } else {
                alert("Key and Value are required values.")
            }
        }

        setType(evt) {
            self.storedType = $(evt.target).val();
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
