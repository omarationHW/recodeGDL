<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-xmark" /></div>
      <div class="module-view-info">
        <h1>Bajas — Estacionamientos Públicos</h1>
        <p>Procesamiento de bajas con motivo</p>
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
      <!-- Sección de Baja -->
      <div class="form-section">
        <div class="section-header section-header-danger">
          <div class="section-icon"><font-awesome-icon icon="user-xmark" /></div>
          <div class="section-title-group">
            <h3>Formulario de Baja</h3>
            <span class="section-subtitle">Complete los datos para procesar la baja del estacionamiento</span>
          </div>
        </div>
        <div class="section-body">
          <!-- Alerta de advertencia -->
          <div class="alert-warning-box">
            <font-awesome-icon icon="exclamation-triangle" class="alert-icon" />
            <div class="alert-content">
              <strong>Importante:</strong> La baja de un estacionamiento público es una acción que puede tener consecuencias importantes.
              Asegúrese de verificar la información antes de confirmar.
            </div>
          </div>

          <div class="form-grid cols-2">
            <div class="form-field">
              <label class="municipal-form-label required-field">Número de Licencia</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="id-card" /></span>
                <input
                  class="municipal-form-control"
                  v-model="form.numlic"
                  placeholder="Ingrese el número de licencia"
                  @keyup.enter="darBaja"
                />
              </div>
              <small class="field-hint">Número de licencia del estacionamiento a dar de baja</small>
            </div>
            <div class="form-field span-full">
              <label class="municipal-form-label required-field">Motivo de la Baja</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="comment-alt" /></span>
                <input
                  class="municipal-form-control"
                  v-model="form.motivo"
                  placeholder="Describa el motivo de la baja"
                  @keyup.enter="darBaja"
                />
              </div>
              <small class="field-hint">Indique la razón por la cual se da de baja el estacionamiento</small>
            </div>
          </div>

          <div class="form-actions">
            <button class="btn-municipal-danger" :disabled="loading" @click="darBaja">
              <font-awesome-icon icon="ban" /> Procesar Baja
            </button>
            <button class="btn-municipal-secondary" :disabled="loading" @click="limpiarFormulario">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Información adicional -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="info-circle" /></div>
          <div class="section-title-group">
            <h3>Información del Proceso</h3>
            <span class="section-subtitle">Detalles sobre el proceso de baja</span>
          </div>
        </div>
        <div class="section-body">
          <div class="info-list">
            <div class="info-item">
              <font-awesome-icon icon="check-circle" class="info-icon text-success" />
              <span>La baja queda registrada en el historial del sistema</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="clock" class="info-icon text-warning" />
              <span>Se registra la fecha y hora de la operación</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="user" class="info-icon text-info" />
              <span>Se registra el usuario que realizó la baja</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="file-alt" class="info-icon text-primary" />
              <span>El motivo queda guardado para referencia futura</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'BajasPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Bajas - Estacionamientos Públicos'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { reactive, ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const form = reactive({
  numlic: '',
  motivo: ''
})

function validarFormulario() {
  if (!form.numlic || form.numlic.trim() === '') {
    showToast('warning', 'Debe ingresar el número de licencia')
    return false
  }

  if (!form.motivo || form.motivo.trim() === '') {
    showToast('warning', 'Debe ingresar el motivo de la baja')
    return false
  }

  return true
}

function limpiarFormulario() {
  form.numlic = ''
  form.motivo = ''
  showToast('info', 'Formulario limpiado')
}

async function darBaja() {
  if (!validarFormulario()) return

  hideLoading()
  await nextTick()

  const confirmacion = await Swal.fire({
    icon: 'warning',
    title: 'Confirmar Baja',
    html: `
      <div style="text-align: left;">
        <p>¿Está seguro de dar de baja la licencia <strong>${form.numlic}</strong>?</p>
        <table style="width: 100%; margin-top: 1rem; border-collapse: collapse;">
          <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Licencia:</td>
            <td style="padding: 0.5rem;">${form.numlic}</td>
          </tr>
          <tr>
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Motivo:</td>
            <td style="padding: 0.5rem;">${form.motivo}</td>
          </tr>
        </table>
        <p style="margin-top: 1rem; color: #dc3545; font-size: 0.9rem;">
          <strong>Esta acción no se puede deshacer.</strong>
        </p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Procesando baja...', 'Por favor espere')
  try {
    const params = [
      { nombre: 'p_numlic', valor: form.numlic.trim(), tipo: 'string' },
      { nombre: 'p_motivo', valor: form.motivo.trim(), tipo: 'string' }
    ]

    const resp = await execute('sp_sfrm_baja_pub', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Baja Registrada',
        text: data?.message || 'La baja se procesó correctamente',
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
      limpiarFormulario()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo procesar la baja'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
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
/* Secciones */
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5rem;
  overflow: hidden;
}

.section-header,
.header-with-badge {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
}

.section-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
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
  padding: 1.5rem;
}

/* Alert box */
.alert-warning-box {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 8px;
  margin-bottom: 1.5rem;
}

.alert-icon,
.empty-state-icon {
  color: #856404;
  font-size: 1.5rem;
  flex-shrink: 0;
}

.alert-content {
  color: #856404;
  line-height: 1.5;
}

/* Form grid */
.form-grid {
  display: grid;
  gap: 1.5rem;
}

.form-grid.cols-2 {
  grid-template-columns: repeat(2, 1fr);
}

.span-full {
  grid-column: 1 / -1;
}

@media (max-width: 768px) {
  .form-grid.cols-2 { grid-template-columns: 1fr; }
}

.form-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.required-field::after {
  content: ' *';
  color: #dc3545;
}

.field-hint {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.8rem;
  color: #6c757d;
}

.input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 12px;
  color: #6c757d;
  z-index: 1;
}

.input-group .municipal-form-control {
  padding-left: 38px;
}

/* Form actions */
.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e9ecef;
}

.btn-municipal-danger {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-municipal-danger:hover:not(:disabled) {
  background: linear-gradient(135deg, #c82333 0%, #bd2130 100%);
  transform: translateY(-1px);
}

.btn-municipal-danger:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Info list */
.info-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.info-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.text-success { color: #28a745; }
.text-warning { color: #ffc107; }
.text-info { color: #17a2b8; }
.text-primary { color: #667eea; }

/* Clases de componentes municipales */
.municipal-tabs {
  display: flex;
  border-bottom: 2px solid #dee2e6;
  margin-bottom: 1.5rem;
}

.municipal-tab {
  padding: 0.75rem 1.5rem;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  color: #6c757d;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.municipal-tab:hover {
  color: #667eea;
  border-bottom-color: #667eea;
}

.municipal-tab.active {
  color: #667eea;
  border-bottom-color: #667eea;
}

.row-hover {
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

.table-row-selected {
  background-color: #e7f3ff !important;
  font-weight: 500;
}
</style>
