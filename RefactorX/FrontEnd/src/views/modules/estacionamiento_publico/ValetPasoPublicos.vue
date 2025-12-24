<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="car" /></div>
      <div class="module-view-info">
        <h1>Valet Paso</h1>
        <p>Procesamiento de archivos CSV de valet parking</p>
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
      <!-- Seccion de Carga de Archivo -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="file-upload" /></div>
          <div class="section-title-group">
            <h3>Cargar Archivo CSV</h3>
            <span class="section-subtitle">Seleccione o pegue el contenido del archivo</span>
          </div>
        </div>
        <div class="section-body">
          <div class="upload-options">
            <!-- Opcion 1: Cargar archivo -->
            <div class="upload-option">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-csv" /> Seleccionar archivo CSV
              </label>
              <div class="file-input-group">
                <input
                  type="file"
                  ref="fileInput"
                  class="municipal-form-control"
                  accept=".csv,.txt"
                  @change="cargarArchivo"
                />
                <button class="btn-municipal-secondary" @click="limpiarTodo" :disabled="!csv">
                  <font-awesome-icon icon="times" /> Limpiar
                </button>
              </div>
            </div>

            <!-- Separador -->
            <div class="upload-divider">
              <span>o</span>
            </div>

            <!-- Opcion 2: Pegar contenido -->
            <div class="upload-option">
              <label class="municipal-form-label">
                <font-awesome-icon icon="paste" /> Pegar contenido CSV
              </label>
              <textarea
                class="municipal-form-control csv-textarea"
                rows="6"
                v-model="csv"
                placeholder="Pegue aqui el contenido del archivo CSV...

