<template>
  <div class="acceso-container">
    <div class="acceso-card">
      <div class="acceso-header">
        <div class="acceso-logo">
          <i class="fas fa-landmark"></i>
        </div>
        <h2 class="acceso-title">Control de Acceso - Cementerios</h2>
        <p class="acceso-subtitle">Sistema Municipal de Ingresos</p>
      </div>

      <form @submit.prevent="handleLogin" class="acceso-form">
        <div class="form-group">
          <label class="form-label">
            <i class="fas fa-user"></i>
            Usuario
          </label>
          <input
            v-model="credentials.usuario"
            type="text"
            class="form-control"
            placeholder="Ingrese su usuario"
            :disabled="loading"
            autocomplete="username"
            required
            autofocus
          />
        </div>

        <div class="form-group">
          <label class="form-label">
            <i class="fas fa-lock"></i>
            Contraseña
          </label>
          <input
            v-model="credentials.password"
            type="password"
            class="form-control"
            placeholder="Ingrese su contraseña"
            :disabled="loading"
            autocomplete="current-password"
            required
          />
        </div>

        <div v-if="error" class="alert-danger">
          <i class="fas fa-exclamation-circle"></i>
          {{ error }}
        </div>

        <div v-if="loading" class="alert-info">
          <i class="fas fa-spinner fa-spin"></i>
          Conectando con el servidor...
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-municipal-primary" :disabled="loading || !isFormValid">
            <i class="fas fa-sign-in-alt"></i>
            Ingresar
          </button>
          <button type="button" @click="handleCancel" class="btn-municipal-secondary" :disabled="loading">
            <i class="fas fa-times"></i>
            Cancelar
          </button>
        </div>

        <div class="acceso-info">
          <p class="text-muted">
            <i class="fas fa-info-circle"></i>
            Intentos restantes: {{ intentosRestantes }}
          </p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'

const api = useApi()
const toast = useToast()
const router = useRouter()

const credentials = ref({
  usuario: '',
  password: ''
})

const loading = ref(false)
const error = ref('')
const intentos = ref(0)
const maxIntentos = 3

const intentosRestantes = computed(() => maxIntentos - intentos.value)

const isFormValid = computed(() => {
  return credentials.value.usuario.trim() !== '' &&
         credentials.value.password.trim() !== '' &&
         intentosRestantes.value > 0
})

const handleLogin = async () => {
  if (!isFormValid.value) {
    return
  }

  error.value = ''
  loading.value = true

  try {
    // Validar credenciales con el servidor
    const response = await api.callStoredProcedure('SP_VALIDAR_USUARIO', {
      p_usuario: credentials.value.usuario.trim(),
      p_password: credentials.value.password.trim()
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'S') {
        // Login exitoso
        toast.success(`Bienvenido, ${result.nombre_usuario || credentials.value.usuario}`)

        // Registrar el acceso
        await registrarAcceso(result.id_usuario)

        // Guardar sesión (simplificado, en producción usar store/pinia)
        sessionStorage.setItem('usuario', JSON.stringify({
          id: result.id_usuario,
          nombre: result.nombre_usuario,
          usuario: credentials.value.usuario
        }))

        // Redirigir al módulo de cementerios
        router.push({ name: 'cementerios' })
      } else {
        // Login fallido
        intentos.value++
        error.value = result.mensaje || 'Usuario o contraseña incorrectos'

        if (intentosRestantes.value === 0) {
          error.value = 'Máximo de intentos alcanzado. Contacte al administrador.'
          setTimeout(() => {
            handleCancel()
          }, 3000)
        }
      }
    } else {
      intentos.value++
      error.value = 'Usuario o contraseña incorrectos'
    }
  } catch (err) {
    console.error('Error al validar usuario:', err)
    error.value = 'Error de conexión con el servidor'
    intentos.value++
  } finally {
    loading.value = false
  }
}

const registrarAcceso = async (idUsuario) => {
  try {
    await api.callStoredProcedure('SP_REGISTRAR_ACCESO', {
      p_id_usuario: idUsuario,
      p_modulo: 'CEMENTERIOS',
      p_accion: 'LOGIN'
    })
  } catch (err) {
    console.error('Error al registrar acceso:', err)
  }
}

const handleCancel = () => {
  // Limpiar formulario
  credentials.value = {
    usuario: '',
    password: ''
  }
  error.value = ''
  intentos.value = 0

  // Redirigir al inicio
  router.push({ path: '/' })
}
</script>

<style scoped>
.acceso-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--color-primary) 0%, #1e3a5f 100%);
  padding: 2rem;
}

.acceso-card {
  width: 100%;
  max-width: 450px;
  background: white;
  border-radius: 1rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  overflow: hidden;
}

.acceso-header {
  background: linear-gradient(135deg, var(--color-primary) 0%, #2c5aa0 100%);
  color: white;
  padding: 2.5rem 2rem;
  text-align: center;
}

.acceso-logo {
  font-size: 4rem;
  margin-bottom: 1rem;
  opacity: 0.9;
}

.acceso-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.acceso-subtitle {
  font-size: 0.95rem;
  opacity: 0.9;
  margin: 0;
}

.acceso-form {
  padding: 2rem;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  color: var(--color-text-primary);
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.form-label i {
  color: var(--color-primary);
}

.form-control {
  width: 100%;
  padding: 0.875rem 1rem;
  border: 2px solid var(--color-border);
  border-radius: 0.5rem;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-control:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(33, 87, 155, 0.1);
}

.form-control:disabled {
  background-color: var(--color-bg-secondary);
  cursor: not-allowed;
}

.form-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-top: 2rem;
}

.acceso-info {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--color-border);
  text-align: center;
}

.acceso-info p {
  margin: 0;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
}

.alert-danger,
.alert-info {
  padding: 0.875rem 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.95rem;
}

.alert-danger {
  background-color: #fee;
  color: var(--color-danger);
  border: 1px solid var(--color-danger);
}

.alert-info {
  background-color: #e7f3ff;
  color: #0066cc;
  border: 1px solid #0066cc;
}

.fa-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
