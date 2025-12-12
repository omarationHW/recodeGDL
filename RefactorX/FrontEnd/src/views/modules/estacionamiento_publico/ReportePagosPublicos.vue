<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Reporte de Pagos — Estacionamientos</h1>
        <p>Folios pagados y adeudos por inspector</p>
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
      <!-- Sección de Filtros -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Parámetros del Reporte</h3>
            <span class="section-subtitle">Configure los filtros para generar el reporte</span>
          </div>
        </div>
        <div class="section-body">
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label">Fecha</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar" /></span>
                <input type="date" class="municipal-form-control" v-model="fecha" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Recaudadora</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="building" /></span>
                <input type="number" class="municipal-form-control" v-model.number="reca" placeholder="9=Todas" />
              </div>
              <small class="field-hint">Ingrese 9 para todas las recaudadoras</small>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Tipo de Reporte</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="chart-bar" /></span>
                <select class="municipal-form-control" v-model="tipo">
                  <option value="pagados">Folios pagados</option>
                  <option value="adeudo_inspector">Adeudos por inspector</option>
                </select>
              </div>
            </div>
            <div class="form-field form-field-actions">
              <label class="municipal-form-label invisible">.</label>
              <button class="btn-municipal-primary" :disabled="loading" @click="ejecutar">
                <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" /> Ejecutar Reporte
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sección de Resultados -->
      <div class="form-section">
        <div class="section-header section-header-success">
          <div class="section-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Resultados del Reporte</h3>
            <span class="section-subtitle">
              <span v-if="rows.length > 0" class="badge-purple">{{ rows.length }} registros encontrados</span>
              <span v-else>Sin resultados</span>
            </span>
          </div>
          <div class="section-actions" v-if="loading">
            <div class="spinner-border spinner-border-sm" role="status"></div>
          </div>
        </div>
        <div class="section-body" v-if="!loading">
          <!-- Tabla de folios pagados -->
          <div v-if="tipo === 'pagados'" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Reca</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Año</th>
                  <th>Folio</th>
                  <th>Placa</th>
                  <th>Fecha</th>
                  <th>Estado</th>
                  <th>Infracción</th>
                  <th class="text-end">Tarifa</th>
                  <th>Movto</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.axo}-${r.folio}`" class="row-hover">
                  <td class="text-center">{{ r.reca }}</td>
                  <td class="text-center">{{ r.caja }}</td>
                  <td>{{ r.operacion }}</td>
                  <td class="text-center">{{ r.axo }}</td>
                  <td><strong class="text-primary">{{ r.folio }}</strong></td>
                  <td><code>{{ r.placa }}</code></td>
                  <td>{{ formatDate(r.fecha_folio) }}</td>
                  <td><span class="badge-estado" :class="getEstadoClass(r.estado)">{{ r.estado }}</span></td>
                  <td>{{ r.infraccion }}</td>
                  <td class="text-end fw-bold">{{ formatMoney(r.tarifa) }}</td>
                  <td class="text-center">{{ r.codigo_movto }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="11" class="empty-state">
                    <font-awesome-icon icon="file-invoice-dollar" size="2x" class="empty-icon" />
                    <p>No hay datos para mostrar. Configure los parámetros y ejecute el reporte.</p>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="rows.length > 0" class="table-footer">
                <tr class="totals-row">
                  <td colspan="9" class="text-end fw-bold">TOTAL:</td>
                  <td class="text-end fw-bold text-success">{{ formatMoney(totalTarifa) }}</td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Tabla de adeudos por inspector -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Inspector</th>
                  <th class="text-end">Folios</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.vigilante" class="row-hover">
                  <td><strong>{{ r.inspector }}</strong></td>
                  <td class="text-end"><span class="badge-purple">{{ r.folios }}</span></td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="2" class="empty-state">
                    <font-awesome-icon icon="user-tie" size="2x" class="empty-icon" />
                    <p>No hay adeudos por inspector para la fecha seleccionada.</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > itemsPerPage" class="pagination-footer">
            <div class="pagination-info">
              Mostrando <strong>{{ startIndex }}</strong> a <strong>{{ endIndex }}</strong> de <strong>{{ rows.length }}</strong> registros
            </div>
            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model.number="itemsPerPage" class="municipal-form-control">
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>
              <div class="pagination-nav">
                <button class="pagination-button" @click="changePage(1)" :disabled="currentPage === 1" title="Primera">
                  <font-awesome-icon icon="angles-left" />
                </button>
                <button class="pagination-button" @click="changePage(currentPage - 1)" :disabled="currentPage === 1" title="Anterior">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
                <button class="pagination-button" @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages" title="Siguiente">
                  <font-awesome-icon icon="chevron-right" />
                </button>
                <button class="pagination-button" @click="changePage(totalPages)" :disabled="currentPage === totalPages" title="Última">
                  <font-awesome-icon icon="angles-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - ReportePagosPublicos">
      <h3>Reporte de Pagos Públicos</h3>
      <p>Este módulo genera reportes de pagos de estacionamientos públicos.</p>
      <h4>Tipos de Reporte:</h4>
      <ul>
        <li><strong>Folios pagados:</strong> Lista detallada de folios pagados en la fecha</li>
        <li><strong>Adeudos por inspector:</strong> Resumen de adeudos agrupados por inspector</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'ReportePagosPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const fecha = ref(new Date().toISOString().substring(0, 10))
const reca = ref(9)
const tipo = ref('pagados')
const rows = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(50)
const totalPages = computed(() => Math.max(1, Math.ceil(rows.value.length / itemsPerPage.value)))
const startIndex = computed(() => ((currentPage.value - 1) * itemsPerPage.value) + 1)
const endIndex = computed(() => Math.min(currentPage.value * itemsPerPage.value, rows.value.length))
const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rows.value.slice(start, end)
})

// Total de tarifas
const totalTarifa = computed(() => rows.value.reduce((sum, r) => sum + Number(r.tarifa || 0), 0))

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function formatDate(d) {
  if (!d) return '—'
  const dt = new Date(d)
  return dt.toLocaleDateString('es-MX')
}

function formatMoney(n) {
  try {
    return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n || 0))
  } catch {
    return n
  }
}

function getEstadoClass(estado) {
  if (!estado) return ''
  const e = estado.toString().toLowerCase()
  if (e.includes('pagado') || e.includes('activo')) return 'badge-success'
  if (e.includes('pendiente') || e.includes('adeudo')) return 'badge-warning'
  if (e.includes('cancel') || e.includes('baja')) return 'badge-danger'
  return 'badge-info'
}

async function ejecutar() {
  if (!fecha.value) {
    showToast('warning', 'Seleccione una fecha para generar el reporte')
    return
  }

  showLoading('Consultando...', 'Generando reporte de pagos')
  rows.value = []
  currentPage.value = 1
  try {
    let resp
    if (tipo.value === 'pagados') {
      const params = [
        { nombre: 'p_reca', valor: reca.value, tipo: 'integer' },
        { nombre: 'p_fechora', valor: fecha.value, tipo: 'string' }
      ]
      resp = await execute('report_folios_pagados', BASE_DB, params, '', null, SCHEMA)
    } else {
      const params = [{ nombre: 'p_fechora', valor: fecha.value, tipo: 'string' }]
      resp = await execute('report_folios_adeudo_por_inspector', BASE_DB, params, '', null, SCHEMA)
    }

    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length > 0) {
      showToast('success', `Reporte generado: ${rows.value.length} registro(s)`)
    } else {
      showToast('info', 'No se encontraron registros para la fecha especificada')
    }
  } catch (e) {
    handleApiError(e)
    rows.value = []
  } finally {
    hideLoading()
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

.form-field-actions {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}

/* Table */
.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #6c757d;
}

.empty-icon {
  margin-bottom: 1rem;
  opacity: 0.5;
}

.badge-estado {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.badge-success { background: #d4edda; color: #155724; }
.badge-warning { background: #fff3cd; color: #856404; }
.badge-danger { background: #f8d7da; color: #721c24; }
.badge-info { background: #d1ecf1; color: #0c5460; }

.totals-row {
  background: #e8f5e9;
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
</style>
