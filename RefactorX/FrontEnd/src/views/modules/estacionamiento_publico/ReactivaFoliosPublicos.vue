<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="rotate-left" /></div>
      <div class="module-view-info">
        <h1>Reactivar Folios — Estacionamientos</h1>
        <p>Búsqueda por placa+folio o año+folio</p>
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
      <!-- Sección de Búsqueda -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="search" /></div>
          <div class="section-title-group">
            <h3>Búsqueda de Folios</h3>
            <span class="section-subtitle">Seleccione el tipo de búsqueda e ingrese los criterios</span>
          </div>
        </div>
        <div class="section-body">
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label">Opción de Búsqueda</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="list" /></span>
                <select class="municipal-form-control" v-model.number="opcion">
                  <option :value="0">Placa + Folio</option>
                  <option :value="1">Año + Folio</option>
                </select>
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label" :class="{ 'text-muted': opcion === 1 }">Placa</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="car" /></span>
                <input
                  class="municipal-form-control"
                  v-model="placa"
                  :disabled="opcion === 1"
                  placeholder="ABC1234"
                  @input="placa = placa.toUpperCase()"
                />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label" :class="{ 'text-muted': opcion === 0 }">Año</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar" /></span>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="axo"
                  :disabled="opcion === 0"
                />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label required-field">Folio</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="hashtag" /></span>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="folio"
                  placeholder="Ej: 123 o 123,456,789"
                />
              </div>
              <small class="field-hint">Puede ser lista separada por comas</small>
            </div>
          </div>
          <div class="form-actions">
            <button class="btn-municipal-primary" :disabled="loading" @click="buscar">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar Folios
            </button>
            <button
              class="btn-municipal-success"
              :disabled="loading || resultados.length === 0"
              @click="reactivar"
            >
              <font-awesome-icon icon="rotate-left" /> Reactivar Seleccionados
            </button>
          </div>
        </div>
      </div>

      <!-- Sección de Resultados -->
      <div class="form-section" v-if="resultados.length > 0 || loading">
        <div class="section-header section-header-info header-with-badge">
          <div class="section-icon"><font-awesome-icon icon="list" /></div>
          <div class="section-title-group">
            <h3>Resultados de Búsqueda</h3>
            <span class="section-subtitle">
              <span v-if="resultados.length > 0" class="badge-purple">{{ totalRecords }} folio(s) encontrado(s)</span>
              <span v-else>Buscando...</span>
            </span>
          </div>
          <div class="section-actions" v-if="loading">
            <div class="spinner-border spinner-border-sm" role="status"></div>
          </div>
        </div>
        <div class="section-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center">Año</th>
                  <th>Folio</th>
                  <th>Placa</th>
                  <th>Movimiento</th>
                  <th>Fecha</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedData" :key="`${r.axo}-${r.folio}`" class="row-hover">
                  <td class="text-center">{{ r.axo }}</td>
                  <td><strong class="text-primary">{{ r.folio }}</strong></td>
                  <td><code>{{ r.placa }}</code></td>
                  <td><span class="badge-movto">{{ r.codigo_movto }}</span></td>
                  <td>{{ formatDate(r.fecha_movto) }}</td>
                </tr>
                <tr v-if="resultados.length === 0 && !loading">
                  <td colspan="5" class="empty-state">
                    <font-awesome-icon icon="search" size="2x" class="empty-state-icon" />
                    <p>No se encontraron folios con los criterios especificados</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-footer" v-if="totalRecords > rowsPerPage">
            <div class="pagination-info">
              Mostrando <strong>{{ startIndex }}</strong> a <strong>{{ endIndex }}</strong> de <strong>{{ totalRecords }}</strong> registros
            </div>
            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model.number="rowsPerPage" class="municipal-form-control">
                  <option :value="10">10</option>
                  <option :value="20">20</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>
              <div class="pagination-nav">
                <button class="pagination-button" @click="goToPage(1)" :disabled="currentPage === 1">
                  <font-awesome-icon icon="angles-left" />
                </button>
                <button class="pagination-button" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
                <button class="pagination-button" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                  <font-awesome-icon icon="chevron-right" />
                </button>
                <button class="pagination-button" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                  <font-awesome-icon icon="angles-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Información -->
      <div class="form-section">
        <div class="section-header section-header-warning">
          <div class="section-icon"><font-awesome-icon icon="exclamation-triangle" /></div>
          <div class="section-title-group">
            <h3>Información Importante</h3>
            <span class="section-subtitle">Sobre la reactivación de folios</span>
          </div>
        </div>
        <div class="section-body">
          <div class="info-list">
            <div class="info-item">
              <font-awesome-icon icon="rotate-left" class="info-icon text-primary" />
              <span>La reactivación restaura folios que fueron cancelados o dados de baja</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="list" class="info-icon text-info" />
              <span>Puede buscar múltiples folios separándolos por comas (ej: 123,456,789)</span>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="history" class="info-icon text-warning" />
              <span>Se registra la fecha y usuario que realizó la reactivación</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ReactivaFoliosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Reactivar Folios Estacionamientos'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Formulario
