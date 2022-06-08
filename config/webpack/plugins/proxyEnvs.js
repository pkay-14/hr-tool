const { DefinePlugin } = require('webpack');

module.exports = {
    /**
     * Create webpack plugin for injecting allowed env variables
     * @param envs {Array<String>} list of env names
     * @return {DefinePlugin}
     */
    proxyEnvs(envs) {
        const proxyingEnvs = {};

        envs.forEach(env => (proxyingEnvs[env] = process.env[env]));

        return new DefinePlugin({
            'process.env': JSON.stringify(proxyingEnvs)
        });
    }
};
