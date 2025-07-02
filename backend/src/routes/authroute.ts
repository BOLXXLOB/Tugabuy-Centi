import  express from "express"
import { login,logout } from "../controllers/authcontroller"

const router = express.Router()

router.route("/login").post(login)
router.route("/logout/:id").get(logout)


export default router