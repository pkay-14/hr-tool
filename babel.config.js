const aliases = require('./config/webpack/aliases');

module.exports = function(api) {
    api.cache(true);

    const presets = [
        [
            '@babel/preset-env',
            {
                ignoreBrowserslistConfig: false
            }
        ]
    ];
    const plugins = [
        '@babel/plugin-transform-runtime',
        '@babel/plugin-proposal-object-rest-spread',
        '@babel/plugin-proposal-optional-chaining',
        '@babel/plugin-syntax-dynamic-import',
        '@babel/plugin-proposal-class-properties',
        [
            'module-resolver',
            {
                root: ['./app/frontend'],
                alias: aliases
            }
        ]
    ];

    return {
        presets,
        plugins
    };
};
