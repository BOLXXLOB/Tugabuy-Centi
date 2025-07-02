import { Response } from "express"
import Category from "../models/categorymodels";
import { CustomRequest } from "../middleware/tokenvalidation";
import { redisClient } from "../comunication/redis";

const createCategory = async (req: CustomRequest, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const { desc } = req.body;

    if (!desc) {
        res.status(400).json({ message: "Missing fields in request" })
        return
    }

        const existdesc = await Category.findOne({ desc })
        if (existdesc) {
            res.status(409).json({ message: "Category already exists" })
            return
        }

    let category = await Category.create(req.body)


    if (!category) {
        res.status(422).json({ message: "Error creating category" })
        return
    }

    await redisClient.set(`${category._id}`,JSON.stringify(category));
    res.status(201).json(category)
}
const getAllCategories = async (req: CustomRequest, res: Response): Promise<void> => {

        const cacheKey = "all_categories";
        const cachedCategories = await redisClient.get(cacheKey);
            if (cachedCategories) {
        res.status(200).json(JSON.parse(cachedCategories));
        return;
    }

    const categories = await Category.find();
     await redisClient.set(cacheKey, JSON.stringify(categories), { EX: 600 });
    res.status(200).json(categories);
}
const getCategoryById = async (req: CustomRequest, res: Response): Promise<void> => {
    const categoryId = req.params.id;

    
    const cachedCategory = await redisClient.get(categoryId);
    if (cachedCategory) {
        res.status(200).json(JSON.parse(cachedCategory));
        return;
    }

    const category = await Category.findById(categoryId);

    if (!category) {
        res.status(404).json({ message: "Category not found" });
        return;
    }

   
    await redisClient.set(categoryId, JSON.stringify(category), { EX: 3600 });

    res.status(200).json(category);
};

const deleteCategoryById = async (req: CustomRequest, res: Response): Promise<void> => {
    const category = await Category.findByIdAndDelete(req.params.id);

    if (!category) {
        res.status(404).json({ message: "Category not found" });
        return;
    }

    await redisClient.del(`${req.params.id}`);

    res.status(204).json({ message: "Category successfully deleted" });
};

const updateCategoryById = async (req: CustomRequest, res: Response): Promise<void> => {
    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const existcategory = await Category.findById(req.params.id);
    if (!existcategory) {
        res.status(404).json({ message: "Category not found" });
        return;
    }

    const validfield = ["desc"];
    const field = Object.keys(req.body);
    const allfieldarevalid = field.every(field => validfield.includes(field));

    if (!allfieldarevalid) {
        res.status(400).json({ message: "Request contain invalid fields" });
        return;
    }

    if (req.body.desc) {
        const existdesc = await Category.findOne({ desc: req.body.desc });
        if (existdesc) {
            res.status(409).json({ message: "Category already exists" });
            return;
        }
    }

    let category = await Category.findOneAndUpdate({ _id: req.params.id }, req.body, {
        new: true,
        runValidators: true,
    });

    if (!category) {
        res.status(400).json({ message: "Error updating category" });
        return;
    }

    await redisClient.set(`${req.params.id}`, JSON.stringify(category), { EX: 3600 });

    res.status(200).json(category);
};


export { createCategory,getAllCategories,getCategoryById,deleteCategoryById,updateCategoryById };