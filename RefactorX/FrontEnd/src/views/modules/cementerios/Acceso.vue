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

      <div class="back-to-dashboard">
        <router-link to="/" class="back-link">
          <font-awesome-icon icon="arrow-left" />
          Volver al Dashboard
        </router-link>
      </div>
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
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
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
    , '', null, 'comun')

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
    loading.value = false
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
    , '', null, 'comun')
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
/* =================================================================================
   LOGIN CEMENTERIOS - TEMA MUNICIPAL GUADALAJARA
   Usando variables CSS del municipal-theme.css
   ================================================================================= */

.acceso-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--gradient-guadalajara);
  padding: var(--space-lg);
}

.acceso-card {
  background: white;
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  padding: var(--space-3xl);
  max-width: 450px;
  width: 100%;
  animation: fadeInUp 0.5s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.acceso-header {
  text-align: center;
  margin-bottom: var(--space-2xl);
}

.acceso-logo {
  font-size: 3rem;
  color: var(--municipal-primary);
  margin-bottom: var(--space-md);
  opacity: 0.9;
}

.acceso-title {
  color: var(--municipal-primary);
  font-size: 1.5rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-heading);
  margin: 0 0 var(--space-sm) 0;
}

.acceso-subtitle {
  color: var(--slate-600);
  font-size: 0.95rem;
  font-family: var(--font-municipal);
  margin: 0;
}

.acceso-form {
  padding: 0;
}

.form-group {
  margin-bottom: var(--space-lg);
}

.form-label,
.municipal-form-label {
  display: flex;
  align-items: center;
  gap: var(--space-xs);
  color: var(--slate-700);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--space-sm);
  font-family: var(--font-municipal);
}

.form-label i,
.municipal-form-label i {
  color: var(--municipal-primary);
}

.form-control,
.municipal-form-control {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid var(--slate-300);
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-family: var(--font-municipal);
  transition: var(--transition-normal);
  color: var(--slate-700);
}

.form-control:focus,
.municipal-form-control:focus {
  outline: none;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
}

.form-control:disabled,
.municipal-form-control:disabled {
  background-color: var(--slate-100);
  cursor: not-allowed;
  color: var(--slate-500);
}

.form-actions {
  display: flex;
  justify-content: center;
  gap: var(--space-md);
  margin-top: var(--space-xl);
}

.btn-municipal-primary {
  flex: 1;
  background: var(--gradient-municipal) !important;
  border: 2px solid var(--municipal-primary);
  color: white;
  padding: 14px 24px;
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  cursor: pointer;
  transition: var(--transition-normal);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
}

.btn-municipal-primary:hover:not(:disabled) {
  background: var(--municipal-secondary) !important;
  border-color: var(--municipal-secondary);
  transform: translateY(-2px);
  box-shadow: var(--shadow-lg);
}

.btn-municipal-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-municipal-secondary {
  flex: 1;
  background: white;
  border: 2px solid var(--slate-300);
  color: var(--slate-700);
  padding: 14px 24px;
  border-radius: var(--radius-md);
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  cursor: pointer;
  transition: var(--transition-normal);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: var(--slate-50);
  border-color: var(--slate-400);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.acceso-info {
  margin-top: var(--space-lg);
  padding-top: var(--space-lg);
  border-top: 1px solid var(--slate-200);
  text-align: center;
}

.acceso-info p {
  margin: 0;
  font-size: 0.875rem;
  color: var(--slate-600);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
}

.text-muted {
  color: var(--slate-600);
}

.alert-danger {
  background-color: rgba(220, 53, 69, 0.1);
  color: var(--municipal-danger);
  padding: 12px 16px;
  border-radius: var(--radius-md);
  border-left: 4px solid var(--municipal-danger);
  margin-bottom: var(--space-md);
  text-align: center;
  font-weight: var(--font-weight-regular);
  animation: shake 0.5s ease-out;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-sm);
}

.alert-info {
  color: var(--municipal-primary);
  padding: 12px 16px;
  margin-bottom: var(--space-md);
  text-align: center;
  font-weight: var(--font-weight-regular);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-sm);
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-10px); }
  75% { transform: translateX(10px); }
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

.back-to-dashboard {
  margin-top: var(--space-lg);
  text-align: center;
  padding-top: var(--space-lg);
  border-top: 1px solid var(--slate-200);
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs);
  color: var(--municipal-primary);
  font-size: 0.95rem;
  font-weight: var(--font-weight-regular);
  text-decoration: none;
  transition: var(--transition-normal);
}

.back-link:hover {
  color: var(--municipal-secondary);
  text-decoration: underline;
}

/* Responsive */
@media (max-width: 768px) {
  .acceso-card {
    padding: var(--space-2xl) var(--space-lg);
    max-width: 100%;
  }

  .acceso-title {
    font-size: 1.3rem;
  }
}
</style>
