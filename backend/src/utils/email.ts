import nodemailer from "nodemailer";

export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "tugabuy2025@gmail.com",     
    pass: "ewcv zqom fbbs ncda",
  },
})
