<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Listado de Adeudo Global con Accesorios</h1>
        <p>Inicio > Reportes > Adeudo Global con Accesorios</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel1"
          :disabled="loading || adeudosConAccesorios.length === 0">
          <font-awesome-icon icon="file-excel" />
          Excel 1
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel2"
          :disabled="loading || localesSinAdeudo.length === 0">
          <font-awesome-icon icon="file-excel" />
          Excel 2
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="loading || (adeudosConAccesorios.length === 0 && localesSinAdeudo.length === 0)">
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
              <select class="municipal-form-control" v-model="selectedRec" @change="onRecChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="!selectedRec || loading">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="1995" max="2999"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="mes" min="1" max="12"
                placeholder="Mes" :disabled="loading" />
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar
                </button>
                <button class="btn-municipal-secondary me-2" @click="buscarLocalesSinAdeudo" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar Locales sin Adeudo
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

      <!-- Tabla 1: Locales con Adeudos y Accesorios -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales con Adeudos y Accesorios
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="adeudosConAccesorios.length > 0">
              {{ formatNumber(adeudosConAccesorios.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingTable1" class="text-center py-5">
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
                  <th class="text-end">Importe Adeudo</th>
                  <th class="text-end">Importe Recargos</th>
                  <th class="text-end">Importe Multa</th>
                  <th class="text-end">Importe Gastos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="adeudosConAccesorios.length === 0 && !searchPerformed1">
                  <td colspan="12" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar locales con adeudos y accesorios</p>
                  </td>
                </tr>
                <tr v-else-if="adeudosConAccesorios.length === 0">
                  <td colspan="12" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales con adeudos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedAdeudosConAccesorios" :key="index"
                  @click="selectedAdeudo1 = row" :class="{ 'table-row-selected': selectedAdeudo1 === row }"
                  class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.importe_adeudo) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(row.importe_recargos) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.importe_multa) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-info">{{ formatCurrency(row.importe_gastos) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación - Tabla 1 -->
          <div v-if="adeudosConAccesorios.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage1 - 1) * itemsPerPage1) + 1 }}
                a {{ Math.min(currentPage1 * itemsPerPage1, totalRecords1) }}
                de {{ totalRecords1 }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPage1"
                @change="changePageSize1($event.target.value)" style="width: auto; display: inline-block;">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
                <option value="250">250</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage1(1)" :disabled="currentPage1 === 1"
                title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage1(currentPage1 - 1)"
                :disabled="currentPage1 === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>

              <button v-for="page in visiblePages1" :key="page" class="btn-sm"
                :class="page === currentPage1 ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage1(page)">
                {{ page }}
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage1(currentPage1 + 1)"
                :disabled="currentPage1 === totalPages1" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage1(totalPages1)"
                :disabled="currentPage1 === totalPages1" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla 2: Locales sin Adeudos con Accesorios -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales sin Adeudos con Accesorios
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="localesSinAdeudo.length > 0">
              {{ formatNumber(localesSinAdeudo.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingTable2" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error2" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error2 }}
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
                  <th class="text-end">Importe Adeudo</th>
                  <th class="text-end">Importe Recargos</th>
                  <th class="text-end">Importe Multa</th>
                  <th class="text-end">Importe Gastos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="localesSinAdeudo.length === 0 && !searchPerformed2">
                  <td colspan="12" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Haz clic en "Buscar Locales sin Adeudo" para consultar locales sin adeudos con accesorios</p>
                  </td>
                </tr>
                <tr v-else-if="localesSinAdeudo.length === 0">
                  <td colspan="12" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales sin adeudo con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedLocalesSinAdeudo" :key="index" @click="selectedAdeudo2 = row"
                  :class="{ 'table-row-selected': selectedAdeudo2 === row }" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_adeudo) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_recargos) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_multa) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_gastos) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación - Tabla 2 -->
          <div v-if="localesSinAdeudo.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage2 - 1) * itemsPerPage2) + 1 }}
                a {{ Math.min(currentPage2 * itemsPerPage2, totalRecords2) }}
                de {{ totalRecords2 }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPage2"
                @change="changePageSize2($event.target.value)" style="width: auto; display: inline-block;">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
                <option value="250">250</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage2(1)" :disabled="currentPage2 === 1"
                title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage2(currentPage2 - 1)"
                :disabled="currentPage2 === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>

              <button v-for="page in visiblePages2" :key="page" class="btn-sm"
                :class="page === currentPage2 ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage2(page)">
                {{ page }}
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage2(currentPage2 + 1)"
                :disabled="currentPage2 === totalPages2" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage2(totalPages2)"
                :disabled="currentPage2 === totalPages2" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Toast Notifications -->
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

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const mercados = ref([])
const selectedRec = ref('')
const selectedMercado = ref('')
const axo = ref(new Date().getFullYear())
const mes = ref(new Date().getMonth() + 1)

// Datos de las dos tablas
const adeudosConAccesorios = ref([])
const localesSinAdeudo = ref([])

const selectedAdeudo1 = ref(null)
const selectedAdeudo2 = ref(null)

const loading = ref(false)
const loadingTable1 = ref(false)
const loadingTable2 = ref(false)

const error = ref('')
const error2 = ref('')

const searchPerformed1 = ref(false)
const searchPerformed2 = ref(false)

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Paginación - Tabla 1
const currentPage1 = ref(1)
const itemsPerPage1 = ref(25)
const totalRecords1 = computed(() => adeudosConAccesorios.value.length)

// Paginación - Tabla 2
const currentPage2 = ref(1)
const itemsPerPage2 = ref(25)
const totalRecords2 = computed(() => localesSinAdeudo.value.length)

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ayuda: Seleccione una oficina, mercado, año y mes para consultar adeudos globales con accesorios')
}

