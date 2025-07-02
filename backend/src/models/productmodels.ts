import mongoose from "mongoose";

const { Schema } = mongoose;

const productSchema = new Schema({

    name: {
        type: String,
        required: [true,"Please provide a name"]
    } ,
    desc: {
        type: String,
        required: [true,"Please provide a description"]
    } ,
    price: {
        type: Number,
        required: [true,"Please provide a price"],
    } ,
    id_category: {
        type: Schema.Types.ObjectId,
        ref: "category",
        required: [true,"Please provide a category id"]
    },
    state: {
        type: String,
        enum: ["Active","Inactive"],
        default: "Active"
    },
    id_user: {
        type: Schema.Types.ObjectId,
        ref: "user",
        required: [true,"Please provide a user id"]
    },
        image: {
        type: String,

    } ,
        base64: {
        type: String,

    } ,
        created_at: { 
        type: Date, 
        default: Date.now 
    },
        


});

const Product = mongoose.model("product",productSchema)

export default Product;