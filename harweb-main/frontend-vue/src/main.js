import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import axios from 'axios'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'
import './assets/style.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'

const app = createApp(App)

// Configurar axios como propiedad global
app.config.globalProperties.$axios = axios

// Configurar axios base URL y timeout 
axios.defaults.baseURL = 'http://localhost:8000'
axios.defaults.timeout = 60000 // 60 segundos para debugging

// Interceptor de respuesta para logging
axios.interceptors.response.use(
  (response) => {
    console.log('✓ API Success:', response.config.url, response.data)
    return response
  },
  (error) => {
    console.error('✗ API Error:', error.config?.url, error.code, error.message)
    console.error('Error details:', error.response?.data || error)
    
    // NO devolver datos mock - dejar que falle normalmente
    return Promise.reject(error)
  }
)

app.use(createPinia())
app.use(router)
app.use(Toast, {
  timeout: 3000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: "button",
  icon: true,
  rtl: false
})

app.mount('#app')