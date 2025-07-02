import { Request, Response } from "express"
import User from "../models/usermodel";

const login = async (req: Request, res: Response): Promise<void> => {

    if (!req.body) {
        res.status(400).json({ message: "Request body is missing" });
        return;
    }

    const { email, password } = req.body;

    if (!email || !password) {
        res.status(400).json({ message: "Missing fields in request" })
        return
    }

    const user = await User.findOne({ email }).select("+password");
    if (!user) {
        res.status(401).json({ message: "Invalid credentials or user not found" })
        return
    }

    const validpassword = await (user as any).comparepassword(password)

    if (!validpassword) {
        res.status(401).json({ message: "Invalid credentials or user not found" })
        return
    }

    const gentoken = (user as any).generatetoken()

    user.token = gentoken
    await user.save()

    res.status(200).json({ user })


}

const logout = async (req: Request, res: Response): Promise<void> => {

    const user = await User.findById(req.params.id)

    if (!user) {
        res.status(404).json({ message: "User not found!" });
        return
    }
    user.token = ""

    await user.save()

    res.status(200).json(user)


}
export { login, logout };