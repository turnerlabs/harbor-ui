<lighthouse>
    <div class="section" id="index-banner">
        <div class="container">
            <div class="row">
              <div class="col s12 m12">
                <h1 class="header center-on-small-only">Lighthouse</h1>
              </div>
            </div>
        </div>
    </div>
    <div class="container lighthouse">
        <loading_elm if={ isLoading } isloading="{ isLoading }"></loading_elm>
        <div class="content" if={ isLoading === false }>
            <p>Overall Cost: ${ barge.total }</p>
            <p>Overall Compute Cost: ${ compute.total }</p>
            <p>Overall ELB Cost: ${ elb.total }</p>
            <lighthouse_barge each="{ barge, i in barges }" color-map={ colorMap } elbs="{elbs}"></lighthouse_barge>
        </div>
    </div>

    <script>
        // get lighthouse data and load
        // 343597384413
        var self = this,
            GROUPSET_PURPOSE = 'Groupset-343597387313',
            GROUPSET_TYPE = 'Groupset-343597387313',
            drawnBarges = 0,
            bargeCount = 0,
            renderedMap = {},
            colorMap = {
                cnn: 'rgb(202,0,2)', // CNN Red
                'elb-cnn': 'rgba(202,0,2, .8)', // CNN Red
                'compute-cnn': 'rgba(202,0,2, .4)', // CNN Red
                mss: 'rgb(0,0,204)', // Blue
                'elb-mss': 'rgba(0,0,204, .8)', // Blue
                'compute-mss': 'rgba(0,0,204, .4)', // Blue
                'Assets Not Allocated': 'rgb(128,133,133)'
            },
            d = utils.debug;

        RiotControl.trigger('menu_register', 'Lighthouse', 'lighthouse');

        self.on('mount', function () {
            d('lighthouse::mount');
            self.isLoading = true;
            self.colorMap = colorMap;
            RiotControl.trigger('get_cloudhealth_data', 'https://chapi.cloudhealthtech.com/olap_reports/custom/343597384413' + window.config.cloudHealthApiKey, updateBarges);
            self.update();
        });

        RiotControl.on('graphRendered', function(context) {
            renderedMap[context.meta] = true;
            drawnBarges++;
            if (drawnBarges === bargeCount) {
                setTimeout(function() {
                    self.childBargesRendered = true;
                    self.update();
                }, 100);
            }
        });

        function updateBarges(data) {
            var massagedData = getData(data, GROUPSET_PURPOSE);
            self.data = data;
            self.barge = {series: massagedData[0], labels: massagedData[1], rawTotal: massagedData[3].raw, total: massagedData[3].total};
            self.barges = massagedData[2].sort(sortBarge);
            self.barge.total = massagedData[3].total;
            RiotControl.trigger('get_cloudhealth_data', 'https://chapi.cloudhealthtech.com/olap_reports/custom/343597384418' + window.config.cloudHealthApiKey, updateElbs);

            setTimeout(function() {
                self.isLoading = false;
                self.update();
            },1000);

            self.update();
        }

        function updateElbs(data) {
            var massagedData = getData(data, GROUPSET_PURPOSE),
                i;
            self.elbData = data;
            self.elb = {series: massagedData[0], labels: massagedData[1], rawTotal: massagedData[3].raw, total: massagedData[3].total};
            self.elbs = massagedData[2].sort(sortBarge);
            self.elb.total = massagedData[3].total;
            self.compute = generateComputeData(self.barge, self.elb);
            for (i = 0;i < self.barges.length;i++) {
                if (self.barges[i] && self.elbs[i]) {
                    self.barges[i].compute = generateComputeData(self.barges[i], self.elbs[i]);
                    self.barges[i].compute.series[0].map(function(o) {o.meta = 'compute-' + o.meta; return o;});
                    if (self.barges[i].compute.series[0][0] && self.colorMap[self.barges[i].compute.series[0][0].meta]) {
                        self.barges[i].compute.color = self.colorMap[self.barges[i].compute.series[0][0].meta];
                    }
                }
            }

            for (i = 0;i < self.elb.series.length;i++) {
                self.barge.series.push(self.elb.series[i].map(function(o) {o.meta = 'elb-' + o.meta; return o;}));
            }

            for (i = 0;i < self.compute.series.length;i++) {
                self.barge.series.push(self.compute.series[i].map(function(o) {o.meta = 'compute-' + o.meta; return o;}));
            }

            self.update();
        }

        function sortBarge(a,b) {
            if (a && b) {
                if (a.rawTotal < b.rawTotal) {
                    return 1;
                } else {
                    return -1;
                }
            }

            return 1;
        }

        /**
         * takes the total and subtracts the ELB cost to get the Compute cost.\
         *
         * @param {Object} totals A object with all total values
         * @param {Object} elb The object with elb data to subtract from the totals
         *
         * @return {Object} compute The compute data
         */
        function generateComputeData(totals, elb) {

            var i,
                x,
                compute = {series: [], labels: totals.labels, rawTotal: 0},
                computeValue;

            for (i = 0;i < totals.series.length;i++) {
                compute.series.push([]);
                if (elb.series[i]) {
                    for (x = 0;x < totals.series[i].length;x++){
                        if (totals.series[i][x].value && elb.series[i][x].meta === totals.series[i][x].meta) {
                            computeValue = totals.series[i][x].value - elb.series[i][x].value;
                            compute.series[i].push({value: computeValue, meta: elb.series[i][x].meta});
                            compute.rawTotal += computeValue;
                        } else {
                            compute.series[i].push({value: null, meta: elb.series[i][x].meta});
                        }
                    }
                }
            }

            compute.total = numeral(compute.rawTotal).format('0,0.00')

            return compute;
        }

        /**
         * gets and sets barge data for the entire lighthouse view.
         *
         * This function crawls through all the data returned from CloudHealth and munges into a form that is
         * usable by the view.
         *
         * @param {Object} data Raw data from CloudWatch
         * @params {String} groupset The groupset to capture
         *
         * @return {Array} [combinedSeries, combinedLables, individualBarges]
         */
        function getData(data, groupset) {
            var barges = getBargeData(data, groupset),
                labels = [],
                series = [],
                totals = {raw: 0},
                finalBarges = [],
                i;

            for (i = 0;i < data.data.length;i++) {

                if (i === 0 && !totals.total) {
                    totals.raw = numeral(data.data[i][0][0]);
                } else {
                    labels.push(data.dimensions[0].time[i].label);
                    for (var x = 0;x < data.data[i].length;x++) {
                        var barge = barges[x];

                        if (barge) {

                            if (!barge.data) {
                                barge.data = [];
                                barge.series = [[]];
                                barge.rawTotal = data.data[0][x][0];
                                barge.total = numeral(barge.rawTotal).format('0,0.00');
                                barge.labels = labels;
                            }

                            barge.data.push({time: data.dimensions[0].time[i], data: data.data[i][x][0]});
                            barge.series[0].push({meta: barge.label, value: data.data[i][x][0]});
                        }
                    }
                }
            }

            // clean up barges that have 0.00 dollars
            for (i = 0;i < barges.length;i++) {
                if (barges[i] && (barges[i].total === "0.00" ||
                                  barges[i].label.indexOf('Total') !== -1)) {
                    finalBarges.push(null);
                } else {
                    finalBarges.push(barges[i]);
                    bargeCount++;
                    series.push(barges[i].series[0]);
                }
            }

            totals.total = numeral(totals.raw).format('0,0.00');

            return [series, labels, finalBarges, totals];
        }

        function getBargeData(data, groupset) {
            var barges = [];
            for (var x = 0;x < data.data[0].length;x++) {
                if (data.dimensions[1] && data.dimensions[1][groupset]) {
                    var barge = data.dimensions[1][groupset][x];
                    barge.index = x;
                    barges.push(barge);
                }
            }

            return barges;
        }

    </script>

    <style></style>
</lighthouse>
