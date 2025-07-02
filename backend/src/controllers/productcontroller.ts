import { Request, Response } from "express"
import Product from "../models/productmodels";
import Category from "../models/categorymodels";
import User from "../models/usermodel";
import { CustomRequest } from "../middleware/tokenvalidation";
import { UploadDir, fs } from "..";
import path from "path";
import { existsSync } from "fs";
import { redisClient } from "../comunication/redis";

const createProduct = async (req: CustomRequest, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const { name, desc, price, id_category, id_user, image } = req.body;


    if (!name || !desc || !price || !id_category || !id_user) {
        res.status(400).json({ message: "Missing fields in request" })
        return
    }

    const existcategory = await Category.findById(id_category)
    if (!existcategory) {
        res.status(409).json({ message: "The category does not exist" })
        return
    }
    const existuser = await User.findById(id_user)
    if (!existuser) {
        res.status(409).json({ message: "The user does not exist" })
        return
    }

    let product = await Product.create(req.body)


    if (!product) {
        res.status(422).json({ message: "Error creating product" })
        return
    }

    await redisClient.set(`${product._id}`, JSON.stringify(product));
    res.status(201).json(product)
}

const getAllProducts = async (req: CustomRequest, res: Response): Promise<void> => {

    const cacheKey = "all_products";
    const cachedProducts = await redisClient.get(cacheKey);
    if (cachedProducts) {
        res.status(200).json(JSON.parse(cachedProducts));
        return;
    }

    const products = await Product.find()
    await redisClient.set(cacheKey, JSON.stringify(products), { EX: 600 });
    res.status(200).json(products)
}

const getProductById = async (req: CustomRequest, res: Response): Promise<void> => {
    const productId = req.params.id;

    const cachedProducts = await redisClient.get(productId);
    if (cachedProducts) {
        res.status(200).json(JSON.parse(cachedProducts));
        return;
    }

    const product = await Product.findById(productId);
    if (!product) {
        res.status(404).json({ message: "Product not found" });
    }

    await redisClient.set(productId, JSON.stringify(product), { EX: 3600 });
    res.status(200).json(product)
}

const getProductsByUser = async (req: CustomRequest, res: Response): Promise<void> => {
    const userId = req.params.userId;

    if (!userId) {
        res.status(400).json({ message: "Missing user in request" });
        return;
    }
    const cachedProducts = await redisClient.get(`${userId}`);
    if (cachedProducts) {
        res.status(200).json(JSON.parse(cachedProducts));
        return;
    }
    const user = await User.findById(userId);
    if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
    }

    const products = await Product.find({ id_user: userId });

    await redisClient.set(`${userId}`, JSON.stringify(products), { EX: 1800 });

    res.status(200).json(products);
};

const deleteProductById = async (req: CustomRequest, res: Response): Promise<void> => {


    const product = await Product.findById(req.params.id)
    if (!product) {
        res.status(404).json({ message: "Product not found" });
    }

    const userid = await User.findById(product!.id_user)

    if (req.user._id.toString() != userid?._id.toString()) {
        res.status(403).json({ message: "Access denied" });
    }

    await Product.findByIdAndDelete(req.params.id);
    await redisClient.del(req.params.id);
    await redisClient.del("all_products");
    res.status(200).json({ message: "Product successfully deleted" });
}

