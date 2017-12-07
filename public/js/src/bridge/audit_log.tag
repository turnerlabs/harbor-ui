<audit_log>
    <div class="row">
        <div class="col s12" each="{ log in logs }">
            <div class="log">
                Timestamp: {log.timestamp}<br/>
                User: {log.user}<br/>
                <div class="action" if="{log.action}">
                  <h5 class="header">Trigger</h5>
                  <div class="details">
                    Action: <code class="pre-wrap">{log.action}</code>
                  </div>
                </div>
                <div class="action" if="{log.created.length}">
                  <h5 class="header">Created</h5>
                  <div class="details" each="{ change in log.created}">
                    Key: {change.key},
                    Value: <span class="created">{change.value}</span>
                  </div>
                </div>
                <div class="action" if="{log.updated.length}">
                  <h5 class="header">Updated</h5>
                  <div class="details" each="{ change in log.updated}">
                    Key: {change.key},
                    Update: <span class="updated">{change.value}</span>
                  </div>
                </div>
                <div class="action" if="{log.deleted.length}">
                  <h5 class="header">Deleted</h5>
                  <div class="details" each="{ change in log.deleted}">
                    Key: {change.key},
                    Value: <span class="deleted">{change.value}</span>
                  </div>
                </div>
            </div>
        </div>
        <div if="{ shipment.audit_logs.length == 0 }">
            <h4>There are no logs for this Shipment.</h4>
        </div>
    </div>



    <script>
    var self = this,
        d = utils.debug,
        updated = false;

    self.logs = [];

    RiotControl.on('get_shipment_audit_logs_result', function (audit_logs) {
        d('bridge/audit_log::get_shipment_audit_logs_result', audit_logs.length);

        if (audit_logs && audit_logs.length) {
            self.logs = audit_logs.map(function (log) {
                var diff = log.diff,
                    new_log = {
                        timestamp: log.timestamp,
                        user: log.user,
                        deleted: [],
                        updated: [],
                        created: []
                    };

                if (!diff) {
                    return new_log;
                }

                // If not array then it was a trigger action
                if (diff.charAt(0) !== '{' || diff.charAt(diff.length - 1) !== '}') {
                    new_log.action = diff;
                    return new_log;
                }

                // if not then it was a change to a shipit object
                diff = JSON.parse(diff);
                for (var key in diff) {
                    if (diff[key].length === 1) {
                        new_log.created.push({ key: key, value: JSON.stringify(diff[key][0]) });
                    }
                    else if (diff[key].length === 2) {
                        new_log.updated.push({ key: key, value: diff[key][0] + " => " + diff[key][1] });
                    }
                    else {
                        new_log.deleted.push({ key: key, value: diff[key][0] });
                    }
                }

                return new_log;
            });
        }
    });
    </script>

    <style scoped>
    .log {
        display: block;
        background-color: #f5f5f5;
        border: 1px solid #bdbdbd;
        padding: 5px 10px;
        border-radius: 4px;
        overflow-x: scroll;
        margin-bottom: 5px;
    }

    .pre-wrap {
      white-space: pre-wrap;
    }

    .details {
      margin-left: 10px;
    }

    .created {
        color: #009900;
        font-weight: bold;
    }

    .updated {
        font-weight: bold;
    }

    .deleted {
        color: #ff0000;
        font-weight: bold;
    }


    </style>
</audit_log>
