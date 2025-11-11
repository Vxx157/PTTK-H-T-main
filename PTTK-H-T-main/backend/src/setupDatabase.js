const { sequelize, Product } = require('./models')

;(async () => {
  try {
    await sequelize.authenticate()
    await sequelize.sync()
    const count = await Product.count()
    if (count === 0) {
      await Product.bulkCreate([
        { name: 'Phone A', price: 5000000 },
        { name: 'Phone B', price: 7500000 },
        { name: 'Phone C', price: 12000000 }
      ])
      console.log('Seeded initial products')
    } else {
      console.log('Products already seeded')
    }
    process.exit(0)
  } catch (err) {
    console.error('DB setup failed', err)
    process.exit(1)
  }
})()
