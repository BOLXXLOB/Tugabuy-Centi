import mongoose from "mongoose";

const { Schema } = mongoose;

const chatSchema = new Schema({

    id_product: {
        type: Schema.Types.ObjectId,
        ref: "product",
        required: [true,"Please provide a product id"]
    },
        id_user: {
        type: Schema.Types.ObjectId,
        ref: "user",
        required: [true,"Please provide an user id"]
    }
        
});

const Chat = mongoose.model("chat",chatSchema)

export default Chat;