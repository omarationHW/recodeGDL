<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta General de Locales</h1>
        <p>Inicio > Consultas > General</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel"
          :disabled="loading || locales.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="loading || locales.length === 0">
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
            Búsqueda de Local
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <form @submit.prevent="buscarLocal">
            <!-- Filtros en dos filas -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select v-model="form.oficina" class="municipal-form-control" required @change="cargarMercados" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.aseguradora }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                <select v-model="form.num_mercado" class="municipal-form-control" required
                  :disabled="!form.oficina || loading">
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <select v-model="form.categoria" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.id" :value="cat.id">
                    {{ cat.nombre }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select v-model="form.seccion" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Local <span class="required">*</span></label>
                <input v-model="form.local" type="number" class="municipal-form-control" required :disabled="loading"
                  placeholder="Número de local">
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Letra</label>
                <input v-model="form.letra_local" type="text" class="municipal-form-control" maxlength="1"
                  :disabled="loading" placeholder="A-Z">
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input v-model="form.bloque" type="text" class="municipal-form-control" maxlength="1"
                  :disabled="loading" placeholder="1-9">
              </div>
            </div>

            <!-- Botones de acción -->
            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="submit" class="btn-municipal-primary me-2" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                  <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                    <font-awesome-icon icon="eraser" />
                    Limpiar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla: Resultados de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="locales.length > 0">
              {{ formatNumber(locales.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingLocales" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="errorLocales" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorLocales }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Nombre</th>
                  <th>Arrendatario</th>
                  <th>Giro</th>
                  <th>Superficie</th>
                  <th>Vigencia</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0 && !searchPerformed">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar locales</p>
                  </td>
                </tr>
                <tr v-else-if="locales.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="loc in locales" :key="loc.id_local"
                  @click="selectedLocal = loc"
                  :class="{ 'table-row-selected': selectedLocal?.id_local === loc.id_local }"
                  class="row-hover">
                  <td><strong class="text-primary">{{ loc.id_local }}</strong></td>
                  <td>{{ loc.nombre }}</td>
                  <td>{{ loc.arrendatario }}</td>
                  <td>{{ loc.giro }}</td>
                  <td>{{ loc.superficie }}</td>
                  <td>{{ loc.vigencia }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm" @click.stop="verDetalle(loc)">
                      <font-awesome-icon icon="eye" />
                      Ver Detalle
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de detalle -->
    <div v-if="showModal" class="modal-backdrop" @click.self="cerrarModal">
      <div class="modal-content modal-xl">
        <div class="modal-header municipal-modal-header">
          <h5 class="modal-title">
            <font-awesome-icon icon="info-circle" />
            Detalle del Local
          </h5>
          <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
        </div>
        <div class="modal-body">
          <!-- Información del local -->
          <div class="row">
            <div class="col-md-6">
              <table class="table table-sm table-bordered">
                <tr><th class="table-light" style="width: 40%">Mercado</th><td>{{ detalle.nombre_mercado }}</td></tr>
                <tr><th class="table-light">Control</th><td>{{ detalle.id_local }}</td></tr>
                <tr><th class="table-light">Nombre</th><td>{{ detalle.nombre }}</td></tr>
                <tr><th class="table-light">Arrendatario</th><td>{{ detalle.arrendatario }}</td></tr>
                <tr><th class="table-light">Giro</th><td>{{ detalle.giro }}</td></tr>
                <tr><th class="table-light">Superficie</th><td>{{ detalle.superficie }}</td></tr>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-bordered">
                <tr><th class="table-light" style="width: 40%">Fecha Alta</th><td>{{ detalle.fecha_alta }}</td></tr>
                <tr><th class="table-light">Fecha Baja</th><td>{{ detalle.fecha_baja || '-' }}</td></tr>
                <tr><th class="table-light">Vigencia</th><td>{{ detalle.vigencia }}</td></tr>
                <tr><th class="table-light">Usuario</th><td>{{ detalle.usuario }}</td></tr>
                <tr><th class="table-light">Bloqueo</th><td>{{ detalle.bloqueo || '-' }}</td></tr>
                <tr><th class="table-light">Observación</th><td>{{ detalle.observacion || '-' }}</td></tr>
              </table>
            </div>
          </div>

          <!-- Tabs de información adicional -->
          <ul class="nav nav-tabs mt-3">
            <li class="nav-item">
              <button class="nav-link" :class="{ active: tab === 'adeudos' }" @click="tab = 'adeudos'">
                Adeudos ({{ adeudos.length }})
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ active: tab === 'pagos' }" @click="tab = 'pagos'">
                Pagos ({{ pagos.length }})
              </button>
            </li>
            <li class="nav-item">
              <button class="nav-link" :class="{ active: tab === 'requerimientos' }" @click="tab = 'requerimientos'">
                Requerimientos ({{ requerimientos.length }})
              </button>
            </li>
          </ul>

          <!-- Contenido de tabs -->
          <div class="tab-content p-3 border border-top-0">
            <!-- Tab Adeudos -->
            <div v-if="tab === 'adeudos'">
              <div v-if="loadingTab" class="text-center py-3">
                <span class="spinner-border spinner-border-sm"></span> Cargando...
              </div>
              <table v-else class="table table-sm table-hover">
                <thead class="table-light">
                  <tr>
                    <th>Año</th>
                    <th>Periodo</th>
                    <th class="text-end">Importe</th>
                    <th class="text-end">Recargos</th>
                    <th class="text-end">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(a, idx) in adeudos" :key="idx">
                    <td>{{ a.axo }}</td>
                    <td>{{ a.periodo }}</td>
                    <td class="text-end"><strong class="text-danger">{{ formatCurrency(a.importe) }}</strong></td>
                    <td class="text-end"><strong class="text-warning">{{ formatCurrency(a.recargos) }}</strong></td>
                    <td class="text-end"><strong class="text-primary">{{ formatCurrency(parseFloat(a.importe || 0) + parseFloat(a.recargos || 0)) }}</strong></td>
                  </tr>
                  <tr v-if="adeudos.length === 0">
                    <td colspan="5" class="text-center text-muted">
                      <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                      <p>Sin adeudos registrados</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Tab Pagos -->
            <div v-if="tab === 'pagos'">
              <div v-if="loadingTab" class="text-center py-3">
                <span class="spinner-border spinner-border-sm"></span> Cargando...
              </div>
              <table v-else class="table table-sm table-hover">
                <thead class="table-light">
                  <tr>
                    <th>Año</th>
                    <th>Periodo</th>
                    <th>Fecha Pago</th>
                    <th class="text-end">Importe</th>
                    <th>Folio</th>
                    <th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(p, idx) in pagos" :key="idx">
                    <td>{{ p.axo }}</td>
                    <td>{{ p.periodo }}</td>
                    <td>{{ p.fecha_pago }}</td>
                    <td class="text-end"><strong class="text-success">{{ formatCurrency(p.importe_pago) }}</strong></td>
                    <td>{{ p.folio }}</td>
                    <td>{{ p.usuario }}</td>
                  </tr>
                  <tr v-if="pagos.length === 0">
                    <td colspan="6" class="text-center text-muted">
                      <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                      <p>Sin pagos registrados</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Tab Requerimientos -->
            <div v-if="tab === 'requerimientos'">
              <div v-if="loadingTab" class="text-center py-3">
                <span class="spinner-border spinner-border-sm"></span> Cargando...
              </div>
              <table v-else class="table table-sm table-hover">
                <thead class="table-light">
                  <tr>
                    <th>Folio</th>
                    <th>Fecha Emisión</th>
                    <th class="text-end">Importe Multa</th>
                    <th class="text-end">Importe Gastos</th>
                    <th class="text-end">Total</th>
                    <th>Vigencia</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(r, idx) in requerimientos" :key="idx">
                    <td><strong class="text-primary">{{ r.folio }}</strong></td>
                    <td>{{ r.fecha_emision }}</td>
                    <td class="text-end"><strong class="text-warning">{{ formatCurrency(r.importe_multa) }}</strong></td>
                    <td class="text-end"><strong class="text-info">{{ formatCurrency(r.importe_gastos) }}</strong></td>
                    <td class="text-end"><strong class="text-danger">{{ formatCurrency(parseFloat(r.importe_multa || 0) + parseFloat(r.importe_gastos || 0)) }}</strong></td>
                    <td>{{ r.vigencia }}</td>
                  </tr>
                  <tr v-if="requerimientos.length === 0">
                    <td colspan="6" class="text-center text-muted">
                      <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                      <p>Sin requerimientos registrados</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
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
import { ref, onMounted } from 'vue'
import axios from 'axios'

// Estado
const showFilters = ref(true)
const loading = ref(false)
const loadingLocales = ref(false)
const loadingTab = ref(false)
const showModal = ref(false)
const tab = ref('adeudos')

// Errores
const errorLocales = ref('')

// Estado de búsqueda
const searchPerformed = ref(false)
const selectedLocal = ref(null)

// Catálogos
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const categorias = ref([
  { id: 1, nombre: 'Categoría 1' },
  { id: 2, nombre: 'Categoría 2' },
  { id: 3, nombre: 'Categoría 3' }
])

// Formulario
const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})

// Datos
const locales = ref([])
const detalle = ref({})
const adeudos = ref([])
const pagos = ref([])
const requerimientos = ref([])

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Métodos de UI
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ingrese los datos del local para buscar su información general. Los campos marcados con (*) son obligatorios.')
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

// Lifecycle
onMounted(() => {
  cargarRecaudadoras()
  cargarSecciones()
})

const cargarRecaudadoras = async () => {
  loading.value = true
  errorLocales.value = ''
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
      errorLocales.value = res.data.eResponse?.message || 'Error al cargar recaudadoras'
      showToast('error', errorLocales.value)
    }
  } catch (err) {
    errorLocales.value = 'Error de conexión al cargar recaudadoras'
    console.error('Error al cargar recaudadoras:', err)
    showToast('error', errorLocales.value)
  } finally {
    loading.value = false
  }
}

