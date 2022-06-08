/* eslint-disable no-undef */

const { HotModuleReplacementPlugin } = require('webpack');
const webpackMerge = require('webpack-merge');
const ManifestPlugin = require('webpack-manifest-plugin');
const { root } = require('./utils');
const { manifest } = require('./settings');
const commonConfig = require('./common');

const publicPath = 'http://localhost:3035/';

module.exports = webpackMerge(commonConfig, {
    mode: 'development',
    output: {
        pathinfo: true,
        filename: '[name].js',
        publicPath,
        hotUpdateChunkFilename: 'hot/[id].[hash].hot-update.js',
        hotUpdateMainFilename: 'hot/[hash].hot-update.json'
    },
    devServer: {
        host: process.env.WEBPACK_HOST || 'localhost',
        port: 3035,
        compress: true,
        hot: true,
        devMiddleware: {
          stats: { colors: true }
      },
      client: false,
      // client: {
      //   logging: 'none',
      //   overlay: {
      //       warnings: true,
      //       errors: true
      //   },
      // },
      historyApiFallback: true,
      static: {
        directory: root('public/assets'),
      },
      headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
      }
    },
    stats: { errorDetails: true },
    watchOptions: { aggregateTimeout: 100 },
    devtool: 'eval-cheap-module-source-map',
    plugins: [
        new HotModuleReplacementPlugin(),
        new ManifestPlugin({
            fileName: manifest.dev,
            publicPath,
            writeToFileEmit: true
        })
    ]
});