const updateProductById = async (req: CustomRequest, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const existproduct = await Product.findById(req.params.id)

    if (!existproduct) {
        res.status(404).json({ message: "Product not found" });
    }

    const userid = await User.findById(existproduct!.id_user)


    if (req.user._id.toString() !== userid?._id.toString()) {
        res.status(403).json({ message: "Access denied!" });
    }

    const validfield = ["name", "desc", "price", "id_category", "id_user"]
    const field = Object.keys(req.body)
    const allfieldarevalid = field.every(field => validfield.includes(field))

    if (!allfieldarevalid) {
        res.status(400).json({ message: "Request contain invalid fields" })
        return
    }

    if (req.body.id_category) {
        const existcategory = await Category.findById({ _id: req.body.id_category })
        if (!existcategory) {
            res.status(409).json({ message: "The category does not exist" })
            return
        }
    }
    if (req.body.id_user) {
        const existuser = await User.findById({ _id: req.body.id_user })
        if (!existuser) {
            res.status(409).json({ message: "The user does not exist" })
            return
        }
    }


    let product = await Product.findOneAndUpdate({ _id: req.params.id }, req.body, {
        new: true,
        runValidators: true,
    });

    if (!product) {
        res.status(400).json({ message: "Error updating product" })
        return
    }

    await redisClient.del(req.params.id);
    await redisClient.del("all_products");
    res.status(200).json(product)
}
const imageToProduct = async (req: CustomRequest, res: Response): Promise<void> => {

    if (!req.files?.image) {
        res.status(400).json({ message: "No file provided" });
        return;
    }

    const product = await Product.findById(req.params.id)

    if (!product) {
        res.status(404).json({ message: "Product not found" });
        return
    }

    const imageFile = req.files.image[0]
    const imagePath = path.join(UploadDir, imageFile.originalname)
    fs.writeFileSync(imagePath, imageFile.buffer)

    const imageBuffer = fs.readFileSync(imagePath);

    product.image = imageFile.originalname;
    product.base64 = imageBuffer.toString('base64');
    await product.save();

    await redisClient.del(req.params.id);
    await redisClient.del("all_products");

    await redisClient.set(`${product._id}`, JSON.stringify(product));

    res.status(201).json(product)
};

const getAllDataProduct = async (req: CustomRequest, res: Response): Promise<void> => {
    const productId = req.params.id;

    // const cached = await redisClient.get(`product_data:${productId}`);
    // if (cached) {
    //     res.status(200).json(JSON.parse(cached));
    //     return;
    // }

    const product = await Product.findById(productId);
    if (!product) {
        res.status(404).json({ message: "Product not found" });
        return;
    }

    if (product.image) {
        const imagePath = path.join(UploadDir, product.image);
        if (fs.existsSync(imagePath)) {
            const imageBuffer = fs.readFileSync(imagePath);
            product.base64 = imageBuffer.toString('base64');
        } else {
            console.log('Image not found');
        }
    }

    await redisClient.del("all_products");
    await redisClient.del(req.params.id);

 
    // await redisClient.set(`${productId}`, JSON.stringify(response), { EX: 3600 });

    res.status(200).json(product);
};

const getProductsByCategory = async (req: CustomRequest, res: Response): Promise<void> => {
    const categoryId = req.params.categoryId;

    if (!categoryId) {
        res.status(400).json({ message: "Missing category in request" });
        return;
    }

    const cached = await redisClient.get(`${categoryId}`);
    if (cached) {
        res.status(200).json(JSON.parse(cached));
        return;
    }

    const category = await Category.findById(categoryId);
    if (!category) {
        res.status(404).json({ message: "Category not found" });
        return;
    }

    const products = await Product.find({ id_category: categoryId });

   
    await redisClient.set(`${categoryId}`, JSON.stringify(products), { EX: 1800 });

    res.status(200).json(products);
};

const getAllProductsExceptLoggedUser = async (req: CustomRequest, res: Response): Promise<void> => {
    try {
        if (!req.user || !req.user._id) {
            res.status(401).json({ message: "Unauthorized: User not logged in" });
            return;
        }

        const cacheKey = `${req.user._id}`;
        const cached = await redisClient.get(cacheKey);
        if (cached) {
            res.status(200).json(JSON.parse(cached));
            return;
        }

        const products = await Product.find({ id_user: { $ne: req.user._id } });

        
        await redisClient.set(cacheKey, JSON.stringify(products), { EX: 900 });

        res.status(200).json(products);
    } catch (error) {
        console.error("Error fetching products:", error);
        res.status(500).json({ message: "Server error while fetching products" });
    }
};



export { createProduct, getAllProducts, getProductById, getProductsByUser, deleteProductById, updateProductById, imageToProduct, getAllDataProduct, getProductsByCategory, getAllProductsExceptLoggedUser };