const cargarMercados = async () => {
  mercados.value = []
  form.value.num_mercado = ''
  form.value.seccion = ''

  if (!form.value.oficina) return

  loading.value = true
  errorLocales.value = ''
  try {
    const nivelUsuario = 1 // TODO: Obtener del store de usuario
    const oficinaParam = form.value.oficina || null

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
        ]
      }
    })

    if (res.data.eResponse && res.data.eResponse.success === true) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast('success', `Se cargaron ${mercados.value.length} mercados`)
      } else {
        showToast('info', 'No se encontraron mercados para esta oficina')
      }
    } else {
      errorLocales.value = res.data.eResponse?.message || 'Error al cargar mercados'
      showToast('error', errorLocales.value)
    }
  } catch (err) {
    errorLocales.value = 'Error de conexión al cargar mercados'
    console.error('Error al cargar mercados:', err)
    showToast('error', errorLocales.value)
  } finally {
    loading.value = false
  }
}

const cargarSecciones = async () => {
  secciones.value = []
  form.value.seccion = ''

  loading.value = true
  errorLocales.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (res.data.eResponse && res.data.eResponse.success === true) {
      secciones.value = res.data.eResponse.data.result || []
      if (secciones.value.length > 0) {
        showToast('success', `Se cargaron ${secciones.value.length} secciones`)
      }
    } else {
      errorLocales.value = res.data.eResponse?.message || 'Error al cargar secciones'
      showToast('error', errorLocales.value)
    }
  } catch (error) {
    errorLocales.value = 'Error de conexión al cargar secciones'
    console.error('Error al cargar secciones:', error)
    showToast('error', errorLocales.value)
  } finally {
    loading.value = false
  }
}

