<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos de Energía Eléctrica</h1>
        <p>Mercados > Reportes > Adeudos de Energía Eléctrica</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || adeudos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || adeudos.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Filtros en una sola fila -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedOficina" @change="fetchMercados" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in oficinas" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="loading || !selectedOficina">
                <option value="">Seleccione...</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="1994" max="2999"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="mes" min="1" max="12"
                placeholder="Mes (1-12)" :disabled="loading" />
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscarAdeudos" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Adeudos de Energía Eléctrica
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="adeudos.length > 0">
              {{ formatNumber(adeudos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Rec.</th>
                  <th>Merc.</th>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Adicionales</th>
                  <th class="text-end">Cuota Bim/Mes</th>
                  <th>Año</th>
                  <th class="text-end">Adeudo</th>
                  <th>Periodo de Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="adeudos.length === 0 && !searchPerformed">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar adeudos de energía eléctrica</p>
                  </td>
                </tr>
                <tr v-else-if="adeudos.length === 0">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron adeudos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedAdeudos" :key="row.id_local + '-' + row.id_energia + '-' + index"
                  @click="selectedAdeudo = row" :class="{ 'table-row-selected': selectedAdeudo === row }" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.local_adicional }}</td>
                  <td class="text-end">{{ formatCurrency(row.cuota) }}</td>
                  <td>{{ row.axo }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.adeudo) }}</strong>
                  </td>
                  <td>
                    <button class="btn-municipal-secondary btn-sm" @click.stop="verMeses(row)">
                      <font-awesome-icon icon="eye" />
                      Ver Detalle
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="adeudos.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPage"
                @change="changePageSize($event.target.value)" style="width: auto; display: inline-block;">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"
                title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>

              <button v-for="page in visiblePages" :key="page" class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)">
                {{ page }}
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de Meses de Adeudo -->
    <div class="modal fade" id="mesesModal" tabindex="-1" aria-labelledby="mesesModalLabel" aria-hidden="true" ref="mesesModalRef">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="mesesModalLabel">
              <font-awesome-icon icon="calendar-alt" />
              Detalle de Meses de Adeudo
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div v-if="loadingMeses" class="text-center py-4">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Cargando...</span>
              </div>
              <p class="mt-3 text-muted">Cargando detalle de meses...</p>
            </div>
            <div v-else-if="mesesAdeudo.length === 0">
              <p class="text-muted text-center">
                <font-awesome-icon icon="info-circle" size="2x" class="mb-3" />
                <br>
                No hay información de meses de adeudo para este registro.
              </p>
            </div>
            <div v-else class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Periodo</th>
                    <th class="text-end">Importe</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="m in mesesAdeudo" :key="m.periodo">
                    <td>{{ m.periodo }}</td>
                    <td class="text-end">
                      <strong class="text-danger">{{ formatCurrency(m.importe) }}</strong>
                    </td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <th>Total</th>
                    <th class="text-end">
                      <strong class="text-danger">{{ formatCurrency(totalMesesAdeudo) }}</strong>
                    </th>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" data-bs-dismiss="modal">
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
//import { Modal } from 'bootstrap'

const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const oficinas = ref([])
const mercados = ref([])
const selectedOficina = ref('')
const selectedMercado = ref('')
const axo = ref(new Date().getFullYear())
const mes = ref(new Date().getMonth() + 1)
const adeudos = ref([])
const selectedAdeudo = ref(null)
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Modal de meses
const mesesModalRef = ref(null)
const mesesAdeudo = ref([])
const loadingMeses = ref(false)
let mesesModal = null

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(25)
const totalRecords = computed(() => adeudos.value.length)

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Seleccione una oficina, mercado, año y mes para consultar los adeudos de energía eléctrica', 'info')
}

const fetchOficinas = async () => {
  showLoading('Cargando Adeudos de Energía', 'Preparando oficinas recaudadoras...')
  loading.value = true
  error.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: [],
        Esquema: 'publico'
      }
    })
    if (res.data.eResponse.success) {
      oficinas.value = res.data.eResponse.data.result || []
      if (oficinas.value.length > 0) {
        showToast(`Se cargaron ${oficinas.value.length} oficinas recaudadoras`, 'success')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al cargar oficinas recaudadoras'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar oficinas recaudadoras'
    console.error('Error al cargar oficinas:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const fetchMercados = async () => {
  if (!selectedOficina.value) {
    mercados.value = []
    selectedMercado.value = ''
    return
  }

  loading.value = true
  error.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_oficina',
        Base: 'mercados',
        Parametros: [
          { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'string' }
        ],
        Esquema: 'publico'
      }
    })
    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        selectedMercado.value = mercados.value[0].num_mercado_nvo
      } else {
        selectedMercado.value = ''
        showToast('No se encontraron mercados para esta oficina', 'warning')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al cargar mercados'
      showToast(error.value, 'error')
      mercados.value = []
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar mercados'
    console.error('Error al cargar mercados:', err)
    showToast(error.value, 'error')
    mercados.value = []
  } finally {
    loading.value = false
  }
}

