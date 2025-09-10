import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
// controllers 配下の *_controller.js を自動登録
eagerLoadControllersFrom("controllers", application)