const buscarLocal = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.seccion || !form.value.local) {
    errorLocales.value = 'Debe completar todos los campos obligatorios'
    showToast('warning', errorLocales.value)
    return
  }

  loading.value = true
  loadingLocales.value = true
  errorLocales.value = ''
  locales.value = []
  selectedLocal.value = null
  searchPerformed.value = true

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_general_buscar',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) || 1 },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: parseInt(form.value.local) },
          { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
          { Nombre: 'p_bloque', Valor: form.value.bloque || null }
        ]
      }
    })
    if (response.data.success && response.data.data) {
      locales.value = response.data.data
      if (locales.value.length === 0) {
        showToast('info', 'No se encontraron locales con los criterios especificados')
      } else {
        showToast('success', `Se encontraron ${locales.value.length} locales`)
        showFilters.value = false
      }
    } else {
      errorLocales.value = response.data.message || 'Error en la búsqueda'
      showToast('error', errorLocales.value)
    }
  } catch (error) {
    errorLocales.value = error.response?.data?.message || 'Error al buscar locales'
    console.error('Error al buscar locales:', error)
    showToast('error', errorLocales.value)
  } finally {
    loading.value = false
    loadingLocales.value = false
  }
}

const limpiarFiltros = () => {
  form.value.oficina = ''
  form.value.num_mercado = ''
  form.value.categoria = ''
  form.value.seccion = ''
  form.value.local = ''
  form.value.letra_local = ''
  form.value.bloque = ''
  mercados.value = []
  locales.value = []
  selectedLocal.value = null
  errorLocales.value = ''
  searchPerformed.value = false
  // Recargar secciones
  cargarSecciones()
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (locales.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('info', 'Funcionalidad de exportación en desarrollo')
}

const imprimir = () => {
  if (locales.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }
  // TODO: Implementar impresión
  showToast('info', 'Funcionalidad de impresión en desarrollo')
}

const verDetalle = async (local) => {
  detalle.value = local
  adeudos.value = []
  pagos.value = []
  requerimientos.value = []
  tab.value = 'adeudos'
  showModal.value = true

  // Cargar datos de los tabs
  await cargarDatosDetalle(local.id_local)
}

const cargarDatosDetalle = async (idLocal) => {
  loadingTab.value = true
  try {
    // Cargar adeudos
    const resAdeudos = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_general_adeudos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: idLocal }
        ]
      }
    })
    if (resAdeudos.data.success && resAdeudos.data.data) {
      adeudos.value = resAdeudos.data.data
    }

    // Cargar pagos
    const resPagos = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_general_pagos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: idLocal }
        ]
      }
    })
    if (resPagos.data.success && resPagos.data.data) {
      pagos.value = resPagos.data.data
    }

    // Cargar requerimientos
    const resReq = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_general_requerimientos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_local', Valor: idLocal }
        ]
      }
    })
    if (resReq.data.success && resReq.data.data) {
      requerimientos.value = resReq.data.data
    }
  } catch (error) {
    showToast('Error al cargar detalles', 'error')
  } finally {
    loadingTab.value = false
  }
}

