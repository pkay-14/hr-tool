const utils = require('../utils');

module.exports = {
    test: /\.js$/,
    include: [utils.root('app/frontend')],
    exclude: /node_modules/,
    use: {
        loader: 'babel-loader',
        options: {
            cacheDirectory: true
        }
    }
};
