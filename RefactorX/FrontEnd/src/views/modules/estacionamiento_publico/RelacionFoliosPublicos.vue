<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list-ol" /></div>
      <div class="module-view-info">
        <h1>Relacion de Folios</h1>
        <p>Consulta por tipo de fecha</p>
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
      <!-- Seccion de Filtros -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Parametros de Consulta</h3>
            <span class="section-subtitle">Seleccione el tipo de fecha y la fecha a consultar</span>
          </div>
        </div>
        <div class="section-body">
          <div class="filter-grid">
            <div class="form-field">
              <label class="municipal-form-label">Tipo de Fecha</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar-alt" /></span>
                <select class="municipal-form-control with-icon" v-model.number="opcion">
                  <option :value="1">Fecha Folio</option>
                  <option :value="2">Fecha Alta</option>
                  <option :value="3">Fecha Baja (Pago)</option>
                  <option :value="4">Fecha Baja (Cancelacion)</option>
                </select>
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Fecha</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar-day" /></span>
                <input type="date" class="municipal-form-control with-icon" v-model="fecha" @keyup.enter="consultar" />
              </div>
            </div>
            <div class="form-field form-field-action">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary btn-block" :disabled="loading" @click="consultar">
                <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" /> Ejecutar Consulta
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Resultados -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Resultados</h3>
            <span class="section-subtitle">
              <span v-if="rows.length > 0">{{ rows.length }} registro(s) encontrado(s)</span>
              <span v-else>Esperando consulta</span>
            </span>
          </div>
          <div class="section-actions" v-if="rows.length > 0">
            <button class="btn-section-action" @click="exportarExcel" title="Exportar a Excel">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
        <div class="section-body">
          <!-- Tabla de resultados -->
          <div v-if="rows.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th><font-awesome-icon icon="calendar" class="th-icon" /> Ano</th>
                  <th><font-awesome-icon icon="file-alt" class="th-icon" /> Folio</th>
                  <th><font-awesome-icon icon="car" class="th-icon" /> Placa</th>
                  <th><font-awesome-icon icon="calendar-day" class="th-icon" /> Fecha</th>
                  <th><font-awesome-icon icon="info-circle" class="th-icon" /> Estado</th>
                  <th><font-awesome-icon icon="exclamation-triangle" class="th-icon" /> Infraccion</th>
                  <th><font-awesome-icon icon="dollar-sign" class="th-icon" /> Tarifa</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.axo}-${r.folio}`">
                  <td><span class="badge-year">{{ r.axo }}</span></td>
                  <td><code class="folio-code">{{ r.folio }}</code></td>
                  <td><span class="placa-badge">{{ r.placa || '—' }}</span></td>
                  <td>{{ formatDate(r.fecha_folio) }}</td>
                  <td>
                    <span class="estado-badge" :class="getEstadoClass(r.estado)">
                      {{ r.estado || '—' }}
                    </span>
                  </td>
                  <td>{{ r.infraccion || '—' }}</td>
                  <td class="text-end"><strong>${{ formatNumber(r.tarifa) }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Estado vacio -->
          <div v-else class="empty-state-panel">
            <div class="empty-icon-container">
              <font-awesome-icon icon="list-ol" size="3x" />
            </div>
            <h4>Relacion de Folios</h4>
            <p>Seleccione un tipo de fecha y una fecha para generar la relacion</p>
            <div class="info-chips">
              <span class="info-chip"><font-awesome-icon icon="calendar" /> Fecha Folio</span>
              <span class="info-chip"><font-awesome-icon icon="plus-circle" /> Fecha Alta</span>
              <span class="info-chip"><font-awesome-icon icon="minus-circle" /> Fecha Baja</span>
            </div>
          </div>

          <!-- Paginacion -->
          <div class="pagination-footer" v-if="rows.length > 0">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * pageSize) + 1 }} a {{ Math.min(currentPage * pageSize, rows.length) }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="currentPage = 1" :disabled="currentPage === 1">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Pagina {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage = totalPages" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label>Por pagina:</label>
              <select class="municipal-form-control" v-model.number="pageSize" @change="currentPage = 1">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Informacion -->
      <div class="form-section">
        <div class="section-header section-header-help">
          <div class="section-icon"><font-awesome-icon icon="info-circle" /></div>
          <div class="section-title-group">
            <h3>Tipos de Fecha</h3>
            <span class="section-subtitle">Descripcion de las opciones disponibles</span>
          </div>
        </div>
        <div class="section-body">
          <div class="info-list">
            <div class="info-item">
              <font-awesome-icon icon="file-alt" class="info-icon text-primary" />
              <div class="info-content">
                <strong>Fecha Folio:</strong> Fecha de emision del folio de infraccion
              </div>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="plus-circle" class="info-icon text-success" />
              <div class="info-content">
                <strong>Fecha Alta:</strong> Fecha de registro en el sistema
              </div>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="dollar-sign" class="info-icon text-warning" />
              <div class="info-content">
                <strong>Fecha Baja (Pago):</strong> Fecha de pago del folio
              </div>
            </div>
            <div class="info-item">
              <font-awesome-icon icon="times-circle" class="info-icon text-danger" />
              <div class="info-content">
                <strong>Fecha Baja (Cancelacion):</strong> Fecha de cancelacion del folio
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - RelacionFoliosPublicos">
      <h3>Relacion de Folios</h3>
      <p>Este modulo permite consultar folios por diferentes tipos de fecha.</p>
      <h4>Instrucciones:</h4>
      <ol>
        <li>Seleccione el tipo de fecha a consultar</li>
        <li>Ingrese la fecha deseada</li>
        <li>Presione el boton "Ejecutar Consulta"</li>
        <li>Los resultados se mostraran en la tabla</li>
      </ol>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'RelacionFoliosPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const opcion = ref(1)
const fecha = ref(new Date().toISOString().substring(0, 10))
const rows = ref([])

// Paginacion
const currentPage = ref(1)
const pageSize = ref(25)

const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value) || 1)

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return rows.value.slice(start, end)
})

function formatDate(d) {
  if (!d) return '—'
  const dt = new Date(d)
  return dt.toLocaleDateString('es-MX')
}

function formatNumber(n) {
  if (!n && n !== 0) return '0.00'
  return Number(n).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

function getEstadoClass(estado) {
  if (!estado) return ''
  const e = estado.toLowerCase()
  if (e.includes('pago') || e.includes('pagado')) return 'estado-success'
  if (e.includes('cancel')) return 'estado-danger'
  if (e.includes('pend')) return 'estado-warning'
  return 'estado-info'
}

async function consultar() {
  if (!fecha.value) {
    showToast('warning', 'Seleccione una fecha')
    return
  }

  showLoading('Consultando...', 'Generando relacion de folios')
  rows.value = []
  currentPage.value = 1

  try {
    const params = [
      { nombre: 'opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'fecha', valor: fecha.value, tipo: 'string' }
    ]
    const resp = await execute('sQRp_relacion_folios_report', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length > 0) {
      showToast('success', `Se encontraron ${rows.value.length} registro(s)`)
    } else {
      showToast('info', 'No se encontraron folios para la fecha especificada')
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function exportarExcel() {
  showToast('info', 'Funcion de exportacion en desarrollo')
}

// Documentacion y Ayuda
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

.section-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.section-header-help {
  background: linear-gradient(135deg, #6c757d 0%, #495057 100%);
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

.section-title-group {
  flex: 1;
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

.btn-section-action {
  background: rgba(255,255,255,0.2);
  border: 1px solid rgba(255,255,255,0.3);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-section-action:hover {
  background: rgba(255,255,255,0.3);
}

.section-body {
  padding: 1.5rem;
}

/* Filter grid */
.filter-grid {
  display: grid;
  grid-template-columns: 1fr 1fr auto;
  gap: 1.5rem;
  align-items: end;
}

@media (max-width: 768px) {
  .filter-grid {
    grid-template-columns: 1fr;
  }
}

.form-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
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
  padding-left: 38px;
}

.btn-block {
  width: 100%;
}

/* Table styles */
.th-icon {
  margin-right: 0.5rem;
  opacity: 0.7;
}

.badge-year {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-weight: 600;
  font-size: 0.85rem;
}

.folio-code {
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
  color: #495057;
}

.placa-badge {
  background: #fff3cd;
  color: #856404;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
  font-weight: 600;
}

.estado-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.estado-success {
  background: #d4edda;
  color: #155724;
}

.estado-danger {
  background: #f8d7da;
  color: #721c24;
}

.estado-warning {
  background: #fff3cd;
  color: #856404;
}

.estado-info {
  background: #d1ecf1;
  color: #0c5460;
}

/* Empty state */
.empty-state-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  color: #6c757d;
}

.empty-icon-container {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.empty-state-panel h4 {
  margin: 0 0 0.5rem;
  color: #495057;
}

.empty-state-panel p {
  margin: 0 0 1.5rem;
}

.info-chips {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  justify-content: center;
}

.info-chip {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  color: #495057;
}

.info-chip svg {
  margin-right: 0.5rem;
}

/* Pagination */
.pagination-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
  padding-top: 1rem;
  margin-top: 1rem;
  border-top: 1px solid #e9ecef;
}

.pagination-info {
  color: #6c757d;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-current {
  padding: 0 1rem;
  font-weight: 500;
}

.pagination-size {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-size label {
  color: #6c757d;
  font-size: 0.9rem;
}

.pagination-size select {
  width: auto;
  padding: 0.25rem 0.5rem;
}

/* Info list */
.info-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
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

.info-content {
  flex: 1;
}

.text-primary { color: #667eea; }
.text-success { color: #28a745; }
.text-warning { color: #ffc107; }
.text-danger { color: #dc3545; }
.text-end { text-align: right; }
</style>
