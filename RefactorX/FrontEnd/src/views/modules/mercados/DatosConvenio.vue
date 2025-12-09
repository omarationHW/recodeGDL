<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Convenios</h1>
        <p>Inicio > Mercados > Convenios</p>
      </div>
      <div class="button-group ms-auto">
        <button v-if="convenioSeleccionado" class="btn-municipal-secondary" @click="volverListado">
          <font-awesome-icon icon="arrow-left" />
          Volver al Listado
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Vista de Listado -->
      <template v-if="!convenioSeleccionado">
        <!-- Filtros de búsqueda -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="filter" />
              Filtros de Búsqueda
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">Nombre</label>
                <input type="text" v-model="filtros.nombre" class="municipal-form-control"
                       placeholder="Buscar por nombre..." @keyup.enter="buscarConvenios" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Vigencia</label>
                <select v-model="filtros.vigencia" class="municipal-form-control">
                  <option value="">Todas</option>
                  <option value="V">Vigente</option>
                  <option value="C">Cancelado</option>
                  <option value="P">Pagado</option>
                  <option value="B">Baja</option>
                </select>
              </div>
              <div class="form-group align-self-end">
                <button class="btn-municipal-primary" @click="buscarConvenios" :disabled="loadingList">
                  <font-awesome-icon :icon="loadingList ? 'spinner' : 'search'" :spin="loadingList" />
                  Buscar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Tabla de Convenios -->
        <div class="municipal-card">
          <div class="municipal-card-header header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Listado de Convenios
            </h5>
            <div class="header-right">
              <span class="badge-purple" v-if="convenios.length > 0">
                {{ convenios.length }} registros
              </span>
            </div>
          </div>
          <div class="municipal-card-body table-container">
            <div v-if="loadingList" class="text-center py-5">
              <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Cargando...</span>
              </div>
              <p class="mt-3 text-muted">Cargando convenios...</p>
            </div>

            <div v-else-if="convenios.length > 0" class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>ID</th>
                    <th>Folio</th>
                    <th>Nombre</th>
                    <th>Calle</th>
                    <th>Núm.</th>
                    <th class="text-end">Pago Total</th>
                    <th>Fecha Firma</th>
                    <th>Estado</th>
                    <th class="text-center">Acción</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="conv in paginatedConvenios" :key="conv.id_convenio" class="row-hover" @click="seleccionarConvenio(conv)">
                    <td>{{ conv.id_convenio }}</td>
                    <td>{{ conv.folio }}</td>
                    <td>{{ conv.nombre }}</td>
                    <td>{{ conv.desc_calle }}</td>
                    <td>{{ conv.numero }}</td>
                    <td class="text-end">{{ formatCurrency(conv.pago_total) }}</td>
                    <td>{{ conv.fecha_firma }}</td>
                    <td>
                      <span class="status-badge" :class="getStatusClass(conv.vigencia)">
                        {{ conv.estado }}
                      </span>
                    </td>
                    <td class="text-center">
                      <button class="btn-municipal-primary btn-sm" @click.stop="seleccionarConvenio(conv)">
                        <font-awesome-icon icon="eye" />
                        Ver
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>

              <!-- Paginación para convenios -->
              <div class="pagination-container">
                <div class="pagination-info">
                  Mostrando {{ ((currentPageConvenios - 1) * itemsPerPageConvenios) + 1 }}
                  a {{ Math.min(currentPageConvenios * itemsPerPageConvenios, totalRecordsConvenios) }}
                  de {{ totalRecordsConvenios }} registros
                </div>
                <div class="pagination-controls">
                  <label class="me-2">Registros por página:</label>
                  <select v-model.number="itemsPerPageConvenios" class="form-select form-select-sm">
                    <option :value="10">10</option>
                    <option :value="25">25</option>
                    <option :value="50">50</option>
                    <option :value="100">100</option>
                    <option :value="250">250</option>
                  </select>
                </div>
                <div class="pagination-buttons">
                  <button @click="goToPageConvenios(1)" :disabled="currentPageConvenios === 1" title="Primera página">
                    <font-awesome-icon icon="angle-double-left" />
                  </button>
                  <button @click="goToPageConvenios(currentPageConvenios - 1)" :disabled="currentPageConvenios === 1" title="Página anterior">
                    <font-awesome-icon icon="angle-left" />
                  </button>
                  <button v-for="page in visiblePagesConvenios" :key="page"
                    :class="page === currentPageConvenios ? 'active' : ''"
                    @click="goToPageConvenios(page)">
                    {{ page }}
                  </button>
                  <button @click="goToPageConvenios(currentPageConvenios + 1)" :disabled="currentPageConvenios === totalPagesConvenios" title="Página siguiente">
                    <font-awesome-icon icon="angle-right" />
                  </button>
                  <button @click="goToPageConvenios(totalPagesConvenios)" :disabled="currentPageConvenios === totalPagesConvenios" title="Última página">
                    <font-awesome-icon icon="angle-double-right" />
                  </button>
                </div>
              </div>
            </div>

            <div v-else class="text-center text-muted py-4">
              <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
              <p>No se encontraron convenios</p>
            </div>
          </div>
        </div>
      </template>

      <!-- Vista de Detalle -->
      <template v-else>
        <!-- Loading -->
        <div v-if="loadingDetail" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-3 text-muted">Cargando convenio...</p>
        </div>

        <!-- Datos del Convenio -->
        <template v-else-if="convenio">
          <div class="row">
            <!-- Columna Izquierda -->
            <div class="col-md-6">
              <div class="municipal-card">
                <div class="municipal-card-header">
                  <h5>
                    <font-awesome-icon icon="user" />
                    Datos del Convenio
                  </h5>
                </div>
                <div class="municipal-card-body">
                  <div class="form-row">
                    <div class="form-group" style="flex: 1;">
                      <label class="municipal-form-label">ID Convenio</label>
                      <input type="text" class="municipal-form-control" :value="convenio.id_convenio" readonly />
                    </div>
                    <div class="form-group" style="flex: 1;">
                      <label class="municipal-form-label">Folio</label>
                      <input type="text" class="municipal-form-control" :value="convenio.folio" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group" style="flex: 2;">
                      <label class="municipal-form-label">Nombre</label>
                      <input type="text" class="municipal-form-control" :value="convenio.nombre" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group" style="flex: 2;">
                      <label class="municipal-form-label">Calle</label>
                      <input type="text" class="municipal-form-control" :value="convenio.desc_calle" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Número</label>
                      <input type="text" class="municipal-form-control" :value="convenio.numero" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Metros²</label>
                      <input type="text" class="municipal-form-control" :value="convenio.metros2" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Tipo Casa</label>
                      <input type="text" class="municipal-form-control" :value="convenio.tipo_casa || '-'" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Colonia</label>
                      <input type="text" class="municipal-form-control" :value="convenio.colonia" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Vigencia</label>
                      <input type="text" class="municipal-form-control" :value="convenio.estado" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group" style="flex: 2;">
                      <label class="municipal-form-label">Observaciones</label>
                      <input type="text" class="municipal-form-control" :value="convenio.observacion || '-'" readonly />
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Columna Derecha -->
            <div class="col-md-6">
              <div class="municipal-card">
                <div class="municipal-card-header">
                  <h5>
                    <font-awesome-icon icon="money-bill-wave" />
                    Datos de Pago
                  </h5>
                </div>
                <div class="municipal-card-body">
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Pago Total</label>
                      <input type="text" class="municipal-form-control" :value="formatCurrency(convenio.pago_total)" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Pago Inicial</label>
                      <input type="text" class="municipal-form-control" :value="formatCurrency(convenio.pago_inicial)" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Pago Quincenal</label>
                      <input type="text" class="municipal-form-control" :value="formatCurrency(convenio.pago_quincenal)" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Pagos Parciales</label>
                      <input type="text" class="municipal-form-control" :value="convenio.pagos_parciales" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Recargos</label>
                      <input type="text" class="municipal-form-control" :value="formatCurrency(convenio.recargos_conv)" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Saldo Insoluto</label>
                      <input type="text" class="municipal-form-control" :value="formatCurrency(convenio.saldo_insoluto)" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Tipo Pago</label>
                      <input type="text" class="municipal-form-control" :value="convenio.tipodesc" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Usuario</label>
                      <input type="text" class="municipal-form-control" :value="convenio.usuario" readonly />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Fecha Firma</label>
                      <input type="text" class="municipal-form-control" :value="convenio.fecha_firma" readonly />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Fecha Vencimiento</label>
                      <input type="text" class="municipal-form-control" :value="convenio.fecha_vencimiento" readonly />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tabla de Parcialidades -->
          <div class="municipal-card mt-3">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="list" />
                Parcialidades / Pagos
              </h5>
              <div class="header-right">
                <span class="badge-purple" v-if="parciales.length > 0">
                  {{ parciales.length }} registros
                </span>
              </div>
            </div>
            <div class="municipal-card-body table-container">
              <div v-if="parciales.length > 0" class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Parcial</th>
                      <th>Tipo</th>
                      <th class="text-end">Importe</th>
                      <th>Fecha Pago</th>
                      <th>Oficina</th>
                      <th>Caja</th>
                      <th>Operación</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(p, idx) in paginatedParciales" :key="idx" class="row-hover">
                      <td>{{ p.pago_parcial }} / {{ p.total_parciales }}</td>
                      <td>{{ p.descparc }}</td>
                      <td class="text-end">{{ formatCurrency(p.importe) }}</td>
                      <td>{{ p.fecha_pago }}</td>
                      <td>{{ p.oficina_pago }}</td>
                      <td>{{ p.caja_pago }}</td>
                      <td>{{ p.operacion_pago }}</td>
                    </tr>
                  </tbody>
                </table>

                <!-- Paginación para parciales -->
                <div class="pagination-container">
                  <div class="pagination-info">
                    Mostrando {{ ((currentPageParciales - 1) * itemsPerPageParciales) + 1 }}
                    a {{ Math.min(currentPageParciales * itemsPerPageParciales, totalRecordsParciales) }}
                    de {{ totalRecordsParciales }} registros
                  </div>
                  <div class="pagination-controls">
                    <label class="me-2">Registros por página:</label>
                    <select v-model.number="itemsPerPageParciales" class="form-select form-select-sm">
                      <option :value="10">10</option>
                      <option :value="25">25</option>
                      <option :value="50">50</option>
                      <option :value="100">100</option>
                      <option :value="250">250</option>
                    </select>
                  </div>
                  <div class="pagination-buttons">
                    <button @click="goToPageParciales(1)" :disabled="currentPageParciales === 1" title="Primera página">
                      <font-awesome-icon icon="angle-double-left" />
                    </button>
                    <button @click="goToPageParciales(currentPageParciales - 1)" :disabled="currentPageParciales === 1" title="Página anterior">
                      <font-awesome-icon icon="angle-left" />
                    </button>
                    <button v-for="page in visiblePagesParciales" :key="page"
                      :class="page === currentPageParciales ? 'active' : ''"
                      @click="goToPageParciales(page)">
                      {{ page }}
                    </button>
                    <button @click="goToPageParciales(currentPageParciales + 1)" :disabled="currentPageParciales === totalPagesParciales" title="Página siguiente">
                      <font-awesome-icon icon="angle-right" />
                    </button>
                    <button @click="goToPageParciales(totalPagesParciales)" :disabled="currentPageParciales === totalPagesParciales" title="Última página">
                      <font-awesome-icon icon="angle-double-right" />
                    </button>
                  </div>
                </div>
              </div>
              <div v-else class="text-center text-muted py-4">
                <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                <p>No hay pagos registrados para este convenio</p>
              </div>
            </div>
          </div>
        </template>

        <!-- Sin datos -->
        <div v-else class="text-center py-5">
          <font-awesome-icon icon="exclamation-circle" size="3x" class="text-warning mb-3" />
          <p class="text-muted">No se encontró información del convenio</p>
        </div>
      </template>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

