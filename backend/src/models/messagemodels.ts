
import mongoose from "mongoose";

const { Schema } = mongoose;

const messageSchema = new Schema({

    
    message:{
        type: String,
        required:[true,"Please write a message"]
    },
    send_time:{
        type: Date,
        default: Date.now
    },
    id_chat: {
        type: Schema.Types.ObjectId,
        ref: "chat",
        required: [true,"Please provide a chat id"]
    },
    id_user: {
        type: Schema.Types.ObjectId,
        ref: "user",
        required: [true,"Please provide a user id"]
    }
        
});

const Message = mongoose.model("message",messageSchema)

export default Message;