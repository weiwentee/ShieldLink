const path = require('path');

module.exports = {
  entry: './web/sw.js', // Entry point for your service worker
  output: {
    path: path.resolve(__dirname, 'web/sw'),
    filename: 'sw.js', // Output bundled service worker
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env'], // Transpile modern JavaScript
          },
        },
      },
    ],
  },
  mode: 'production', // Minifies the output
};
