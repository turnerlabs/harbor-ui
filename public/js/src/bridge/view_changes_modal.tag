<view_changes_modal>
    <div id="{ modalId }" name="{ modalId }" class="modal modal-fixed-footer">
        <div class="modal-content">
            <h4>Changes</h4>
            <ul class="collection" if="{ changes.length }">
                <li class="collection-item type-{ change.status }" each="{ change in changes }">
                    <h5 if="{ change.status == 'error' }">ERROR: { change.message }</h5>
                    <a class="secondary-content" onclick="{ parent.deleteChange }"><i class="small material-icons red-text">delete</i></a>
                    <code>{ change.method } /{ change.url.replace(config.shipit_url, '') }</code>
                    <pre>{ JSON.stringify(change.data, null, 2) }</pre>
                </li>
            </ul>
            <p if="{ !changes.length }">No changes</p>
        </div>
        <div class="modal-footer">
            <button onclick="{ closeModal }" class="modal-action modal-close waves-effect waves-red btn-flat">Cancel</button>
            <button onclick="{ saveChanges }" class="btn">Save</button>
        </div>
    </div>

    <style>
    .collection li.type-error {
        /* red lighten-4 */
        background-color: #ffcdd2;
    }

    .collection li.type-success {
        /* #c8e6c9 green lighten-4 */
        background-color: #c8e6c9;
    }

    .collection li.type-prep {
        /* #c8e6c9 amber lighten-4 */
        background-color: #ffecb3;
    }
    </style>

    <script>
    var self = this,
        d = utils.debug;

    closeModal(evt) {
        $('#' + self.modalId).closeModal();
    }

    saveChanges(evt) {
        d('bridge/view_changes_modal::saveChanges');
        RiotControl.trigger('shipit_save_changes');
        $('#' + self.modalId).closeModal();
    }

    deleteChange(evt) {
        d('bridge/view_changes_modal::deleteChange', evt);
        var change = evt.item.change,
            index = self.changes.indexOf(change);

        if (index !== -1) {
            self.changes.splice(index, 1);
            RiotControl.trigger()
        }
    }

    RiotControl.on('open_changes_modal', function (changes) {
        d('bridge/view_changes_modal::open_changes_modal', changes);
        self.changes = changes;
        $('#' + self.modalId).openModal();
        self.update();
    });

    self.on('update', function () {
        self.modalId = self.opts.targetid;
    });
    </script>
</view_changes_modal>
