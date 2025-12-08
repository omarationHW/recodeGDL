<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos de Energía</h1>
        <p>Inicio > Mercados > Consulta Pagos Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || resultados.length === 0">
          <font-awesome-icon icon="file-excel" /> Excel
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" /> Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="search-type-options mb-3">
            <label class="search-option" :class="{ active: searchType === 'local' }">
              <input type="radio" value="local" v-model="searchType" @change="onSearchTypeChange">
              <span><font-awesome-icon icon="store" /> Por Local</span>
            </label>
            <label class="search-option" :class="{ active: searchType === 'fecha_pago' }">
              <input type="radio" value="fecha_pago" v-model="searchType" @change="onSearchTypeChange">
              <span><font-awesome-icon icon="calendar-alt" /> Por Fecha de Pago</span>
            </label>
          </div>

          <div v-if="searchType === 'local'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="formLocal.oficina" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group" style="flex: 0.7;">
              <label class="municipal-form-label">Mercado</label>
              <select class="municipal-form-control" v-model.number="formLocal.num_mercado" :disabled="loading || !formLocal.oficina">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Cat.</label>
              <input type="number" class="municipal-form-control" v-model.number="formLocal.categoria" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección</label>
              <select class="municipal-form-control" v-model="formLocal.seccion" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Local <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="formLocal.local" :disabled="loading" />
            </div>
            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="formLocal.letra_local" maxlength="1" :disabled="loading" />
            </div>
            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="formLocal.bloque" maxlength="1" :disabled="loading" />
            </div>
          </div>

          <div v-if="searchType === 'fecha_pago'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="formFechaPago.fecha_pago" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Oficina <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="formFechaPago.oficina_pago" @change="onOficinaPagoChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Caja</label>
              <select class="municipal-form-control" v-model="formFechaPago.caja_pago" :disabled="loading || cajas.length === 0">
                <option value="">Todas</option>
                <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Operación</label>
              <input type="number" class="municipal-form-control" v-model.number="formFechaPago.operacion_pago" :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading || !searchType">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="table" /> Pagos de Energía</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="resultados.length > 0">{{ formatNumber(resultados.length) }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">Buscando pagos de energía...</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th><th>Rec.</th><th>Merc.</th><th>Cat.</th><th>Sec.</th>
                  <th>Local</th><th>Letra</th><th>Bloque</th><th>Año</th><th>Mes</th>
                  <th>Fecha Pago</th><th>Ofc. Pago</th><th>Caja</th><th>Oper.</th>
                  <th class="text-end">Importe</th><th>Folio</th><th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="resultados.length === 0 && !searchPerformed">
                  <td colspan="17" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione una opción de búsqueda y los filtros</p>
                  </td>
                </tr>
                <tr v-else-if="resultados.length === 0">
                  <td colspan="17" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos de energía</p>
                  </td>
                </tr>
                <tr v-else v-for="row in paginatedResultados" :key="row.id_pago_energia" class="row-hover">
                  <td>{{ row.id_local }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ formatDate(row.fecha_pago) }}</td>
                  <td>{{ row.oficina_pago }}</td>
                  <td>{{ row.caja_pago }}</td>
                  <td>{{ row.operacion_pago }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(row.importe_pago) }}</strong></td>
                  <td>{{ row.folio }}</td>
                  <td>{{ row.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="resultados.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ paginationStart }} a {{ paginationEnd }} de {{ totalItems }} registros
            </div>
            <div class="pagination-controls">
              <label class="me-2">Registros por página:</label>
              <select v-model.number="itemsPerPage" class="form-select form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="prevPage" :disabled="currentPage === 1">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span>Página {{ currentPage }} de {{ totalPages }}</span>
              <button @click="nextPage" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import axios from 'axios'

const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchType = ref('')
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const cajas = ref([])
const resultados = ref([])
const loading = ref(false)
const searchPerformed = ref(false)

const formLocal = ref({ oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '' })
const formFechaPago = ref({ fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '' })

const toast = ref({ show: false, type: 'info', message: '' })

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return resultados.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(resultados.value.length / itemsPerPage.value)
})

const paginationStart = computed(() => {
  return resultados.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > resultados.value.length ? resultados.value.length : end
})

const totalItems = computed(() => resultados.value.length)

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

watch(resultados, () => {
  currentPage.value = 1
})

const toggleFilters = () => { showFilters.value = !showFilters.value }
const mostrarAyuda = () => { showToast('info', 'Ayuda: Busque pagos de energía por local o por fecha de pago') }
const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}
const hideToast = () => { toast.value.show = false }
const getToastIcon = (type) => ({ success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }[type] || 'info-circle')

