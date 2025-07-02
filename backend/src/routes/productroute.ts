import  express from "express"
import { createProduct,getAllProducts,getProductById,getProductsByUser,deleteProductById,updateProductById,imageToProduct,getAllDataProduct,getProductsByCategory,getAllProductsExceptLoggedUser } from "../controllers/productcontroller"
import { isValidToken } from "../middleware/tokenvalidation"
import { processImage } from "../middleware/upload"

const router = express.Router()

router.route("/").post(isValidToken,createProduct).get(isValidToken,getAllProducts)
router.route("/product/:id").get(isValidToken, getAllDataProduct)
router.route("/category/:categoryId").get(isValidToken, getProductsByCategory)
router.route("/user/:userId").get(isValidToken, getProductsByUser);
router.get('/products', isValidToken, getAllProductsExceptLoggedUser);
router.route("/:id").get(isValidToken,getProductById).delete(isValidToken,deleteProductById).patch(isValidToken,updateProductById).post(isValidToken,processImage,imageToProduct)


export default router