<template>
  <div class="module-view module-layout">
    <!-- ========== HEADER ========== -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="magnifying-glass" />
      </div>
      <div class="module-view-info">
        <h1>Consulta por Registro</h1>
        <p>Consulta detallada de apremios por registro</p>
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
        <button class="btn-municipal-primary" @click="buscar" v-if="filters.registro">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- ========== FILTROS COLAPSABLES ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Criterios de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Registro</label>
              <input
                class="municipal-form-control"
                v-model="filters.registro"
                @keyup.enter="buscar"
                placeholder="Ingrese el registro a consultar"
              />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar" :disabled="!filters.registro">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- ========== RESULTADO DE CONSULTA ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="file-alt" />
            Resultado de Consulta
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="data && !Array.isArray(data)">
              1 registro encontrado
            </span>
            <span class="badge-purple" v-else-if="data && Array.isArray(data) && data.length > 0">
              {{ data.length }} registros encontrados
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="!data && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="search" size="3x" />
            </div>
            <h4>Consulta por Registro</h4>
            <p>Ingrese un registro para consultar la información detallada</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="(!data || (Array.isArray(data) && data.length === 0)) && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontró información para el registro especificado</p>
          </div>

          <!-- Resultado estructurado -->
          <div v-else>
            <div class="municipal-tabs">
              <button
                class="municipal-tab"
                :class="{ active: activeTab === 'structured' }"
                @click="activeTab = 'structured'"
              >
                <font-awesome-icon icon="table" /> Vista Estructurada
              </button>
              <button
                class="municipal-tab"
                :class="{ active: activeTab === 'json' }"
                @click="activeTab = 'json'"
              >
                <font-awesome-icon icon="code" /> Vista JSON
              </button>
            </div>

            <div v-show="activeTab === 'structured'" class="structured-view">
              <div v-if="!Array.isArray(data)">
                <!-- Mostrar objeto único -->
                <div class="form-row" v-for="(value, key) in data" :key="key">
                  <div class="form-group">
                    <label class="municipal-form-label">{{ formatLabel(key) }}</label>
                    <p>{{ formatValue(value) }}</p>
                  </div>
                </div>
              </div>
              <div v-else>
                <!-- Mostrar array de objetos -->
                <div class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th v-for="col in getColumns(data)" :key="col">{{ formatLabel(col) }}</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="(row, idx) in data"
                        :key="idx"
                        @click="selectedRow = row"
                        :class="{ 'table-row-selected': selectedRow === row }"
                        class="row-hover"
                      >
                        <td v-for="col in getColumns(data)" :key="col">
                          {{ formatValue(row[col]) }}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <div v-show="activeTab === 'json'" class="json-view">
              <pre class="pre-wrap">{{ JSON.stringify(data, null, 2) }}</pre>
            </div>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ConsultaReg'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Consulta por Registro'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// ========== CONSTANTES ==========
const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'sp_consultareg_mercados'

// ========== COMPOSABLES ==========
const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// ========== ESTADO - FILTROS ==========
const showFilters = ref(true)
const filters = ref({
  registro: ''
})

// ========== ESTADO - DATOS ==========
const data = ref(null)
const primeraBusqueda = ref(false)
const selectedRow = ref(null)
const hasSearched = ref(false)

// ========== ESTADO - VISTA ==========
const activeTab = ref('structured')

// ========== FUNCIONES - BÚSQUEDA ==========
const buscar = async () => {
  if (!filters.value.registro) {
    showToast('error', 'Debe ingresar un registro para consultar')
    return
  }

  showLoading('Consultando registro...', 'Buscando información')
  hasSearched.value = true
  selectedRow.value = null
  showFilters.value = false
  primeraBusqueda.value = true
  const startTime = performance.now()

  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_id_local', type: 'I', value: parseInt(filters.value.registro || 0) }
    ])

    if (response && response.data) {
      data.value = Array.isArray(response.data) ? response.data : response.data
    } else if (response && response.result) {
      data.value = Array.isArray(response.result) ? response.result : response.result
    } else {
      data.value = null
    }

    const endTime = performance.now()
    const duration = endTime - startTime
    const durationText = duration < 1000
      ? `${Math.round(duration)}ms`
      : `${(duration / 1000).toFixed(2)}s`

    const count = !data.value ? 0 : Array.isArray(data.value) ? data.value.length : 1
    showToast('success', `Consulta completada en ${durationText} - ${count} registro(s)`)
  } catch (error) {
    data.value = null
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    registro: ''
  }
  data.value = null
  primeraBusqueda.value = false
  hasSearched.value = false
  selectedRow.value = null
}

// ========== FUNCIONES - FILTROS ==========
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// ========== HELPERS ==========
const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const formatMoney = (value) => {
  return Number(value || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('es-MX').format(date)
}

const formatLabel = (key) => {
  // Convertir snake_case o camelCase a Title Case
  return key
    .replace(/_/g, ' ')
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, str => str.toUpperCase())
    .trim()
}

const formatValue = (value) => {
  if (value === null || value === undefined) return '-'
  if (typeof value === 'boolean') return value ? 'Sí' : 'No'
  if (typeof value === 'object') return JSON.stringify(value)
  return String(value)
}

const getColumns = (arr) => {
  if (!arr || arr.length === 0) return []
  return Object.keys(arr[0])
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

