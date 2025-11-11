const { Product } = require('../models')

exports.list = async (req, res) => {
  try {
    const products = await Product.findAll()
    res.json(products)
  } catch (err) {
    console.error('productsController.list error:', err)
    res.status(500).json({ error: 'Server error' })
  }
}

exports.get = async (req, res) => {
  try {
    const id = parseInt(req.params.id, 10)
    const p = await Product.findByPk(id)
    if (!p) return res.status(404).json({ error: 'Not found' })
    res.json(p)
  } catch (err) {
    console.error('productsController.get error:', err)
    res.status(500).json({ error: 'Server error' })
  }
}

exports.create = async (req, res) => {
  try {
    const item = req.body
    const created = await Product.create(item)
    res.status(201).json(created)
  } catch (err) {
    console.error('productsController.create error:', err)
    res.status(500).json({ error: 'Server error' })
  }
}
