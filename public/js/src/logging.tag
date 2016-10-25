<logging>
    <h4>
        Logs
        <span class="tail">
            <input type="checkbox" id="logger-{ loggerId }" value="{ tail }" onclick="{ setTail }" checked="{checked: tail, notChecked: !tail}"/>
            <label for="logger-{ loggerId }">Tail Logs</label>
        </span>
    </h4>
    <textarea name="logviewer" class="logs" value="{ lines }" readonly></textarea>

    <script>
    var self = this,
        d = utils.debug;

    self.num         = 0;
    self.lines       = '';
    self.tail = true;

    setTail() {
        self.tail = !self.tail;
        self.update();
    }

    pickContainer(evt) {
        d('bridge/command/logging::pickContainer');
        var num = $(evt.target).val();

        self.num = num;

        RiotControl.trigger('get_logs');
    }

    self.on('mount', function () {
        d('logs::mount');
        autosize(self.logviewer);
        setTimeout(function () {
            $('.interval-select').select2();
        }, 100);
    });

    self.on('update', function () {
        d('bridge/command/logging::update', self.opts);
        self.loggerId = self.opts.loggerid;
        if (self.tail || !self.logs) {
            self.logs = opts.logs;
        }
        utils.tailTextarea(self.logviewer, self.tail);
    });

    this.on('mount', function () {
        d('bridge/element/logging::mounted');
    })

    RiotControl.on('get_logs', function () {
        d('bridge/command/logging::get_logs');

        if (!self.logs) {
            return;
        }

        if (!self.logs.length === 0) {
            self.lines = ["There are no containers to display logs for."];
            self.update();
            return;
        }

        if (Array.isArray(self.logs)) {
            self.lines = self.logs.join('');
        }

        self.update();
    });

    RiotControl.on('app_changed', function (route, path, env) {
        self.lines = [];
        self.logs = null;
        self.tail = true;
    });

    </script>

    <style scoped>
        textarea {
            color: white;
            background-color: black;
            max-height: 1000px;
        }

        .tail {
            margin-left: 10px;
        }

        .log-screen > p {
            color: white;
        }

    </style>
</logging>
