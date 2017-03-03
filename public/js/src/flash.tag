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
            /* red darken-1 */
            background-color: #e53935;
        }

        .passed {
            /* green darken-1 */
            background-color: #43a047;
        }

        .message {
            /* light-blue darken-1 */
            background-color: #039be5
        }

        .success {
            /* green darken-1 */
            background-color: #43a047;
        }
    </style>
</flash>
