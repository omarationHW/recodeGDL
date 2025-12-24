<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="lock" /></div>
      <div class="module-view-info">
        <h1>Seguridad — Inicio de Sesion</h1>
        <p>Validacion de credenciales del sistema</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Login -->
      <div class="login-container">
        <div class="form-section login-card">
          <div class="section-header">
            <div class="section-icon"><font-awesome-icon icon="user-shield" /></div>
            <div class="section-title-group">
              <h3>Acceso al Sistema</h3>
              <span class="section-subtitle">Ingrese sus credenciales</span>
            </div>
          </div>
          <div class="section-body">
            <div class="login-form">
              <div class="form-field">
                <label class="municipal-form-label">Usuario <span class="required">*</span></label>
                <div class="input-group">
                  <span class="input-icon"><font-awesome-icon icon="user" /></span>
                  <input
                    type="text"
                    class="municipal-form-control with-icon"
                    v-model="user"
                    placeholder="Ingrese su usuario"
                    @keyup.enter="login"
                    autocomplete="username"
                  />
                </div>
              </div>

              <div class="form-field">
                <label class="municipal-form-label">Contrasena <span class="required">*</span></label>
                <div class="input-group">
                  <span class="input-icon"><font-awesome-icon icon="key" /></span>
                  <input
                    :type="showPassword ? 'text' : 'password'"
                    class="municipal-form-control with-icon with-toggle"
                    v-model="pass"
                    placeholder="Ingrese su contrasena"
                    @keyup.enter="login"
                    autocomplete="current-password"
                  />
                  <button type="button" class="password-toggle" @click="showPassword = !showPassword">
                    <font-awesome-icon :icon="showPassword ? 'eye-slash' : 'eye'" />
                  </button>
                </div>
              </div>

              <div class="login-actions">
                <button class="btn-municipal-primary btn-login" :disabled="loading" @click="login">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'sign-in-alt'" :spin="loading" />
                  {{ loading ? 'Validando...' : 'Ingresar al Sistema' }}
                </button>
              </div>

              <!-- Mensaje de resultado -->
              <div v-if="loginResult" class="login-result" :class="loginResult.type">
                <font-awesome-icon :icon="loginResult.type === 'success' ? 'check-circle' : 'times-circle'" />
                <span>{{ loginResult.message }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Informacion de Seguridad -->
        <div class="security-info">
          <div class="info-card">
            <font-awesome-icon icon="shield-halved" class="info-icon" />
            <h4>Acceso Seguro</h4>
            <p>Sus credenciales son validadas de forma segura contra la base de datos del sistema.</p>
          </div>
          <div class="info-card">
            <font-awesome-icon icon="clock" class="info-icon" />
            <h4>Sesion Controlada</h4>
            <p>Las sesiones tienen tiempo limitado para proteger su informacion.</p>
          </div>
          <div class="info-card">
            <font-awesome-icon icon="user-lock" class="info-icon" />
            <h4>Permisos</h4>
            <p>El acceso a funciones depende del rol asignado a su usuario.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'SeguridadLoginPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Seguridad — Inicio de Sesión'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const user = ref('')
const pass = ref('')
const showPassword = ref(false)
const loginResult = ref(null)

async function login() {
  if (!user.value.trim() || !pass.value) {
    showToast('warning', 'Ingrese usuario y contrasena')
    return
  }

  showLoading('Validando...', 'Verificando credenciales')
  loginResult.value = null

  try {
    const params = [
      { nombre: 'p_user', valor: user.value.trim(), tipo: 'string' },
      { nombre: 'p_pass', valor: pass.value, tipo: 'string' }
    ]
    const resp = await execute('sp_login_seguridad', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data

    if (r?.success) {
      showToast('success', 'Acceso concedido - Bienvenido al sistema')
      loginResult.value = { type: 'success', message: r.message || 'Acceso concedido' }
    } else {
      showToast('error', r?.message || 'Credenciales incorrectas')
      loginResult.value = { type: 'error', message: r?.message || 'Acceso denegado' }
    }
  } catch (e) {
    handleApiError(e)
    loginResult.value = { type: 'error', message: 'Error al validar credenciales' }
  } finally {
    hideLoading()
  }
}

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
</script>

<style scoped>
/* Login Container */
.login-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
  max-width: 1000px;
  margin: 0 auto;
}

@media (max-width: 992px) {
  .login-container { grid-template-columns: 1fr; }
}

/* Form Section */
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  overflow: hidden;
}

.login-card {
  box-shadow: 0 4px 20px rgba(0,0,0,0.12);
}

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-icon {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.section-title-group h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.section-subtitle {
  font-size: 0.85rem;
  opacity: 0.9;
}

.section-body {
  padding: 2rem;
}

/* Login Form */
.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.form-field .required {
  color: #dc3545;
}

.input-group {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
  z-index: 1;
}

.municipal-form-control.with-icon {
  padding-left: 40px;
}

.municipal-form-control.with-toggle {
  padding-right: 45px;
}

.password-toggle {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #6c757d;
  cursor: pointer;
  padding: 0.25rem;
  z-index: 1;
}

.password-toggle:hover {
  color: #667eea;
}

.login-actions {
  margin-top: 0.5rem;
}

.btn-login {
  width: 100%;
  padding: 0.85rem 1.5rem;
  font-size: 1rem;
  font-weight: 600;
}

/* Login Result */
.login-result {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  border-radius: 8px;
  font-weight: 500;
}

.login-result.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.login-result.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

/* Security Info */
.security-info {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.info-card {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1.25rem;
  border-left: 4px solid #667eea;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.info-icon {
  font-size: 1.5rem;
  color: #667eea;
}

.info-card h4 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: #495057;
}

.info-card p {
  margin: 0;
  font-size: 0.9rem;
  color: #6c757d;
  line-height: 1.5;
}
</style>