const cerrarModal = () => {
  showModal.value = false
}
</script>

<style scoped>
/* Los estilos están definidos en municipal-theme.css */
/* Estilos adicionales específicos del componente si son necesarios */

/* Modal */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 50px;
  z-index: 1050;
  overflow-y: auto;
}

.modal-content {
  background: white;
  border-radius: 8px;
  max-width: 1100px;
  width: 95%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-xl {
  max-width: 1100px;
}

.municipal-modal-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 8px 8px 0 0;
}

.municipal-modal-header .modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Tabs personalizados */
.nav-tabs {
  border-bottom: 2px solid #dee2e6;
}

.nav-tabs .nav-link {
  cursor: pointer;
  color: #495057;
  border: none;
  border-bottom: 3px solid transparent;
  padding: 0.75rem 1.5rem;
  transition: all 0.3s ease;
}

.nav-tabs .nav-link:hover {
  color: #667eea;
  border-bottom-color: #667eea;
}

.nav-tabs .nav-link.active {
  font-weight: 600;
  color: #667eea;
  border-bottom-color: #667eea;
  background: transparent;
}

/* Estados empty */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.text-end {
  text-align: right;
}

.text-center {
  text-align: center;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

/* Filas de tabla */
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

.municipal-table td.text-center,
.municipal-table th.text-center {
  text-align: center;
}
</style>
