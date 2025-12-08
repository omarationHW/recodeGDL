<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Requerimientos</h1>
        <p>Inicio > Consultas > Requerimientos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel"
          :disabled="loading || requerimientos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="loading || requerimientos.length === 0">
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
          <form @submit.prevent="buscarLocales">
            <!-- Filtros en una sola fila -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select v-model="form.oficina" class="municipal-form-control" required @change="cargarMercados" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.recaudadora }}
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

      <!-- Tabla: Locales Encontrados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales Encontrados
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
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0 && !searchPerformed">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar locales</p>
                  </td>
                </tr>
                <tr v-else-if="locales.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="l in locales" :key="l.id_local"
                  @click="selectedLocal = l"
                  :class="{ 'table-row-selected': selectedLocal?.id_local === l.id_local }"
                  class="row-hover">
                  <td><strong class="text-primary">{{ l.id_local }}</strong></td>
                  <td>{{ l.oficina }}</td>
                  <td>{{ l.num_mercado }}</td>
                  <td>{{ l.categoria }}</td>
                  <td>{{ l.seccion }}</td>
                  <td><strong>{{ l.local }}</strong></td>
                  <td>{{ l.letra_local }}</td>
                  <td>{{ l.bloque }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm" @click.stop="seleccionarLocal(l)">
                      <font-awesome-icon icon="file-alt" />
                      Ver Requerimientos
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tabla: Requerimientos del Local -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="file-invoice" />
            Requerimientos del Local {{ selectedLocal?.id_local }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="requerimientos.length > 0">
              {{ formatNumber(requerimientos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingRequerimientos" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando requerimientos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="errorRequerimientos" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorRequerimientos }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Fecha Emisión</th>
                  <th>Vigencia</th>
                  <th>Diligencia</th>
                  <th>Practicado</th>
                  <th class="text-end">Importe Global</th>
                  <th class="text-end">Importe Multa</th>
                  <th class="text-end">Importe Recargo</th>
                  <th class="text-end">Importe Gastos</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="requerimientos.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron requerimientos para este local</p>
                  </td>
                </tr>
                <tr v-else v-for="r in requerimientos" :key="r.id_control"
                  @click="selectedReq = r"
                  :class="{ 'table-row-selected': selectedReq?.id_control === r.id_control }"
                  class="row-hover">
                  <td><strong class="text-primary">{{ r.folio }}</strong></td>
                  <td>{{ r.fecha_emision }}</td>
                  <td>{{ r.vigencia }}</td>
                  <td>{{ r.diligencia }}</td>
                  <td>{{ r.clave_practicado }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(r.importe_global) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(r.importe_multa) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(r.importe_recargo) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-info">{{ formatCurrency(r.importe_gastos) }}</strong>
                  </td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm" @click.stop="verPeriodos(r)">
                      <font-awesome-icon icon="calendar-alt" />
                      Ver Periodos
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tabla: Periodos del Requerimiento -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="calendar-check" />
            Periodos del Requerimiento - Folio: {{ selectedReq?.folio }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="periodos.length > 0">
              {{ formatNumber(periodos.length) }} periodos
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingPeriodos" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando periodos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="errorPeriodos" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorPeriodos }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="periodos.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron periodos para este requerimiento</p>
                  </td>
                </tr>
                <tr v-else v-for="(p, idx) in periodos" :key="idx" class="row-hover">
                  <td><strong>{{ p.axo }}</strong></td>
                  <td>{{ p.periodo }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(p.importe) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(p.recargos) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-primary">{{ formatCurrency(parseFloat(p.importe || 0) + parseFloat(p.recargos || 0)) }}</strong>
                  </td>
                </tr>
                <tr v-if="periodos.length > 0" class="table-footer-total">
                  <td colspan="2"><strong>TOTAL</strong></td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(totalPeriodos.importe) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(totalPeriodos.recargos) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-primary">{{ formatCurrency(totalPeriodos.total) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const loading = ref(false)
const loadingLocales = ref(false)
const loadingRequerimientos = ref(false)
const loadingPeriodos = ref(false)

// Errores
const errorLocales = ref('')
const errorRequerimientos = ref('')
const errorPeriodos = ref('')

// Estado de búsqueda
const searchPerformed = ref(false)

// Catálogos
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])

// Formulario
const form = ref({
  oficina: '',
  num_mercado: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})

// Datos
const locales = ref([])
const requerimientos = ref([])
const periodos = ref([])
const selectedLocal = ref(null)
const selectedReq = ref(null)

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
  showToast('info', 'Ingrese los datos del local para buscar sus requerimientos. Los campos marcados con (*) son obligatorios.')
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

const totalPeriodos = computed(() => {
  const importe = periodos.value.reduce((sum, p) => sum + parseFloat(p.importe || 0), 0)
  const recargos = periodos.value.reduce((sum, p) => sum + parseFloat(p.recargos || 0), 0)
  return { importe, recargos, total: importe + recargos }
})

// Lifecycle
onMounted(async () => {
  showLoading('Cargando Consulta de Requerimientos', 'Preparando catálogos del sistema...')
  try {
    await cargarRecaudadoras()
    await cargarSecciones()
  } finally {
    hideLoading()
  }
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

const buscarLocales = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.seccion || !form.value.local) {
    errorLocales.value = 'Debe completar todos los campos obligatorios'
    showToast('warning', errorLocales.value)
    return
  }

  loading.value = true
  loadingLocales.value = true
  errorLocales.value = ''
  locales.value = []
  requerimientos.value = []
  periodos.value = []
  selectedLocal.value = null
  selectedReq.value = null
  searchPerformed.value = true

  try {
    // Limpiar valores vacíos para enviar null - convertir cualquier string vacío o con solo espacios a null
    const letraLocal = (form.value.letra_local && form.value.letra_local.trim() !== '')
      ? form.value.letra_local.trim()
      : null
    const bloque = (form.value.bloque && form.value.bloque.trim() !== '')
      ? form.value.bloque.trim()
      : null

    const payload = {
      eRequest: {
        Operacion: 'sp_get_locales_by_mercado',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
          { Nombre: 'p_categoria', Valor: 1 },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_local', Valor: parseInt(form.value.local) },
          { Nombre: 'p_letra_local', Valor: letraLocal },
          { Nombre: 'p_bloque', Valor: bloque }
        ]
      }
    }

    console.log('=== DEBUG ConsRequerimientos.buscarLocales ===')
    console.log('Valores originales del formulario:', {
      letra_local: `"${form.value.letra_local}"`,
      bloque: `"${form.value.bloque}"`
    })
    console.log('Valores procesados:', {
      letra_local: letraLocal === null ? 'NULL' : `"${letraLocal}"`,
      bloque: bloque === null ? 'NULL' : `"${bloque}"`
    })
    console.log('Payload completo enviado al API:', JSON.stringify(payload, null, 2))

    const response = await axios.post('/api/generic', payload)

    console.log('Respuesta completa del API:', response.data)

    if (response.data.eResponse && response.data.eResponse.success === true) {
      locales.value = response.data.eResponse.data.result || []
      if (locales.value.length === 0) {
        showToast('info', 'No se encontraron locales con los criterios especificados')
      } else {
        showToast('success', `Se encontraron ${locales.value.length} locales`)
        showFilters.value = false
      }
    } else {
      errorLocales.value = response.data.eResponse?.message || 'Error en la búsqueda'
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

const seleccionarLocal = async (local) => {
  selectedLocal.value = local
  requerimientos.value = []
  periodos.value = []
  selectedReq.value = null

  loading.value = true
  loadingRequerimientos.value = true
  errorRequerimientos.value = ''

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_requerimientos_by_local',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_modulo', Valor: 11 },  // 11 = módulo de mercados
          { Nombre: 'p_control_otr', Valor: local.id_local }
        ]
      }
    })
    if (response.data.eResponse && response.data.eResponse.success === true) {
      requerimientos.value = response.data.eResponse.data.result || []
      if (requerimientos.value.length === 0) {
        showToast('info', 'No se encontraron requerimientos para este local')
      } else {
        showToast('success', `Se encontraron ${requerimientos.value.length} requerimientos`)
      }
    } else {
      errorRequerimientos.value = response.data.eResponse?.message || 'Error al obtener requerimientos'
      showToast('error', errorRequerimientos.value)
    }
  } catch (error) {
    errorRequerimientos.value = 'Error de conexión al cargar requerimientos'
    console.error('Error al cargar requerimientos:', error)
    showToast('error', errorRequerimientos.value)
  } finally {
    loading.value = false
    loadingRequerimientos.value = false
  }
}

const verPeriodos = async (requerimiento) => {
  selectedReq.value = requerimiento
  periodos.value = []

  loading.value = true
  loadingPeriodos.value = true
  errorPeriodos.value = ''

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_periodos_by_requerimiento',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_control_otr', Valor: requerimiento.control_otr }
        ]
      }
    })
    if (response.data.eResponse && response.data.eResponse.success === true) {
      periodos.value = response.data.eResponse.data.result || []
      if (periodos.value.length === 0) {
        showToast('info', 'No se encontraron periodos para este requerimiento')
      } else {
        showToast('success', `Se encontraron ${periodos.value.length} periodos`)
      }
    } else {
      errorPeriodos.value = response.data.eResponse?.message || 'Error al obtener periodos'
      showToast('error', errorPeriodos.value)
    }
  } catch (error) {
    errorPeriodos.value = 'Error de conexión al cargar periodos'
    console.error('Error al cargar periodos:', error)
    showToast('error', errorPeriodos.value)
  } finally {
    loading.value = false
    loadingPeriodos.value = false
  }
}

const limpiarFiltros = () => {
  form.value.oficina = ''
  form.value.num_mercado = ''
  form.value.seccion = ''
  form.value.local = ''
  form.value.letra_local = ''
  form.value.bloque = ''
  mercados.value = []
  locales.value = []
  requerimientos.value = []
  periodos.value = []
  selectedLocal.value = null
  selectedReq.value = null
  errorLocales.value = ''
  errorRequerimientos.value = ''
  errorPeriodos.value = ''
  searchPerformed.value = false
  // Recargar secciones
  cargarSecciones()
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (requerimientos.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('info', 'Funcionalidad de exportación en desarrollo')
}

const imprimir = () => {
  if (requerimientos.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }
  // TODO: Implementar impresión
  showToast('info', 'Funcionalidad de impresión en desarrollo')
}
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

.text-center {
  text-align: center;
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

.municipal-table td.text-center,
.municipal-table th.text-center {
  text-align: center;
}

/* Estilo para fila de totales */
.table-footer-total {
  background-color: #f8f9fa;
  font-weight: bold;
  border-top: 2px solid #dee2e6;
}

.table-footer-total td {
  padding: 0.75rem;
}
</style>