const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

const fetchRecaudadoras = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    if (res.data.eResponse.success === true) {
      recaudadoras.value = res.data.eResponse.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast('success', `Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`)
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al cargar recaudadoras'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar recaudadoras'
    console.error('Error al cargar recaudadoras:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const onRecChange = async () => {
  selectedMercado.value = ''
  mercados.value = []
  if (!selectedRec.value) return

  loading.value = true
  error.value = ''
  try {

    const nivelUsuario = 1; // TODO: Obtener del store de usuario
        const oficinaParam = selectedRec.value || null;

    const res = await axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_get_catalogo_mercados',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
              { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
            ]
          }
        });


    console.log('.........');
    if (res.data.eResponse && res.data.eResponse.success === true) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast('success', `Se cargaron ${mercados.value.length} mercados`)
      } else {
        showToast('info', 'No se encontraron mercados para esta oficina')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al cargar mercados'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar mercados'
    console.error('Error al cargar mercados:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const buscar = async () => {
  if (!selectedRec.value || !selectedMercado.value || !axo.value || !mes.value) {
    error.value = 'Debe seleccionar oficina, mercado, año y mes'
    showToast('warning', error.value)
    return
  }

  if (mes.value < 1 || mes.value > 12) {
    error.value = 'El mes debe estar entre 1 y 12'
    showToast('warning', error.value)
    return
  }

  if (axo.value < 1995 || axo.value > 2999) {
    error.value = 'El año debe estar entre 1995 y 2999'
    showToast('warning', error.value)
    return
  }

  loading.value = true
  loadingTable1.value = true
  error.value = ''
  adeudosConAccesorios.value = []
  selectedAdeudo1.value = null
  searchPerformed1.value = true
  currentPage1.value = 1

  console.log('Buscando adeudos con accesorios para:', {
    oficina: selectedRec.value,
    mercado: selectedMercado.value,
    año: axo.value,
    mes: mes.value
  });
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_ade_global_locales',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_office_id', valor: selectedRec.value, tipo: 'integer' },
          { nombre: 'p_market_id', valor: selectedMercado.value, tipo: 'integer' },
          { nombre: 'p_year', valor: axo.value, tipo: 'integer' },
          { nombre: 'p_month', valor: mes.value, tipo: 'integer' }
        ]
      }
    })
    if (res.data.eResponse && res.data.eResponse.success === true) {
      adeudosConAccesorios.value = res.data.eResponse.data.result || []
      if (adeudosConAccesorios.value.length > 0) {
        showToast('success', `Se encontraron ${adeudosConAccesorios.value.length} locales con adeudos`)
        showFilters.value = false
      } else {
        showToast('info', 'No se encontraron locales con adeudos con los criterios especificados')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al consultar adeudos globales'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar adeudos globales'
    console.error('Error al buscar adeudos:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
    loadingTable1.value = false
  }
}

const buscarLocalesSinAdeudo = async () => {
  if (!selectedMercado.value || !axo.value || !mes.value) {
    error2.value = 'Debe seleccionar mercado, año y mes'
    showToast('warning', error2.value)
    return
  }

  if (mes.value < 1 || mes.value > 12) {
    error2.value = 'El mes debe estar entre 1 y 12'
    showToast('warning', error2.value)
    return
  }

  if (axo.value < 1995 || axo.value > 2999) {
    error2.value = 'El año debe estar entre 1995 y 2999'
    showToast('warning', error2.value)
    return
  }

  loading.value = true
  loadingTable2.value = true
  error2.value = ''
  localesSinAdeudo.value = []
  selectedAdeudo2.value = null
  searchPerformed2.value = true
  currentPage2.value = 1

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_locales_sin_adeudo_con_accesorios',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_market_id', valor: selectedMercado.value, tipo: 'integer' },
          { nombre: 'p_year', valor: axo.value, tipo: 'integer' },
          { nombre: 'p_month', valor: mes.value, tipo: 'integer' },
          { nombre: 'p_year2', valor: axo.value, tipo: 'integer' }
        ]
      }
    })
    if (res.data.eResponse && res.data.eResponse.success === true) {
      localesSinAdeudo.value = res.data.eResponse.data.result || []
      if (localesSinAdeudo.value.length > 0) {
        showToast('success', `Se encontraron ${localesSinAdeudo.value.length} locales sin adeudo`)
        showFilters.value = false
      } else {
        showToast('info', 'No se encontraron locales sin adeudo con los criterios especificados')
      }
    } else {
      error2.value = res.data.eResponse?.message || 'Error al consultar locales sin adeudo'
      showToast('error', error2.value)
    }
  } catch (err) {
    error2.value = 'Error de conexión al consultar locales sin adeudo'
    console.error('Error al buscar locales sin adeudo:', err)
    showToast('error', error2.value)
  } finally {
    loading.value = false
    loadingTable2.value = false
  }
}

