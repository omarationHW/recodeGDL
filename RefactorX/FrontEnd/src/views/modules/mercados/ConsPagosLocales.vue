<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-check-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos del Local</h1>
        <p>Inicio > Mercados > Consulta Pagos Locales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || pagos.length === 0">
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
            <label class="search-option" :class="{ active: opcion === 'L' }">
              <input type="radio" value="L" v-model="opcion" @change="onOpcionChange">
              <span><font-awesome-icon icon="store" /> Por Local</span>
            </label>
            <label class="search-option" :class="{ active: opcion === 'F' }">
              <input type="radio" value="F" v-model="opcion" @change="onOpcionChange">
              <span><font-awesome-icon icon="calendar-alt" /> Por Fecha de Pago</span>
            </label>
          </div>

          <div v-if="opcion === 'L'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.oficina" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.num_mercado" @change="onMercadoChange" :disabled="loading || mercados.length === 0">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Cat.</label>
              <input type="number" class="municipal-form-control" v-model.number="form.categoria" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="form.seccion" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Local <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.local" :disabled="loading" />
            </div>
            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="form.letra_local" maxlength="1" :disabled="loading" />
            </div>
            <div class="form-group" style="flex: 0.5;">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="form.bloque" maxlength="1" :disabled="loading" />
            </div>
          </div>

          <div v-if="opcion === 'F'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_pago" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Oficina <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.oficina_pago" @change="onOficinaPagoChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Caja</label>
              <select class="municipal-form-control" v-model="form.caja_pago" :disabled="loading || cajas.length === 0">
                <option value="">Todas</option>
                <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Operación</label>
              <input type="number" class="municipal-form-control" v-model.number="form.operacion_pago" :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscarPagos" :disabled="loading || !opcion">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="table" /> Pagos Encontrados</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="pagos.length > 0">{{ formatNumber(pagos.length) }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-3 text-muted">Buscando pagos...</p>
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
                <tr v-if="pagos.length === 0 && !searchPerformed">
                  <td colspan="17" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione una opción de búsqueda y los filtros</p>
                  </td>
                </tr>
                <tr v-else-if="pagos.length === 0">
                  <td colspan="17" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos</p>
                  </td>
                </tr>
                <tr v-else v-for="row in pagos" :key="row.id_pago_local" class="row-hover">
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
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const opcion = ref('')
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const cajas = ref([])
const pagos = ref([])
const loading = ref(false)
const searchPerformed = ref(false)

const form = ref({
  oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '',
  fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: ''
})

const toast = ref({ show: false, type: 'info', message: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const mostrarAyuda = () => { showToast('Ayuda: Busque pagos por local o por fecha de pago', 'info') }
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
  if (val === null || val === undefined) return '$0.00'
  return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
const formatDate = (val) => val ? new Date(val).toLocaleDateString('es-MX') : ''
const formatNumber = (num) => new Intl.NumberFormat('es-MX').format(num)

const fetchRecaudadoras = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'padron_licencias', Parametros: [] }
    })
    if (res.data.eResponse?.success) recaudadoras.value = res.data.eResponse.data.result || []
  } catch { showToast('Error al cargar recaudadoras', 'error') }
}

const fetchSecciones = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_secciones', Base: 'padron_licencias', Parametros: [] }
    })
    if (res.data.eResponse?.success) secciones.value = res.data.eResponse.data.result || []
  } catch { showToast('Error al cargar secciones', 'error') }
}

const onOficinaChange = async () => {
  form.value.num_mercado = ''
  form.value.categoria = ''
  mercados.value = []
  if (!form.value.oficina) return
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados', Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: form.value.oficina },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: 1 }
        ]
      }
    })
    if (res.data.eResponse?.success) mercados.value = res.data.eResponse.data.result || []
  } catch { showToast('Error al cargar mercados', 'error') }
}

const onMercadoChange = () => {
  const selected = mercados.value.find(m => m.num_mercado_nvo === form.value.num_mercado)
  if (selected) form.value.categoria = selected.categoria
}