const opcion = ref(0)
const placa = ref('')
const axo = ref(new Date().getFullYear())
const folio = ref('')
const resultados = ref([])

// Paginación
const currentPage = ref(1)
const rowsPerPage = ref(10)
const totalRecords = computed(() => resultados.value.length)
const totalPages = computed(() => Math.max(1, Math.ceil(totalRecords.value / rowsPerPage.value)))
const startIndex = computed(() => ((currentPage.value - 1) * rowsPerPage.value) + 1)
const endIndex = computed(() => Math.min(currentPage.value * rowsPerPage.value, totalRecords.value))
const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * rowsPerPage.value
  const end = start + rowsPerPage.value
  return resultados.value.slice(start, end)
})

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function formatDate(d) {
  if (!d) return '—'
  const dt = new Date(d)
  return dt.toLocaleDateString('es-MX')
}

async function buscar() {
  if (opcion.value === 0 && !placa.value.trim()) {
    showToast('warning', 'Ingrese la placa para buscar')
    return
  }

  if (opcion.value === 1 && !axo.value) {
    showToast('warning', 'Ingrese el año para buscar')
    return
  }

  if (!folio.value.trim()) {
    showToast('warning', 'Ingrese el folio para buscar')
    return
  }

  showLoading('Buscando...', 'Consultando folios')
  resultados.value = []
  currentPage.value = 1
  try {
    const params = [
      { nombre: 'p_opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value.toUpperCase(), tipo: 'string' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_folio', valor: folio.value, tipo: 'string' }
    ]
    const resp = await execute('sp_reactiva_folios_buscar', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    resultados.value = Array.isArray(data) ? data : []

    if (resultados.value.length > 0) {
      showToast('success', `Se encontraron ${resultados.value.length} folio(s)`)
    } else {
      showToast('info', 'No se encontraron folios con los criterios especificados')
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

async function reactivar() {
  if (resultados.value.length === 0) {
    showToast('warning', 'No hay folios para reactivar')
    return
  }

  hideLoading()
  await nextTick()

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Reactivación',
    html: `
      <div style="text-align: left;">
        <p>¿Está seguro de reactivar los siguientes folios?</p>
        <table style="width: 100%; margin-top: 1rem; border-collapse: collapse;">
          <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Cantidad:</td>
            <td style="padding: 0.5rem;"><strong>${resultados.value.length}</strong> folio(s)</td>
          </tr>
          <tr style="border-bottom: 1px solid #dee2e6;">
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Búsqueda:</td>
            <td style="padding: 0.5rem;">${opcion.value === 0 ? 'Placa + Folio' : 'Año + Folio'}</td>
          </tr>
          <tr>
            <td style="padding: 0.5rem; font-weight: 600; color: #6c757d;">Criterio:</td>
            <td style="padding: 0.5rem;">${opcion.value === 0 ? placa.value : axo.value} - Folio: ${folio.value}</td>
          </tr>
        </table>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, reactivar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Reactivando...', 'Procesando folios')
  try {
    const params = [
      { nombre: 'p_opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value.toUpperCase(), tipo: 'string' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_folio', valor: folio.value, tipo: 'string' }
    ]
    await execute('sp_reactiva_folios_ejecutar', BASE_DB, params, '', null, SCHEMA)

    hideLoading()
    await nextTick()

    await Swal.fire({
      icon: 'success',
      title: 'Reactivación Exitosa',
      text: `Se reactivaron ${resultados.value.length} folio(s) correctamente`,
      timer: 2500,
      timerProgressBar: true,
      showConfirmButton: false
    })

    // Limpiar resultados y formulario
    resultados.value = []
    folio.value = ''
    placa.value = ''
    axo.value = new Date().getFullYear()
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

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.section-header-warning {
  background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
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

.section-actions {
  margin-left: auto;
}

.section-body {
  padding: 1.5rem;
}

/* Form grid */
.form-grid {
  display: grid;
  gap: 1.5rem;
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

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e9ecef;
}

.btn-municipal-success {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.625rem 1.25rem;
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-municipal-success:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
}

.btn-municipal-success:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Table */
.badge-movto {
  background: #667eea;
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #6c757d;
}

.empty-state-icon {
  margin-bottom: 1rem;
  opacity: 0.5;
}

/* Pagination */
.pagination-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 0;
  border-top: 1px solid #e9ecef;
  margin-top: 1rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.page-size-selector {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.page-size-selector select {
  width: auto;
  padding: 0.375rem 0.75rem;
}

.pagination-nav {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-button {
  width: 36px;
  height: 36px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.pagination-button:hover:not(:disabled) {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.pagination-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-current {
  padding: 0 1rem;
  font-weight: 500;
  color: #495057;
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

.text-primary { color: #667eea; }
.text-info { color: #17a2b8; }
.text-warning { color: #ffc107; }
.text-muted { color: #6c757d; }
</style>
