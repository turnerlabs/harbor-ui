<flash>
    <script>
    var d = utils.debug;
    RiotControl.on('flash_message', function(type, message, timer) {
        d('flash::flash_message', type, message, timer);
        Materialize.toast(message, timer || 4000, type || '');
    });
    </script>
    <style>
        .error {
            background-color: #F44336;
        }

        .passed {
            background-color: #4CAF50;
        }

        .success {
            background-color: #4CAF50;
        }
    </style>
</flash>
