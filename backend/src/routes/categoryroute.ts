import  express from "express"
import { createCategory,getAllCategories,getCategoryById,deleteCategoryById,updateCategoryById } from "../controllers/categorycontroller"
import { isValidToken } from "../middleware/tokenvalidation"

const router = express.Router()

router.route("/")
    .post(isValidToken,createCategory)
    .get(isValidToken,getAllCategories)

router.route("/:id")
    .get(isValidToken,getCategoryById)
    .delete(isValidToken,deleteCategoryById)
    .patch(isValidToken,updateCategoryById)


export default router