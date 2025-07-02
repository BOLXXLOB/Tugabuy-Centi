import express, { Request, Response, NextFunction } from 'express'
import multer from 'multer'
import path from 'path'

const processImage = multer({
storage:multer.memoryStorage(),
limits:{fileSize: 100*1024*1024},
}).fields([
 {name: "image", maxCount:1}
])


export { processImage}
