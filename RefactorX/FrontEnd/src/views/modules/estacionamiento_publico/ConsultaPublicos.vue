<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="search" /></div>
      <div class="module-view-info">
        <h1>Consulta de Estacionamientos Públicos</h1>
        <p>Listado, filtros y detalles</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="loadData" :disabled="loading">
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Sección de Búsqueda -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Filtros de Búsqueda</h3>
            <span class="section-subtitle">Criterios para consultar estacionamientos</span>
          </div>
        </div>
        <div class="section-body">
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label">Categoría</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="tag" /></span>
                <input type="text" class="municipal-form-control" v-model="filters.categoria" placeholder="Ej. PB, PC" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Nombre</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="building" /></span>
                <input type="text" class="municipal-form-control" v-model="filters.nombre" placeholder="Nombre del estacionamiento" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Sector</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="map-marker-alt" /></span>
                <input type="text" class="municipal-form-control" v-model="filters.sector" placeholder="J/H/L/R" />
              </div>
            </div>
            <div class="form-field form-field-actions">
              <label class="municipal-form-label invisible">.</label>
              <div class="button-group">
                <button class="btn-municipal-primary" @click="search" :disabled="loading">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
                <button class="btn-municipal-secondary" @click="clearFilters" :disabled="loading">
                  <font-awesome-icon icon="times" /> Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sección de Resultados -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="list" /></div>
          <div class="section-title-group">
            <h3>Resultados de Búsqueda</h3>
            <span class="section-subtitle">
              <span v-if="totalRecords > 0" class="badge-purple">{{ totalRecords }} registros encontrados</span>
              <span v-else>Sin resultados</span>
            </span>
          </div>
          <div class="section-actions" v-if="loading">
            <div class="spinner-border spinner-border-sm" role="status"></div>
          </div>
        </div>
        <div class="section-body" v-if="!loading || items.length > 0">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No.Esta</th>
                  <th>Cajones</th>
                  <th>Categoría</th>
                  <th>Nombre</th>
                  <th>Calle</th>
                  <th>No.Ext</th>
                  <th>Sector</th>
                  <th>Zona</th>
                  <th>Licencia</th>
                  <th>Teléfono</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in items" :key="item.id" class="row-hover" :class="{ 'row-selected': selected?.id === item.id }" @click="selectRow(item)">
                  <td><strong class="text-primary">{{ item.numesta }}</strong></td>
                  <td class="text-center">{{ item.cupo }}</td>
                  <td><span class="badge-category">{{ item.categoria }}</span></td>
                  <td><strong>{{ item.nombre }}</strong></td>
                  <td>{{ item.calle }}</td>
                  <td class="text-center">{{ item.numext }}</td>
                  <td>{{ item.nomsector || item.sector }}</td>
                  <td class="text-center">{{ item.zona }}-{{ item.subzona }}</td>
                  <td><code class="license-code">{{ item.numlicencia }}</code></td>
                  <td>{{ item.telefono }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-info btn-sm" @click.stop="openDetails(item)" title="Ver detalles">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
                <tr v-if="items.length === 0 && !loading">
                  <td colspan="11" class="empty-state">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>No se encontraron estacionamientos con los criterios especificados</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-footer" v-if="totalRecords > 0">
            <div class="pagination-info">
              Mostrando <strong>{{ startIndex }}</strong> a <strong>{{ endIndex }}</strong> de <strong>{{ totalRecords }}</strong> registros
            </div>
            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model.number="itemsPerPage" @change="changePageSize" class="municipal-form-control">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                </select>
              </div>
              <div class="pagination-nav">
                <button class="pagination-button" @click="goToPage(1)" :disabled="currentPage === 1" title="Primera página">
                  <font-awesome-icon icon="angles-left" />
                </button>
                <button class="pagination-button" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" title="Anterior">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
                <button class="pagination-button" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" title="Siguiente">
                  <font-awesome-icon icon="chevron-right" />
                </button>
                <button class="pagination-button" @click="goToPage(totalPages)" :disabled="currentPage === totalPages" title="Última página">
                  <font-awesome-icon icon="angles-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Detalles -->
    <Modal :show="showDetails" title="Detalles del Estacionamiento" size="xl" @close="showDetails = false" :showDefaultFooter="false">
      <div v-if="selected" class="details-container">
        <!-- Tabs de navegación -->
        <div class="detail-tabs">
          <button class="detail-tab" :class="{ active: detailTab === 'info' }" @click="detailTab = 'info'">
            <font-awesome-icon icon="info-circle" /> Información
          </button>
          <button class="detail-tab" :class="{ active: detailTab === 'adeudos' }" @click="detailTab = 'adeudos'; loadAdeudos()">
            <font-awesome-icon icon="file-invoice-dollar" /> Adeudos
          </button>
          <button class="detail-tab" :class="{ active: detailTab === 'multas' }" @click="detailTab = 'multas'; loadMultas()">
            <font-awesome-icon icon="gavel" /> Multas
          </button>
          <button class="detail-tab" :class="{ active: detailTab === 'lic' }" @click="detailTab = 'lic'">
            <font-awesome-icon icon="id-card" /> Licencia
          </button>
        </div>

        <!-- Tab: Información -->
        <div v-show="detailTab === 'info'" class="detail-panel">
          <div class="info-grid">
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="building" /> Datos Generales</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">Nombre:</span><span class="info-value">{{ selected.nombre }}</span></div>
                <div class="info-row"><span class="info-label">Categoría:</span><span class="info-value"><span class="badge-category">{{ selected.categoria }}</span></span></div>
                <div class="info-row"><span class="info-label">No. Estacionamiento:</span><span class="info-value text-primary fw-bold">{{ selected.numesta }}</span></div>
                <div class="info-row"><span class="info-label">Cajones:</span><span class="info-value">{{ selected.cupo }}</span></div>
              </div>
            </div>
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="map-marker-alt" /> Ubicación</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">Dirección:</span><span class="info-value">{{ selected.calle }} {{ selected.numext }}</span></div>
                <div class="info-row"><span class="info-label">Sector:</span><span class="info-value">{{ selected.nomsector || selected.sector }}</span></div>
                <div class="info-row"><span class="info-label">Zona:</span><span class="info-value">{{ selected.zona }}-{{ selected.subzona }}</span></div>
              </div>
            </div>
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="id-card" /> Licencia</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">No. Licencia:</span><span class="info-value"><code class="license-code">{{ selected.numlicencia }}</code></span></div>
                <div class="info-row"><span class="info-label">Teléfono:</span><span class="info-value">{{ selected.telefono || '—' }}</span></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab: Adeudos -->
        <div v-show="detailTab === 'adeudos'" class="detail-panel">
          <div v-if="loadingAdeudos" class="loading-indicator">
            <div class="spinner-border" role="status"></div>
            <span>Cargando adeudos...</span>
          </div>
          <div v-else>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Concepto</th>
                    <th class="text-center">Año</th>
                    <th class="text-center">Mes</th>
                    <th class="text-end">Adeudo</th>
                    <th class="text-end">Recargos</th>
                    <th class="text-end">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="a in adeudos" :key="`${a.concepto}-${a.axo}-${a.mes}`">
                    <td>{{ a.concepto }}</td>
                    <td class="text-center">{{ a.axo }}</td>
                    <td class="text-center">{{ a.mes }}</td>
                    <td class="text-end">{{ formatMoney(a.adeudo) }}</td>
                    <td class="text-end">{{ formatMoney(a.recargos) }}</td>
                    <td class="text-end fw-bold">{{ formatMoney(Number(a.adeudo || 0) + Number(a.recargos || 0)) }}</td>
                  </tr>
                  <tr v-if="adeudos.length === 0">
                    <td colspan="6" class="empty-state">
                      <font-awesome-icon icon="check-circle" class="text-success" size="2x" />
                      <p>Sin adeudos pendientes</p>
                    </td>
                  </tr>
                </tbody>
                <tfoot v-if="adeudos.length > 0" class="table-footer">
                  <tr class="totals-row">
                    <td colspan="3" class="text-end fw-bold">TOTALES:</td>
                    <td class="text-end fw-bold">{{ formatMoney(totalAdeudo) }}</td>
                    <td class="text-end fw-bold">{{ formatMoney(totalRecargos) }}</td>
                    <td class="text-end fw-bold text-danger total-amount">{{ formatMoney(totalAdeudo + totalRecargos) }}</td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </div>

        <!-- Tab: Multas -->
        <div v-show="detailTab === 'multas'" class="detail-panel">
          <div v-if="loadingFines" class="loading-indicator">
            <div class="spinner-border" role="status"></div>
            <span>Cargando multas...</span>
          </div>
          <div v-else>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>No. Acta</th>
                    <th>Fecha</th>
                    <th>Giro</th>
                    <th class="text-end">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="m in multas" :key="m.id_multa">
                    <td><code>{{ m.num_acta }}</code></td>
                    <td>{{ formatDate(m.fecha_acta) }}</td>
                    <td>{{ m.giro }}</td>
                    <td class="text-end fw-bold">{{ formatMoney(m.total) }}</td>
                  </tr>
                  <tr v-if="multas.length === 0">
                    <td colspan="4" class="empty-state">
                      <font-awesome-icon icon="check-circle" class="text-success" size="2x" />
                      <p>Sin multas registradas</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Tab: Licencia General -->
        <div v-show="detailTab === 'lic'" class="detail-panel">
          <div class="license-search">
            <div class="form-field">
              <label class="municipal-form-label">Recaudadora</label>
              <div class="input-group">
                <input type="number" class="municipal-form-control" v-model.number="licReca" style="max-width: 120px;" />
                <button class="btn-municipal-primary" @click="loadLicGrales" :disabled="loadingLicGrales">
                  <font-awesome-icon :icon="loadingLicGrales ? 'spinner' : 'search'" :spin="loadingLicGrales" /> Consultar
                </button>
              </div>
            </div>
          </div>
          <div v-if="loadingLicGrales" class="loading-indicator">
            <div class="spinner-border" role="status"></div>
            <span>Consultando licencia...</span>
          </div>
          <div v-else-if="licGrales" class="info-grid">
            <div class="info-card info-card-full">
              <div class="info-card-header"><font-awesome-icon icon="file-alt" /> Datos de Licencia General</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">Propietario:</span><span class="info-value">{{ licGrales.propietario || '—' }}</span></div>
                <div class="info-row"><span class="info-label">Giro:</span><span class="info-value">{{ licGrales.desc_giro || '—' }}</span></div>
                <div class="info-row"><span class="info-label">Ubicación:</span><span class="info-value">{{ licGrales.ubicacion || '—' }}</span></div>
                <div class="info-row"><span class="info-label">RFC:</span><span class="info-value"><code>{{ licGrales.rfc || '—' }}</code></span></div>
                <div class="info-row"><span class="info-label">Vigente:</span><span class="info-value">
                  <span :class="licGrales.vigente === 'SI' ? 'badge-success' : 'badge-danger'">{{ licGrales.vigente || '—' }}</span>
                </span></div>
              </div>
            </div>
          </div>
          <div v-else class="empty-state-panel">
            <font-awesome-icon icon="file-alt" size="2x" class="text-muted" />
            <p>Ingrese la recaudadora y presione Consultar para ver los datos de licencia</p>
          </div>
        </div>
      </div>
    </Modal>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - ConsultaPublicos">
      <h3>Consulta Públicos</h3>
      <p>Documentación del módulo Estacionamiento Público.</p>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'ConsultaPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { ref, computed, onMounted, watch } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const items = ref([])
const totalRecords = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const showDetails = ref(false)
const selected = ref(null)
const multas = ref([])
const loadingFines = ref(false)
const adeudos = ref([])
const loadingAdeudos = ref(false)
const licGrales = ref(null)
const loadingLicGrales = ref(false)
const licReca = ref(4)
const detailTab = ref('info')

const filters = ref({ categoria: '', nombre: '', sector: '' })

const startIndex = computed(() => ((currentPage.value - 1) * itemsPerPage.value) + 1)
const endIndex = computed(() => Math.min(currentPage.value * itemsPerPage.value, totalRecords.value))
const totalPages = computed(() => Math.max(1, Math.ceil(totalRecords.value / itemsPerPage.value)))

const totalAdeudo = computed(() => adeudos.value.reduce((sum, a) => sum + Number(a.adeudo || 0), 0))
const totalRecargos = computed(() => adeudos.value.reduce((sum, a) => sum + Number(a.recargos || 0), 0))

async function loadData() {
  showLoading('Cargando...', 'Consultando estacionamientos')
  try {
    const parametros = [
      { nombre: 'categoria', valor: filters.value.categoria, tipo: 'string' },
      { nombre: 'nombre', valor: filters.value.nombre, tipo: 'string' },
      { nombre: 'sector', valor: filters.value.sector, tipo: 'string' }
    ]
    const pagination = { limit: itemsPerPage.value, offset: (currentPage.value - 1) * itemsPerPage.value }
    const resp = await execute('sp_get_public_parking_list', BASE_DB, parametros, '', pagination, SCHEMA)
    const result = resp?.result || resp?.data?.result || []
    items.value = result
    totalRecords.value = resp?.count ?? resp?.data?.count ?? result.length
    if (result.length > 0) {
      showToast('success', `Se encontraron ${totalRecords.value} estacionamientos`)
    } else {
      showToast('info', 'No se encontraron registros con los criterios especificados')
    }
  } catch (e) {
    handleApiError(e)
    items.value = []
    totalRecords.value = 0
  } finally {
    hideLoading()
  }
}

function search() {
  currentPage.value = 1
  loadData()
}

function clearFilters() {
  filters.value = { categoria: '', nombre: '', sector: '' }
  search()
}

function changePageSize() {
  currentPage.value = 1
  loadData()
}

function goToPage(p) {
  if (p < 1 || p > totalPages.value) return
  currentPage.value = p
  loadData()
}

function selectRow(item) {
  selected.value = item
}

async function loadAdeudos() {
  if (!selected.value) return
  loadingAdeudos.value = true
  try {
    const paramsAde = [
      { nombre: 'p_opc', valor: 3, tipo: 'integer' },
      { nombre: 'p_pubid', valor: selected.value.id, tipo: 'integer' },
      { nombre: 'p_axo', valor: 0, tipo: 'integer' },
      { nombre: 'p_mes', valor: 0, tipo: 'integer' }
    ]
    const respA = await execute('cajero_pub_detalle', BASE_DB, paramsAde, '', null, SCHEMA)
    adeudos.value = respA?.result || respA?.data?.result || []
  } catch (e) {
    handleApiError(e)
    adeudos.value = []
  } finally {
    loadingAdeudos.value = false
  }
}

async function loadMultas() {
  if (!selected.value) return
  loadingFines.value = true
  try {
    const parametros = [{ nombre: 'p_numlicencia', valor: selected.value.numlicencia, tipo: 'integer' }]
    const resp = await execute('sp_get_public_parking_fines', BASE_DB, parametros, '', null, SCHEMA)
    multas.value = resp?.result || resp?.data?.result || []
  } catch (e) {
    handleApiError(e)
    multas.value = []
  } finally {
    loadingFines.value = false
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

async function openDetails(item) {
  selected.value = item
  showDetails.value = true
  detailTab.value = 'info'
  multas.value = []
  adeudos.value = []
  licGrales.value = null
}

async function loadLicGrales() {
  if (!selected.value) return
  loadingLicGrales.value = true
  try {
    const params = [
      { nombre: 'NumLicencia', valor: selected.value.numlicencia, tipo: 'integer' },
      { nombre: 'cero', valor: 0, tipo: 'integer' },
      { nombre: 'reca', valor: licReca.value, tipo: 'integer' }
    ]
    const resp = await execute('spget_lic_grales', BASE_DB, params, '', null, SCHEMA)
    const rows = resp?.result || resp?.data?.result || []
    licGrales.value = rows[0] || null
    if (licGrales.value) {
      showToast('success', 'Licencia encontrada')
    } else {
      showToast('warning', 'No se encontró información de licencia')
    }
  } catch (e) {
    handleApiError(e)
    licGrales.value = null
  } finally {
    loadingLicGrales.value = false
  }
}

onMounted(loadData)
watch([itemsPerPage], () => { /* handled by changePageSize */ })

// Documentación y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

<style scoped>
/* Estilos de secciones */
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

/* Table styling */
.row-selected {
  background-color: #e3f2fd !important;
  border-left: 3px solid #2196f3;
}

.badge-category {
  background: #667eea;
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
}

.license-code {
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
  color: #495057;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #6c757d;
}

.empty-state .empty-icon {
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

/* Modal styles */
.details-container {
  min-height: 400px;
}

.detail-tabs {
  display: flex;
  gap: 0.5rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #e9ecef;
  margin-bottom: 1.5rem;
}

.detail-tab {
  padding: 0.75rem 1.25rem;
  border: none;
  background: #f8f9fa;
  border-radius: 8px 8px 0 0;
  cursor: pointer;
  font-weight: 500;
  color: #6c757d;
  transition: all 0.2s;
}

.detail-tab:hover {
  background: #e9ecef;
}

.detail-tab.active {
  background: #667eea;
  color: white;
}

.detail-panel {
  min-height: 300px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.info-card {
  background: #f8f9fa;
  border-radius: 8px;
  overflow: hidden;
}

.info-card-full {
  grid-column: 1 / -1;
}

.info-card-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.75rem 1rem;
  font-weight: 600;
}

.info-card-body {
  padding: 1rem;
}

.info-row {
  display: flex;
  padding: 0.5rem 0;
  border-bottom: 1px solid #e9ecef;
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  flex: 0 0 140px;
  font-weight: 500;
  color: #6c757d;
}

.info-value {
  flex: 1;
  color: #212529;
}

.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 3rem;
  color: #6c757d;
}

.totals-row {
  background: #fff3cd;
}

.total-amount {
  font-size: 1.1rem;
}

.license-search {
  margin-bottom: 1.5rem;
}

.license-search .input-group {
  display: flex;
  gap: 0.5rem;
}

.empty-state-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #6c757d;
  text-align: center;
}

.badge-success {
  background: #28a745;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-weight: 600;
}

.badge-danger {
  background: #dc3545;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 4px;
  font-weight: 600;
}
</style>