const limpiarFiltros = () => {
  selectedRec.value = ''
  selectedMercado.value = ''
  mercados.value = []
  axo.value = new Date().getFullYear()
  mes.value = new Date().getMonth() + 1
  adeudosConAccesorios.value = []
  localesSinAdeudo.value = []
  selectedAdeudo1.value = null
  selectedAdeudo2.value = null
  error.value = ''
  error2.value = ''
  searchPerformed1.value = false
  searchPerformed2.value = false
  currentPage1.value = 1
  currentPage2.value = 1
  showToast('info', 'Filtros limpiados')
}

const exportarExcel1 = () => {
  if (adeudosConAccesorios.value.length === 0) {
    showToast('warning', 'No hay datos para exportar en la tabla de locales con adeudos')
    return
  }
  // TODO: Implementar exportación a Excel para tabla 1
  showToast('info', 'Funcionalidad de exportación Excel 1 en desarrollo')
}

const exportarExcel2 = () => {
  if (localesSinAdeudo.value.length === 0) {
    showToast('warning', 'No hay datos para exportar en la tabla de locales sin adeudo')
    return
  }
  // TODO: Implementar exportación a Excel para tabla 2
  showToast('info', 'Funcionalidad de exportación Excel 2 en desarrollo')
}

const imprimir = () => {
  if (adeudosConAccesorios.value.length === 0 && localesSinAdeudo.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }
  // TODO: Implementar impresión
  showToast('info', 'Funcionalidad de impresión en desarrollo')
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

// Paginación - Computed - Tabla 1
const totalPages1 = computed(() => {
  return Math.ceil(totalRecords1.value / itemsPerPage1.value)
})

const paginatedAdeudosConAccesorios = computed(() => {
  const start = (currentPage1.value - 1) * itemsPerPage1.value
  const end = start + itemsPerPage1.value
  return adeudosConAccesorios.value.slice(start, end)
})

const visiblePages1 = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage1.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages1.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Paginación - Computed - Tabla 2
const totalPages2 = computed(() => {
  return Math.ceil(totalRecords2.value / itemsPerPage2.value)
})

const paginatedLocalesSinAdeudo = computed(() => {
  const start = (currentPage2.value - 1) * itemsPerPage2.value
  const end = start + itemsPerPage2.value
  return localesSinAdeudo.value.slice(start, end)
})

const visiblePages2 = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage2.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages2.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Paginación - Métodos - Tabla 1
const goToPage1 = (page) => {
  if (page < 1 || page > totalPages1.value) return
  currentPage1.value = page
  selectedAdeudo1.value = null
}

const changePageSize1 = (size) => {
  itemsPerPage1.value = parseInt(size)
  currentPage1.value = 1
  selectedAdeudo1.value = null
}

// Paginación - Métodos - Tabla 2
const goToPage2 = (page) => {
  if (page < 1 || page > totalPages2.value) return
  currentPage2.value = page
  selectedAdeudo2.value = null
}

const changePageSize2 = (size) => {
  itemsPerPage2.value = parseInt(size)
  currentPage2.value = 1
  selectedAdeudo2.value = null
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
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
