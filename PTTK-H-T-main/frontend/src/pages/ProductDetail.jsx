import React, {useEffect, useState} from 'react'
import { useParams } from 'react-router-dom'
import api from '../services/api'

export default function ProductDetail(){
  const { id } = useParams()
  const [product, setProduct] = useState(null)

  useEffect(()=>{
    api.get('/products/'+id)
      .then(r=>setProduct(r))
      .catch(e=>console.error(e))
  },[id])

  if (!product) return <div style={{padding:20}}>Đang tải...</div>

  return (
    <div style={{padding:20}}>
      <h2>{product.name}</h2>
      <p>Giá: {product.price} VND</p>
      <p>Mô tả: Mô tả sản phẩm (thêm trường mô tả khi cần)</p>
    </div>
  )
}
