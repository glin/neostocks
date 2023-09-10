const path = require('path')
const { VueLoaderPlugin } = require('vue-loader')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const CssMinimizerPlugin = require('css-minimizer-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin')

module.exports = (env, argv) => ({
  entry: './ui',

  resolve: {
    extensions: ['.js', '.vue']
  },

  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'dist/static'),
    publicPath: '/static/'
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
        use: [
          argv.mode === 'development' ? 'vue-style-loader' : MiniCssExtractPlugin.loader,
          'css-loader',
          {
            loader: 'postcss-loader',
            options: {
              postcssOptions: {
                plugins: [require('autoprefixer')]
              }
            }
          }
        ]
      },
      {
        test: /\.scss$/,
        use: [
          argv.mode === 'development' ? 'vue-style-loader' : MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              // Disable url() resolving for fonts. These should be preloaded and cached
              // long-term under /static/fonts/.
              url: false
            }
          },
          {
            loader: 'postcss-loader',
            options: {
              postcssOptions: {
                plugins: [require('autoprefixer')]
              }
            }
          },
          'sass-loader'
        ]
      },
      {
        test: /\.svg$/,
        use: 'vue-svg-loader'
      },
      {
        // Embed images as data URIs
        test: /\.(png|jpg|gif|ico)$/,
        type: 'asset/inline'
      },
      {
        test: /\.html$/,
        use: {
          loader: 'html-loader',
          options: {
            // Disable attribute processing; preserve URLs as-is in index.html
            sources: false
          }
        }
      }
    ]
  },

  plugins: [
    new VueLoaderPlugin(),
    new HtmlWebpackPlugin({
      template: 'ui/assets/index.html',
      filename: path.resolve(__dirname, 'dist/index.html')
    }),
    new CopyWebpackPlugin([
      {
        from: path.resolve(__dirname, 'public')
      }
    ]),
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash].css'
    })
  ],

  optimization: {
    moduleIds: 'named',
    minimizer: [
      new TerserPlugin(),
      new CssMinimizerPlugin()
    ]
  },

  devServer: {
    historyApiFallback: true,
    contentBase: path.resolve(__dirname, 'public')
  }
})
