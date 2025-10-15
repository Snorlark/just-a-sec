const mongoose = require('mongoose');

const articleSchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true},
    title: { type: String, required: true, unique: true},
    content: { type: [String], required: true},
    isActive: { type: Boolean, default: true},
});

module.export = mongoose.model('Article', articleSchema);