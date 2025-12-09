<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>Padrón Global de Locales</h1>
        <p>Inicio > Reportes > Padrón Global</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="exportarExcel" :disabled="!resultados.length">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="consultar">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Año <span class="required">*</span></label>
                <input type="number" v-model.number="filters.year" class="municipal-form-control"
                       min="2000" :max="new Date().getFullYear() + 1" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes <span class="required">*</span></label>
                <select v-model.number="filters.month" class="municipal-form-control" required>
                  <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Estatus <span class="required">*</span></label>
                <select v-model="filters.status" class="municipal-form-control" required>
                  <option value="A">Vigentes</option>
                  <option value="B">Baja</option>
                  <option value="C">Baja por Acuerdo</option>
                  <option value="D">Baja Administrativa</option>
                  <option value="T">Todos</option>
                </select>
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-12 text-end">
                <button type="submit" class="btn-municipal-primary me-2" :disabled="loading">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                  {{ loading ? 'Consultando...' : 'Consultar' }}
                </button>
                <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros">
                  <font-awesome-icon icon="eraser" /> Limpiar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Mensaje informativo -->
      <div v-if="!busquedaRealizada && !loading" class="alert alert-info mt-3">
        <font-awesome-icon icon="info-circle" />
        Seleccione año, mes y estatus, luego haga clic en <strong>Consultar</strong>.
      </div>

      <!-- Mensaje sin resultados -->
      <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning mt-3">
        <font-awesome-icon icon="exclamation-triangle" />
        No se encontraron locales con los criterios seleccionados.
      </div>

      <!-- Tabla de resultados -->
      <div v-if="resultados.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Padrón Global</h5>
          <div class="header-right">
            <span class="badge-blue me-2">{{ resultados.length }} locales</span>
            <span class="badge-success me-2">Al corriente: {{ localesAlCorriente }}</span>
            <span class="badge-danger">Con adeudo: {{ localesConAdeudo }}</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Registro</th>
                  <th>Nombre del Local</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                  <th class="text-center">Estatus</th>
                  <th>Descripción</th>
                  <th class="text-center">Situación de Pago</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedResultados" :key="row.id_local" class="row-hover">
                  <td><span class="badge-light-info">{{ row.registro }}</span></td>
                  <td><strong>{{ row.nombre }}</strong></td>
                  <td class="text-end">{{ formatNumber(row.superficie) }} m²</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.renta) }}</strong></td>
                  <td class="text-center">
                    <span class="badge" :class="getBadgeVigencia(row.vigencia)">
                      {{ getTextoVigencia(row.vigencia) }}
                    </span>
                  </td>
                  <td>{{ row.descripcion_local }}</td>
                  <td class="text-center">
                    <span class="badge" :class="row.adeudo === 1 ? 'badge-danger' : 'badge-light-info'">
                      {{ row.leyenda }}
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-header">
                <tr>
                  <th colspan="3" class="text-end">Totales:</th>
                  <th class="text-end">{{ formatCurrency(totalRenta) }}</th>
                  <th colspan="3"></th>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container mt-3">
            <div class="pagination-info">
              Mostrando {{ (currentPage - 1) * pageSize + 1 }} a
              {{ Math.min(currentPage * pageSize, resultados.length) }} de {{ resultados.length }} locales
            </div>
            <div class="pagination-controls">
              <button class="btn-pagination" @click="previousPage" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-pagination" @click="nextPage" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
            <div class="items-per-page">
              <label>
                Registros por página:
                <select v-model.number="pageSize" class="municipal-form-control" style="width: auto;">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                  <option :value="250">250</option>
                </select>
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({
  year: new Date().getFullYear(),
  month: new Date().getMonth() + 1,
  status: 'A'
})

const resultados = ref([])
const loading = ref(false)
const busquedaRealizada = ref(false)
const currentPage = ref(1)
const pageSize = ref(25)
const toast = ref({ show: false, type: 'info', message: '' })

const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
])

const totalPages = computed(() => Math.ceil(resultados.value.length / pageSize.value) || 1)
const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return resultados.value.slice(start, start + pageSize.value)
})
const totalRenta = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.renta) || 0), 0))
const localesAlCorriente = computed(() => resultados.value.filter(r => r.adeudo === 0).length)
const localesConAdeudo = computed(() => resultados.value.filter(r => r.adeudo === 1).length)

const previousPage = () => {
  if (currentPage.value > 1) currentPage.value--
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++
}

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('info', 'Consulte el padrón global de locales por año, mes y estatus. Puede exportar los resultados a Excel.')
}

const consultar = async () => {
  showLoading('Consultando padrón global...', 'Por favor espere')
  loading.value = true
  busquedaRealizada.value = false

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_padron_global',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_year', Valor: parseInt(filters.value.year) },
          { Nombre: 'p_month', Valor: parseInt(filters.value.month) },
          { Nombre: 'p_status', Valor: filters.value.status }
        ]
      }
    })

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      resultados.value = response.data.eResponse.data.result
      busquedaRealizada.value = true
      currentPage.value = 1
      showToast('success', `Se encontraron ${resultados.value.length} locales`)
    } else {
      resultados.value = []
      busquedaRealizada.value = true
      showToast('info', 'No se encontraron locales con los criterios especificados')
    }
  } catch (error) {
    console.error('Error al consultar:', error)
    showToast('error', 'Error al consultar el padrón global')
    resultados.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    year: new Date().getFullYear(),
    month: new Date().getMonth() + 1,
    status: 'A'
  }
  resultados.value = []
  busquedaRealizada.value = false
  currentPage.value = 1
}

const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  if (value == null) return '0'
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value)
}

const getBadgeVigencia = (vigencia) => {
  const map = {
    'A': 'badge-success',
    'B': 'badge-danger',
    'C': 'badge-warning',
    'D': 'badge-secondary'
  }
  return map[vigencia] || 'badge-info'
}

const getTextoVigencia = (vigencia) => {
  const map = {
    'A': 'Vigente',
    'B': 'Baja',
    'C': 'Baja Acuerdo',
    'D': 'Baja Admin'
  }
  return map[vigencia] || vigencia
}

const exportarExcel = () => {
  const mesNombre = meses.value.find(m => m.value === filters.value.month)?.label || filters.value.month

  const csv = [
    'Registro,Nombre,Superficie,Renta,Estatus,Descripción,Situación de Pago',
    ...resultados.value.map(r =>
      `"${r.registro}","${r.nombre}",${r.superficie},${r.renta},"${getTextoVigencia(r.vigencia)}","${r.descripcion_local}","${r.leyenda}"`
    )
  ].join('\n')

  const BOM = '\uFEFF'
  const blob = new Blob([BOM + csv], { type: 'text/csv;charset=utf-8;' })
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `padron_global_${filters.value.year}_${mesNombre}.csv`
  a.click()
  window.URL.revokeObjectURL(url)

  showToast('success', 'Reporte exportado exitosamente')
}

onMounted(() => {
  // Component ready
})
</script>

