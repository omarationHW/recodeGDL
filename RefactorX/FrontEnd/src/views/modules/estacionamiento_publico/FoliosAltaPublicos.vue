<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-plus" /></div>
      <div class="module-view-info">
        <h1>Alta de Folio de Adeudo — Estacionamientos Públicos</h1>
        <p>Registrar nuevo folio en ta14_folios_adeudo</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Sección de Datos del Folio -->
      <div class="form-section">
        <div class="section-header section-header-success">
          <div class="section-icon"><font-awesome-icon icon="file-circle-plus" /></div>
          <div class="section-title-group">
            <h3>Datos del Folio</h3>
            <span class="section-subtitle">Complete la información para registrar el folio de adeudo</span>
          </div>
        </div>
        <div class="section-body">
          <!-- Datos básicos -->
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label required-field">Año</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.axo" :min="2000" :max="2100" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label required-field">Folio</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="hashtag" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.folio" placeholder="Número de folio" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label required-field">Fecha Folio</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar-day" /></span>
                <input type="date" class="municipal-form-control" v-model="f.fecha_folio" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label required-field">Placa</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="car" /></span>
                <input type="text" class="municipal-form-control" v-model="f.placa" placeholder="ABC1234" maxlength="7" @input="f.placa = f.placa.toUpperCase()" />
              </div>
              <small class="field-hint">Máximo 7 caracteres</small>
            </div>
          </div>

          <!-- Infracción y Estado -->
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label">Infracción</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="exclamation-triangle" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.infraccion" placeholder="Código" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Estado</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="flag" /></span>
                <select class="municipal-form-control" v-model.number="f.estado">
                  <option :value="0">0 - Pendiente</option>
                  <option :value="1">1 - Activo</option>
                  <option :value="2">2 - Pagado</option>
                  <option :value="3">3 - Cancelado</option>
                </select>
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Vigilante</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="user-shield" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.vigilante" placeholder="ID" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Usuario Inicial</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="user" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.usu_inicial" placeholder="ID" />
              </div>
            </div>
          </div>

          <!-- Ubicación -->
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label">Zona</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="map-marker-alt" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.zona" placeholder="Número de zona" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Espacio</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="parking" /></span>
                <input type="number" class="municipal-form-control" v-model.number="f.espacio" placeholder="Número de espacio" />
              </div>
            </div>
          </div>

          <!-- Botones -->
          <div class="form-actions">
            <button class="btn-municipal-primary" @click="guardar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" /> Guardar Folio
            </button>
            <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
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
            <h3>Información</h3>
            <span class="section-subtitle">Campos marcados con * son obligatorios</span>
          </div>
        </div>
        <div class="section-body">
          <div class="info-list">
            <div class="info-item">
              <font-awesome-icon icon="check-circle" class="info-icon text-success" />
              <span>El folio se registrará en la tabla <code>ta14_folios_adeudo</code></span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="calendar-alt" class="info-icon text-info" />
              <span>El año y folio forman la clave primaria del registro</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="car" class="info-icon text-warning" />
              <span>La placa se convierte automáticamente a mayúsculas</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - FoliosAltaPublicos">
      <h3>Alta de Folios de Adeudo</h3>
      <p>Este módulo permite registrar nuevos folios de adeudo para estacionamientos públicos.</p>
      <h4>Campos obligatorios:</h4>
      <ul>
        <li><strong>Año:</strong> Año fiscal del folio</li>
        <li><strong>Folio:</strong> Número único del folio</li>
        <li><strong>Fecha:</strong> Fecha de emisión del folio</li>
        <li><strong>Placa:</strong> Placa del vehículo (máx 7 caracteres)</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'FoliosAltaPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { reactive, ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const f = reactive({
  axo: new Date().getFullYear(),
  folio: null,
  fecha_folio: new Date().toISOString().split('T')[0],
  placa: '',
  infraccion: 0,
  estado: 0,
  vigilante: 0,
  usu_inicial: 0,
  zona: 0,
  espacio: 0
})

function validarFormulario() {
  if (!f.axo || f.axo < 2000 || f.axo > 2100) {
    showToast('warning', 'El año es requerido y debe estar entre 2000 y 2100')
    return false
  }
  if (!f.folio || f.folio <= 0) {
    showToast('warning', 'El folio es requerido y debe ser mayor a 0')
    return false
  }
  if (!f.fecha_folio) {
    showToast('warning', 'La fecha del folio es requerida')
    return false
  }
  if (!f.placa || f.placa.trim() === '') {
    showToast('warning', 'La placa es requerida')
    return false
  }
  return true
}

function limpiar() {
  f.folio = null
  f.placa = ''
  f.infraccion = 0
  f.estado = 0
  f.vigilante = 0
  f.usu_inicial = 0
  f.zona = 0
  f.espacio = 0
  showToast('info', 'Formulario limpiado')
}

async function guardar() {
  if (!validarFormulario()) return

  hideLoading()
  await nextTick()

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Alta',
    html: `
      <div style="text-align: left;">
        <p>¿Registrar el siguiente folio de adeudo?</p>
        <table style="width: 100%; margin-top: 1rem; border-collapse: collapse;">
          <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Año:</td>
            <td style="padding: 0.5rem;">${f.axo}</td>
          </tr>
          <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Folio:</td>
            <td style="padding: 0.5rem;">${f.folio}</td>
          </tr>
          <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Placa:</td>
            <td style="padding: 0.5rem;"><code>${f.placa}</code></td>
          </tr>
          <tr>
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Fecha:</td>
            <td style="padding: 0.5rem;">${f.fecha_folio}</td>
          </tr>
        </table>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, registrar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Guardando...', 'Registrando folio de adeudo')
  try {
    const params = [
      { nombre: 'p_axo', valor: f.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: f.folio, tipo: 'integer' },
      { nombre: 'p_fecha_folio', valor: f.fecha_folio, tipo: 'date' },
      { nombre: 'p_placa', valor: f.placa.toUpperCase(), tipo: 'string' },
      { nombre: 'p_infraccion', valor: f.infraccion || 0, tipo: 'integer' },
      { nombre: 'p_estado', valor: f.estado || 0, tipo: 'integer' },
      { nombre: 'p_vigilante', valor: f.vigilante || 0, tipo: 'integer' },
      { nombre: 'p_usu_inicial', valor: f.usu_inicial || 0, tipo: 'integer' },
      { nombre: 'p_zona', valor: f.zona || 0, tipo: 'integer' },
      { nombre: 'p_espacio', valor: f.espacio || 0, tipo: 'integer' }
    ]

    const resp = await execute('sp_insert_folio_adeudo', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Folio Registrado',
        text: data?.message || `Folio ${f.folio} registrado correctamente`,
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
      limpiar()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo registrar el folio'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

// Documentación y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
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

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
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

/* Form grid */
.form-grid {
  display: grid;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-grid.cols-4 {
  grid-template-columns: repeat(4, 1fr);
}

@media (max-width: 1200px) {
  .form-grid.cols-4 { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 768px) {
  .form-grid.cols-4 { grid-template-columns: 1fr; }
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
  padding-top: 1.5rem;
  border-top: 1px solid #e9ecef;
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
</style>