// Estado del listado
const convenios = ref([])
const filtros = ref({
  nombre: '',
  vigencia: ''
})
const loadingList = ref(false)

// Paginación Convenios
const currentPageConvenios = ref(1)
const itemsPerPageConvenios = ref(10)
const totalRecordsConvenios = computed(() => convenios.value.length)
const totalPagesConvenios = computed(() => Math.ceil(totalRecordsConvenios.value / itemsPerPageConvenios.value))

const paginatedConvenios = computed(() => {
  const start = (currentPageConvenios.value - 1) * itemsPerPageConvenios.value
  const end = start + itemsPerPageConvenios.value
  return convenios.value.slice(start, end)
})

const visiblePagesConvenios = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPageConvenios.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPagesConvenios.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

const goToPageConvenios = (page) => {
  if (page < 1 || page > totalPagesConvenios.value) return
  currentPageConvenios.value = page
}

// Estado del detalle
const convenioSeleccionado = ref(null)
const convenio = ref(null)
const parciales = ref([])
const loadingDetail = ref(false)

// Paginación Parciales
const currentPageParciales = ref(1)
const itemsPerPageParciales = ref(10)
const totalRecordsParciales = computed(() => parciales.value.length)
const totalPagesParciales = computed(() => Math.ceil(totalRecordsParciales.value / itemsPerPageParciales.value))

