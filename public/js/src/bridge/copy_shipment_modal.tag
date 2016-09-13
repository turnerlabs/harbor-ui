<copy_shipment_modal>

  <!-- Modal Structure -->
  <div id="{modalId}" name="{modalId}" class="modal">
    <div class="modal-content">
        <h4>Copy {shipment.parentShipment.name} {shipment.name}</h4>
         <div class="row">
            <div class="col s6">
                <loading_elm if={ loading } isloading="{ loading }"></loading_elm>
                <dl if="{errors}" each={ key,step in errors }>
                    <dt><h5>Errors with step: { key } </h5></dt>
                    <dd if="{step.length}" each="{error in step}">
                        <p if="{!error.body.map}">{error.body}</p>
                        <p if="{error.body.map}" each="{err in error.body}">
                            <strong>{err.field}</strong>
                            {err.requirement}
                        </p>
                    </dd>
                </dl>
            </div>
        </div>
        <div class="row">
            <div class="col s6">
                <h5>Select Environment</h5>
                <select class="copy-environment-select" onchange={ setEnvironment } style="width: 100%">
                    <option each={ environments } selected={ parent.shipment.name == name }>{ name }</option>
                </select>
            </div>
        </div>
    </div>
    <div class="modal-footer">
      <button onclick="{saveShipment}" class="waves-effect waves-green btn-flat">Copy</button>
      <button onclick="{closeModal}" class="modal-action modal-close waves-effect waves-red btn-flat">Cancel</button>
    </div>
  </div>

  <script>
  var self = this;

  setEnvironment(evt) {
      var val = $(evt.target).val().toLowerCase();
      self.shipment.name = val;
      self.update();
  }

  saveShipment(evt) {
    var convertedShipment = utils.convertShipment(self.shipment);
    // Build Shipment
    self.loading = true;
    self.errors = null;
    RiotControl.trigger('bridge_create_shipment', convertedShipment);
    evt.stopPropagation();
  }

  closeModal(evt) {
      $('#' + self.modalId).closeModal();
  }

  RiotControl.on('bridge_create_shipment_result', function(status, data) {

        if (status === 200 && data.errors) {
            RiotControl.trigger('flash_message', 'error', "Errors while creating shipment");
        }

        if (status === 200 && !data.errors) {
            self.closeModal();
            riot.route('#bridge/' + self.shipment.parentShipment.name + '/' + self.shipment.name);
        } else {
            self.errors = data.errors;
        }

        self.loading = false;
        self.update();
  });

  self.on('mount', function() {
    setTimeout(function() { $('.copy-environment-select').select2({tags: true})}, 1000);
  });

  self.on('update', function() {
      self.modalId = self.opts.targetid;
      self.shipment = self.opts.shipment;
      self.environments = [
        {name: 'private-' + ArgoAuth.getUser()},
        {name: 'dev'},
        {name: 'ref'},
        {name: 'qa'},
        {name: 'staging'},
        {name: 'prod'}
      ];
      self.update();
  });
  </script>
  <style>
  </style>


</copy_shipment_modal>
