import express from "express";
import { addRegistro, getRegistros } from "../controllers/registro-controller.js";

const registroRouter = express.Router();

registroRouter.post("/", addRegistro);
registroRouter.get("/", getRegistros);

export default registroRouter;