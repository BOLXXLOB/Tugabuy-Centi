import mongoose from "mongoose";

export async function connectBD(mongoURL:string) {
    try {
        await mongoose.connect(mongoURL)
        console.log(`MONGODB SUCCESS \t DB URL:\t ${mongoURL}`.green);
    } catch (error:any) {
        console.log(`MONGODB ERROR \t DB URL:\t ${mongoURL}\nError:${error.message}`.red);
    }
}

export async function closeConnection() {
    await mongoose.connection.close()
}