const path = require('path')
const NamedModulesPlugin = require('webpack').NamedModulesPlugin
const { VueLoaderPlugin } = require('vue-loader')
const HtmlWebpackPlugin = require('html-webpack-plugin')

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
        test: /\.(png|jpg|gif|ico)$/,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192
            }
          }
        ]
      },
      {
        test: /\.html$/,
        use: {
          loader: 'html-loader',
          options: {
            attrs: ['link:href']
          }
        }
      }
    ]
  },

  plugins: [
    new NamedModulesPlugin(),
    new VueLoaderPlugin(),
    new HtmlWebpackPlugin({
      template: 'src/assets/index.html',
      filename: path.resolve(__dirname, 'dist/index.html')
    })
  ],

  devServer: {
    historyApiFallback: true,
    contentBase: path.resolve(__dirname, 'public')
  }
}