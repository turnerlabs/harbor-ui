<audit_log>
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

    <script>
    var self = this,
        d = utils.debug,
        updated = false;

    self.on('update', function () {
        d('bridge/auditlog::update');
        var log = self.opts.log;
        var diff = log.diff;
        self.log = {
          timestamp: log.timestamp,
          user: log.user,
          deleted: [],
          updated: [],
          created: []
        };

        if (!diff) {
          return;
        }

        // If not array then it was a trigger action
        if (diff.charAt(0) !== '{' || diff.charAt(diff.length-1) !== '}') {
            self.log.action = diff;
            return;
        }

        // if not then it was a change to a shipit object
        diff = JSON.parse(diff);
        for (var key in diff) {
            if (diff[key].length === 1) {
                self.log.created.push({key: key, value: JSON.stringify(diff[key][0])});
            } else if (diff[key].length === 2) {
                self.log.updated.push({key: key, value: diff[key][0] + " => " + diff[key][1]});
            } else {
                self.log.deleted.push({key: key, value: diff[key][0]});
            }
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
