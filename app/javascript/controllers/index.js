// app/javascript/controllers/index.js
import { application } from "./application"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

// Eagerly load all controllers defined in controllers folder
const context = require.context("controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))


