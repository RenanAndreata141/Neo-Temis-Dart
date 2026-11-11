const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    nome: { type: String, required: true, trim: true, maxlength: 120 },
    oab: { type: String, required: true, unique: true, trim: true, uppercase: true },
    email: { type: String, trim: true, lowercase: true, maxlength: 160, default: '' },
    senhaHash: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);
