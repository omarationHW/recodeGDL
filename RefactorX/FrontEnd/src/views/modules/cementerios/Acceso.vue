<template>
  <div class="acceso-container">
    <div class="acceso-card">
      <div class="acceso-header">
        <div class="acceso-logo">
          <font-awesome-icon icon="landmark" />
        </div>
        <h2 class="acceso-title">Control de Acceso - Cementerios</h2>
        <p class="acceso-subtitle">Sistema Municipal de Ingresos</p>
      </div>

      <form @submit.prevent="handleLogin" class="acceso-form">
        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="user" />
            Usuario
          </label>
          <input
            v-model="credentials.usuario"
            type="text"
            class="municipal-form-control"
            placeholder="Ingrese su usuario"
            :disabled="loading"
            autocomplete="username"
            required
            autofocus
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="lock" />
            Contraseña
          </label>
          <input
            v-model="credentials.password"
            type="password"
            class="municipal-form-control"
            placeholder="Ingrese su contraseña"
            :disabled="loading"
            autocomplete="current-password"
            required
          />
        </div>

        <div v-if="error" class="alert-danger">
          <font-awesome-icon icon="exclamation-circle" />
          {{ error }}
        </div>

        <div v-if="loading" class="alert-info">
          <font-awesome-icon icon="spinner fa-spin" />
          Conectando con el servidor...
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-municipal-primary" :disabled="loading || !isFormValid">
            <font-awesome-icon icon="sign-in-alt" />
            Ingresar
          </button>
          <button type="button" @click="handleCancel" class="btn-municipal-secondary" :disabled="loading">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>

        <div class="acceso-info">
          <p class="text-muted">
            <font-awesome-icon icon="info-circle" />
            Intentos restantes: {{ intentosRestantes }}
          </p>
        </div>
      </form>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'Acceso'"
    :moduleName="'cementerios'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import sessionService from '@/services/sessionService'

const router = useRouter()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

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
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_validar_usuario',
        Base: 'cementerio',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_usuario', valor: credentials.value.usuario.trim(), tipo: 'string' },
          { nombre: 'p_password', valor: credentials.value.password.trim(), tipo: 'string' }
        ]
      }
    })

    // Verificar respuesta del SP
    console.log('📦 Respuesta completa del servidor:', response.data)

    if (response.data.eResponse && response.data.eResponse.success) {
      const result = response.data.eResponse.data.result
      console.log('📦 Result del SP:', result)

      if (result && result.length > 0) {
        const userData = result[0]
        console.log('📦 userData:', userData)

        // Verificar si el login fue exitoso
        // El SP retorna: {success: true, message: 'Usuario válido'}
        const loginExitoso = userData.success === true ||
                            userData.resultado === 'S' ||
                            (userData.message && userData.message.includes('válido'))

        if (loginExitoso) {
          // Guardar sesión usando sessionService
          // Si el SP no retorna id_usuario, usamos el nombre de usuario como identificador
          sessionService.setSession(
            {
              usuario: credentials.value.usuario,
              id_usuario: userData.id_usuario || credentials.value.usuario,
              nombre: userData.nombre_usuario || userData.nombre || credentials.value.usuario,
              sistema: 'cementerios'
            },
            null // Cementerios no usa ejercicio
          )

          // Registrar el acceso (si existe id_usuario)
          if (userData.id_usuario) {
            await registrarAcceso(userData.id_usuario)
          }

          console.log('✅ Login exitoso (Cementerios):', sessionService.getSessionInfo())

          // Redirigir al módulo de cementerios
          router.push({ name: 'cementerios' })
        } else {
          // Login fallido
          intentos.value++
          const mensaje = userData.mensaje || userData.message || 'Usuario o contraseña incorrectos'
          error.value = `${mensaje} (Intento ${intentos.value} de ${maxIntentos})`

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
    } else {
      intentos.value++
      error.value = response.data.eResponse?.message || 'Error al validar credenciales'
    }
  } catch (err) {
    console.error('Error al validar usuario:', err)

    if (err.response) {
      error.value = err.response.data?.message || 'Error al conectar con el servidor'
    } else if (err.request) {
      error.value = 'No se pudo conectar con el servidor. Verifique su conexión.'
    } else {
      error.value = 'Error al procesar la solicitud'
    }

    intentos.value++
  } finally {
    loading.value = false
  }
}

const registrarAcceso = async (idUsuario) => {
  try {
    await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_registrar_acceso',
        Base: 'cementerios',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_usuario', valor: idUsuario, tipo: 'string' },
          { nombre: 'p_modulo', valor: 'CEMENTERIOS', tipo: 'string' },
          { nombre: 'p_accion', valor: 'LOGIN', tipo: 'string' }
        ]
      }
    })
    console.log('✅ Acceso registrado correctamente')
  } catch (err) {
    console.error('Error al registrar acceso:', err)
    // No es crítico, continuar con el login
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
