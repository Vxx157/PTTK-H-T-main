let users = [ { id:1, name:'Admin', email:'admin@example.com' } ]

exports.list = (req,res) => res.json(users)
exports.create = (req,res) => { const u = req.body; u.id = users.length ? Math.max(...users.map(x=>x.id))+1 : 1; users.push(u); res.status(201).json(u) }