const onOficinaPagoChange = async () => {
  cajas.value = []
  form.value.caja_pago = ''
  if (!form.value.oficina_pago) return
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_cajas', Base: 'padron_licencias',
        Parametros: [{ Nombre: 'p_oficina', Valor: form.value.oficina_pago }]
      }
    })
    if (res.data.eResponse?.success) cajas.value = res.data.eResponse.data.result || []
  } catch { showToast('Error al cargar cajas', 'error') }
}

const onOpcionChange = () => {
  pagos.value = []
  searchPerformed.value = false
}

const buscarPagos = async () => {
  if (!opcion.value) {
    showToast('Seleccione una opción de búsqueda', 'warning')
    return
  }

  let sp = '', params = []
  if (opcion.value === 'L') {
    if (!form.value.oficina || !form.value.num_mercado || !form.value.seccion || !form.value.local) {
      showToast('Complete los campos requeridos', 'warning')
      return
    }
    sp = 'sp_cons_pagos_locales_por_local'
    params = [
      { Nombre: 'p_oficina', Valor: form.value.oficina },
      { Nombre: 'p_num_mercado', Valor: form.value.num_mercado },
      { Nombre: 'p_categoria', Valor: form.value.categoria || 1 },
      { Nombre: 'p_seccion', Valor: form.value.seccion },
      { Nombre: 'p_local', Valor: form.value.local },
      { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
      { Nombre: 'p_bloque', Valor: form.value.bloque || null }
    ]
  } else {
    if (!form.value.fecha_pago || !form.value.oficina_pago) {
      showToast('Complete los campos requeridos', 'warning')
      return
    }
    sp = 'sp_cons_pagos_locales_por_fecha'
    params = [
      { Nombre: 'p_fecha_pago', Valor: form.value.fecha_pago },
      { Nombre: 'p_oficina_pago', Valor: form.value.oficina_pago },
      { Nombre: 'p_caja_pago', Valor: form.value.caja_pago || null },
      { Nombre: 'p_operacion_pago', Valor: form.value.operacion_pago || null }
    ]
  }

  loading.value = true
  pagos.value = []
  searchPerformed.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: sp, Base: 'padron_licencias', Parametros: params }
    })
    if (res.data.eResponse?.success) {
      pagos.value = res.data.eResponse.data.result || []
      if (pagos.value.length > 0) {
        showToast(`Se encontraron ${pagos.value.length} pagos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron pagos', 'info')
      }
    } else {
      showToast(res.data.eResponse?.message || 'Error en la consulta', 'error')
    }
  } catch { showToast('Error al buscar pagos', 'error') }
  finally { loading.value = false }
}

const limpiarFiltros = () => {
  form.value = {
    oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '',
    fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: ''
  }
  mercados.value = []
  cajas.value = []
  pagos.value = []
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (pagos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

onMounted(async () => {
  showLoading('Cargando Consulta de Pagos de Locales', 'Preparando catálogos...')
  try {
    await fetchRecaudadoras()
    await fetchSecciones()
  } finally {
    hideLoading()
  }
})
</script>

<style scoped>
.empty-icon { color: #ccc; margin-bottom: 1rem; }
.text-end { text-align: right; }
.spinner-border { width: 3rem; height: 3rem; }
.row-hover:hover { background-color: #f8f9fa; }
.required { color: #dc3545; }
.search-type-options { display: flex; gap: 1rem; }
.search-option {
  display: flex; align-items: center; cursor: pointer; padding: 0.75rem 1.25rem;
  border: 2px solid #dee2e6; border-radius: 8px; transition: all 0.2s;
}
.search-option:hover { border-color: #6f42c1; background-color: #f8f9fa; }
.search-option.active { border-color: #6f42c1; background-color: #6f42c1; color: white; }
.search-option input { display: none; }
.search-option span { display: flex; align-items: center; gap: 0.5rem; font-weight: 500; }
.municipal-table td.text-end, .municipal-table th.text-end { text-align: right; }
</style>