const formatCurrency = (val) => val ? '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 }) : '$0.00'
const formatDate = (val) => val ? new Date(val).toLocaleDateString('es-MX') : ''
const formatNumber = (num) => new Intl.NumberFormat('es-MX').format(num)

const fetchRecaudadoras = async () => {
  try {
    const res = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'padron_licencias', Parametros: [] } })
    if (res.data.eResponse?.success) recaudadoras.value = res.data.eResponse.data.result || []
  } catch { showToast('error', 'Error al cargar recaudadoras') }
}

const fetchSecciones = async () => {
  try {
    const res = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_secciones', Base: 'padron_licencias', Parametros: [] } })
    if (res.data.eResponse?.success) secciones.value = res.data.eResponse.data.result || []
  } catch { showToast('error', 'Error al cargar secciones') }
}

const onOficinaChange = async () => {
  mercados.value = []
  formLocal.value.num_mercado = ''
  if (!formLocal.value.oficina) return
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_consulta_locales_get_mercados', Base: 'padron_licencias', Parametros: [{ Nombre: 'p_oficina', Valor: formLocal.value.oficina }] }
    })
    if (res.data.eResponse?.success) mercados.value = res.data.eResponse.data.result || []
  } catch { showToast('error', 'Error al cargar mercados') }
}

const onOficinaPagoChange = async () => {
  cajas.value = []
  formFechaPago.value.caja_pago = ''
  if (!formFechaPago.value.oficina_pago) return
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_cajas_energia', Base: 'padron_licencias', Parametros: [{ Nombre: 'p_oficina', Valor: formFechaPago.value.oficina_pago }] }
    })
    if (res.data.eResponse?.success) cajas.value = res.data.eResponse.data.result || []
  } catch { showToast('error', 'Error al cargar cajas') }
}

const onSearchTypeChange = () => { resultados.value = []; searchPerformed.value = false }

const buscar = async () => {
  if (!searchType.value) { showToast('warning', 'Seleccione tipo de búsqueda'); return }

  let sp = '', params = []
  if (searchType.value === 'local') {
    if (!formLocal.value.oficina || !formLocal.value.local) { showToast('warning', 'Complete recaudadora y local'); return }
    sp = 'sp_cons_pagos_energia_por_local'
    params = [
      { Nombre: 'p_oficina', Valor: formLocal.value.oficina },
      { Nombre: 'p_num_mercado', Valor: formLocal.value.num_mercado || null },
      { Nombre: 'p_categoria', Valor: formLocal.value.categoria || null },
      { Nombre: 'p_seccion', Valor: formLocal.value.seccion || null },
      { Nombre: 'p_local', Valor: formLocal.value.local },
      { Nombre: 'p_letra_local', Valor: formLocal.value.letra_local || null },
      { Nombre: 'p_bloque', Valor: formLocal.value.bloque || null }
    ]
  } else {
    if (!formFechaPago.value.fecha_pago || !formFechaPago.value.oficina_pago) { showToast('warning', 'Complete fecha y oficina'); return }
    sp = 'sp_cons_pagos_energia_por_fecha'
    params = [
      { Nombre: 'p_fecha_pago', Valor: formFechaPago.value.fecha_pago },
      { Nombre: 'p_oficina_pago', Valor: formFechaPago.value.oficina_pago },
      { Nombre: 'p_caja_pago', Valor: formFechaPago.value.caja_pago || null },
      { Nombre: 'p_operacion_pago', Valor: formFechaPago.value.operacion_pago || null }
    ]
  }

  showLoading('Consultando pagos de energía...', 'Por favor espere')
  loading.value = true; resultados.value = []; searchPerformed.value = true
  try {
    const res = await axios.post('/api/generic', { eRequest: { Operacion: sp, Base: 'padron_licencias', Parametros: params } })
    if (res.data.eResponse?.success) {
      resultados.value = res.data.eResponse.data.result || []
      resultados.value.length > 0 ? (showToast('success', `${resultados.value.length} pagos encontrados`), showFilters.value = false) : showToast('info', 'No se encontraron pagos')
    } else showToast('error', res.data.eResponse?.message || 'Error')
  } catch { showToast('error', 'Error al buscar') }
  finally {
    loading.value = false
    hideLoading()
  }
}

const limpiar = () => {
  formLocal.value = { oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '' }
  formFechaPago.value = { fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '' }
  cajas.value = []; resultados.value = []; searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => resultados.value.length ? showToast('info', 'Exportación en desarrollo') : showToast('warning', 'No hay datos')

onMounted(async () => {
  showLoading('Cargando Consulta de Pagos de Energía', 'Preparando catálogos...')
  try {
    await fetchRecaudadoras()
    await fetchSecciones()
  } finally {
    hideLoading()
  }
})
</script>
