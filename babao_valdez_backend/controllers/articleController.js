const Article = require('../models/Article');

const getArticles = async (req, res) => {
  try {
    const articles = await Article.find();
    res.json({ articles });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const createArticle = async (req, res) => {
  try {
    const article = await Article.create(req.body);
    res.status(201).json(article);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const updateArticle = async (req, res) => {
  try {
    const article = await Article.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(article);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const toggleArticleStatus = async (req, res) => {
  try {
    const article = await Article.findById(req.params.id);
    article.isActive = !article.isActive;
    await article.save();
    res.json(article);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

const getArticleByName = async (req, res) => {
  try {
    const article = await Article.findOne({ name: req.params.name, isActive: true });
    if (!article) {
      return res.status(404).json({ message: 'Article not found' });
    }
    res.json(article);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = { getArticles, createArticle, updateArticle, toggleArticleStatus, getArticleByName };
