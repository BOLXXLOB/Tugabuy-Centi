import  express from "express"
import { createUser,getAllUsers,getUserById,deleteUserById,updateUserById,imageToUser, getAllDataUser,changePassword } from "../controllers/usercontroller";
import { isValidToken } from "../middleware/tokenvalidation";
import { processImage } from "../middleware/upload";

const router = express.Router()

router.route("/").post(createUser).get(isValidToken, getAllUsers)
router.route("/profile/:id").get(isValidToken, getAllDataUser).patch(isValidToken, changePassword)
router.route("/:id").get(isValidToken,getUserById).delete(isValidToken,deleteUserById).patch(isValidToken,updateUserById).post(isValidToken,processImage,imageToUser)

export default router