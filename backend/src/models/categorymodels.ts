import mongoose from "mongoose";

const { Schema } = mongoose;

const categorySchema = new Schema({

    desc: {
        type: String,
        required: [true,"Please provide a description"]
    }
        
});

const Category = mongoose.model("category",categorySchema)

export default Category;