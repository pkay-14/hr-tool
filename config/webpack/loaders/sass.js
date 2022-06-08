/* eslint-disable no-undef */

module.exports = {
    test: /\.sass$/,
    use: [
      'vue-style-loader',
      'css-loader',
      {
        loader: 'sass-loader', // compiles Sass to CSS, using Node Sass by default
        options: {
          sourceMap: true,
        }
      }
    ]
};
