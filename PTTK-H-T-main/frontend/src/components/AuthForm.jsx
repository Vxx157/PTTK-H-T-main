import React from 'react'

export default function AuthForm({ type='login' }){
  return (
    <form style={{maxWidth:400,margin:'0 auto',padding:16}}>
      <h3>{type==='login' ? 'Đăng nhập' : 'Đăng ký'}</h3>
      {type !== 'login' && (
        <div style={{marginBottom:8}}>
          <label>Họ tên</label>
          <input name="name" style={{width:'100%'}} />
        </div>
      )}
      <div style={{marginBottom:8}}>
        <label>Email</label>
        <input name="email" style={{width:'100%'}} />
      </div>
      <div style={{marginBottom:8}}>
        <label>Mật khẩu</label>
        <input name="password" type="password" style={{width:'100%'}} />
      </div>
      <button type="submit">{type==='login' ? 'Đăng nhập' : 'Đăng ký'}</button>
    </form>
  )
}
