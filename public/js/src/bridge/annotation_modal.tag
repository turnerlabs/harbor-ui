<annotation_modal>
    <div class="modal-content">
        <h4 id="annotation-modal-title">Create Annotation</h4>
        <div class="row">
            <div class="input-field col s6">
                <input id="annotation-key" type="text" class="validate fields"/>
                <label for="annotation-key">Key</label>
            </div>
            <div class="input-field col s6">
                <input id="annotation-value" type="text" class="validate fields"/>
                <label for="annotation-value">Value</label>
            </div>

            <input id="annotation-original-key" type="hidden" class="fields"/>
        </div>
    </div>
    <div class="modal-footer">
        <button class="modal-action waves-effect waves-green btn" onclick="{ saveAnnotation }">Save</button>
        <button class="modal-action modal-close waves-effect waves-red btn-flat">Cancel</button>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    // begin
    saveAnnotation(evt) {
        d('bridge/annotation_modal::saveAnnotation', evt);
        $('.modal-action').attr('disabled', true);
        var shipment = self.parent.shipment.parentShipment.name,
            environment = self.parent.shipment.name,
            annotation = {
                key: $('#annotation-key').val(),
                value: $('#annotation-value').val()
            },
            name = $('#annotation-original-key').val();

        if (name) {
            RiotControl.trigger('update_annotation', shipment, environment, name, annotation);
        }
        else {
            RiotControl.trigger('create_annotation', shipment, environment, annotation);
        }
    }
    // end
    </script>
</annotation_modal>
