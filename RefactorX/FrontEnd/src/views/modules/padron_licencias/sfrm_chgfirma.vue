<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Cambio de Firma</h1>
        <p>Padrón de Licencias - Cambio de firma de usuario del sistema</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Instrucciones -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Instrucciones
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="instructions-box">
          <ul>
            <li>La firma debe tener un mínimo de 4 caracteres</li>
            <li>Se recomienda usar una combinación de letras y números</li>
            <li>La firma nueva debe ingresarse dos veces para confirmar</li>
            <li>Por seguridad, debe ingresar su firma actual antes de cambiarla</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Formulario de cambio de firma -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="edit" />
          Formulario de Cambio de Firma
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="changeFirma">
          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="user" />
              Usuario: <span class="required">*</span>
            </label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.usuario"
              placeholder="Nombre de usuario"
              required
              maxlength="20"
            >
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="lock" />
              Firma Actual: <span class="required">*</span>
            </label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="formData.firmaActual"
              placeholder="Ingrese su firma actual"
              required
              maxlength="20"
              autocomplete="current-password"
            >
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="key" />
              Nueva Firma: <span class="required">*</span>
            </label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="formData.nuevaFirma"
              placeholder="Ingrese su nueva firma (mínimo 4 caracteres)"
              required
              minlength="4"
              maxlength="20"
              autocomplete="new-password"
              @input="validateFirmaStrength"
            >
            <!-- Indicador de fortaleza -->
            <div v-if="formData.nuevaFirma" class="password-strength-indicator">
              <div class="strength-bar" :class="strengthClass">
                <div class="strength-fill" :style="{ width: strengthPercentage + '%' }"></div>
              </div>
              <small :class="'strength-text-' + strengthClass">
                Fortaleza: {{ strengthText }}
              </small>
            </div>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="check-circle" />
              Confirmar Nueva Firma: <span class="required">*</span>
            </label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="formData.confirmarFirma"
              placeholder="Confirme su nueva firma"
              required
              minlength="4"
              maxlength="20"
              autocomplete="new-password"
              @input="validateMatch"
            >
            <!-- Indicador de coincidencia -->
            <div v-if="formData.confirmarFirma" class="match-indicator">
              <small v-if="firmasMatch" class="text-success">
                <font-awesome-icon icon="check-circle" />
                Las firmas coinciden
              </small>
              <small v-else class="text-danger">
                <font-awesome-icon icon="times-circle" />
                Las firmas no coinciden
              </small>
            </div>
          </div>

          <div class="button-group">
            <button
              type="submit"
              class="btn-municipal-primary"
              :disabled="loading || !canSubmit"
            >
              <font-awesome-icon icon="save" />
              Cambiar Firma
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="resetForm"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Historial de cambios (opcional) -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="history" />
          Recomendaciones de Seguridad
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="security-tips">
          <div class="tip-item">
            <font-awesome-icon icon="shield-alt" class="text-success" />
            <span>Cambie su firma periódicamente</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="user-secret" class="text-warning" />
            <span>No comparta su firma con otras personas</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="eye-slash" class="text-info" />
            <span>Use una firma diferente a su contraseña</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="exclamation-triangle" class="text-danger" />
            <span>Evite usar datos personales obvios</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'sfrm_chgfirma'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()

// Estado
const formData = ref({
  usuario: '',
  firmaActual: '',
  nuevaFirma: '',
  confirmarFirma: ''
})

const strengthPercentage = ref(0)
const strengthClass = ref('weak')
const strengthText = ref('Débil')
const firmasMatch = ref(false)

// Computed
const canSubmit = computed(() => {
  return formData.value.usuario &&
         formData.value.firmaActual &&
         formData.value.nuevaFirma &&
         formData.value.confirmarFirma &&
         formData.value.nuevaFirma === formData.value.confirmarFirma &&
         formData.value.nuevaFirma.length >= 4
})

