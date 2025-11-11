const express = require('express')
const cors = require('cors')
const bodyParser = require('body-parser')
const productsRouter = require('./routes/products')
const usersRouter = require('./routes/users')
const ordersRouter = require('./routes/orders')

const app = express()
const port = process.env.PORT || 3000

app.use(cors())
app.use(bodyParser.json())

app.use('/api/products', productsRouter)
app.use('/api/users', usersRouter)
app.use('/api/orders', ordersRouter)

app.get('/api/health', (req, res) => res.json({ status: 'ok' }))

app.listen(port, () => console.log(`Backend running on http://localhost:${port}`))
