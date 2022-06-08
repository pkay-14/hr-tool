/* eslint-disable no-undef */

const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const isDev = process.env.NODE_ENV === 'development';

module.exports = {
    test: /\.s?css$/,
    use: [
        isDev ? 'style-loader' : MiniCssExtractPlugin.loader,
        {
            loader: 'css-loader', // translates CSS into CommonJS
            options: { sourceMap: true }
        },
        {
            loader: 'postcss-loader'
        },
        'resolve-url-loader',
        {
            loader: 'sass-loader', // compiles Sass to CSS, using Node Sass by default
            options: {
                sourceMap: true,
            }
        }
    ]
};
