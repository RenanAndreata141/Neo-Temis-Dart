const mongoose = require('mongoose');

const STATUS = ['Em andamento', 'Aguardando', 'Concluído', 'Arquivado'];

const processoSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    nome: { type: String, required: true, trim: true, maxlength: 200 },
    numero: { type: String, trim: true, maxlength: 60, default: '' },
    cliente: { type: String, trim: true, maxlength: 160, default: '' },
    status: { type: String, enum: STATUS, default: STATUS[0] },
    descricao: { type: String, trim: true, maxlength: 10000, default: '' },
    // Data de vencimento (prazo) do processo. Guardada como meia-noite UTC do dia.
    prazo: { type: Date, default: null },
    imagem: {
      dados: { type: Buffer, select: false },
      tipo: { type: String },
    },
  },
  { timestamps: true }
);

processoSchema.methods.paraJson = function () {
  return {
    id: this._id.toString(),
    nome: this.nome,
    numero: this.numero,
    cliente: this.cliente,
    status: this.status,
    descricao: this.descricao,
    // "AAAA-MM-DD" ou null
    prazo: this.prazo ? this.prazo.toISOString().slice(0, 10) : null,
    temImagem: !!(this.imagem && this.imagem.tipo),
    atualizadoEm: this.updatedAt ? this.updatedAt.getTime() : 0,
  };
};

module.exports = mongoose.model('Processo', processoSchema);
module.exports.STATUS = STATUS;
