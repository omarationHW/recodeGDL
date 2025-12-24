<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>{{ tablaNombre || 'Padrón de Concesionarios' }}</h1>
        <p>Otras Obligaciones - Padrón sin Adeudos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="cargarDatosIniciales"
          title="Actualizar datos"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Vigencia de la Concesión</label>
              <select
                v-model="vigenciaSeleccionada"
                class="municipal-form-control"
                :disabled="loading"
              >
                <option value="TODOS">TODOS</option>
                <option
                  v-for="vigencia in vigencias"
                  :key="vigencia.descripcion"
                  :value="vigencia.descripcion"
                >
                  {{ vigencia.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarPadron"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-success"
              @click="exportarPadron"
              :disabled="loading || padronData.length === 0"
            >
              <font-awesome-icon icon="file-export" />
              Exportar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Padrón de Concesionarios
            <span class="badge-purple" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body" v-if="!loading && padronData.length > 0">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>{{ etiquetas.etiq_control || 'Control' }}</th>
                  <th>{{ etiquetas.concesionario || 'Concesionario' }}</th>
                  <th>{{ etiquetas.ubicacion || 'Ubicación' }}</th>
                  <th>{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}</th>
                  <th>{{ etiquetas.lugar || 'Lugar' }}</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(registro, index) in paginatedData"
                  :key="registro.id_34_datos"
                  class="row-hover"
                >
                  <td>{{ registro.control }}</td>
                  <td>{{ registro.concesionario }}</td>
                  <td>{{ registro.ubicacion }}</td>
                  <td>{{ registro.nomcomercial }}</td>
                  <td>{{ registro.lugar }}</td>
                  <td>
                    <span class="badge" :class="getStatusClass(registro.statusregistro)">
                      {{ registro.statusregistro }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-controls" v-if="totalPages > 1">
            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="goToFirstPage"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="pagination-button"
                @click="goToPreviousPage"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-info-text">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="pagination-button"
                @click="goToNextPage"
                :disabled="currentPage >= totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="pagination-button"
                @click="goToLastPage"
                :disabled="currentPage >= totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
            <div class="pagination-info">
              <label class="municipal-form-label">Registros por página:</label>
              <select
                v-model="itemsPerPage"
                class="municipal-form-control pagination-select"
              >
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>

        <div class="municipal-card-body" v-else-if="!loading && padronData.length === 0">
          <div class="text-center text-muted">
            <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
            <p>No se encontraron registros en el padrón con los filtros seleccionados.</p>
          </div>
        </div>
      </div>

    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda y Documentación -->
  <DocumentationModal
    :show="showDocModal"
    :componentName="'AuxRep'"
    :moduleName="'otras_obligaciones'"
    :docType="docType"
    :title="'Auxiliar de Reportes - Otras Obligaciones'"
    @close="showDocModal = false"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

// Composables
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

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Estado local de loading
const loading = ref(false)

// Estado
const tablaId = ref(route.params.tablaId || route.query.tablaId || 3)
const tablaNombre = ref('')
const vigenciaSeleccionada = ref('TODOS')
const vigencias = ref([])
const etiquetas = ref({})
const padronData = ref([])
const totalRecords = ref(0)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(25)

// Computed
const totalPages = computed(() => {
  return Math.ceil(padronData.value.length / itemsPerPage.value)
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return padronData.value.slice(start, end)
})

// Métodos de navegación
const goToFirstPage = () => {
  currentPage.value = 1
}

const goToPreviousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const goToNextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const goToLastPage = () => {
  currentPage.value = totalPages.value
}

const goBack = () => {
  router.push('/otras-obligaciones/menu')
}

// Cargar información de la tabla
const loadTablaInfo = async () => {
  try {
    const response = await execute(
      'sp_padron_tablas',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tablaId.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tablaNombre.value = `PADRÓN SIN ADEUDOS DE: ${response.result[0].nombre}`
    }
  } catch (error) {
    console.error('Error al cargar información de la tabla:', error)
  }
}

// Cargar etiquetas
const loadEtiquetas = async () => {
  try {
    const response = await execute(
      'sp_padron_etiquetas',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tablaId.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
  }
}

// Cargar vigencias
const loadVigencias = async () => {
  try {
    const response = await execute(
      'sp_padron_vigencias',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tablaId.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      vigencias.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar vigencias:', error)
  }
}

// Cargar padrón
const loadPadron = async () => {
  const startTime = performance.now()
  loading.value = true
  showLoading('Cargando padrón...', 'Consultando registros')

  try {
    const response = await execute(
      'sp_padron_concesionarios',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: tablaId.value, tipo: 'integer' },
        { nombre: 'par_vigencia', valor: vigenciaSeleccionada.value, tipo: 'varchar' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      padronData.value = response.result
      totalRecords.value = padronData.value.length
      currentPage.value = 1

      if (totalRecords.value > 0) {
        showToast('success', `${totalRecords.value} registro(s) encontrado(s)`, timeMessage)
      } else {
        showToast('info', 'No se encontraron registros con los filtros seleccionados', timeMessage)
      }
    } else {
      padronData.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron registros', timeMessage)
    }
  } catch (error) {
    handleApiError(error)
    padronData.value = []
    totalRecords.value = 0
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Buscar padrón con confirmación
const buscarPadron = async () => {
  await loadPadron()
}

// Exportar padrón a CSV
const exportarPadron = async () => {
  if (padronData.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay datos para exportar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  try {
    const csv = convertToCSV(padronData.value)
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `padron_${tablaId.value}_${vigenciaSeleccionada.value}_${new Date().getTime()}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('success', 'Padrón exportado correctamente')
  } catch (error) {
    await Swal.fire({
      icon: 'error',
      title: 'Error al exportar',
      text: 'No se pudo exportar el padrón',
      confirmButtonColor: '#ea8215'
    })
  }
}

// Convertir a CSV
const convertToCSV = (data) => {
  if (!data || data.length === 0) return ''

  const headers = [
    etiquetas.value.etiq_control || 'Control',
    etiquetas.value.concesionario || 'Concesionario',
    etiquetas.value.ubicacion || 'Ubicación',
    etiquetas.value.nombre_comercial || 'Nombre Comercial',
    etiquetas.value.lugar || 'Lugar',
    'Status',
    'Observaciones'
  ]

  const rows = data.map(registro => [
    registro.control || '',
    registro.concesionario || '',
    registro.ubicacion || '',
    registro.nomcomercial || '',
    registro.lugar || '',
    registro.statusregistro || '',
    registro.obs || ''
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
  ].join('\n')

  return csvContent
}

// Obtener clase de status
const getStatusClass = (status) => {
  if (!status) return 'badge-secondary'

  const statusLower = status.toLowerCase()

  if (statusLower.includes('vigente') || statusLower.includes('activo')) {
    return 'badge-success'
  } else if (statusLower.includes('cancelado') || statusLower.includes('inactivo')) {
    return 'badge-danger'
  } else if (statusLower.includes('suspendido')) {
    return 'badge-warning'
  } else {
    return 'badge-info'
  }
}

// Cargar datos iniciales
const cargarDatosIniciales = async () => {
  loading.value = true
  showLoading('Actualizando datos...')

  try {
    await loadTablaInfo()
    await loadEtiquetas()
    await loadVigencias()
    await loadPadron()
    showToast('success', 'Datos actualizados')
  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Lifecycle
onMounted(async () => {
  loading.value = true
  showLoading('Inicializando...')

  try {
    await loadTablaInfo()
    await loadEtiquetas()
    await loadVigencias()
    await loadPadron()
  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
})
</script>

<style scoped>
/* ====== FORM ROW ====== */
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  flex: 1;
  min-width: 200px;
}

/* ====== BUTTON GROUP ====== */
.button-group {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

/* ====== BADGES ====== */
.badge-purple {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.35rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 600;
  color: white;
  background: linear-gradient(135deg, #6f42c1, #5a32a3);
  border-radius: 20px;
  margin-left: 0.5rem;
}

.badge {
  display: inline-block;
  padding: 0.35rem 0.65rem;
  font-size: 0.75rem;
  font-weight: 600;
  border-radius: 0.375rem;
}

.badge-success {
  background-color: #198754;
  color: white;
}

.badge-danger {
  background-color: #dc3545;
  color: white;
}

.badge-warning {
  background-color: #ffc107;
  color: #1a1a2e;
}

.badge-info {
  background-color: #0dcaf0;
  color: #1a1a2e;
}

.badge-secondary {
  background-color: #6c757d;
  color: white;
}

/* ====== TABLA ====== */
.table-responsive {
  overflow-x: auto;
  margin: 0 -1rem;
  padding: 0 1rem;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}

.municipal-table-header {
  background: linear-gradient(135deg, #1a1a2e, #16213e);
}

.municipal-table-header th {
  padding: 0.875rem 1rem;
  color: white;
  font-weight: 600;
  text-align: left;
  white-space: nowrap;
}

.municipal-table tbody tr {
  border-bottom: 1px solid #e9ecef;
  transition: background-color 0.2s ease;
}

.municipal-table tbody tr:hover,
.row-hover:hover {
  background-color: rgba(234, 130, 21, 0.08);
}

.municipal-table td {
  padding: 0.75rem 1rem;
  vertical-align: middle;
}

/* ====== PAGINACIÓN ====== */
.pagination-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 0;
  margin-top: 1rem;
  border-top: 1px solid #e9ecef;
  flex-wrap: wrap;
  gap: 1rem;
}

.pagination-nav {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 0.375rem;
  cursor: pointer;
  color: #495057;
  transition: all 0.2s ease;
}

.pagination-button:hover:not(:disabled) {
  background: #ea8215;
  border-color: #ea8215;
  color: white;
}

.pagination-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-info-text {
  padding: 0 1rem;
  font-size: 0.875rem;
  color: #495057;
  font-weight: 500;
}

.pagination-info {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-select {
  width: auto;
  min-width: 80px;
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
  border: 1px solid #ced4da;
  border-radius: 0.375rem;
  background-color: white;
}

/* ====== SPINNER ====== */
.spinner-border {
  width: 1.5rem;
  height: 1.5rem;
  border: 2px solid #ea8215;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spin 0.75s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* ====== EMPTY STATE ====== */
.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.empty-state-icon {
  color: #dee2e6;
  margin-bottom: 1rem;
}

/* ====== RESPONSIVE ====== */
@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
  }

  .form-group {
    min-width: 100%;
  }

  .button-group {
    flex-direction: column;
  }

  .button-group button {
    width: 100%;
  }

  .pagination-controls {
    flex-direction: column;
    align-items: stretch;
  }

  .pagination-nav {
    justify-content: center;
  }

  .pagination-info {
    justify-content: center;
  }
}
</style>
