/* eslint-disable no-undef */

const path = require('path');
const utils = require('./utils');

const output = utils.root(`public/${process.env.SOURCE_DIRECTORY}`);
const loadersDir = path.join(__dirname, 'loaders');
const manifest = {
    dev: utils.root(`public/${process.env.SOURCE_DIRECTORY}/manifest.json`),
    prod: utils.root(`public/${process.env.SOURCE_DIRECTORY}/manifest.json`)
};
const sslPath = process.env.SSLPATH;

module.exports = {
    global,
    output,
    manifest,
    loadersDir,
    sslPath
};
