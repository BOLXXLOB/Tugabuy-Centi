import { Response } from "express"
import Chat from "../models/chatmodels"
import Product from "../models/productmodels"
import User from "../models/usermodel"
import { CustomRequest } from "../middleware/tokenvalidation"
import { transporter } from "../utils/email"
import { redisClient } from "../comunication/redis";

const createChat = async (req: CustomRequest, res: Response): Promise<void> => {
    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const { id_product, id_user } = req.body;

    if (!id_product || !id_user) {
        res.status(400).json({ message: "Missing fields in request" });
        return;
    }


    const product = await Product.findById(id_product);
    if (!product) {
        res.status(404).json({ message: "Product not found" });
        return;
    }

    const user = await User.findById(id_user);
    if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
    }


    const owner = await User.findById(product.id_user);
    if (!owner || !owner.email) {
        res.status(404).json({ message: "Owner of product not found or missing email" });
        console.log(owner)
        return;
    }

    if (user._id.toString() === owner._id.toString()) {
        res.status(400).json({ message: "You cannot create a chat with yourself (user is the owner of the product)" });
        return;
    }

    const existingChat = await Chat.findOne({ id_product, id_user });
    if (existingChat) {
        res.status(409).json({ message: "Chat already exists between this user and product" });
        return;
    }

    let chat = await Chat.create(req.body);
    if (!chat) {
        res.status(422).json({ message: "Error creating Chat" });
        return;
    }


    try {
        await transporter.sendMail({
            from: "tugabuy2025@gmail.com",
            to: owner.email,
            subject: "Novo interesse no seu produto",
            html: `
  <div style="font-family: Arial, sans-serif; color: #333; padding: 20px; background-color: #f4f4f4;">
    <div style="max-width: 600px; margin: auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
      <h2 style="color: #4CAF50;">Olá ${owner.name},</h2>
      <p>Alguém demonstrou interesse no seu produto:</p>
      <p style="font-size: 18px; font-weight: bold; color: #555;">"${product.name}"</p>
      <p>Foi criado um novo chat relacionado a este item.</p>
      <hr style="margin: 20px 0;">
      <p style="font-size: 12px; color: #888;">Recebeu este email porque é o dono do produto na plataforma TugaBuy.</p>
    </div>
  </div>
`
        });
    } catch (error) {
        console.error("Error sending email:", error);
    }

    await redisClient.set(`${chat._id}`, JSON.stringify(chat));
    res.status(201).json(chat);
}

const getAllChats = async (req: CustomRequest, res: Response): Promise<void> => {

    const cacheKey = "all_chats";
    const cachedChats = await redisClient.get(cacheKey);
    if (cachedChats) {
        res.status(200).json(JSON.parse(cachedChats));
        return;
    }

    const chats = await Chat.find()
    await redisClient.set(cacheKey, JSON.stringify(chats), { EX: 600 });
    res.status(200).json(chats)
}

const getChatById = async (req: CustomRequest, res: Response): Promise<void> => {

    const chatId = req.params.id;

    const cachedChats = await redisClient.get(chatId);
    if (cachedChats) {
        res.status(200).json(JSON.parse(cachedChats));
        return;
    }

    const chat = await Chat.findById(chatId)

    if (!chat) {
        res.status(404).json({ message: "Chat not found" });
    }
    await redisClient.set(chatId, JSON.stringify(chat), { EX: 3600 });
    res.status(200).json(chat)
}

const getChatsByUser = async (req: CustomRequest, res: Response): Promise<void> => {
    const userId = req.params.userId;

    if (!userId) {
        res.status(400).json({ message: "Missing user in request" });
        return;
    }
    const cachedChats = await redisClient.get(`user/${userId}`);
    if (cachedChats) {
        res.status(200).json(JSON.parse(cachedChats));
        return;
    }
    const user = await User.findById(userId);
    if (!user) {
        res.status(404).json({ message: "User not found" });
        return;
    }

    const chats = await Chat.find({ id_user: userId });

    await redisClient.set(`user/${userId}`, JSON.stringify(chats), { EX: 1800 });

    res.status(200).json(chats);
};

const getChatsByOwner = async (req: CustomRequest, res: Response): Promise<void> => {

    const ownerId = req.params.ownerId;

    if (!ownerId) {
        res.status(400).json({ message: "Missing owner in request" });
        return;
    }

    // const cachedChats = await redisClient.get(`owner/${ownerId}`);
    // if (cachedChats) {
    //      res.status(200).json(JSON.parse(cachedChats));
    //      return;
    // }

    const products = await Product.find({ id_user: ownerId });

    if (!products.length) {
        res.status(200).json([]);
        return;
    }

    const productIds = products.map(product => product._id);


    const chats = await Chat.find({ id_product: { $in: productIds } });

    await redisClient.set(`owner/${ownerId}`, JSON.stringify(chats), { EX: 1800 });

    res.status(200).json(chats);

};

const deleteChatById = async (req: CustomRequest, res: Response): Promise<void> => {

    const chat = await Chat.findByIdAndDelete(req.params.id)

    if (!chat) {
        res.status(404).json({ message: "Chat not found" });
    }
    await redisClient.del(req.params.id);
    await redisClient.del("all_chats");

    const owners = await redisClient.keys('owner/*');
    for (let key of owners) {
        await redisClient.del(key);
    }

    const users = await redisClient.keys('user/*');
    for (let key of users) {
        await redisClient.del(key);
    }

    res.status(204).json({ message: "Chat successfully deleted" });
}

export { createChat, getAllChats, getChatById, deleteChatById, getChatsByUser, getChatsByOwner }; 