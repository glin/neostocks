const path = require('path')
const NamedModulesPlugin = require('webpack').NamedModulesPlugin
const { VueLoaderPlugin } = require('vue-loader')

module.exports = {
  resolve: {
    extensions: ['.js', '.vue']
  },

  output: {
    path: path.resolve(__dirname, 'dist/static'),
    publicPath: '/static'
  },

  module: {
    rules: [
      {
        test: /\.vue$/,
        use: 'vue-loader'
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: 'babel-loader'
      },
      {
        test: /\.css$/,
        use: ['vue-style-loader', 'css-loader']
      },
      {
        test: /\.svg$/,
        use: 'vue-svg-loader'
      },
      {
        test: /\.(png|jpg|gif)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192
            }
          }
        ]
      }
    ]
  },

  plugins: [
    new NamedModulesPlugin(),
    new VueLoaderPlugin()
  ],

  devServer: {
    historyApiFallback: true,
    contentBase: path.resolve(__dirname, 'public')
  }
}