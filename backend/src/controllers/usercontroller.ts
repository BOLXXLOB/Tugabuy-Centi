import { Request, Response } from "express";
import User from "../models/usermodel";
import { CustomRequest } from "../middleware/tokenvalidation";
import { UploadDir, fs } from "..";
import path from "path";
import Product from "../models/productmodels";
import { redisClient } from "../comunication/redis";

const createUser = async (req: Request, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const { name, email, password, phone, image, address } = req.body;

    if (!name || !email || !password || !phone || !address) {
        res.status(400).json({ message: "Missing fields in request" })
        return
    }
    const existemail = await User.findOne({ email })
    if (existemail) {
        res.status(409).json({ message: "Email already in use" })
        return
    }
    const existphone = await User.findOne({ phone })
    if (existphone) {
        res.status(409).json({ message: "Phone number already in use" })
        return
    }


    let user = await User.create(req.body)


    if (!user) {
        res.status(422).json({ message: "Error creating user" })
        return
    }

    await redisClient.set(`${user._id}`, JSON.stringify(user))

    res.status(201).json(user)

};

const getAllUsers = async (req: CustomRequest, res: Response): Promise<void> => {
    const cacheKey = "all_users";
    const cachedUsers = await redisClient.get(cacheKey);

    if (cachedUsers) {
        res.status(200).json(JSON.parse(cachedUsers));
        return;
    }

    const users = await User.find();
    await redisClient.set(cacheKey, JSON.stringify(users), { EX: 600 });
    res.status(200).json(users);
}


const getUserById = async (req: CustomRequest, res: Response): Promise<void> => {
    const userId = req.params.id;


    const cachedUser = await redisClient.get(userId);
    if (cachedUser) {
        res.status(200).json(JSON.parse(cachedUser));
        return;
    }


    const user = await User.findById(userId);
    if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
    }


    await redisClient.set(userId, JSON.stringify(user), { EX: 3600 });
    res.status(200).json(user);
};

const changePassword = async (req: CustomRequest, res: Response): Promise<void> => {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
        res.status(400).json({ message: "Both current and new passwords are required" });
        return;
    }

    const user: any = await User.findById(req.params.id).select("+password");


    if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
    }

    if (req.user._id.toString() !== user._id.toString()) {
        res.status(403).json({ message: "Access denied" });
        return;
    }

    const isValidPassword = await user.comparepassword(currentPassword);
    if (!isValidPassword) {
        res.status(401).json({ message: "Current password is incorrect" });
        return;
    }

    user.password = newPassword;
    await user.save();

    await redisClient.del(req.user._id.toString());
    await redisClient.del("all_users");

    res.status(200).json({ message: "Password changed successfully" });
};

const deleteUserById = async (req: CustomRequest, res: Response): Promise<void> => {

    const userid = await User.findById(req.params.id)

    if (req.user._id.toString() != userid?._id.toString()) {
        res.status(403).json({ message: "Access denied" });
    }

    const user = await User.findByIdAndDelete(req.params.id)

    if (!user) {
        res.status(404).json({ message: "User not found" });
    }

    await redisClient.del(req.params.id);
    await redisClient.del("all_users");
    await Product.deleteMany({ id_user: req.params.id })


    res.status(204).json({ message: "User successfully deleted" });
}

const updateUserById = async (req: CustomRequest, res: Response): Promise<void> => {
    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const userid = await User.findById(req.params.id);

    if (!userid) {
        res.status(404).json({ message: "User not found" });
        return;
    }

    if (req.user._id.toString() !== userid._id.toString()) {
        res.status(403).json({ message: "Access denied" });
        return;
    }

    const validFields = ["name", "email", "password", "phone", "image", "address"];
    const requestFields = Object.keys(req.body);
    const allFieldsAreValid = requestFields.every(field => validFields.includes(field));



    if (!allFieldsAreValid) {
        res.status(400).json({ message: "Request contains invalid fields" });
        return;
    }

    // Verifica email duplicado (mas ignora se for o mesmo do utilizador atual)
    if (req.body.email && req.body.email !== userid.email) {
        const existingEmail = await User.findOne({ email: req.body.email });
        if (existingEmail) {
            res.status(409).json({ message: "Email already in use" });
            return;
        }
    }

    const newPhone = req.body.phone !== undefined ? Number(req.body.phone) : undefined;
    const currentPhone = userid.phone;

    // Verifica telefone duplicado (ignora se for o mesmo do utilizador atual)
    if (newPhone !== undefined && newPhone !== currentPhone) {
        const existingPhone = await User.findOne({ phone: newPhone });
        if (existingPhone) {
            res.status(409).json({ message: "Phone number already in use" });
            return;
        }
    }

    let user = await User.findOneAndUpdate({ _id: req.params.id }, req.body, {
        new: true,
        runValidators: true,
    });

    if (!user) {
        res.status(400).json({ message: "Error updating user" });
        return;
    }

    await redisClient.del(req.params.id);
    await redisClient.del("all_users");

    res.status(200).json(user);
};


const imageToUser = async (req: CustomRequest, res: Response): Promise<void> => {

    console.log(req.files)

    if (!req.files?.image) {
        res.status(400).json({ message: "No file provided" });
        return;
    }

    const existuser = await User.findById(req.params.id)

    if (!existuser) {
        res.status(404).json({ message: "User not found" });
        return
    }
    console.log(req.files?.image)


    const imageFile = req.files.image[0]
    const imagePath = path.join(UploadDir, imageFile.originalname)
    fs.writeFileSync(imagePath, imageFile.buffer)

    const imageBuffer = fs.readFileSync(imagePath);

    existuser.image = imageFile.originalname;
    existuser.base64 = imageBuffer.toString('base64');
    await existuser.save();

    await redisClient.del(req.params.id);
    await redisClient.del("all_users");

    await redisClient.set(`${existuser._id}`, JSON.stringify(existuser));


    res.status(201).json(existuser)

};

const getAllDataUser = async (req: CustomRequest, res: Response): Promise<void> => {
    const userId = req.params.id;

    /*const cached = await redisClient.get(`${userId}`);
    if (cached) {
        res.status(200).json(JSON.parse(cached));
        return;
    }*/

    const existuser = await User.findById(userId);
    if (!existuser) {
        res.status(404).json({ message: "User not found" });
        return;
    }


    if (existuser.image) {
        const imagePath = path.join(UploadDir, existuser.image);
        if (fs.existsSync(imagePath)) {
            const imageBuffer = fs.readFileSync(imagePath);
            existuser.base64 = imageBuffer.toString('base64');
        } else {
            console.log('Image not found');
        }
    }

    await redisClient.del("all_users");
    await redisClient.del(req.params.id);

    res.status(200).json(existuser);
};


export { createUser, getAllUsers, getUserById, deleteUserById, updateUserById, imageToUser, getAllDataUser, changePassword };
