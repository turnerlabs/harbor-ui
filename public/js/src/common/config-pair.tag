<config-pair>
    <div class="valign-wrapper">
        <div if="{ name }" class="col s3 valign">
            <i if="{ var_type == 'hidden' }" class="tiny material-icons" title="Hidden Env Var">lock</i>
            <i if="{ var_type == 'discover' }" class="tiny material-icons" title="Discover Env Var">visibility</i>
            { name }
        </div>
        <div if="{ val }" class="col s8 valign">
            <input type="text" value="{ val }" onblur="{ updateValue }" />
        </div>
        <div class="col s1 valign">
            <span onclick="{ removeValue }" name="{ valueLocation }" class="remover" title="Remove"><i class="material-icons">close</i></span>
        </div>
    </div>

    <style>
    .remover {
        cursor: pointer;
    }
    </style>

    <script>
    var self = this,
        d = utils.debug;

    updateValue(evt) {
        var val = $(evt.target).val();

        if (val && self.val !== val) {
            d('common/config-pair::environment_variable_update', self.key, val, self.opts);
            RiotControl.trigger('environment_variable_update', self.key, val, self.opts);

            self.val = val;
            self.update();
        } else if (!val) {
            RiotControl.trigger('environment_variable_delete', self.key, self.opts);
        }
    }

    removeValue(evt) {
        d('common/config-pair::environment_variable_delete', self.name, self.opts);
        RiotControl.trigger('environment_variable_delete', self.name, self.opts);
    }

    self.on('update', function () {
        d('common/config-pair::update', self.opts);
        self.name = self.opts.key; // key was conflicting with another value on "self"
        self.val = self.opts.val;
        self.var_type = self.opts.var_type || 'text';
        self.valueLocation = self.opts.location || 'environment';
    });
    </script>
</config-pair>
