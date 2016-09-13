<lighthouse_barge>

  <div class="barge" if={ barge }>
      <div class="row barge-header">
          <div class="legend legend-label pull-left" style="width: { calculateTotal(barge.rawTotal, parent.barge.rawTotal) }%; background-color: {barge.color || ''};">
              Total: { barge.label }
          </div>
          <div if="{((100 - calculateTotal(barge.rawTotal, parent.barge.rawTotal)) - 2) > 0}" class="legend pull-left" style="width: { (100 - calculateTotal(barge.rawTotal, parent.barge.rawTotal)) - 2 }%; background-color: lightgrey;">
          </div>
          <div class="barge-total pull-left">${ barge.total } ({ calculateTotal(barge.rawTotal, parent.barge.rawTotal) }%)</div>
      </div>
      <div class="row barge-header">
          <div class="elb-legend legend-label pull-left" style="width: { calculateTotal(elbs[i].rawTotal, barge.rawTotal) }%; background-color: {barge.color || ''};">
              ELB
          </div>
          <div if="{((100 - calculateTotal(elbs[i].rawTotal, barge.rawTotal)) - 2) > 0}" class="elb-legend pull-left" style="width: { (100 - calculateTotal(elbs[i].rawTotal, barge.rawTotal)) - 2 }%; background-color: lightgrey;">
          </div>
          <div class="barge-total pull-left">${ elbs[i].total } ({ calculateTotal(elbs[i].rawTotal, barge.rawTotal) }%)</div>
      </div>
      <div class="row barge-header">
          <div class="elb-legend legend-label pull-left" style="width: { calculateTotal(barge.compute.rawTotal, barge.rawTotal) }%; background-color: {barge.color || ''};">
              Compute
          </div>
          <div if="{((100 - calculateTotal(barge.compute.rawTotal, barge.rawTotal)) - 2) > 0}" class="elb-legend pull-left" style="width: { (100 - calculateTotal(barge.compute.rawTotal, barge.rawTotal)) - 2 }%; background-color: lightgrey;">
          </div>
          <div class="barge-total pull-left">${ barge.compute.total } ({ calculateTotal(barge.compute.rawTotal, barge.rawTotal) }%)</div>
          <div class="count">
              <p if="{ count }">Container Count: { count }</p>
          </div>
      </div>
      <lighthouse_barge_barchart class="barchart pull-left" barge={ barge } color-map={ colorMap }></lighthouse_barge_barchart>
  </div>

  <script>
        // Barge logic for lighthouse
        //

        var self = this,
            called = {base: false},
            product,
            added = false;

        calculateTotal(total, parentTotal) {
            return Math.floor((total / parentTotal) * 100);
        }

        self.on('update', function(dontUpdate) {

            if (!self.barge || !self.elbs) {
                return;
            }

            if (added === false) {

                self.colorMap = self.opts['color-map'];

                var customer = self.barge.label.split('-')[0].trim();
                if (self.elbs[self.i]) {
                  self.barge.series.push(self.elbs[self.i].series[0]);
                  self.barge.series.push(self.barge.compute.series[0]);
                }


                product = customer.toLowerCase() + '-barge-api';

                RiotControl.trigger('discover', product, 'prod', 'fire_get_kube_data');

                added = true;
            }
        });


        RiotControl.on('fire_get_kube_data', function(data, _product) {

            if (!data[0] || !data[0].ipaddress) {
                self.count = 0;
                self.update();
                return;
            }

            var ip = data[0].ipaddress;

            if (called[ip] || product !== _product) {
                return;
            }

            called[ip] = true;
            RiotControl.trigger('get_kube_data', ip, 'set_kube_data:' + data[0].ipaddress);

            RiotControl.on('set_kube_data:' + ip, function(data) {
                var items = data.items.sort(versionSort),
                    count = 0,
                    used = {};

                for (var key in items) {
                    if (!used[items[key].metadata.namespace]) {
                        used[items[key].metadata.namespace] = true;
                        count += items[key].status.replicas;
                    }
                }

                self.count = count;
                self.update();
            });
        });

        function versionSort(a, b) {
            if (parseInt(a.metadata.labels.version, 10) > parseInt(b.metadata.labels.version, 10)) {
                return -1;
            } else {
                return 1;
            }
        }

  </script>

  <style scoped>

      .barge {
          width: 100%;
          min-height: 300px;
      }

      h4 {
        width: 100%;
      }

      .barge-header {
          color: white;
          width: 100%;
      }

      .barge-header .barge-counter {
            width: 100%;
      }

      .barge-counter {
          float: left;
      }

      .legend {
          height: 30px;
          color: white;
          padding: 5px;
          float: left;
          font-size: 14px;
      }

      .elb-legend {
          height: 20px;
          color: white;
          float: left;
          padding: 3px;
          font-size: 12px;
      }

      .barge-total {
          color: grey;
          margin-left: 5px;
          float: left;
          margin-top: 5px;
          float: left;
          font-size: 12px;
      }

      .barchart {
          width: 100%;
      }

      .count {
          float: left;
          width: 100%;
      }

      .legend-label {
        overflow: visible;
        white-space: nowrap;
        position: relative;
        z-index: 200;
      }
  </style>
</lighthouse_barge>