Formato esperado:
folio,placa,fecha_entrada,fecha_salida,tarifa,importe
1001,ABC123,2025-01-01 08:00,2025-01-01 10:00,50.00,100.00"
              ></textarea>
            </div>
          </div>

          <!-- Info del archivo cargado -->
          <div v-if="archivoNombre" class="file-info-box">
            <font-awesome-icon icon="file-alt" class="file-icon" />
            <div class="file-details">
              <strong>{{ archivoNombre }}</strong>
              <span class="file-size">{{ lineasCount }} lineas detectadas</span>
            </div>
          </div>

          <!-- Formato esperado -->
          <div class="format-help">
            <h6><font-awesome-icon icon="info-circle" /> Formato del archivo CSV:</h6>
            <div class="format-grid">
              <span class="format-item"><code>Col 1</code> Folio</span>
              <span class="format-item"><code>Col 2</code> Placa</span>
              <span class="format-item"><code>Col 3</code> Fecha Entrada</span>
              <span class="format-item"><code>Col 4</code> Fecha Salida</span>
              <span class="format-item"><code>Col 5</code> Tarifa</span>
              <span class="format-item"><code>Col 6</code> Importe</span>
            </div>
            <p class="format-note">Separadores aceptados: coma (,) o punto y coma (;)</p>
          </div>

          <!-- Boton de procesar -->
          <div class="action-row">
            <button
              class="btn-municipal-success btn-lg"
              @click="procesarArchivo"
              :disabled="!csv || procesando"
            >
              <font-awesome-icon :icon="procesando ? 'spinner' : 'play'" :spin="procesando" />
              {{ procesando ? 'Procesando...' : 'Procesar Archivo' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Seccion de Resultado del Procesamiento -->
      <div class="form-section" v-if="resultado">
        <div class="section-header" :class="resultado.errores === 0 ? 'section-header-success' : 'section-header-warning'">
          <div class="section-icon"><font-awesome-icon icon="clipboard-check" /></div>
          <div class="section-title-group">
            <h3>Resultado del Procesamiento</h3>
            <span class="section-subtitle">{{ resultado.fecha }}</span>
          </div>
        </div>
        <div class="section-body">
          <div class="result-grid">
            <div class="result-card result-total">
              <font-awesome-icon icon="list" class="result-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultado.total }}</span>
                <span class="result-label">Total Lineas</span>
              </div>
            </div>
            <div class="result-card result-success">
              <font-awesome-icon icon="check-circle" class="result-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultado.insertados }}</span>
                <span class="result-label">Insertados</span>
              </div>
            </div>
            <div class="result-card result-error">
              <font-awesome-icon icon="times-circle" class="result-icon" />
              <div class="result-content">
                <span class="result-value">{{ resultado.errores }}</span>
                <span class="result-label">Errores</span>
              </div>
            </div>
          </div>

          <!-- Detalle de errores -->
          <div v-if="resultado.detalle" class="error-list">
            <h6><font-awesome-icon icon="exclamation-triangle" /> Detalle de errores:</h6>
            <div class="error-content">{{ resultado.detalle }}</div>
          </div>
        </div>
      </div>

      <!-- Seccion de Consulta de Registros -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="search" /></div>
          <div class="section-title-group">
            <h3>Consultar Registros Procesados</h3>
            <span class="section-subtitle">Buscar por fecha o placa</span>
          </div>
        </div>
        <div class="section-body">
          <div class="filter-row">
            <div class="filter-field">
              <label class="municipal-form-label">Fecha Desde</label>
              <input type="date" class="municipal-form-control" v-model="filtroDesde" />
            </div>
            <div class="filter-field">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input type="date" class="municipal-form-control" v-model="filtroHasta" />
            </div>
            <div class="filter-field">
              <label class="municipal-form-label">Placa</label>
              <input type="text" class="municipal-form-control" v-model="filtroPlaca" placeholder="Buscar..." />
            </div>
            <div class="filter-actions">
              <button class="btn-municipal-primary" @click="consultar" :disabled="loading">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiarFiltros">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>

          <!-- Tabla de resultados -->
          <div v-if="registros.length > 0" class="table-responsive mt-3">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Fecha Proceso</th>
                  <th>Folio</th>
                  <th>Placa</th>
                  <th>Entrada</th>
                  <th>Salida</th>
                  <th>Tarifa</th>
                  <th>Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedData" :key="r.id">
                  <td><code class="id-code">{{ r.id }}</code></td>
                  <td>{{ formatDate(r.fecha_proceso) }}</td>
                  <td><strong>{{ r.folio }}</strong></td>
                  <td>{{ r.placa }}</td>
                  <td>{{ formatDateTime(r.fecha_entrada) }}</td>
                  <td>{{ formatDateTime(r.fecha_salida) }}</td>
                  <td class="text-end">{{ formatMoney(r.tarifa) }}</td>
                  <td class="text-end"><strong>{{ formatMoney(r.importe) }}</strong></td>
                </tr>
              </tbody>
            </table>

            <!-- Paginacion -->
            <div class="pagination-container" v-if="totalPages > 1">
              <div class="pagination-info">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} - {{ Math.min(currentPage * itemsPerPage, registros.length) }} de {{ registros.length }}
              </div>
              <div class="pagination-controls">
                <button @click="changePage(1)" :disabled="currentPage === 1" class="btn-page">
                  <font-awesome-icon icon="angle-double-left" />
                </button>
                <button @click="changePage(currentPage - 1)" :disabled="currentPage === 1" class="btn-page">
                  <font-awesome-icon icon="angle-left" />
                </button>
                <span class="page-indicator">{{ currentPage }} / {{ totalPages }}</span>
                <button @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages" class="btn-page">
                  <font-awesome-icon icon="angle-right" />
                </button>
                <button @click="changePage(totalPages)" :disabled="currentPage === totalPages" class="btn-page">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>

          <div v-else-if="consultado" class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" class="empty-state-icon" />
            <p>No se encontraron registros</p>
          </div>
        </div>
      </div>

      <!-- Seccion de Resumen -->
      <div class="form-section">
        <div class="section-header section-header-purple">
          <div class="section-icon"><font-awesome-icon icon="chart-bar" /></div>
          <div class="section-title-group">
            <h3>Resumen por Fecha</h3>
            <span class="section-subtitle">Estadisticas de procesamiento</span>
          </div>
          <div class="section-actions">
            <button class="btn-municipal-secondary btn-sm" @click="cargarResumen" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'sync-alt'" :spin="loading" /> Actualizar
            </button>
          </div>
        </div>
        <div class="section-body">
          <div v-if="resumen.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th class="text-end">Registros</th>
                  <th class="text-end">Placas Unicas</th>
                  <th class="text-end">Total Importe</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in resumen" :key="r.fecha">
                  <td><strong>{{ formatDate(r.fecha) }}</strong></td>
                  <td class="text-end">{{ r.total_registros }}</td>
                  <td class="text-end">{{ r.placas_unicas }}</td>
                  <td class="text-end"><strong>{{ formatMoney(r.total_importe) }}</strong></td>
                  <td class="text-center">
                    <button class="btn-action btn-delete" @click="eliminarFecha(r.fecha)" title="Eliminar registros">
                      <font-awesome-icon icon="trash-alt" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="empty-state">
            <font-awesome-icon icon="chart-line" size="3x" class="empty-state-icon" />
            <p>No hay datos de resumen</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ValetPasoPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Valet Paso'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado - Carga de archivo
const fileInput = ref(null)
const csv = ref('')
const archivoNombre = ref('')
const procesando = ref(false)
const resultado = ref(null)

// Estado - Consulta
const filtroDesde = ref('')
const filtroHasta = ref('')
const filtroPlaca = ref('')
const registros = ref([])
const consultado = ref(false)
const resumen = ref([])

// Paginacion
const currentPage = ref(1)
const itemsPerPage = ref(10)

const lineasCount = computed(() => {
  if (!csv.value) return 0
  return csv.value.split('\n').filter(l => l.trim()).length
})

const totalPages = computed(() => Math.ceil(registros.value.length / itemsPerPage.value))

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return registros.value.slice(start, start + itemsPerPage.value)
})

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

