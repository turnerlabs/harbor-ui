<filter>
    <p class="filter">
        Filter: <input type="text" class="text ui-widget-content ui-corner-all" onkeyup={ doKeyUp }>
    </p>

    <script>
    var self = this,
        d = utils.debug;

    self.list;
    self.eventName = opts.eventname;

    function filterCallback(val) {
        var rx = new RegExp(val);

        return function filterData(item) {
            return rx.test(item.name);
        };
    }

    doKeyUp(evt) {
        var me   = $(evt.target),
            val  = me.val(),
            list = self.list.filter(filterCallback(val));

        RiotControl.trigger(self.eventName, list);
    }

    self.on('mount', function () {
        d('filter::on(mount)');

        self.update();
    });

    RiotControl.on('filter_list_updated', function (list) {
        d('filter::on(filter_list_updated)', list);
        self.list = list;

        self.update();
    });
    </script>
</filter>
