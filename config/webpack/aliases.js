/* eslint-disable no-undef */
const { resolve } = require('path');

const rootPath = resolve(process.cwd(), 'app/frontend');

// For adding and editing aliases you also have to change jsconfig.json and jest.config.js. Also, check config/webpack/loaders/shared.js, there are a few aliases too.
module.exports = {
    '@': resolve(rootPath, 'packs'),
    '@styles': resolve(rootPath, 'styles'),
    '@images': resolve(rootPath, 'images'),
    '@shared': resolve(rootPath, 'packs/shared')
};
