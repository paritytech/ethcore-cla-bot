'use strict'

form  = require 'express-form'

field = form.field

exports = module.exports = form(
  field('name').trim().required()
  field('email').trim().required().isEmail()
  field('github').trim().required().is /^[a-zA-Z0-9\_\-]+$/
  field('country').trim().required()
  field('signature').trim().equals('I AGREE')
  field('project').trim().required()
  field('kind').trim().required()
)
