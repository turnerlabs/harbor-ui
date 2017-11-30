<annotations>
    <p>Notes about this Shipment Environment.</p>
    <div class="row">
        <dl class="col s12">
            <span each="{ note in shipment.annotations }">
                <dt style="font-family: 'Lucida Console', Monaco, monospace;">{ note.key }</dt>
                <dd>
                    <button class="btn-floating red right" onclick="{ deleteAnnotation }"><i class="material-icons">delete</i></button>
                    <button class="btn-floating yellow darken-2 right" style="margin-right: 7px;" onclick="{ editAnnotation }"><i class="material-icons">mode_edit</i></button>
                    { note.value }
                </dd>
                <hr/>
            </span>
        </dl>
    </div>

    <div class="row">
        <div class="col s12">
            <button class="btn add-annotation-btn modal-trigger" data-target="annotation-modal" onclick="{ addAnnotation }">Add Annotation</button>
        </div>
    </div>

    <div id="annotation-modal" class="modal modal-fixed-footer">
        <annotation_modal></annotation_modal>
    </div>

    <script>
    var self = this,
        d = utils.debug;

    // begin
    addAnnotation(evt) {
        d('bridge/annotations::addAnnotation');
        // Set the title
        $('#annotation-modal #annotation-modal-title').text('Create Annotation');

        // Clear out the values
        $('#annotation-modal #annotation-key').val('');
        $('#annotation-modal #annotation-value').val('');
        $('#annotation-modal #annotation-original-key').val('');
    }

    editAnnotation(evt) {
        d('bridge/annotations::editAnnotation', evt.item.note.key);

        $('#annotation-modal #annotation-modal-title').text('Update Annotation');
        $('#annotation-modal #annotation-key').val(evt.item.note.key);
        $('#annotation-modal #annotation-value').val(evt.item.note.value);
        $('#annotation-modal #annotation-original-key').val(evt.item.note.key);
        Materialize.updateTextFields();

        $('#annotation-modal').openModal();
    }

    deleteAnnotation(evt) {
        d('bridge/annotations::deleteAnnotation', evt.item.note.key);
        var shipment = self.shipment.parentShipment.name,
            environment = self.shipment.name;

        if (window.confirm('Are you sure you want to delete Annotation "'+ evt.item.note.key +'"?\n\nThis action CANNOT be undone.')) {
            RiotControl.trigger('delete_annotation', shipment, environment, evt.item.note.key);
        }
    }

    RiotControl.on('annotations_modified', function (annotations) {
        $('.modal-action').attr('disabled', false);
        $('#annotation-modal').closeModal();
        $('#annotation-modal .fields').val('');

        self.shipment.annotations = annotations;
        self.update();
    });


    self.on('update', function () {
        self.shipment = self.opts.shipment;
    });
    // end
    </script>
</annotations>
