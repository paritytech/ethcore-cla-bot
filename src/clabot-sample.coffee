'use strict'

express = require 'express'
jade    = require 'jade'

data     = require './lib/data'

passport = require('passport')
GitHubStrategy = require('passport-github').Strategy

passport.use new GitHubStrategy
  clientID: 'x'
  clientSecret: 'x'
  callbackURL: "http://localhost:1337/auth/github/callback"
, (accessToken, refreshToken, profile, cb) ->
  data.saveOrCreateSigner profile, (err) ->
    cb(err, profile)

app = express.createServer()

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  data.getProfile id, (err, profile) ->
    done null, profile

app.use express.cookieParser()
app.use express.session({ secret: 'x' })
app.use passport.initialize()
app.use passport.session()
app.use require('connect-assets')()
app.use express.compress()

app.get '/logout', (req,res) ->
  req.session.destroy()
  res.redirect '/'

app.get '/', (req,res) ->
  if req.isAuthenticated()
    res.redirect '/form/parity'
  else
    res.render 'landing.jade', layout: no

app = require('clabot').createApp
  app: app
  getContractors: data.getContractors
  token: 'process.env.GITHUB_TOKEN'
  templateData:
    link: 'http://clabot.github.com/individual.html'
    maintainer: 'boennemann'
  secrets:
    clabot:
      sandbox: 'process.env.HUB_SECRET'
      clabot: 'process.env.HUB_SECRET'


# auth
app.get '/auth/github', passport.authenticate('github')

app.get '/auth/github/callback', passport.authenticate('github', { failureRedirect: '/login' }), (req, res) ->
    res.redirect('/form/parity')

app.get '/sign', data.save

app.get '/form/:project/:kind?', (req, res) ->

  unless req.isAuthenticated()
    res.redirect('/')
    return

  project = req.params.project
  # Makes no sense, yet. Extensible in the future.
  if project isnt 'clabot' then project = 'clabot'
  kind    = req.params.kind?.toLowerCase() || 'Individual'
  kind    = kind.charAt(0).toUpperCase() + kind.slice 1
  if kind isnt 'Entity' then kind = 'Individual'

  res.render 'form.jade',
    user : req.user
    layout: no

port = process.env.PORT or 1337

app.listen port
console.log "Listening on #{port}"
