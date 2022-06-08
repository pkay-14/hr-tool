/* eslint-disable no-undef */

module.exports = {
    test: /\.(gif|svg|png|jpe?g)$/,
    use: [
        {
            loader: 'file-loader',
            options: { name: '[name].[ext]' }
        },
        {
            loader: 'image-webpack-loader',
            options: {
                gifsicle: { enabled: false },
                optipng: { enabled: false }
            }
        }
    ]
};
