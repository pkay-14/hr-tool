/* eslint-disable no-undef */

const { join } = require('path');
const webpack = require('webpack');
const { VueLoaderPlugin } = require('vue-loader');
const { sync } = require('glob');
const utils = require('./utils');
const settings = require('./settings');
const { proxyEnvs } = require('./plugins/proxyEnvs');
const aliases = require('./aliases');

module.exports = {
    entry: {
      // admin: './app/frontend/packs/admin.js',
      timeOffDetails: './app/frontend/packs/timeOffDetails.js',
      setupAxios: './app/frontend/packs/shared/setup-axios.js'
    },
    resolve: {
        alias: aliases,
        extensions: ['.js', '.vue', '.css', '.scss', '.svg', '.png', '.jpg', '.json', '.html'],
        modules: [utils.root('app/frontend/packs'), 'node_modules']
    },
    module: {
        rules: sync(join(settings.loadersDir, '*.js')).map((loader) => require(loader))
    },
    optimization: {
        runtimeChunk: { name: 'common' },
        splitChunks: {
            cacheGroups: {
                vendor: {
                    test: /node_modules/,
                    name: 'common',
                    chunks: 'async',
                    enforce: true
                }
            }
        }
    },
    node: {
        setImmediate: false,
        dgram: 'empty',
        fs: 'empty',
        net: 'empty',
        tls: 'empty',
        child_process: 'empty'
    },
    stats: { children: false },
    plugins: [
        new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/),
        new webpack.ProvidePlugin({
            $: 'jquery',
            jQuery: 'jquery',
            jquery: 'jquery',
            'window.jQuery': 'jquery'
        }),
        new VueLoaderPlugin(),

        // Proxy allowed only envs to frontend js
        proxyEnvs(['CABLE_URL', 'IMAGE_BULK_UPLOAD_URL', 'NODE_ENV'])
    ]
};
