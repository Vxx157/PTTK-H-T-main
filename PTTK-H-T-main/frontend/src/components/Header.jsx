import React from 'react'
import { Link } from 'react-router-dom'

export default function Header(){
  return (
    <header style={{background:'#0f172a',color:'#fff',padding:'12px 20px'}}>
      <div style={{display:'flex',alignItems:'center',justifyContent:'space-between'}}>
        <div style={{display:'flex',alignItems:'center',gap:12}}>
          <Link to='/' style={{color:'#fff',textDecoration:'none',fontWeight:'700'}}>Mobile Shop</Link>
        </div>
        <nav style={{display:'flex',gap:12}}>
          <Link to='/products' style={{color:'#fff',textDecoration:'none'}}>Sản phẩm</Link>
          <Link to='/cart' style={{color:'#fff',textDecoration:'none'}}>Giỏ hàng</Link>
          <Link to='/orders' style={{color:'#fff',textDecoration:'none'}}>Đơn hàng</Link>
          <Link to='/login' style={{color:'#fff',textDecoration:'none'}}>Đăng nhập</Link>
        </nav>
      </div>
    </header>
  )
}
