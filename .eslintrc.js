const aliases = require('./config/webpack/aliases');

module.exports = {
    extends: ['eslint:recommended'],
    plugins: ['import'],
    parser: 'babel-eslint',
    parserOptions: {
        ecmaVersion: 8,
        sourceType: 'module',
        allowImportExportEverywhere: true
    },
    settings: {
        'import/resolver': {
            alias: {
                map: Object.entries(aliases)
            },

            node: {
                extensions: ['.js', '.scss', '.css', '.vue', '.html']
            }
        }
    },
    env: {
        browser: true,
        es6: true,
        jquery: true,
        node: true,
        jest: true
    },
    globals: {
        noty: false,
        cy: false,
        Buffer: false
    },
    rules: {
        // enable additional rules
        // 'linebreak-style': ['error', 'unix'], // might conflict with Prettier
        'no-unused-vars': ['warn', { vars: 'local', args: 'after-used' }],
        'no-extra-bind': 'error',

        // override default options for rules from base configurations
        'no-cond-assign': ['error', 'always'],
        eqeqeq: ['warn', 'smart'],

        // disable rules from base configurations
        'block-scoped-var': 'error',
        'guard-for-in': 'error',
        'no-loop-func': 'error',
        'no-self-compare': 'error',
        'no-use-before-define': ['error', { 'functions': false }],
        'no-unneeded-ternary': 'error',
        'no-prototype-builtins': 'off',
        'no-extend-native': 'error',
        'padding-line-between-statements': [
            'error',
            // offset after variables
            { blankLine: 'always', prev: ['const', 'let', 'var'], next: '*' },
            { blankLine: 'any', prev: ['const', 'let', 'var'], next: ['const', 'let', 'var'] },

            // offset after imports
            { blankLine: 'always', prev: 'import', next: '*' },
            { blankLine: 'any', prev: 'import', next: 'import' },

            // offset after oneline if statements
            { blankLine: 'always', prev: 'if', next: '*' },
            { blankLine: 'any', prev: 'if', next: 'if' },
            { blankLine: 'any', prev: 'multiline-block-like', next: '*' }
        ],
        'no-console': ['error', { allow: ['warn', 'error'] }],
        'comma-dangle': ['error', 'never'],
        quotes: ['error', 'single'],
        semi: ['error', 'always'],
        curly: ['error', 'multi-line'],
        'lines-between-class-members': ['error', 'always', { exceptAfterSingleLine: true }],
        'padded-blocks': ['error', 'never'],
        'object-curly-spacing': ['error', 'always'],
        'array-bracket-spacing': ['error', 'never'],
        'comma-spacing': [
            'error',
            {
                before: false,
                after: true
            }
        ],
        'space-infix-ops': 'error',
        'keyword-spacing': [
            'error',
            {
                before: true,
                after: true
            }
        ],
        'comma-style': ['error', 'last'],
        'space-before-blocks': 'error',
        'arrow-spacing': [
            'error',
            {
                before: true,
                after: true
            }
        ],
        'brace-style': ['error', '1tbs', { allowSingleLine: true }],
        'template-curly-spacing': ['error', 'never'],
        'prefer-template': 'error',
        'no-useless-concat': 'error',
        'no-duplicate-imports': 'error',
        'no-param-reassign': ['error', { props: false }],
        'new-parens': ['error', 'always'],
        'default-param-last': 'error',
        'max-params': ['error', 4],
        'no-useless-computed-key': ['error', { enforceForClassMembers: true }],
        'dot-notation': 'error',
        'import/no-unresolved': [
            'error',
            {
                caseSensitive: true,
                ignore: ['^moment(-timezone)?$', '^sha256$', '^noty$']
            }
        ],
        'import/named': 'error',
        'import/default': 'error',
        'import/namespace': 'error',
        'import/no-absolute-path': 'error',
        'import/no-self-import': 'error',
        'import/no-useless-path-segments': 'error',
        'import/export': 'error',
        'import/no-deprecated': 'warn',
        'import/first': 'error',
        'import/no-namespace': 'error',
        'import/extensions': ['error', 'never', { scss: 'always', html: 'always' }],
        'import/order': ['error', { groups: ['builtin', 'external', 'internal', 'parent', 'sibling'] }],
        'import/newline-after-import': 'error'
    },
    overrides: [
        {
            files: '*.vue',
            extends: ['plugin:vue/essential'],
            plugins: ['vue'],
            rules: {
                'vue/script-indent': ['error', 2, { switchCase: 1 }],
                'vue/html-indent': ['error', 2],
                'vue/prop-name-casing': ['error', 'camelCase'],
                'vue/attribute-hyphenation': ['error', 'always'],
                'vue/component-definition-name-casing': 'error',
                'vue/component-name-in-template-casing': 'error',
                'vue/require-prop-types': 'error',
                'vue/require-default-prop': 'error',
                'vue/mustache-interpolation-spacing': ['error', 'always'],
                'vue/html-self-closing': 'error',
                'vue/html-closing-bracket-spacing': [
                    'error',
                    {
                        startTag: 'never',
                        endTag: 'never',
                        selfClosingTag: 'always'
                    }
                ],
                'vue/html-closing-bracket-newline': [
                    'error',
                    {
                        singleline: 'never',
                        multiline: 'always'
                    }
                ],
                'vue/no-spaces-around-equal-signs-in-attribute': 'error',
                'vue/singleline-html-element-content-newline': 'error',
                'vue/v-bind-style': 'error',
                'vue/v-on-style': 'error',
                'vue/component-tags-order': [
                    'error',
                    {
                        order: ['template', 'script', 'style']
                    }
                ],
                'vue/order-in-components': [
                    'error',
                    {
                        order: [
                            'el',
                            'name',
                            'functional',
                            'components',
                            'directives',
                            'mixins',
                            'inheritAttrs',
                            'model',
                            'props',
                            'propsData',
                            'data',
                            'computed',
                            'watch',
                            'LIFECYCLE_HOOKS',
                            'methods',
                            ['template', 'render']
                        ]
                    }
                ],
                'vue/this-in-template': 'error',
                'vue/block-tag-newline': [
                    'error',
                    {
                        singleline: 'always',
                        multiline: 'always'
                    }
                ],
                'vue/match-component-file-name': ['error', { extensions: ['vue'] }],
                'vue/no-empty-component-block': 'error',
                'vue/no-static-inline-styles': 'error',
                'vue/no-useless-mustaches': 'error',
                'vue/no-useless-v-bind': 'error',
                'vue/padding-line-between-blocks': ['error', 'always'],
                'vue/require-name-property': 'error',
                'vue/html-button-has-type': ['error'],
                'vue/no-unused-refs': 'error',
                'object-shorthand': ['error', 'always', { avoidQuotes: true }]
            }
        }
    ]
};
