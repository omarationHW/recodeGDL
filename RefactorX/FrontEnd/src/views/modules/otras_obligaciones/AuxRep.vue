<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>{{ tablaNombre || 'Padrón de Concesionarios' }}</h1>
        <p>Otras Obligaciones - Padrón sin Adeudos</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
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
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Padrón de Concesionarios
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
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
                class="municipal-form-control"
                style="width: auto; display: inline-block; margin-left: 10px;"
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
            <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
            <p>No se encontraron registros en el padrón con los filtros seleccionados.</p>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos del padrón...</p>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'AuxRep'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

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
  router.push('/otras_obligaciones')
}

// Cargar información de la tabla
const loadTablaInfo = async () => {
  try {
    const response = await execute(
      'SP_AUXREP_TABLAS_GET',
      'otras_obligaciones',
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
      'SP_AUXREP_ETIQUETAS_GET',
      'otras_obligaciones',
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
      'SP_AUXREP_VIGENCIAS_GET',
      'otras_obligaciones',
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
  setLoading(true, 'Cargando padrón...')

  try {
    const response = await execute(
      'SP_AUXREP_PADRON_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: tablaId.value, tipo: 'integer' },
        { nombre: 'par_vigencia', valor: vigenciaSeleccionada.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      padronData.value = response.result
      totalRecords.value = padronData.value.length
      currentPage.value = 1

      if (totalRecords.value > 0) {
        showToast('success', `${totalRecords.value} registro(s) encontrado(s)`)
      } else {
        showToast('info', 'No se encontraron registros con los filtros seleccionados')
      }
    } else {
      padronData.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron registros')
    }
  } catch (error) {
    handleApiError(error)
    padronData.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
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

// Lifecycle
onMounted(async () => {
  setLoading(true, 'Inicializando...')

  try {
    await loadTablaInfo()
    await loadEtiquetas()
    await loadVigencias()
    await loadPadron()
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
})
</script>
