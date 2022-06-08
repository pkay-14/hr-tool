/* eslint-disable no-undef */

module.exports = {
    plugins: {
        autoprefixer: { grid: false, flexbox: 'no-2009' },
        cssnano: process.env.NODE_ENV === 'production' ? { zindex: false, reduceIdents: { keyframes: false } } : false
    }
};