// Métodos
const validateFirmaStrength = () => {
  const firma = formData.value.nuevaFirma
  let strength = 0

  if (firma.length >= 4) strength += 20
  if (firma.length >= 8) strength += 20
  if (/[a-z]/.test(firma)) strength += 20
  if (/[A-Z]/.test(firma)) strength += 20
  if (/[0-9]/.test(firma)) strength += 10
  if (/[^a-zA-Z0-9]/.test(firma)) strength += 10

  strengthPercentage.value = Math.min(strength, 100)

  if (strength < 40) {
    strengthClass.value = 'weak'
    strengthText.value = 'Débil'
  } else if (strength < 70) {
    strengthClass.value = 'medium'
    strengthText.value = 'Media'
  } else {
    strengthClass.value = 'strong'
    strengthText.value = 'Fuerte'
  }
}

const validateMatch = () => {
  firmasMatch.value = formData.value.nuevaFirma === formData.value.confirmarFirma
}

const changeFirma = async () => {
  // Validaciones
  if (!formData.value.usuario.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Usuario requerido',
      text: 'Por favor ingrese su nombre de usuario',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!formData.value.firmaActual) {
    await Swal.fire({
      icon: 'warning',
      title: 'Firma actual requerida',
      text: 'Debe ingresar su firma actual para continuar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (formData.value.nuevaFirma.length < 4) {
    await Swal.fire({
      icon: 'warning',
      title: 'Firma muy corta',
      text: 'La nueva firma debe tener al menos 4 caracteres',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!firmasMatch.value) {
    await Swal.fire({
      icon: 'error',
      title: 'Las firmas no coinciden',
      text: 'La nueva firma y su confirmación no coinciden',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (formData.value.firmaActual === formData.value.nuevaFirma) {
    await Swal.fire({
      icon: 'warning',
      title: 'Firma sin cambios',
      text: 'La nueva firma debe ser diferente a la actual',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    title: '¿Confirmar cambio de firma?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se cambiará la firma para el usuario:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Usuario:</strong> ${formData.value.usuario}</li>
          <li style="margin: 5px 0;"><strong>Fortaleza de la nueva firma:</strong>
            <span class="badge-${strengthClass.value}">${strengthText.value}</span>
          </li>
        </ul>
        <p style="margin-top: 15px; color: #dc3545; font-size: 0.9em;">
          <strong>IMPORTANTE:</strong> Asegúrese de recordar su nueva firma
        </p>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cambiar firma',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) {
    return
  }

  setLoading(true, 'Cambiando firma...')

  try {
    const response = await execute(
      'sfrm_chgfirma_upd_firma',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: formData.value.usuario.trim(), tipo: 'string' },
        { nombre: 'p_firma_actual', valor: formData.value.firmaActual, tipo: 'string' },
        { nombre: 'p_firma_nueva', valor: formData.value.nuevaFirma, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      resetForm()

      await Swal.fire({
        icon: 'success',
        title: '¡Firma cambiada!',
        text: 'Su firma ha sido actualizada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', 'Firma cambiada exitosamente')
    } else {
      const errorMessage = response?.result?.[0]?.message || 'Error al cambiar la firma'

      await Swal.fire({
        icon: 'error',
        title: 'Error al cambiar firma',
        text: errorMessage,
        confirmButtonColor: '#ea8215'
      })

      showToast('error', errorMessage)
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo cambiar la firma. Verifique su firma actual.',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    setLoading(false)
  }
}

const resetForm = () => {
  formData.value = {
    usuario: '',
    firmaActual: '',
    nuevaFirma: '',
    confirmarFirma: ''
  }
  strengthPercentage.value = 0
  strengthClass.value = 'weak'
  strengthText.value = 'Débil'
  firmasMatch.value = false
  showToast('info', 'Formulario limpiado')
}

// Lifecycle
onMounted(() => {
  // No cargar nada automáticamente
})
</script>

