import React, {useEffect, useState} from 'react'
import api from '../services/api'
import ProductCard from '../components/ProductCard'

export default function ProductList(){
  const [products, setProducts] = useState([])

  useEffect(()=>{
    api.get('/products')
      .then(r=>setProducts(r))
      .catch(e=>console.error(e))
  },[])

  return (
    <div style={{padding:20}}>
      <h2>Danh sách sản phẩm</h2>
      <div style={{display:'flex',gap:16,flexWrap:'wrap'}}>
        {products.map(p => <ProductCard key={p.id} product={p} />)}
      </div>
    </div>
  )
}
