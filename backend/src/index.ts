import express from "express";
import rateLimit from "express-rate-limit";
import mongoSanitize from 'express-mongo-sanitize';
import path from "path";
import fs from 'fs';
import { connectBD } from "./comunication/mongoose";
import { connectToRedis } from "./comunication/redis";
import userrouter from "./routes/userroute";
import categoryrouter from "./routes/categoryroute";
import productrouter from "./routes/productroute";
import chatrouter from "./routes/chatroute";
import messagerouter from "./routes/messageroute";
import authrouter from "./routes/authroute";
import 'colors'; 


const app = express();
const port = 3000;

// Limite de requisições
/* const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: "Too many requests from the same IP. Try again in a few minutes."
});
app.use(limiter);*/


app.use(express.json());

// Sanitização
app.use((req, res, next) => {
  if (req.body) mongoSanitize.sanitize(req.body);
  if (req.params) mongoSanitize.sanitize(req.params);
  if (req.query) mongoSanitize.sanitize(req.query);
  next();
});

// Diretório de uploads
const UploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(UploadDir)) {
  fs.mkdirSync(UploadDir);
}
export { UploadDir, fs };

const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('./swagger.json');

app.use('/api-docs', swaggerUi.serve,swaggerUi.setup(swaggerDocument))

// Rotas
app.use("/users", userrouter);
app.use("/categories", categoryrouter);
app.use("/products", productrouter);
app.use("/chats", chatrouter);
app.use("/messages", messagerouter);
app.use("/auth", authrouter);


const mongoURL = "mongodb+srv://diogo:dMf6EkIgnzUFqR2n@cluster0.fygfcsu.mongodb.net/";
const redisURL = "redis://redis:6379";

connectBD(mongoURL).then(async () => {
  await connectToRedis(redisURL);
  app.listen(port, () => {
    console.log(`Server running on port: ${port}`);
  });
});
