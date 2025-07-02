import mongoose from "mongoose";
import bcrypt from "bcryptjs"
import jwt from "jsonwebtoken";


const { Schema } = mongoose;

const userSchema = new Schema({

    name: {
        type: String,
        required: [true,"Please provide a name"]
    } ,
    email: {
        type: String,
        unique: true,
        required: [true,"Please provide an email"]
    } ,
    password: {
        type: String,
        required: [true,"Please provide a password"],
        select: false
    } ,
    phone: {
        type: Number,
        required: [true,"Please provide a phone number"],
    } ,
    image: {
        type: String,
        
    } ,
    base64: {
        type: String,

    } ,
    address: {
        type: String,
        required: [true,"Please provide an address"],
    } ,
    token: {
        type: String,
        select: false
    } ,
    created_at: { 
        type: Date, 
        default: Date.now 
    },

});

userSchema.pre("save", async function (this: any, next: any) {
  if (this.isModified("password")) {
    const isHashed = this.password.startsWith('$2'); 
    if (!isHashed) {
      this.password = await bcrypt.hash(this.password + 'project123abc', 10);
    }
  }
  next();
});

userSchema.methods.comparepassword = async function (this:any, password: string){
    return await bcrypt.compare(password + 'project123abc', this.password );
}

userSchema.methods.generatetoken = function(this:any){
    const token = jwt.sign({sub:this._id, iss:'project'},'keyproject',{expiresIn: 31557600}); // expira em 1 semana
    return token;
    
}

userSchema.methods.confirmtoken = function(this:any){
try {
    jwt.verify(this.token,'keyproject')
    return true;
} catch (error) {
    return false;
}
}

const User = mongoose.model("user", userSchema)

export default User;