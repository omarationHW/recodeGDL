<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="lock" />
      </div>
      <div class="module-view-info">
        <h1>Cambio de Contraseña</h1>
        <p>Padrón de Licencias - Cambio de contraseña de usuario del sistema</p></div>
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
            <li>La contraseña debe tener un mínimo de 8 caracteres</li>
            <li>Se recomienda usar mayúsculas, minúsculas, números y caracteres especiales</li>
            <li>La nueva contraseña debe ingresarse dos veces para confirmar</li>
            <li>Por seguridad, debe ingresar su contraseña actual antes de cambiarla</li>
            <li>Evite usar datos personales obvios como fechas de nacimiento</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Formulario de cambio de contraseña -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="edit" />
          Formulario de Cambio de Contraseña
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="changePassword">
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
              Contraseña Actual: <span class="required">*</span>
            </label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="formData.passwordActual"
              placeholder="Ingrese su contraseña actual"
              required
              maxlength="50"
              autocomplete="current-password"
            >
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="key" />
              Nueva Contraseña: <span class="required">*</span>
            </label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="formData.nuevaPassword"
              placeholder="Ingrese su nueva contraseña (mínimo 8 caracteres)"
              required
              minlength="8"
              maxlength="50"
              autocomplete="new-password"
              @input="validatePasswordStrength"
            >
            <!-- Indicador de fortaleza -->
            <div v-if="formData.nuevaPassword" class="password-strength-indicator">
              <div class="strength-bar" :class="strengthClass">
                <div class="strength-fill" :style="{ width: strengthPercentage + '%' }"></div>
              </div>
              <small :class="'strength-text-' + strengthClass">
                Fortaleza: {{ strengthText }}
              </small>
            </div>
            <!-- Tips de fortaleza -->
            <div v-if="formData.nuevaPassword" class="password-tips">
              <small :class="formData.nuevaPassword.length >= 8 ? 'text-success' : 'text-muted'">
                <font-awesome-icon :icon="formData.nuevaPassword.length >= 8 ? 'check-circle' : 'circle'" />
                Mínimo 8 caracteres
              </small>
              <small :class="/[A-Z]/.test(formData.nuevaPassword) ? 'text-success' : 'text-muted'">
                <font-awesome-icon :icon="/[A-Z]/.test(formData.nuevaPassword) ? 'check-circle' : 'circle'" />
                Mayúsculas
              </small>
              <small :class="/[a-z]/.test(formData.nuevaPassword) ? 'text-success' : 'text-muted'">
                <font-awesome-icon :icon="/[a-z]/.test(formData.nuevaPassword) ? 'check-circle' : 'circle'" />
                Minúsculas
              </small>
              <small :class="/[0-9]/.test(formData.nuevaPassword) ? 'text-success' : 'text-muted'">
                <font-awesome-icon :icon="/[0-9]/.test(formData.nuevaPassword) ? 'check-circle' : 'circle'" />
                Números
              </small>
              <small :class="/[^a-zA-Z0-9]/.test(formData.nuevaPassword) ? 'text-success' : 'text-muted'">
                <font-awesome-icon :icon="/[^a-zA-Z0-9]/.test(formData.nuevaPassword) ? 'check-circle' : 'circle'" />
                Caracteres especiales
              </small>
            </div>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="check-circle" />
              Confirmar Nueva Contraseña: <span class="required">*</span>
            </label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="formData.confirmarPassword"
              placeholder="Confirme su nueva contraseña"
              required
              minlength="8"
              maxlength="50"
              autocomplete="new-password"
              @input="validateMatch"
            >
            <!-- Indicador de coincidencia -->
            <div v-if="formData.confirmarPassword" class="match-indicator">
              <small v-if="passwordsMatch" class="text-success">
                <font-awesome-icon icon="check-circle" />
                Las contraseñas coinciden
              </small>
              <small v-else class="text-danger">
                <font-awesome-icon icon="times-circle" />
                Las contraseñas no coinciden
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
              Cambiar Contraseña
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

    <!-- Recomendaciones de seguridad -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="shield-alt" />
          Recomendaciones de Seguridad
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="security-tips">
          <div class="tip-item">
            <font-awesome-icon icon="shield-alt" class="text-success" />
            <span>Cambie su contraseña periódicamente (cada 3-6 meses)</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="user-secret" class="text-warning" />
            <span>No comparta su contraseña con otras personas</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="eye-slash" class="text-info" />
            <span>Use una contraseña diferente para cada sistema</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="exclamation-triangle" class="text-danger" />
            <span>Evite usar datos personales obvios (fechas, nombres)</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="random" class="text-primary" />
            <span>Combine letras, números y símbolos especiales</span>
          </div>
          <div class="tip-item">
            <font-awesome-icon icon="lock" class="text-secondary" />
            <span>No anote su contraseña en lugares visibles</span>
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
      :componentName="'sfrm_chgpass'"
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
  passwordActual: '',
  nuevaPassword: '',
  confirmarPassword: ''
})

