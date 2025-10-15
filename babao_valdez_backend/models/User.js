const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  age: { type: String, required: true },
  gender: { type: String, required: true },
  contactNumber: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  type: { type: String, enum: ['admin', 'editor', 'viewer'], default: 'editor' }, // Default to 'editor'
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  address: { type: String, required: true },
  isActive: { type: Boolean, default: true },
});

module.exports = mongoose.model.userSchema || mongoose.model('User', userSchema);
