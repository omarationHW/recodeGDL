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
              <select class="municipal-form-control" v-model.number="formLocal.oficina" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group" style="flex: 0.7;">
              <label class="municipal-form-label">Mercado</label>
              <input type="number" class="municipal-form-control" v-model.number="formLocal.num_mercado" :disabled="loading" />
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
                <tr v-else v-for="row in resultados" :key="row.id_pago_energia" class="row-hover">
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

const showFilters = ref(true)
const searchType = ref('')
const recaudadoras = ref([])
const secciones = ref([])
const cajas = ref([])
const resultados = ref([])
const loading = ref(false)
const searchPerformed = ref(false)

const formLocal = ref({ oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '' })
const formFechaPago = ref({ fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '' })

const toast = ref({ show: false, type: 'info', message: '' })

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

  loading.value = true; resultados.value = []; searchPerformed.value = true
  try {
    const res = await axios.post('/api/generic', { eRequest: { Operacion: sp, Base: 'padron_licencias', Parametros: params } })
    if (res.data.eResponse?.success) {
      resultados.value = res.data.eResponse.data.result || []
      resultados.value.length > 0 ? (showToast('success', `${resultados.value.length} pagos encontrados`), showFilters.value = false) : showToast('info', 'No se encontraron pagos')
    } else showToast('error', res.data.eResponse?.message || 'Error')
  } catch { showToast('error', 'Error al buscar') }
  finally { loading.value = false }
}

const limpiar = () => {
  formLocal.value = { oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '' }
  formFechaPago.value = { fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '' }
  cajas.value = []; resultados.value = []; searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => resultados.value.length ? showToast('info', 'Exportación en desarrollo') : showToast('warning', 'No hay datos')

onMounted(() => { fetchRecaudadoras(); fetchSecciones() })
</script>

<style scoped>
.empty-icon { color: #ccc; margin-bottom: 1rem; }
.text-end { text-align: right; }
.spinner-border { width: 3rem; height: 3rem; }
.row-hover:hover { background-color: #f8f9fa; }
.required { color: #dc3545; }
.search-type-options { display: flex; gap: 1rem; }
.search-option { display: flex; align-items: center; cursor: pointer; padding: 0.75rem 1.25rem; border: 2px solid #dee2e6; border-radius: 8px; transition: all 0.2s; }
.search-option:hover { border-color: #6f42c1; background-color: #f8f9fa; }
.search-option.active { border-color: #6f42c1; background-color: #6f42c1; color: white; }
.search-option input { display: none; }
.search-option span { display: flex; align-items: center; gap: 0.5rem; font-weight: 500; }
.municipal-table td.text-end, .municipal-table th.text-end { text-align: right; }
</style>
