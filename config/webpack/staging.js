/* eslint-disable no-undef */

const webpackMerge = require('webpack-merge');
const ManifestPlugin = require('webpack-manifest-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CompressionPlugin = require('compression-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const commonConfig = require('./common');
const settings = require('./settings');

const publicPath = `${process.env.PUBLIC_HOST}/${process.env.SOURCE_DIRECTORY}/`;

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
        new CleanWebpackPlugin(),
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