const buscarAdeudos = async () => {
  if (!selectedOficina.value || !selectedMercado.value || !axo.value || !mes.value) {
    error.value = 'Debe seleccionar oficina, mercado, año y mes'
    showToast(error.value, 'warning')
    return
  }

  if (mes.value < 1 || mes.value > 12) {
    error.value = 'El mes debe estar entre 1 y 12'
    showToast(error.value, 'warning')
    return
  }

  if (axo.value < 1994 || axo.value > 2999) {
    error.value = 'El año debe estar entre 1994 y 2999'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  adeudos.value = []
  selectedAdeudo.value = null
  searchPerformed.value = true
  currentPage.value = 1

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_buscar_adeudos_energia',
        Base: 'mercados',
        Parametros: [
          { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'string' },
          { nombre: 'p_mercado', valor: selectedMercado.value, tipo: 'integer' },
          { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
          { nombre: 'p_mes', valor: mes.value, tipo: 'integer' }
        ],
        Esquema: 'publico'
      }
    })
    if (res.data.eResponse.success) {
      adeudos.value = res.data.eResponse.data.result || []
      if (adeudos.value.length > 0) {
        showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron adeudos con los criterios especificados', 'info')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar adeudos'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar adeudos'
    console.error('Error al buscar adeudos:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const verMeses = async (row) => {
  loadingMeses.value = true
  mesesAdeudo.value = []

  // Abrir modal
  if (!mesesModal) {
    mesesModal = new Modal(mesesModalRef.value)
  }
  mesesModal.show()

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_meses_adeudo_energia',
        Base: 'mercados',
        Parametros: [
          { nombre: 'p_id_energia', valor: row.id_energia, tipo: 'integer' },
          { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
          { nombre: 'p_mes', valor: mes.value, tipo: 'integer' }
        ],
        Esquema: 'publico'
      }
    })
    if (res.data.eResponse.success) {
      mesesAdeudo.value = res.data.eResponse.data.result || []
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar detalle de meses', 'error')
    }
  } catch (err) {
    console.error('Error al cargar meses de adeudo:', err)
    showToast('Error de conexión al cargar detalle de meses', 'error')
  } finally {
    loadingMeses.value = false
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  selectedMercado.value = ''
  mercados.value = []
  axo.value = new Date().getFullYear()
  mes.value = new Date().getMonth() + 1
  adeudos.value = []
  selectedAdeudo.value = null
  error.value = ''
  searchPerformed.value = false
  currentPage.value = 1
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (adeudos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('Funcionalidad de exportación a Excel en desarrollo', 'info')
}

const imprimir = () => {
  if (adeudos.value.length === 0) {
    showToast('No hay datos para imprimir', 'warning')
    return
  }
  // TODO: Implementar impresión
  showToast('Funcionalidad de impresión en desarrollo', 'info')
}

// Utilidades
const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return 'N/A'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return 'N/A'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedAdeudos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return adeudos.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

const totalMesesAdeudo = computed(() => {
  return mesesAdeudo.value.reduce((sum, m) => {
    const importe = typeof m.importe === 'number' ? m.importe : parseFloat(m.importe) || 0
    return sum + importe
  }, 0)
})

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedAdeudo.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedAdeudo.value = null
}

// Lifecycle
onMounted(() => {
  fetchOficinas()
})
</script>

<style scoped>
/* Los estilos están definidos en municipal-theme.css */
/* Estilos adicionales específicos del componente si son necesarios */

.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.text-end {
  text-align: right;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.table-row-selected {
  background-color: #fff3cd !important;
}

.row-hover:hover {
  background-color: #f8f9fa;
  cursor: pointer;
}

.required {
  color: #dc3545;
}

/* Override para columnas numéricas */
.municipal-table td.text-end,
.municipal-table th.text-end {
  text-align: right;
}
</style>
