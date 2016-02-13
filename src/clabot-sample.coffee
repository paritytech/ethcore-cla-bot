'use strict'

express = require 'express'
jade    = require 'jade'

data     = require './lib/data'

passport = require('passport')
GitHubStrategy = require('passport-github').Strategy

passport.use new GitHubStrategy
  clientID: process.env.CLIENT_ID
  clientSecret: process.env.CLIENT_SECRET
  callbackURL: process.env.CALLBACK_URL
, (accessToken, refreshToken, profile, cb) ->
  data.saveOrCreateSigner profile, (err) ->
    cb(err, profile)

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  data.getProfile id, (err, profile) ->
    done null, profile

app = express.createServer()
app.use express.cookieParser()
app.use express.session({ secret: process.env.SESSION_SECRET })
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

# create secrets object
secrets = {}
secrets[process.env.GITHUB_REPO_OWNER] = {}
secrets[process.env.GITHUB_REPO_OWNER][process.env.GITHUB_REPO] = process.env.HUB_SECRET

app = require('clabot').createApp
  app: app
  getContractors: data.getContractors
  token: process.env.GITHUB_TOKEN
  secrets: secrets

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
