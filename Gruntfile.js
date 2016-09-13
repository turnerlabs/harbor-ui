'use strict';

var normalize = require('path').normalize,
    ls = require('fs').readdirSync;

module.exports = function (grunt) {
    // Load tasks
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-jscs');
    grunt.loadNpmTasks('grunt-riot');
    grunt.loadNpmTasks('grunt-mocha-test');

    // Config tasks
    grunt.initConfig({
        jscs: {
            src: [
                /* include */
                'Gruntfile.js',
                'public/js/src/**/*.js',

                /* exclude */
                '!public/js/vendor/**/*.js',
                '!public/js/_tag/**/*.js'
            ],
            options: {
                config: '.jscsrc'
            }
        },

        jshint: {
            files: {
                src: [
                    'Gruntfile.js',
                    'public/js/src/**/*.js',
                    'test/**/*.js'
                ]
            },
            options: {
                jshintrc: normalize('.jshintrc'),
                ignores: [
                    'test/chai.js',
                    'test/mocha.js'
                ]
            }
        },

        riot: {
            options: {
                concat: true,
                compact: false
            },
            dist: {
                src: 'public/js/src/**/*.tag',
                dest: 'public/js/main.js'
            }
        },

        mochaTest: {
            test: {
                options: {
                    reporter: 'spec',
                    require: 'test/coverage-blanket'
                },
                src: ['test/app.js']
            },
            coverage: {
                options: {
                    reporter: 'html-cov',
                    quiet: true,
                    captureFile: 'code-coverage.html'
                },
                src: ['test/app.js']
            }
        },

        uglify: {
            myTarget: {
                files: {
                    'public/js/main.min.js': ['public/js/main.js']
                }
            }
        },

        watch: {
            scripts: {
                files: ['.jshintrc', '.jscsrc', 'Gruntfile.js', 'public/js/src/**/*.js', 'public/js/src/**/*.tag'],
                tasks: ['jshint', 'jscs', 'riot', 'uglify'],
                options: {
                    spawn: false
                }
            }
        }
    });

    // Register tasks
    grunt.registerTask('build', ['riot', 'uglify']);
    grunt.registerTask('test', ['jshint', 'jscs', 'mochaTest']);
    grunt.registerTask('default', ['watch']);
};
