let orders = []

exports.list = (req,res) => res.json(orders)
exports.create = (req,res) => { const o = req.body; o.id = orders.length ? Math.max(...orders.map(x=>x.id))+1 : 1; orders.push(o); res.status(201).json(o) }
