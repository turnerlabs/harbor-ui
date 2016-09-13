<raw-html>
    <span></span>

    <script>
        var self = this,
            timeframe,
            set = false;

        self.on('update', function() {
            if ((!set || timeframe !== self.opts.timeframe) && self.opts.html) {
                set = true;
                timeframe = self.opts.timeframe;
                self.root.innerHTML = self.opts.html;
            }
        });
    </script>
</raw-html>
