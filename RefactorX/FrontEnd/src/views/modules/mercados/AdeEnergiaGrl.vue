<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Generales de Energía</h1>
        <p>Inicio > Reportes > Adeudos Generales de Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="globalLoading.isLoading.value || adeudos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="globalLoading.isLoading.value || adeudos.length === 0">
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
              <select class="municipal-form-control" v-model="selectedRec" @change="onRecChange" :disabled="globalLoading.isLoading.value">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="!selectedRec || globalLoading.isLoading.value">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año Hasta <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="1995" max="2999"
                placeholder="Año" :disabled="globalLoading.isLoading.value" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mes Hasta <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="mes" min="1" max="12"
                placeholder="Mes" :disabled="globalLoading.isLoading.value" />
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscar" :disabled="globalLoading.isLoading.value">
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="globalLoading.isLoading.value">
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
            Resultados de Adeudos de Energía
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="adeudos.length > 0">
              {{ formatNumber(adeudos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de error -->
          <div v-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-if="!error" class="table-responsive">
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
                  <th>Cuota Bim/Mes</th>
                  <th>Año</th>
                  <th>Adeudo</th>
                  <th>Periodo de Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="adeudos.length === 0 && !searchPerformed">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar adeudos de energía</p>
                  </td>
                </tr>
                <tr v-else-if="adeudos.length === 0">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron adeudos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedAdeudos" :key="index" @click="selectedAdeudo = row"
                  :class="{ 'table-row-selected': selectedAdeudo === row }" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.local_adicional }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.cuota) }}</strong>
                  </td>
                  <td>{{ row.axo }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.adeudo) }}</strong>
                  </td>
                  <td>{{ row.mesesadeudos }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="adeudos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ totalRecords }} registros
            </div>
            <div class="pagination-controls">
              <label class="me-2">Registros por página:</label>
              <select v-model.number="itemsPerPage" class="form-select form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="goToPage(1)" :disabled="currentPage === 1" title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button v-for="page in visiblePages" :key="page"
                :class="page === currentPage ? 'active' : ''"
                @click="goToPage(page)">
                {{ page }}
              </button>
              <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button @click="goToPage(totalPages)" :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
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

// Composables
const globalLoading = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const mercados = ref([])
const selectedRec = ref('')
const selectedMercado = ref('')
const axo = ref(new Date().getFullYear())
const mes = ref(new Date().getMonth() + 1)
const adeudos = ref([])
const selectedAdeudo = ref(null)
const error = ref('')
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => adeudos.value.length)

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ayuda: Seleccione una oficina, mercado, año y mes para consultar los adeudos de energía', 'info')
}

const fetchRecaudadoras = async () => {
  await globalLoading.withLoading(async () => {
    error.value = ''
    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_recaudadoras',
          Base: 'mercados',
          Parametros: []
        }
      })
      if (res.data.eResponse && res.data.eResponse.success === true) {
        recaudadoras.value = res.data.eResponse.data.result || []
        if (recaudadoras.value.length > 0) {
          showToast(`Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`, 'success')
        }
      } else {
        error.value = res.data.eResponse?.message || 'Error al cargar recaudadoras'
        showToast(error.value, 'error')
      }
    } catch (err) {
      error.value = 'Error de conexión al cargar recaudadoras'
      console.error('Error al cargar recaudadoras:', err)
      showToast(error.value, 'error')
    }
  }, 'Cargando oficinas recaudadoras...', 'Por favor espere')
}

const onRecChange = async () => {
  selectedMercado.value = ''
  mercados.value = []
  if (!selectedRec.value) return

  await globalLoading.withLoading(async () => {
    error.value = ''
    let p_nivel_usuario = 1 // Nivel de usuario fijo para este contexto
    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_catalogo_mercados',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_oficina', tipo: 'integer', valor: selectedRec.value },
            { nombre: 'p_nivel_usuario', tipo: 'integer', valor: p_nivel_usuario }
          ]
        }
      })
      if (res.data.eResponse && res.data.eResponse.success === true) {
        mercados.value = res.data.eResponse.data.result || []
        if (mercados.value.length > 0) {
          showToast(`Se cargaron ${mercados.value.length} mercados`, 'success')
        } else {
          showToast('No se encontraron mercados para esta oficina', 'info')
        }
      } else {
        error.value = res.data.eResponse?.message || 'Error al cargar mercados'
        showToast(error.value, 'error')
      }
    } catch (err) {
      error.value = 'Error de conexión al cargar mercados'
      console.error('Error al cargar mercados:', err)
      showToast(error.value, 'error')
    }
  }, 'Cargando mercados...', 'Por favor espere')
}

const buscar = async () => {
  if (!selectedRec.value || !selectedMercado.value || !axo.value || !mes.value) {
    error.value = 'Debe seleccionar oficina, mercado, año y mes'
    showToast(error.value, 'warning')
    return
  }

  if (mes.value < 1 || mes.value > 12) {
    error.value = 'El mes debe estar entre 1 y 12'
    showToast(error.value, 'warning')
    return
  }

  if (axo.value < 1995 || axo.value > 2999) {
    error.value = 'El año debe estar entre 1995 y 2999'
    showToast(error.value, 'warning')
    return
  }

  await globalLoading.withLoading(async () => {
    error.value = ''
    adeudos.value = []
    selectedAdeudo.value = null
    searchPerformed.value = true
    currentPage.value = 1

    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'getAdeudosEnergiaGrl',
          Base: 'mercados',
          Parametros: [
            { nombre: 'p_id_rec', valor: selectedRec.value, tipo: 'string' },
            { nombre: 'p_num_mercado_nvo', valor: selectedMercado.value, tipo: 'integer' },
            { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
            { nombre: 'p_mes', valor: mes.value, tipo: 'integer' }
          ]
        }
      })
      if (res.data.eResponse && res.data.eResponse.success === true) {
        adeudos.value = res.data.eResponse.data.result || []
        if (adeudos.value.length > 0) {
          showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success')
          showFilters.value = false
        } else {
          showToast('No se encontraron adeudos con los criterios especificados', 'info')
        }
      } else {
        error.value = res.data.eResponse?.message || 'Error al consultar adeudos'
        showToast(error.value, 'error')
      }
    } catch (err) {
      error.value = 'Error de conexión al consultar adeudos'
      console.error('Error al buscar adeudos:', err)
      showToast(error.value, 'error')
    }
  }, 'Consultando adeudos de energía...', 'Por favor espere')
}

const limpiarFiltros = () => {
  selectedRec.value = ''
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
  fetchRecaudadoras()
})
</script>

<style scoped>
/**
 * ESTILOS MUNICIPALES - PRIORIDAD MEDIA
 *
 * Este componente utiliza principalmente las clases globales definidas en municipal-theme.css:
 * - municipal-card: Tarjetas de contenido
 * - municipal-table: Tablas de datos
 * - btn-municipal-*: Botones con estilos municipales (primary, secondary, purple)
 * - municipal-form-control: Inputs y selects
 * - municipal-form-label: Labels de formularios
 *
 * Los estilos scoped a continuación son específicos de este componente y no pueden ser globales.
 */

/* Estilos específicos del componente que complementan las clases municipales */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
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
</style>
