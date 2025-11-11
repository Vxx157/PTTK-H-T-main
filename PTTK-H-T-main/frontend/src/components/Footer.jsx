import React from 'react'

export default function Footer(){
  return (
    <footer style={{background:'#f3f4f6',padding:16,textAlign:'center'}}>
      <small>© {new Date().getFullYear()} Mobile Shop — Demo</small>
    </footer>
  )
}
