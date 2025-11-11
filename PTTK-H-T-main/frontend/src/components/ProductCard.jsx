import React from 'react'
import { Link } from 'react-router-dom'

export default function ProductCard({ product }){
  return (
    <div style={{border:'1px solid #eee',padding:12,width:220,borderRadius:6}}>
      <div style={{height:120,background:'#fafafa',display:'flex',alignItems:'center',justifyContent:'center'}}>Hình</div>
      <h4 style={{margin:'8px 0'}}>{product.name}</h4>
      <p style={{margin:0}}>{product.price} VND</p>
      <div style={{marginTop:8}}>
        <Link to={'/products/'+product.id}>Xem chi tiết</Link>
      </div>
    </div>
  )
}
