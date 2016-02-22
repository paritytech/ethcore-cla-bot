'use strict'

_      = require 'lodash'
MongoClient = require('mongodb').MongoClient

col = null

MongoClient.connect process.env.MONGO_URL, (err, db) ->
  throw err if err
  db.collection 'signers', (err, collection) ->
    throw err if err
    col = collection

exports.getProfile = (id, callback) ->
  col.findOne id: id, (err,res) ->
    callback err, res

exports.saveOrCreateSigner = (profile, callback) ->
  col.update {id: profile.id}, {$set: profile, $push: {loggedInAt: new Date()}}, {upsert:true}, (err,res) ->
    callback(null, profile.id)

exports.save = (req, res, done) ->
  unless req.isAuthenticated()
    res.end 'No Auth'
  else
    if not req.query
      console.log 'Invalid form data received'
      res.end req.form.errors or 'Invalid form data received'

    else
      col.update id: req.user.id,
        $set:
          name: req.query.name
          email: req.query.email
          signed: true
        $push:
          signedAt: new Date()
      , (err, update) ->
        if err
          res.end err
        else
          res.end 'Submission Saved'

exports.getContractors = (callback) ->
  col.find({signed:true}, {username:1}).toArray (err, docs) ->
    if err
      console.log 'Database Error'
      callback []
    else
      callback(_.pluck(docs, 'username'))

exports.saveOrCreateSigner