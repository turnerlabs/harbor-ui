<config-pair>
    <div class="valign-wrapper">
        <div class="col s3 valign" if={ key }>
            <i if="{ var_type == 'hidden' }" class="tiny material-icons" title="Hidden Env Var">lock</i>
            <i if="{ var_type == 'discover' }" class="tiny material-icons" title="Discover Env Var">visibility</i>
            { key }
        </div>
        <div class="col s8 valign" if={ val }>
            <input if="{!onlyread}" type="text" value={ val } onblur={ updateValue } />
            <input if="{onlyread}" type="text" value={ val } readonly/>
        </div>
        <div class="col s1 valign" if="{!onlyread}">
            <span onclick={ removeValue } name="{valueLocation}" class="remover" title="Remove"><i class="material-icons">close</i></span>
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
        d('common/config-pair::environment_variable_delete', self.key, self.opts);
        RiotControl.trigger('environment_variable_delete', self.key, self.opts);
    }

    self.on('update', function() {
        self.key = self.opts.key;
        self.val = self.opts.val;
        self.var_type = self.opts.var_type || 'text';
        self.valueLocation = self.opts.location || 'environment';
        self.onlyread = self.opts.onlyread;
    });

    self.on('mount', function () {
        d('common/config-pair::mount(%s: "%s")', self.key, self.val, self.opts);
    });
    </script>
</config-pair>
