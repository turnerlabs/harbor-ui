<app>
    <flash></flash>
    <div if={ loading } class="loading"><loading_elm if="{ loading }" isloading="{ loading }"></loading_elm></div>
    <div if={ !loading } id="app" class="app-kontainer">
        <div if={ !isAuthenticated } class="logged-out">
            <loginform></loginform>
        </div>
        <div if={ isAuthenticated } class="logged-in">
            <header>
                <nav class="blue">
                    <div class="nav-wrapper kontainer">
                        <a href="#home" class="brand-logo left-pad">Harbor</a>
                        <ul id="nav-mobile" class="right hide-on-small-only">
                            <li><a href="{ config.blog_url }"><i class="material-icons left">web</i>Blog</a></li>
                            <li><a href="{ config.argonaut_url }"><i class="material-icons left">vpn_key</i>Argonaut</a></li>
                            <li><a onclick="{ logout }"><i class="material-icons left">perm_identity</i>Logout { username }</a></li>
                        </ul>
                    </div>
                </nav>
            </header>

            <main>
                <div class="kontainer">
                    <div class="row">
                        <!-- side nav -->
                        <sidenav/>
                        <!-- /side nav -->

                        <div class="col s9half white z-depth-1" id="content">
                            <home if={ route === 'home'}/>
                            <buildit if={ route === 'buildit'} />
                            <shipyard if={ route === 'shipyard'} />
                            <bridge if={ route === 'bridge'} />
                        </div>
                    </div>
                </div>
            </main>

            <footer class="page-footer grey lighten-2">
                <div class="container grey-text text-darken-1">
                      <div class="row left-pad">
                          <div class="col s4">
                              <h5>BuildIt</h5>
                              <p class="footer-box">Build Docker images from any git repo.</p>
                              <p><a class="btn" href="#buildit">BuildIt</a></p>
                          </div>
                          <div class="col s4">
                              <h5>Shipyard</h5>
                              <p class="footer-box">The Shipyard allows you to walk through creating a new Shipment.</p>
                              <p><a class="btn" href="#shipyard/info">Shipyard</a></p>
                          </div>
                          <div class="col s4">
                              <h5>Command Bridge</h5>
                              <p class="footer-box">View and modify running Shipments.</p>
                              <p><a class="btn" href="#bridge">Command Bridge</a></p>
                          </div>
                      </div>
                </div>
                <div class="footer-copyright">
                    <div class="container grey-text text-darken-1">
                        Harbor version { config.version }
                    </div>
                </div>
            </footer>
        </div>
    </div>

    <script>
        var self = this,
            d = utils.debug,
            hasSetUpdate = false;

        self.config = window.config;
        self.isAuthenticated;
        self.username;

        self.loading = true;

        self.logout = function() {
            RiotControl.trigger('clear_state');
            ArgoAuth.logout(function() {
                location.reload();
            });
        };

        self.on('mount', function() {
            ArgoAuth.isAuthenticated(function(data) {
                authCallback(data);
                self.update();
            });
        });

        riot.route(function (route, type, env) {
            d('app::route(%s) type(%s) env(%s)', route, type, env);
            RiotControl.trigger('app_changed', route, type, env);
            self.route = route.replace('#', '');
            ArgoAuth.isAuthenticated(authCallback);
            self.update();
        });

        function authCallback(data) {
            self.loading = false;
            if (data.success) {
                self.isAuthenticated = true;
                self.username = ArgoAuth.getUser();
                RiotControl.trigger('get_user_groups');
                RiotControl.trigger('get_users');
            } else {
                self.isAuthenticated = false;
                self.username = null;
                RiotControl.trigger('clear_state');
            }
        }

    </script>

    <style>
        #content h1 {
            font-size: 2.5rem;
        }

        #content h2 {
            font-size: 2.2rem;
        }

        #content h3 {
            font-size: 2.1rem;
        }

        #content h4 {
            font-size: 2rem;
        }

        #content h5 {
            font-size: 1.5rem;
        }

        #content p {
            font-size: 1rem;
        }

        .footer-box {
            min-height: 50px;
        }

        .loading {
            max-width: 150px;
            padding: 15px;
            margin: 75px auto;
            color: white;
            font-size: 25px;
        }

        .nav-wrapper a {
            text-decoration: none;
        }

        .nav-wrapper  a.brand-logo {
            transition: background-color .3s;
            padding-left: 15px;
            padding-right: 15px;
        }

        .nav-wrapper a.brand-logo:hover {
            background-color: rgba(0, 0, 0, 0.1);
        }
    </style>
</app>
