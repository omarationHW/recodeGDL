<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="signature" />
      </div>
      <div class="module-view-info">
        <h1>Validación de Firma Digital</h1>
        <p>Padrón de Licencias - Validación de Firma Digital de Usuarios</p></div>
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

    <!-- Formulario de validación -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="shield-alt" />
          Verificación de Firma Electrónica
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="validateFirma">
          <div class="form-group">
            <label class="municipal-form-label">Usuario: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="validationForm.usuario"
              maxlength="50"
              placeholder="Nombre de usuario"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Firma Digital: <span class="required">*</span></label>
            <input
              type="password"
              class="municipal-form-control"
              v-model="validationForm.firma"
              maxlength="255"
              placeholder="Ingrese la firma digital"
              required
            >
            <small class="form-text">
              <font-awesome-icon icon="info-circle" />
              La firma digital es confidencial y se validará contra la base de datos
            </small>
          </div>
          <div class="button-group">
            <button
              type="submit"
              class="btn-municipal-primary"
              :disabled="loading || !validationForm.usuario || !validationForm.firma"
            >
              <font-awesome-icon icon="check-circle" />
              Validar Firma
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="clearForm"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Resultado de validación -->
    <div class="municipal-card" v-if="validationResult">
      <div class="municipal-card-header" :class="validationResult.success ? 'bg-success' : 'bg-danger'">
        <h5 class="text-white">
          <font-awesome-icon :icon="validationResult.success ? 'check-circle' : 'times-circle'" />
          Resultado de Validación
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="validation-result" :class="validationResult.success ? 'result-success' : 'result-error'">
          <div class="result-icon">
            <font-awesome-icon
              :icon="validationResult.success ? 'check-circle' : 'times-circle'"
              size="4x"
            />
          </div>
          <div class="result-content">
            <h3>{{ validationResult.success ? 'Firma Válida' : 'Firma Inválida' }}</h3>
            <p>{{ validationResult.message }}</p>
            <div class="result-details">
              <div class="detail-item">
                <strong>Usuario:</strong>
                <code>{{ validationForm.usuario }}</code>
              </div>
              <div class="detail-item">
                <strong>Fecha de validación:</strong>
                <span>{{ validationResult.timestamp }}</span>
              </div>
              <div class="detail-item">
                <strong>Estado:</strong>
                <span class="badge" :class="validationResult.success ? 'badge-success' : 'badge-danger'">
                  {{ validationResult.success ? 'APROBADA' : 'RECHAZADA' }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Historial de validaciones (opcional) -->
    <div class="municipal-card" v-if="validationHistory.length > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="history" />
          Historial de Validaciones
          <span class="badge-purple">{{ validationHistory.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Usuario</th>
                <th>Resultado</th>
                <th>Mensaje</th>
                <th>Fecha</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in validationHistory" :key="index" class="clickable-row">
                <td><code>{{ item.usuario }}</code></td>
                <td>
                  <span class="badge" :class="item.success ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="item.success ? 'check' : 'times'" />
                    {{ item.success ? 'VÁLIDA' : 'INVÁLIDA' }}
                  </span>
                </td>
                <td>{{ item.message }}</td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="clock" />
                    {{ item.timestamp }}
                  </small>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Validando firma digital...</p>
      </div>
    </div>

    <!-- Toast Notification -->
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
      :componentName="'firmausuario'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onBeforeUnmount } from 'vue'
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
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const validationForm = ref({
  usuario: '',
  firma: ''
})

const validationResult = ref(null)
const validationHistory = ref([])

// Métodos
const validateFirma = async () => {
  if (!validationForm.value.usuario || !validationForm.value.firma) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete el usuario y la firma digital',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Validando firma digital...')

  try {
    const response = await execute(
      'sp_validate_firma_usuario',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: validationForm.value.usuario, tipo: 'string' },
        { nombre: 'p_firma', valor: validationForm.value.firma, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]

      validationResult.value = {
        success: result.success,
        message: result.message,
        timestamp: new Date().toLocaleString('es-ES', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit'
        })
      }

      // Agregar al historial
      validationHistory.value.unshift({
        usuario: validationForm.value.usuario,
        success: result.success,
        message: result.message,
        timestamp: validationResult.value.timestamp
      })

      // Limitar historial a 10 registros
      if (validationHistory.value.length > 10) {
        validationHistory.value.pop()
      }

      if (result.success) {
        showToast('success', 'Firma validada correctamente')
        await Swal.fire({
          icon: 'success',
          title: 'Firma Válida',
          text: result.message,
          confirmButtonColor: '#ea8215',
          timer: 3000
        })
      } else {
        showToast('error', 'Firma inválida')
        await Swal.fire({
          icon: 'error',
          title: 'Firma Inválida',
          text: result.message,
          confirmButtonColor: '#ea8215'
        })
      }

      // Limpiar firma después de validar
      validationForm.value.firma = ''
    } else {
      validationResult.value = {
        success: false,
        message: 'Error al validar la firma',
        timestamp: new Date().toLocaleString('es-ES')
      }

      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se pudo validar la firma',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    validationResult.value = {
      success: false,
      message: 'Error de conexión al validar la firma',
      timestamp: new Date().toLocaleString('es-ES')
    }
  } finally {
    setLoading(false)
  }
}

const clearForm = () => {
  validationForm.value = {
    usuario: '',
    firma: ''
  }
  validationResult.value = null
}

// Lifecycle
onBeforeUnmount(() => {
  validationResult.value = null
})
</script>

