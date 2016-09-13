<charts>
    <h4>Charts</h4>
    <div class="row">
        <div class="col s3 m3">
            <select class="charts-select" onchange={ pickChart } style="width: 100%">
                <option each={ charts } value={ id } selected={ id == this.parent.chart }>{ label }</option>
            </select>
        </div>
    </div>
    <div class="row">
            <div class="col s3 m3">
            <select class="replicas-select" onchange={ pickContainer } style="width: 100%">
                <option each={ name, i in helm.replicas } value={ i } selected={ i == this.parent.num }>Replica { i }</option>
            </select>
            <span class="container-id">{ containerId }</span>
        </div>
    </div>
    <div class="ct-chart ct-perfect-fourth"></div>

    <script>
    var self = this,
        d = utils.debug,
        routed = false,
        chartistElem;

    self.num         = 0;
    self.timer       = null;
    self.chart       = 'cpuUsageTotal';
    self.charts      = [
        {label: 'CPU Total Usage', id: 'cpuUsageTotal'},
        {label: 'CPU Usage per Core', id: 'cpuUsagePerCore'},
        {label: 'CPU Usage Breakdown', id: 'cpuUsageBreakdown'}
    ];
    self.interval    = 1000 * 5;
    self.containerId = null;


    pickChart(evt) {
        var chart = $(evt.target).val();

        self.chart = chart;

        RiotControl.trigger('get_charts');
    }

    pickContainer(evt) {
        d('bridge/command/charts::pickContainer');
        var num = $(evt.target).val();

        self.num = num;

        RiotControl.trigger('get_charts');
    }

    function getInterval(cur, pre) {
        var c = (new Date(cur)).getTime(),
            p = (new Date(pre)).getTime();

        return (c - p) * 1000000;
    }

    function getLabelNames(data) {
        var arr = [],
            t, // time
            s, // seconds
            i;

        if (data) {

            for (i = 1; i < data.stats.length; i++) {
                t = (new Date(data.stats[i].timestamp)).toLocaleString().split(', ')[1];
                s = Number(t.match(/(\d+)\s/)[1]);

                if (s === 0 || s % 10 === 0) {
                    arr.push(t);
                } else {
                    arr.push('');
                }
            }
        }
        return arr;
    }

    function getDatasets(id, data) {
        var series = [],
            c, // current
            p, // previous
            v, // interval
            t, // temporary
            i,
            j;


        switch (id) {
            case 'cpuUsageTotal':
                for (i = 1; i < data.stats.length; i++) {
                    c = data.stats[i];
                    p = data.stats[i - 1];
                    v = getInterval(c.timestamp, p.timestamp);

                    series.push((c.cpu.usage.total - p.cpu.usage.total) / v);
                }

                series = [series];
            break;

            case 'cpuUsagePerCore':
                for (j = 0; j < data.stats[0].cpu.usage.per_cpu_usage.length; j++) {
                    t = [];

                    for (i = 1; i < data.stats.length; i++) {
                        c = data.stats[i];
                        p = data.stats[i - 1];
                        v = getInterval(c.timestamp, p.timestamp);

                        t.push((c.cpu.usage.per_cpu_usage[j] - p.cpu.usage.per_cpu_usage[j]) / v);
                    }

                    series.push(t);
                }
            break;

            case 'cpuUsageBreakdown':
                t = [];

                for (i = 1; i < data.stats.length; i++) {
                    c = data.stats[i];
                    p = data.stats[i - 1];
                    v = getInterval(c.timestamp, p.timestamp);

                    series.push((c.cpu.usage.user - p.cpu.usage.user) / v);
                    t.push((c.cpu.usage.system - p.cpu.usage.system) / v);
                }

                series = [series, t];
            break;
        }

        return {
            labels: getLabelNames(data),
            series: series
        };
    }

    self.on('update', function () {
        d('bridge/command/charts::update');

        self.helm = opts.helm;
        self.container   = opts.container;
        self.environment = opts.environment;

        if (routed) {

            RiotControl.trigger('get_charts');

            if (opts.multiplier !== 'stop') {
                clearInterval(self.timer);
                self.interval = 1000 * opts.multiplier;
                self.timer = setInterval(function () {
                    RiotControl.trigger('get_charts');
                }, self.interval);
            } else {
                clearInterval(self.timer);
            }
        }

        setTimeout(function() { $('.replicas-select').select2()} );
    });

    // cleanup logic
    self.on('unmount', function() {
        if (chartistElem) {
            d('bridge/command/charts::unmount');
            chartistElem.detach();
        }

        setTimeout(function() { $('.charts-select').select2(); });
    });

    RiotControl.on('get_charts', function () {
        d('bridge/command/charts::get_charts(num: %s)', self.num);

        var replica,
            host,
            i;

        if (!self.helm || !self.helm.replicas) {
            return;
        }

        if (!self.helm.replicas[self.num] && self.helm.replicas.length > 0) {
            self.num = 0;
        } else if (!self.helm.replicas[self.num]) {
            return;
        }

        replica = self.helm.replicas[self.num];
        host = self.helm.replicas[self.num].host;

        for (i = 0; i < replica.containers.length; i++) {
            if (self.container === replica.containers[i].name) {
                RiotControl.trigger('get_chart_data', host, replica.containers[i].id);
                self.containerId = replica.containers[i].id;
                break;
            }
        }

        self.update();
    });

    RiotControl.on('get_chart_data_result', function (data) {
        d('bridge/command/charts::get_chart_data_result', data);

        var ele = $('.ct-chart')[0];

        if (chartistElem) {
            chartistElem.detach();
            chartistElem = null;
        }

        chartistElem = new Chartist.Line(ele, getDatasets(self.chart, data), {
            showPoint: false,
            height: '300px',
            scaleMinSpace: 80
        });
    });

    RiotControl.on('app_changed', function (route, path, env) {
        if (chartistElem) {
            chartistElem.detach();
            chartistElem = null;
        }
        clearInterval(self.timer);
        self.timer = null;

        if (route === 'bridge' && path && env) {
            routed = true;
        } else {
            routed = false;
        }
    });
    </script>
</charts>
