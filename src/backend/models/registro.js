import mongoose from "mongoose";

const registroSchema = mongoose.Schema({
    celsius: {
        type: Number,
        required: true
    },
    umidade: {
        type: Number,
        required: true
    },
    data: {
        type: String,
        required: true
    }
    });

export default mongoose.model("Registro", registroSchema);