<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="lock" /></div>
      <div class="module-view-info"><h1>Acceso</h1></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Usuario</label>
              <input class="municipal-form-control" v-model="user" :disabled="loading" @keyup.enter="login"/>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Password</label>
              <input class="municipal-form-control" v-model="pass" type="password" :disabled="loading" @keyup.enter="login"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="login" :disabled="loading || !user || !pass">
              <span v-if="loading"><font-awesome-icon icon="spinner" spin /> Validando...</span>
              <span v-else>Entrar</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - acceso"
    >
      <h3>acceso</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'acceso'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_exclusivo'

const router = useRouter()
const { loading, execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const user = ref('')
const pass = ref('')

const login = async () => {
  if (!user.value || !pass.value) {
    showToast('Ingrese usuario y contraseña', 'warning')
    return
  }

  // Validación simple del lado del cliente
  // En producción, esto debe validarse contra una tabla de usuarios real
  // o mediante autenticación del servidor PostgreSQL
  try {
    // Intentar conectar con las credenciales proporcionadas
    // Por ahora, validamos que los campos no estén vacíos
    // y redirigimos al menú principal

    if (user.value.trim().length >= 3 && pass.value.trim().length >= 3) {
      // Guardar sesión en localStorage
      localStorage.setItem('estacionamiento_exclusivo_user', user.value)
      localStorage.setItem('estacionamiento_exclusivo_session', new Date().toISOString())

      showToast('Acceso concedido', 'success')
      router.push({ name: 'estacionamiento-exclusivo' })
    } else {
      showToast('Usuario o contraseña inválidos', 'error')
    }
  } catch (e) {
    handleApiError(e)
  }
}

// Verificar si ya hay una sesión activa
const checkSession = () => {
  const storedUser = localStorage.getItem('estacionamiento_exclusivo_user')
  const storedSession = localStorage.getItem('estacionamiento_exclusivo_session')

  if (storedUser && storedSession) {
    const sessionDate = new Date(storedSession)
    const now = new Date()
    const hoursSinceLogin = (now - sessionDate) / (1000 * 60 * 60)

    // Si la sesión tiene menos de 8 horas, redirigir automáticamente
    if (hoursSinceLogin < 8) {
      router.push({ name: 'estacionamiento-exclusivo' })
    }
  }
}

// Verificar sesión al montar el componente
onMounted(() => {
  checkSession()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

