<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="lock" /></div>
      <div class="module-view-info">
        <h1>Seguridad — Inicio de Sesión</h1>
        <p>Validación de usuario contra BD</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="login"><font-awesome-icon icon="sign-in-alt" /> Ingresar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Usuario</label><input class="municipal-form-control" v-model="user" /></div>
            <div class="form-group"><label class="municipal-form-label">Contraseña</label><input type="password" class="municipal-form-control" v-model="pass" /></div>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const user = ref('')
const pass = ref('')
const loading = ref(false)
const message = ref('')

async function login() {
  loading.value = true
  message.value = ''
  try {
    const params = [ { nombre: 'p_user', valor: user.value, tipo: 'string' }, { nombre: 'p_pass', valor: pass.value, tipo: 'string' } ]
    const resp = await apiService.execute('sp_login_seguridad', 'estacionamiento_publico', params)
    const r = (resp?.data?.result || [])[0]
    message.value = r ? (r.message || (r.success ? 'Acceso concedido' : 'Acceso denegado')) : (resp?.message || 'Sin respuesta')
  } finally { loading.value = false }
}
</script>

