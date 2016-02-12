'use strict'

_      = require 'lodash'
MongoClient = require('mongodb').MongoClient

col = null
url = 'mongodb://localhost:27017/cla';
MongoClient.connect url, (err, db) ->
  db.collection 'signers', (err, collection) ->
    console.log err if err
    col = collection

exports.save = (req, res) ->
  res.header 'Access-Control-Allow-Origin',  'localhost'

  if not req.form.isValid
    console.log 'Invalid form data received'
    res.send 400, req.form.errors or 'Invalid form data received'

  else
    form = req.form
    col.findOne {github: form.github}, (err, update) ->
      console.log 'form.github', form.github, update
      cb = (err, dbres) ->
        if err
          console.log    err
          console.log   'Database Error'
          res.send 500
        else
          console.log   'Submission Saved'
          res.send 200

      if update
        console.log   'Already Registered'
        res.send 200
      else
        col.save form, cb

exports.getContractors = (callback) ->
  col.find({}, {github:1}).toArray (err, docs) ->
    if err
      console.log 'Database Error'
      callback []
    else
      callback(_.pluck(docs, 'github'))