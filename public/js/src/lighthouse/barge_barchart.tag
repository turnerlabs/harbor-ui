<lighthouse_barge_barchart>

    <div name="chartistBar" class="ct-chart"></div>

    <script>
        // chartist logic goes here
        //
        var self = this,
            barge,
            chart,
            colorMap;

        this.on('update', function() {
            barge = self.opts.barge;
            colorMap = self.opts['color-map'];
            createChart(barge);
        });

        function getRandomRgb() {
            var r = Math.floor(Math.random() * 255),
                g = Math.floor(Math.random() * 255),
                b = Math.floor(Math.random() * 255),
                col = "rgb(" + r + "," + g + "," + b + ")";

            return col;
        }

        function createChart(barge) {
            if (barge) {
                var series = self.opts.series ? self.opts.series : barge.series;

                chart = new Chartist.Bar(self.chartistBar, {
                  labels: barge.labels,
                  series: series
                }, {
                  seriesBarDistance: 10,
                  axisX: {
                    offset: 60
                  },
                  axisY: {
                    offset: 80,
                    labelInterpolationFnc: function(value) {
                      return '$' + value
                    },
                    scaleMinSpace: 15
                  },
                  height: 300,
                  plugins: [Chartist.plugins.tooltip({currency: '$'})]
                });

                chart.on('draw', function(context) {
                  // First we want to make sure that only do something when the draw event is for bars. Draw events do get fired for labels and grids too.
                  if(context.type === 'bar') {

                    var meta = context.meta;

                    if (!self.opts.barge.color && colorMap) {
                        if (!colorMap[meta]) {
                            colorMap[meta] = getRandomRgb();
                        }
                        self.opts.barge.color = colorMap[meta];
                        RiotControl.trigger('graphRendered', context);
                        riot.update();
                    }
                    // With the Chartist.Svg API we can easily set an attribute on our bar that just got drawn
                    context.element.attr({
                      style: 'stroke: ' + colorMap[meta] + ';'
                    });
                  }
                });
            }
        }
    </script>
    <style scoped>


    </style>
</lighthouse_barge_barchart>
