import { Request, Response } from "express"
import Message from "../models/messagemodels";
import Chat from "../models/chatmodels";
import User from "../models/usermodel";
import { CustomRequest } from "../middleware/tokenvalidation";
import { redisClient } from "../comunication/redis";



const createMessage = async (req: CustomRequest, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const { message, id_chat, id_user } = req.body;


    if (!message || !id_chat || !id_user) {
        res.status(400).json({ message: "Missing fields in request" })
        return
    }

    const existchat = await Chat.findById(id_chat)
    if (!existchat) {
        res.status(409).json({ message: "The chat does not exist" })
        return
    }
    const existuser = await User.findById(id_user)
    if (!existuser) {
        res.status(409).json({ message: "The user does not exist" })
        return
    }

    let messages = await Message.create(req.body)


    if (!messages) {
        res.status(422).json({ message: "Error creating message" })
        return
    }

    await redisClient.set(`${message._id}`, JSON.stringify(message));
    res.status(201).json(messages)
}

const getAllMessages = async (req: CustomRequest, res: Response): Promise<void> => {

    const cacheKey = "all_messages";
    const cachedMessages = await redisClient.get(cacheKey);
    if (cachedMessages) {
        res.status(200).json(JSON.parse(cachedMessages));
        return;
    }

    const message = await Message.find()
    await redisClient.set(cacheKey, JSON.stringify(message), { EX: 600 });
    res.status(200).json(message)
}

const getMessageById = async (req: CustomRequest, res: Response): Promise<void> => {

const messageId = req.params.id;

 const cachedMessages = await redisClient.get(messageId);
    if (cachedMessages) {
        res.status(200).json(JSON.parse(cachedMessages));
        return;
    }

    const message = await Message.findById(messageId)

    if (!message) {
        res.status(404).json({ message: "Message not found" });
    }

    await redisClient.set(messageId, JSON.stringify(message), { EX: 3600 });
    res.status(200).json(message)
}

const getMessageByChat = async (req: CustomRequest, res: Response): Promise<void> => {

    const chatId = req.params.chatId;

    if (!chatId) {
        res.status(400).json({ message: "Missing chat in request" });
        return;
    }

   /* const cachedMessages = await redisClient.get(`${chatId}`);
    if (cachedMessages) {
        res.status(200).json(JSON.parse(cachedMessages));
        return;
    }*/

    const chat = await Chat.findById(chatId);
    if (!chat) {
        res.status(404).json({ message: "Chat not found" });
        return;
    }

    const messages = await Message.find({ id_chat: chatId });
await redisClient.set(`${chatId}`, JSON.stringify(messages), { EX: 1800 });
    res.status(200).json(messages);

}

const deleteMessageById = async (req: CustomRequest, res: Response): Promise<void> => {

    const message = await Message.findById(req.params.id)

    if (!message) {
        res.status(404).json({ message: "Message not found" });

    }

    const userid = await User.findById(message!.id_user)

    if (req.user._id != userid?._id) {
        res.status(403).json({ message: "Access denied" });
    }

        await redisClient.del(req.params.id);
        await redisClient.del("all_messages");
    res.status(204).json({ message: "Message successfully deleted" });
}

const updateMessageById = async (req: CustomRequest, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const existmessage = await Message.findById(req.params.id)

    if (!existmessage) {
        res.status(404).json({ message: "Message not found" });
    }

    const userid = await User.findById(existmessage!.id_user)

    if (req.user._id != userid?._id) {
        res.status(403).json({ message: "Access denied" });
    }

    const validfield = ["message", "id_chat", "id_user",]
    const field = Object.keys(req.body)
    const allfieldarevalid = field.every(field => validfield.includes(field))

    if (!allfieldarevalid) {
        res.status(400).json({ message: "Request contain invalid fields" })
        return
    }

    if (req.body.id_chat) {
        const existchat = await Chat.findById({ _id: req.body.id_chat })
        if (!existchat) {
            res.status(409).json({ message: "The chat does not exist" })
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


    let message = await Message.findOneAndUpdate({ _id: req.params.id }, req.body, {
        new: true,
        runValidators: true,
    });

    if (!message) {
        res.status(400).json({ message: "Error updating message" })
        return
    }

    await redisClient.del(req.params.id);
    await redisClient.del("all_messages");
    res.status(200).json(message)
}

export { createMessage, getAllMessages, getMessageById, getMessageByChat, deleteMessageById, updateMessageById };