const paginatedParciales = computed(() => {
  const start = (currentPageParciales.value - 1) * itemsPerPageParciales.value
  const end = start + itemsPerPageParciales.value
  return parciales.value.slice(start, end)
})

const visiblePagesParciales = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPageParciales.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPagesParciales.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

const goToPageParciales = (page) => {
  if (page < 1 || page > totalPagesParciales.value) return
  currentPageParciales.value = page
}

// Toast
const toast = ref({ show: false, type: 'info', message: '' })

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => { toast.value.show = false }

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const formatCurrency = (val) => {
  if (val == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(parseFloat(val))
}

const getStatusClass = (vigencia) => {
  const classes = {
    'V': 'badge-success',
    'P': 'badge-info',
    'C': 'badge-danger',
    'B': 'badge-warning'
  }
  return classes[vigencia] || 'badge-default'
}

const mostrarAyuda = () => {
  showToast('Consulta de convenios y sus pagos', 'info')
}

const buscarConvenios = async () => {
  loadingList.value = true
  showLoading()
  try {
    const params = []
    if (filtros.value.nombre) {
      params.push({ Nombre: 'p_nombre', Valor: filtros.value.nombre })
    } else {
      params.push({ Nombre: 'p_nombre', Valor: null })
    }
    if (filtros.value.vigencia) {
      params.push({ Nombre: 'p_vigencia', Valor: filtros.value.vigencia })
    } else {
      params.push({ Nombre: 'p_vigencia', Valor: null })
    }

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_convenios_list',
        Base: 'mercados',
        Parametros: params
      }
    })

    if (res.data?.eResponse?.success) {
      convenios.value = res.data.eResponse.data?.result || []
      currentPageConvenios.value = 1
      if (convenios.value.length > 0) {
        showToast(`Se encontraron ${convenios.value.length} convenios`, 'success')
      } else {
        showToast('No se encontraron convenios', 'info')
      }
    }
  } catch (err) {
    showToast('Error al buscar convenios', 'error')
    console.error(err)
  } finally {
    loadingList.value = false
    hideLoading()
  }
}

const seleccionarConvenio = async (conv) => {
  convenioSeleccionado.value = conv
  loadingDetail.value = true
  showLoading()

  try {
    // Cargar datos completos del convenio
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_datos_convenio',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_conv', Valor: conv.id_convenio }
        ]
      }
    })
    convenio.value = res.data?.eResponse?.data?.result?.[0] || null

    // Cargar parcialidades
    const res2 = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_convenio_parciales',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_conv', Valor: conv.id_convenio }
        ]
      }
    })
    parciales.value = res2.data?.eResponse?.data?.result || []
    currentPageParciales.value = 1

    if (convenio.value) {
      showToast('Convenio cargado correctamente', 'success')
    }
  } catch (e) {
    showToast('Error al cargar convenio: ' + (e.response?.data?.message || e.message), 'error')
  } finally {
    loadingDetail.value = false
    hideLoading()
  }
}

const volverListado = () => {
  convenioSeleccionado.value = null
  convenio.value = null
  parciales.value = []
}

onMounted(() => {
  buscarConvenios()
})
</script>
