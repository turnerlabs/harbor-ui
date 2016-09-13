"use strict";

let dogapi = require('dogapi');

let e = module.exports;
e.createEmbed = createEmbed;

let options = {
  api_key: process.env.DATADOG_API_KEY,
  app_key: process.env.DATADOG_APP_KEY
};

dogapi.initialize(options);

function createEmbed(data, callback) {
    let options = {
        timeframe: data.timeframe,
        size: data.size,
        legend: data.legend,
        title: data.title
    };
    dogapi.embed.create(data.graph_json, options, callback);
}

