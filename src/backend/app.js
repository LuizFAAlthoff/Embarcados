import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import registroRouter from "../backend/routes/registro-routes.js";
import cors from "cors";


dotenv.config();

const app = express();
const corsOptions = {
    origin: "http://localhost:3000",
    credentials: true,
    optionSucessStatus: 200
};
app.use(cors(corsOptions));
app.use(express.json());
app.use("/registro", registroRouter);

mongoose.connect(`mongodb+srv://admin:${process.env.MONGODB_PASSWORD}@cluster0.umtwcwr.mongodb.net/?retryWrites=true&w=majority`
).then(() => {app.listen(3000, ()=>console.log("Server running on port 3000 and connected to database"))}
).catch((err) => console.log(err));