const strengthPercentage = ref(0)
const strengthClass = ref('weak')
const strengthText = ref('Débil')
const passwordsMatch = ref(false)

// Computed
const canSubmit = computed(() => {
  return formData.value.usuario &&
         formData.value.passwordActual &&
         formData.value.nuevaPassword &&
         formData.value.confirmarPassword &&
         formData.value.nuevaPassword === formData.value.confirmarPassword &&
         formData.value.nuevaPassword.length >= 8
})

// Métodos
const validatePasswordStrength = () => {
  const password = formData.value.nuevaPassword
  let strength = 0

  if (password.length >= 8) strength += 20
  if (password.length >= 12) strength += 15
  if (password.length >= 16) strength += 15
  if (/[a-z]/.test(password)) strength += 15
  if (/[A-Z]/.test(password)) strength += 15
  if (/[0-9]/.test(password)) strength += 10
  if (/[^a-zA-Z0-9]/.test(password)) strength += 10

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
  passwordsMatch.value = formData.value.nuevaPassword === formData.value.confirmarPassword
}

const changePassword = async () => {
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

  if (!formData.value.passwordActual) {
    await Swal.fire({
      icon: 'warning',
      title: 'Contraseña actual requerida',
      text: 'Debe ingresar su contraseña actual para continuar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (formData.value.nuevaPassword.length < 8) {
    await Swal.fire({
      icon: 'warning',
      title: 'Contraseña muy corta',
      text: 'La nueva contraseña debe tener al menos 8 caracteres',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!passwordsMatch.value) {
    await Swal.fire({
      icon: 'error',
      title: 'Las contraseñas no coinciden',
      text: 'La nueva contraseña y su confirmación no coinciden',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (formData.value.passwordActual === formData.value.nuevaPassword) {
    await Swal.fire({
      icon: 'warning',
      title: 'Contraseña sin cambios',
      text: 'La nueva contraseña debe ser diferente a la actual',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Validar contraseña actual primero
  setLoading(true, 'Validando contraseña actual...')

  try {
    const validateResponse = await execute(
      'sfrm_chgpass_sp_chgpass_validate_current',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: formData.value.usuario.trim(), tipo: 'string' },
        { nombre: 'p_password_actual', valor: formData.value.passwordActual, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (!validateResponse || !validateResponse.result || !validateResponse.result[0]?.valid) {
      setLoading(false)
      await Swal.fire({
        icon: 'error',
        title: 'Contraseña incorrecta',
        text: 'La contraseña actual no es válida',
        confirmButtonColor: '#ea8215'
      })
      return
    }

    // Si la validación es exitosa, continuar con el cambio
    const result = await Swal.fire({
      title: '¿Confirmar cambio de contraseña?',
      html: `
        <div style="text-align: left; padding: 0 20px;">
          <p style="margin-bottom: 10px;">Se cambiará la contraseña para el usuario:</p>
          <ul style="list-style: none; padding: 0;">
            <li style="margin: 5px 0;"><strong>Usuario:</strong> ${formData.value.usuario}</li>
            <li style="margin: 5px 0;"><strong>Fortaleza de la nueva contraseña:</strong>
              <span class="badge-${strengthClass.value}">${strengthText.value}</span>
            </li>
          </ul>
          <p style="margin-top: 15px; color: #dc3545; font-size: 0.9em;">
            <strong>IMPORTANTE:</strong> Asegúrese de recordar su nueva contraseña
          </p>
        </div>
      `,
      icon: 'question',
      showCancelButton: true,
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, cambiar contraseña',
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) {
      setLoading(false)
      return
    }

    setLoading(true, 'Cambiando contraseña...')

    // Cambiar la contraseña
    const changeResponse = await execute(
      'sfrm_chgpass_sp_chgpass_update',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: formData.value.usuario.trim(), tipo: 'string' },
        { nombre: 'p_password_nueva', valor: formData.value.nuevaPassword, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (changeResponse && changeResponse.result && changeResponse.result[0]?.success) {
      // Registrar en bitácora
      await execute(
        'sfrm_chgpass_sp_bitacora_chgpass',
        'padron_licencias',
        [
          { nombre: 'p_usuario', valor: formData.value.usuario.trim(), tipo: 'string' },
          { nombre: 'p_accion', valor: 'CAMBIO_CONTRASEÑA', tipo: 'string' }
        ],
        'guadalajara'
      )

      resetForm()

      await Swal.fire({
        icon: 'success',
        title: '¡Contraseña cambiada!',
        text: 'Su contraseña ha sido actualizada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', 'Contraseña cambiada exitosamente')
    } else {
      const errorMessage = changeResponse?.result?.[0]?.message || 'Error al cambiar la contraseña'

      await Swal.fire({
        icon: 'error',
        title: 'Error al cambiar contraseña',
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
      text: 'No se pudo cambiar la contraseña. Verifique su contraseña actual.',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    setLoading(false)
  }
}

const resetForm = () => {
  formData.value = {
    usuario: '',
    passwordActual: '',
    nuevaPassword: '',
    confirmarPassword: ''
  }
  strengthPercentage.value = 0
  strengthClass.value = 'weak'
  strengthText.value = 'Débil'
  passwordsMatch.value = false
  showToast('info', 'Formulario limpiado')
}

// Lifecycle
onMounted(() => {
  // No cargar nada automáticamente
})
</script>

<style scoped>
.instructions-box {
  background: #e7f3ff;
  border-left: 4px solid #0066cc;
  padding: 16px;
  border-radius: 4px;
}

.instructions-box ul {
  margin: 0;
  padding-left: 20px;
}

.instructions-box li {
  margin: 8px 0;
  color: #495057;
}

.password-strength-indicator {
  margin-top: 8px;
}

.strength-bar {
  height: 6px;
  background: #e9ecef;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 4px;
}

.strength-fill {
  height: 100%;
  transition: width 0.3s, background-color 0.3s;
}

.strength-bar.weak .strength-fill {
  background-color: #dc3545;
}

.strength-bar.medium .strength-fill {
  background-color: #ffc107;
}

.strength-bar.strong .strength-fill {
  background-color: #28a745;
}

.strength-text-weak {
  color: #dc3545;
}

.strength-text-medium {
  color: #ffc107;
}

.strength-text-strong {
  color: #28a745;
}

.password-tips {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 8px;
  padding: 8px;
  background: #f8f9fa;
  border-radius: 4px;
}

.password-tips small {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.85em;
}

.match-indicator {
  margin-top: 8px;
}

.security-tips {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
}

.tip-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 6px;
  border-left: 3px solid #dee2e6;
}

.tip-item svg {
  font-size: 1.2em;
}

.badge-weak {
  background-color: #dc3545;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.85em;
}

.badge-medium {
  background-color: #ffc107;
  color: #212529;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.85em;
}

.badge-strong {
  background-color: #28a745;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 0.85em;
}

.required {
  color: #dc3545;
}

.full-width {
  grid-column: 1 / -1;
}
</style>
