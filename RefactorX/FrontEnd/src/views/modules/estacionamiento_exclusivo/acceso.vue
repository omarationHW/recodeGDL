<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="lock" /></div>
      <div class="module-view-info"><h1>Acceso</h1></div>
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
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Usuario</label>
              <input class="municipal-form-control" v-model="user" @keyup.enter="login"/>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Password</label>
              <input class="municipal-form-control" v-model="pass" type="password" @keyup.enter="login"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="login" :disabled="!user || !pass">
              <font-awesome-icon icon="sign-in-alt" />
              Entrar
            </button>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'acceso'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Acceso'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_exclusivo'

const router = useRouter()
const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

const user = ref('')
const pass = ref('')
const selectedRow = ref(null)
const hasSearched = ref(false)

const login = async () => {
  if (!user.value || !pass.value) {
    showToast('warning', 'Ingrese usuario y contraseña')
    return
  }

  // Validación simple del lado del cliente
  // En producción, esto debe validarse contra una tabla de usuarios real
  // o mediante autenticación del servidor PostgreSQL
  showLoading('Validando credenciales...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    // Intentar conectar con las credenciales proporcionadas
    // Por ahora, validamos que los campos no estén vacíos
    // y redirigimos al menú principal

    if (user.value.trim().length >= 3 && pass.value.trim().length >= 3) {
      // Guardar sesión en localStorage
      localStorage.setItem('estacionamiento_exclusivo_user', user.value)
      localStorage.setItem('estacionamiento_exclusivo_session', new Date().toISOString())

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      toast.value.duration = durationText
      showToast('success', 'Acceso concedido')

      setTimeout(() => {
        router.push({ name: 'estacionamiento-exclusivo' })
      }, 500)
    } else {
      showToast('error', 'Usuario o contraseña inválidos')
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
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

