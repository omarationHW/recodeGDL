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
            autocomplete="current-password"
            required
          />
        </div>

        <div v-if="error" class="alert-danger">
          <font-awesome-icon icon="exclamation-circle" />
          {{ error }}
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-municipal-primary" :disabled="!isFormValid">
            <font-awesome-icon icon="sign-in-alt" />
            Ingresar
          </button>
          <button type="button" @click="handleCancel" class="btn-municipal-secondary">
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
    :show="showDocModal"
    :componentName="'Acceso'"
    :moduleName="'cementerios'"
    :docType="docType"
    :title="'Control de Acceso - Cementerios'"
    @close="showDocModal = false"
  />
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()
const router = useRouter()

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const credentials = ref({
  usuario: '',
  password: ''
})

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
  showLoading('Validando credenciales...', 'Por favor espere')

  try {
    // Validar credenciales con el servidor
    const params = [
      {
        nombre: 'p_usuario',
        valor: credentials.value.usuario.trim(),
        tipo: 'string'
      },
      {
        nombre: 'p_password',
        valor: credentials.value.password.trim(),
        tipo: 'string'
      }
    ]

    const response = await execute('sp_validar_usuario', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'publico')

    if (response.result && response.result.length > 0) {
      const result = response.result[0]

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
    hideLoading()
  }
}

const registrarAcceso = async (idUsuario) => {
  try {
    const params = [
      {
        nombre: 'p_id_usuario',
        valor: idUsuario,
        tipo: 'string'
      },
      {
        nombre: 'p_modulo',
        valor: 'CEMENTERIOS',
        tipo: 'string'
      },
      {
        nombre: 'p_accion',
        valor: 'LOGIN',
        tipo: 'string'
      }
    ]

    const response = await execute('sp_registrar_acceso', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'publico')
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

.alert-danger {
  padding: 0.875rem 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.95rem;
  background-color: #fee;
  color: var(--color-danger);
  border: 1px solid var(--color-danger);
}
</style>
