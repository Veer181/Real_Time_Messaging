 // app/javascript/controllers/index.js
import { application } from "./application"
import HelloController from "./hello_controller"

// Eagerly load controllers (manually registered)
application.register("hello", HelloController)
