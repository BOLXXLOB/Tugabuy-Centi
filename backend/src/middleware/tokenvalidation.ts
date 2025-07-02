import { NextFunction, Request, Response } from "express"
import User from "../models/usermodel";
import jwt, { JwtPayload } from "jsonwebtoken";


export interface CustomRequest extends Request {
  user?: any;
  files?: any;
}

export const isValidToken = async (req: CustomRequest, res: Response , next:NextFunction): Promise<void> => {

    if (req.headers.authorization === undefined) {
        res.status(403).json({ message: "Access denied!" })
        return
    }

    let token = req.headers.authorization.split("Bearer ")[1];

    if(token !== undefined){
        const decodedtoken:JwtPayload | string = jwt.verify(token,'keyproject');

        const user = await User.findById(decodedtoken.sub).select('+token')

        if(!user){
            res.status(400).json({message: "Access denied!"})
            return
        }

        if((user as any).confirmtoken()){
            req.user = user
            return next();
        }
    }

    res.status(403).json({message: "Access denied!"})
}