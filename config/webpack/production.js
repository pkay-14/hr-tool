/* eslint-disable no-undef */

const webpackMerge = require('webpack-merge');
const ManifestPlugin = require('webpack-manifest-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CompressionPlugin = require('compression-webpack-plugin');
const commonConfig = require('./common');
const settings = require('./settings');

const publicPath = `${process.env.WEBPACK_PUBLIC_PATH}/`;

module.exports = webpackMerge(commonConfig, {
    mode: 'production',
    bail: true,
    output: {
        path: settings.output,
        publicPath,
        chunkFilename: '[name].[hash].chunk.js',
        filename: '[name].[hash].js'
    },
    stats: { warnings: false },
    plugins: [
        new MiniCssExtractPlugin({ filename: '[name].[hash].css' }),
        new CompressionPlugin({
            algorithm: 'gzip',
            test: /\.(js|css|html|svg)$/,
            threshold: 10240,
            minRatio: 0.8
        }),
        new ManifestPlugin({
            fileName: settings.manifest.prod,
            publicPath,
            writeToFileEmit: true
        })

    ]
});
