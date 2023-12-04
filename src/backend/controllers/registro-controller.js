import mongoose from "mongoose";
import Registro from "../models/registro.js";

// função para adicionar registro

export const addRegistro = async (req, res) => {
    const { celsius, umidade } = req.body;
    if (
        !celsius && celsius.trim() === "" &&
        !umidade && umidade.trim() === ""
        ) {
        return res.status(422).json({ message: "Dados inválidos" });
    }

    let registro;
    let registroData = new Date();
    const formattedData = `${registroData.getFullYear()}/${(registroData.getMonth() + 1).toString().padStart(2, '0')}/${registroData.getDate().toString().padStart(2, '0')} - ${registroData.getHours().toString().padStart(2, '0')}:${registroData.getMinutes().toString().padStart(2, '0')}`;
    try {
        registro = new Registro({
            celsius,
            umidade,
            data: formattedData,
        });

    const session = await mongoose.startSession();
    session.startTransaction();
    await registro.save({ session: session });
    await session.commitTransaction();
    } catch (err) {
        return console.log(err);
    }

    if (!registro) {
        return res.status(500).json({ message: "Erro ao adicionar registro" });
    }
    return res.status(201).json({ message: "Registro adicionado com sucesso" });
};

export const getRegistros = async (req, res) => {
    let registros;
    try {
        registros = await Registro.find();
    } catch (err) {
        return console.log(err);
    }
    if (!registros) {
        return res.status(404).json({ message: "Nenhum registro encontrado" });
    }
    return res.status(200).json({ registros });
}
