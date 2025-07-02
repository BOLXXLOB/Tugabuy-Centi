import  express from "express"
import { createMessage,getAllMessages,getMessageById,getMessageByChat,deleteMessageById,updateMessageById} from "../controllers/messagecontroller"
import { isValidToken } from "../middleware/tokenvalidation"

const router = express.Router()

router.route("/").post(isValidToken,createMessage).get(isValidToken,getAllMessages)
router.route("/chat/:chatId").get(isValidToken, getMessageByChat);
router.route("/:id").get(isValidToken,getMessageById).delete(isValidToken,deleteMessageById).patch(isValidToken,updateMessageById)


export default router