// Carga de archivo
function cargarArchivo(event) {
  const file = event.target.files[0]
  if (!file) return

  archivoNombre.value = file.name
  resultado.value = null

  const reader = new FileReader()
  reader.onload = (e) => {
    csv.value = e.target.result
    showToast('success', `Archivo cargado: ${lineasCount.value} lineas`)
  }
  reader.onerror = () => {
    showToast('error', 'Error al leer el archivo')
  }
  reader.readAsText(file)
}

function limpiarTodo() {
  csv.value = ''
  archivoNombre.value = ''
  resultado.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

// Procesar archivo
async function procesarArchivo() {
  if (!csv.value.trim()) {
    showToast('warning', 'Ingrese contenido CSV para procesar')
    return
  }

  // 1. SweetAlert2 de confirmacion
  const confirmResult = await Swal.fire({
    title: 'Procesar Archivo',
    html: `<p>Se procesaran <strong>${lineasCount.value}</strong> lineas del archivo.</p>
           <p>Los registros se insertaran en la base de datos.</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Si, Procesar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading general
  showLoading('Procesando...', 'Insertando registros en base de datos')
  procesando.value = true
  resultado.value = null

  try {
    const params = [
      { nombre: 'p_contenido', valor: csv.value, tipo: 'string' },
      { nombre: 'p_usuario', valor: 0, tipo: 'integer' }
    ]

    const resp = await execute('sp_valet_paso_procesar', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const row = Array.isArray(data) ? data[0] : data

    resultado.value = {
      fecha: new Date().toLocaleString(),
      total: row?.total_lineas || 0,
      insertados: row?.insertados || 0,
      errores: row?.errores || 0,
      detalle: row?.detalle_errores || ''
    }

    if (resultado.value.errores === 0) {
      showToast('success', `Se insertaron ${resultado.value.insertados} registros correctamente`)
    } else {
      showToast('warning', `Procesado con ${resultado.value.errores} errores`)
    }

    // Actualizar resumen
    await cargarResumen()

  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
    procesando.value = false
  }
}

// Consultar registros
async function consultar() {
  showLoading('Buscando...', 'Consultando registros')
  currentPage.value = 1
  consultado.value = true

  try {
    const params = [
      { nombre: 'p_fecha_desde', valor: filtroDesde.value || null, tipo: 'string' },
      { nombre: 'p_fecha_hasta', valor: filtroHasta.value || null, tipo: 'string' },
      { nombre: 'p_placa', valor: filtroPlaca.value || null, tipo: 'string' }
    ]

    const resp = await execute('sp_valet_paso_consultar', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    registros.value = Array.isArray(data) ? data : []

    if (registros.value.length > 0) {
      showToast('success', `${registros.value.length} registros encontrados`)
    } else {
      showToast('info', 'No se encontraron registros')
    }

  } catch (e) {
    handleApiError(e)
    registros.value = []
  } finally {
    hideLoading()
  }
}

function limpiarFiltros() {
  filtroDesde.value = ''
  filtroHasta.value = ''
  filtroPlaca.value = ''
  registros.value = []
  consultado.value = false
  currentPage.value = 1
}

// Cargar resumen
async function cargarResumen() {
  try {
    const params = [
      { nombre: 'p_fecha_desde', valor: null, tipo: 'string' },
      { nombre: 'p_fecha_hasta', valor: null, tipo: 'string' }
    ]

    const resp = await execute('sp_valet_paso_resumen', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    resumen.value = Array.isArray(data) ? data : []

  } catch (e) {
    console.error('Error cargando resumen:', e)
    resumen.value = []
  }
}

// Eliminar por fecha
async function eliminarFecha(fecha) {
  // 1. SweetAlert2 de confirmacion
  const confirmResult = await Swal.fire({
    title: 'Eliminar Registros',
    html: `<p>Esta a punto de eliminar todos los registros del:</p>
           <p><strong>${formatDate(fecha)}</strong></p>
           <p class="text-danger">Esta accion no se puede deshacer.</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Si, Eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  // 2. Loading general
  showLoading('Eliminando...', 'Procesando eliminacion')

  try {
    const params = [
      { nombre: 'p_fecha', valor: fecha, tipo: 'string' }
    ]

    const resp = await execute('sp_valet_paso_eliminar', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const row = Array.isArray(data) ? data[0] : data

    if (row?.result === 1) {
      showToast('success', row?.msg || 'Registros eliminados')
      await cargarResumen()
    } else {
      showToast('warning', row?.msg || 'No se encontraron registros')
    }

  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Helpers
function formatDate(date) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('es-MX')
}

function formatDateTime(datetime) {
  if (!datetime) return '-'
  return new Date(datetime).toLocaleString('es-MX', { dateStyle: 'short', timeStyle: 'short' })
}

function formatMoney(amount) {
  if (!amount && amount !== 0) return '-'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(amount)
}

onMounted(() => {
  cargarResumen()
})

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

.section-header-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
}

.section-header-warning {
  background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
}

.section-header-purple {
  background: linear-gradient(135deg, #6f42c1 0%, #5a32a3 100%);
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

.section-body {
  padding: 1.5rem;
}

/* Upload options */
.upload-options {
  display: flex;
  gap: 2rem;
  align-items: flex-start;
}

@media (max-width: 768px) {
  .upload-options {
    flex-direction: column;
  }
}

.upload-option {
  flex: 1;
}

.upload-divider {
  display: flex;
  align-items: center;
  padding: 2rem 0;
}

.upload-divider span {
  background: #e9ecef;
  padding: 0.5rem 1rem;
  border-radius: 50%;
  color: #6c757d;
  font-weight: 500;
}

.file-input-group {
  display: flex;
  gap: 0.5rem;
}

.file-input-group input {
  flex: 1;
}

.csv-textarea {
  font-family: 'Consolas', monospace;
  font-size: 0.9rem;
  resize: vertical;
}

/* File info */
.file-info-box {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-top: 1rem;
  padding: 1rem;
  background: #e3f2fd;
  border-radius: 8px;
  border-left: 4px solid #1976d2;
}

.file-icon {
  font-size: 2rem;
  color: #1976d2;
}

.file-details {
  display: flex;
  flex-direction: column;
}

.file-size {
  font-size: 0.85rem;
  color: #6c757d;
}

/* Format help */
.format-help {
  margin-top: 1.5rem;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
}

.format-help h6 {
  margin: 0 0 0.75rem;
  color: #495057;
}

.format-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.format-item {
  padding: 0.375rem 0.75rem;
  background: #fff;
  border-radius: 4px;
  font-size: 0.85rem;
  border: 1px solid #dee2e6;
}

.format-item code {
  background: #667eea;
  color: white;
  padding: 0.125rem 0.375rem;
  border-radius: 3px;
  margin-right: 0.5rem;
  font-size: 0.75rem;
}

.format-note {
  margin: 0.75rem 0 0;
  font-size: 0.85rem;
  color: #6c757d;
  font-style: italic;
}

/* Action row */
.action-row {
  margin-top: 1.5rem;
  display: flex;
  justify-content: center;
}

.btn-lg {
  padding: 0.75rem 2rem;
  font-size: 1.1rem;
}

/* Results grid */
.result-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

@media (max-width: 768px) {
  .result-grid {
    grid-template-columns: 1fr;
  }
}

.result-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 8px;
}

.result-total { background: #d1ecf1; border-left: 4px solid #17a2b8; }
.result-success { background: #d4edda; border-left: 4px solid #28a745; }
.result-error { background: #f8d7da; border-left: 4px solid #dc3545; }

.result-icon { font-size: 2rem; }
.result-total .result-icon { color: #17a2b8; }
.result-success .result-icon { color: #28a745; }
.result-error .result-icon { color: #dc3545; }

.result-value {
  font-size: 2rem;
  font-weight: 700;
  display: block;
}

.result-label {
  font-size: 0.9rem;
  color: #6c757d;
}

/* Error list */
.error-list {
  padding: 1rem;
  background: #fff3cd;
  border-radius: 8px;
  border-left: 4px solid #ffc107;
}

.error-list h6 {
  margin: 0 0 0.75rem;
  color: #856404;
}

.error-content {
  font-family: 'Consolas', monospace;
  font-size: 0.85rem;
  color: #856404;
  white-space: pre-wrap;
  word-break: break-word;
}

/* Filtros */
.filter-row {
  display: flex;
  gap: 1.5rem;
  align-items: flex-end;
  flex-wrap: wrap;
}

.filter-field {
  flex: 1;
  min-width: 150px;
}

.filter-field label {
  display: block;
  margin-bottom: 0.5rem;
}

.filter-actions {
  display: flex;
  gap: 0.5rem;
}

/* Table */
.id-code {
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
}

/* Empty state */
.empty-state {
  text-align: center;
  padding: 3rem;
  color: #6c757d;
}

.empty-state-icon {
  opacity: 0.5;
}

.empty-state p {
  margin-top: 1rem;
}

/* Paginacion */
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
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

.btn-page {
  width: 32px;
  height: 32px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-page:hover:not(:disabled) {
  background: #667eea;
  border-color: #667eea;
  color: white;
}

.btn-page:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-indicator {
  padding: 0 1rem;
  font-weight: 500;
}

/* Botones de accion */
.btn-action {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-delete {
  background: #dc3545;
  color: white;
}

.btn-delete:hover {
  background: #c82333;
  transform: scale(1.1);
}

/* Botones */
.btn-municipal-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  border: none;
  color: white;
  padding: 0.5rem 1.5rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
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
</style>
