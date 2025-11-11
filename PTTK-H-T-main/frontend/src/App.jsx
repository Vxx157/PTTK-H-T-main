import React from 'react'
import './App.css'
import { Routes, Route } from 'react-router-dom'
import Header from './components/Header'
import Footer from './components/Footer'
import Home from './pages/Home'
import ProductList from './pages/ProductList'
import ProductDetail from './pages/ProductDetail'
import Cart from './pages/Cart'
import Checkout from './pages/Checkout'
import Login from './pages/Login'
import Register from './pages/Register'
import Profile from './pages/Profile'
import Orders from './pages/Orders'
import NotFound from './pages/NotFound'

export default function App(){
  return (
    <div style={{display:'flex',flexDirection:'column',minHeight:'100vh'}}>
      <Header />
      <main style={{flex:1}}>
        <Routes>
          <Route path='/' element={<Home/>} />
          <Route path='/products' element={<ProductList/>} />
          <Route path='/products/:id' element={<ProductDetail/>} />
          <Route path='/cart' element={<Cart/>} />
          <Route path='/checkout' element={<Checkout/>} />
          <Route path='/login' element={<Login/>} />
          <Route path='/register' element={<Register/>} />
          <Route path='/profile' element={<Profile/>} />
          <Route path='/orders' element={<Orders/>} />
          <Route path='*' element={<NotFound/>} />
        </Routes>
      </main>
      <Footer />
    </div>
  )
}
