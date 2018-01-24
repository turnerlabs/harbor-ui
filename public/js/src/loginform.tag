<loginform>

    <div class="container" name="formcontainer">
        <div class="row">
            <div class="col s12"></div>
        </div>
        <div class="row">
            <div class="col s12 m4 spacer"></div>
            <div class="col s12 m4 white z-depth-1">
              <img src="{logo}" />
              <h1>Harbor</h1>
              <p><input
                     type="text"
                     name="username"
                     class="form-control"
                     placeholder="NT Username"
                     required autofocus /></p>
              <p><input type="password"
                     name="password"
                     class="form-control"
                     placeholder="NT Password"
                     required /></p>
                  <div class="container">
                    <button id="login"
                     type="submit"
                     onclick="{ login }"
                     class="btn btn-lg btn-primary">Sign in</button>
                </div>
              <p>&nbsp;</p>
            </div>
            <div class="col s12 m4 spacer"></div>
      </div>

    </div> <!-- /container -->

    <script>

        var self = this,
            d = utils.debug;

        self.login = login;
        self.logo = window.config.main_logo;

        $(this.formcontainer).keypress(function(evt) {
            if (evt.which === 1 || evt.which === 13) {
                login(evt);
            }
        });

        function login(evt) {
            ArgoAuth.login(self.username.value, self.password.value, function(data) {
                d('loginform::ArgoAuth.login', data);

                if (data.success) {
                    self.parent.isAuthenticated = true;
                    RiotControl.trigger('send_metric', 'app.login');
                } else {
                  RiotControl.trigger('flash_message', 'error', data.error);
                  RiotControl.trigger('send_metric', 'app.login', data.error);
                  self.username.value = '';
                  self.password.value = '';
                }

                RiotControl.trigger('get_user_groups');

                self.parent.update();
            });
        }

    </script>

    <style scoped>

        .container {
            text-align: center;
        }

        img {
          width: 50%;
          margin-bottom: -36px;
        }

        .spacer {
            border: 1px solid #eee;
        }

        button {
            width: 116px;
        }

    </style>
</loginform>
