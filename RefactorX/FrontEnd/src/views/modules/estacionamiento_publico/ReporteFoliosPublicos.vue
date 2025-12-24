<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-lines" /></div>
      <div class="module-view-info">
        <h1>Reporte de Folios</h1>
        <p>Folios hechos por inspector en fecha</p>
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
      <!-- Seccion de Filtros -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Parametros de Consulta</h3>
            <span class="section-subtitle">Seleccione la fecha para consultar folios por inspector</span>
          </div>
        </div>
        <div class="section-body">
          <div class="filter-row">
            <div class="form-field">
              <label class="municipal-form-label">Fecha</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar-day" /></span>
                <input type="date" class="municipal-form-control with-icon" v-model="fecha" @keyup.enter="ejecutar" />
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
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Resultados</h3>
            <span class="section-subtitle">
              <span v-if="rows.length > 0">{{ rows.length }} inspector(es) encontrado(s)</span>
              <span v-else>Esperando consulta</span>
            </span>
          </div>
          <div class="section-actions" v-if="rows.length > 0">
            <span class="total-badge">
              <font-awesome-icon icon="clipboard-list" /> Total Folios: {{ totalFolios }}
            </span>
          </div>
        </div>
        <div class="section-body">
          <!-- Tabla de resultados -->
          <div v-if="rows.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th><font-awesome-icon icon="user-tie" class="th-icon" /> Inspector</th>
                  <th class="text-center"><font-awesome-icon icon="file-alt" class="th-icon" /> Folios</th>
                  <th class="text-center"><font-awesome-icon icon="percent" class="th-icon" /> Porcentaje</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.inspector">
                  <td>
                    <div class="inspector-cell">
                      <div class="inspector-avatar">
                        <font-awesome-icon icon="user" />
                      </div>
                      <span>{{ r.inspector || '—' }}</span>
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
              <font-awesome-icon icon="file-lines" size="3x" class="empty-state-icon" />
            </div>
            <h4>Reporte de Folios por Inspector</h4>
            <p>Seleccione una fecha para ver los folios generados por cada inspector</p>
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
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ReporteFoliosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Reporte de Folios'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const fecha = ref(new Date().toISOString().substring(0, 10))
const rows = ref([])

// Paginacion
const currentPage = ref(1)
const pageSize = ref(10)

const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value) || 1)

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return rows.value.slice(start, end)
})

const totalFolios = computed(() => {
  return rows.value.reduce((sum, r) => sum + (Number(r.folios) || 0), 0)
})

function getPorcentaje(folios) {
  if (!totalFolios.value) return 0
  return (Number(folios) / totalFolios.value) * 100
}

async function ejecutar() {
  if (!fecha.value) {
    showToast('warning', 'Seleccione una fecha')
    return
  }

  showLoading('Consultando...', 'Obteniendo folios por inspector')
  rows.value = []
  currentPage.value = 1

  try {
    const params = [{ nombre: 'p_fecha', valor: fecha.value, tipo: 'string' }]
    const resp = await execute('sp_get_folios_by_inspector', BASE_DB, params, '', null, SCHEMA)
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

/* Filter row */
.filter-row {
  display: flex;
  gap: 1.5rem;
  align-items: end;
  max-width: 500px;
}

.form-field {
  flex: 1;
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
