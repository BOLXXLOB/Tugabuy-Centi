import  express from "express"
import { createChat,getAllChats,getChatById,deleteChatById,getChatsByUser,getChatsByOwner } from "../controllers/chatcontroller";
import { isValidToken } from "../middleware/tokenvalidation";

const router = express.Router()

router.route("/").post(isValidToken,createChat).get(isValidToken,getAllChats)
router.route("/user/:userId").get(isValidToken,getChatsByUser)
router.route("/owner/:ownerId").get(isValidToken, getChatsByOwner);
router.route("/:id").get(isValidToken,getChatById).delete(isValidToken,deleteChatById)


export default router