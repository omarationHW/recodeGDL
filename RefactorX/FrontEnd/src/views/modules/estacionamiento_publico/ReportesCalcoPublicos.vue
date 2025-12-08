<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="id-badge" /></div>
      <div class="module-view-info">
        <h1>Reportes de Calcomanias</h1>
        <p>Folios capturados por fecha e inspector</p>
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
            <h3>Parametros del Reporte</h3>
            <span class="section-subtitle">Seleccione fecha e inspector para consultar</span>
          </div>
        </div>
        <div class="section-body">
          <div class="form-grid cols-3">
            <div class="form-field">
              <label class="municipal-form-label">Fecha <span class="required">*</span></label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar" /></span>
                <input type="date" class="municipal-form-control with-icon" v-model="fecha" @keyup.enter="ejecutar" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Inspector</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="user-tie" /></span>
                <select class="municipal-form-control with-icon" v-model.number="insSel">
                  <option :value="0">Todos los inspectores</option>
                  <option v-for="i in inspectores" :key="i.id_esta_persona" :value="i.id_esta_persona">{{ i.inspector }}</option>
                </select>
              </div>
            </div>
            <div class="form-field form-field-action">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary" :disabled="loading" @click="ejecutar">
                <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" /> Ejecutar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Resultados -->
      <div class="form-section">
        <div class="section-header section-header-success">
          <div class="section-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Resultados del Reporte</h3>
            <span class="section-subtitle">
              <span v-if="rowsFiltradas.length > 0">{{ rowsFiltradas.length }} inspector(es) encontrado(s)</span>
              <span v-else>Esperando consulta</span>
            </span>
          </div>
          <div class="section-actions" v-if="rowsFiltradas.length > 0">
            <span class="total-badge">
              <font-awesome-icon icon="clipboard-list" /> Total Folios: {{ totalFolios }}
            </span>
          </div>
        </div>
        <div class="section-body">
          <!-- Tabla de resultados -->
          <div v-if="rowsFiltradas.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th><font-awesome-icon icon="user-tie" class="th-icon" /> Inspector</th>
                  <th class="text-center"><font-awesome-icon icon="file-alt" class="th-icon" /> Folios</th>
                  <th class="text-center"><font-awesome-icon icon="percent" class="th-icon" /> Porcentaje</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.vigilante">
                  <td>
                    <div class="inspector-cell">
                      <div class="inspector-avatar">
                        <font-awesome-icon icon="user" />
                      </div>
                      <span>{{ r.inspector || 'Sin asignar' }}</span>
                    </div>
                  </td>
                  <td class="text-center">
                    <span class="folios-badge">{{ r.folios || 0 }}</span>
                  </td>
                  <td class="text-center">
                    <div class="progress-bar-container">
                      <div class="progress-bar" :style="{ width: getPorcentaje(r.folios) + '%' }"></div>
                      <span class="progress-text">{{ getPorcentaje(r.folios).toFixed(1) }}%</span>
                    </div>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="totals-row">
                  <td><strong>TOTAL</strong></td>
                  <td class="text-center"><strong>{{ totalFolios }}</strong></td>
                  <td class="text-center"><strong>100%</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Estado vacio -->
          <div v-else class="empty-state-panel">
            <div class="empty-icon-container">
              <font-awesome-icon icon="id-badge" size="3x" />
            </div>
            <h4>Reporte de Calcomanias</h4>
            <p>Seleccione una fecha y presione "Ejecutar" para ver los folios por inspector</p>
          </div>

          <!-- Paginacion -->
          <div class="pagination-footer" v-if="rowsFiltradas.length > itemsPerPage">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, rowsFiltradas.length) }} de {{ rowsFiltradas.length }} registros
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
              <select class="municipal-form-control" v-model.number="itemsPerPage" @change="currentPage = 1">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - ReportesCalcoPublicos">
      <h3>Reporte de Calcomanias</h3>
      <p>Este modulo genera reportes de folios capturados por cada inspector en una fecha especifica.</p>
      <h4>Instrucciones:</h4>
      <ol>
        <li>Seleccione la fecha a consultar</li>
        <li>Opcionalmente filtre por un inspector especifico</li>
        <li>Presione el boton "Ejecutar"</li>
        <li>Se mostrara la lista de inspectores con sus folios y porcentajes</li>
      </ol>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'ReportesCalcoPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const fecha = ref(new Date().toISOString().substring(0, 10))
const inspectores = ref([])
const insSel = ref(0)
const rows = ref([])

// Paginacion
const currentPage = ref(1)
const itemsPerPage = ref(10)

const rowsFiltradas = computed(() => insSel.value ? rows.value.filter(r => r.vigilante === insSel.value) : rows.value)
const totalPages = computed(() => Math.ceil(rowsFiltradas.value.length / itemsPerPage.value) || 1)

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rowsFiltradas.value.slice(start, end)
})

const totalFolios = computed(() => {
  return rowsFiltradas.value.reduce((sum, r) => sum + (Number(r.folios) || 0), 0)
})

function getPorcentaje(folios) {
  if (!totalFolios.value) return 0
  return (Number(folios) / totalFolios.value) * 100
}

async function cargarInspectores() {
  try {
    const resp = await execute('sp_catalog_inspectors', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    inspectores.value = Array.isArray(data) ? data : []
  } catch (e) {
    handleApiError(e)
  }
}

async function ejecutar() {
  if (!fecha.value) {
    showToast('warning', 'Seleccione una fecha para consultar')
    return
  }

  showLoading('Consultando...', 'Obteniendo reporte de calcomanias')
  rows.value = []
  currentPage.value = 1

  try {
    const params = [{ nombre: 'fechora', valor: fecha.value, tipo: 'string' }]
    const resp = await execute('sp_report_folios', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length > 0) {
      showToast('success', `Se encontraron ${rows.value.length} inspector(es)`)
    } else {
      showToast('info', 'No se encontraron folios para la fecha especificada')
    }
  } catch (e) {
    handleApiError(e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

onMounted(() => { cargarInspectores() })

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

.total-badge {
  background: rgba(255,255,255,0.2);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
}

.section-body {
  padding: 1.5rem;
}

/* Form Grid */
.form-grid {
  display: grid;
  gap: 1.5rem;
}

.form-grid.cols-3 {
  grid-template-columns: 1fr 1.5fr auto;
}

@media (max-width: 992px) {
  .form-grid.cols-3 { grid-template-columns: 1fr 1fr; }
}

@media (max-width: 576px) {
  .form-grid.cols-3 { grid-template-columns: 1fr; }
}

.form-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.form-field .required {
  color: #dc3545;
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

.form-field-action {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
}

/* Table styles */
.th-icon {
  margin-right: 0.5rem;
  opacity: 0.7;
}

.inspector-cell {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.inspector-avatar {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.folios-badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.35rem 1rem;
  border-radius: 20px;
  font-weight: 600;
  font-size: 1rem;
}

.progress-bar-container {
  position: relative;
  height: 24px;
  background: #e9ecef;
  border-radius: 12px;
  overflow: hidden;
  min-width: 120px;
}

.progress-bar {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  transition: width 0.3s ease;
}

.progress-text {
  position: relative;
  z-index: 1;
  line-height: 24px;
  font-weight: 500;
  font-size: 0.85rem;
  color: #495057;
}

.totals-row {
  background: #f8f9fa;
}

.totals-row td {
  border-top: 2px solid #dee2e6;
  font-size: 1.05rem;
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
  margin: 0;
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

.text-center { text-align: center; }
</style>
