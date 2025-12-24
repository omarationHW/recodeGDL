<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="clipboard-list" /></div>
      <div class="module-view-info">
        <h1>Solicitud de Reporte de Folios</h1>
        <p>Consulta de folios por estado y rango de fechas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Filtros -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Parametros del Reporte</h3>
            <span class="section-subtitle">Configure los filtros para generar el reporte</span>
          </div>
        </div>
        <div class="section-body">
          <div class="form-grid cols-4">
            <div class="form-field" v-if="opc !== 6">
              <label class="municipal-form-label">Clave Infraccion</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="hashtag" /></span>
                <select class="municipal-form-control with-icon" v-model.number="cveinf" :disabled="loadingInfracciones">
                  <option :value="0">00 - Todas</option>
                  <option v-for="inf in infracciones" :key="inf.num_clave" :value="inf.num_clave">
                    {{ String(inf.num_clave).padStart(2, '0') }} - {{ inf.descripcion }}
                  </option>
                </select>
              </div>
              <small class="field-hint">Seleccione una infraccion o "Todas"</small>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Tipo de Reporte <span class="required">*</span></label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="list-check" /></span>
                <select class="municipal-form-control with-icon" v-model.number="opc" @change="onTipoReporteChange">
                  <option :value="1">01 - Folios de Adeudos</option>
                  <option :value="2">02 - Folios Pagados</option>
                  <option :value="3">03 - Folios Cancelados</option>
                  <option :value="4">04 - Folios Condonados</option>
                  <option :value="5">05 - Folios Cancelados y Condonados</option>
                  <option :value="6">06 - Relacion de Descuentos Otorgados</option>
                </select>
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Fecha Inicio <span class="required">*</span></label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar" /></span>
                <input type="date" class="municipal-form-control with-icon" v-model="fec_ini" />
              </div>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Fecha Fin <span class="required">*</span></label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="calendar-check" /></span>
                <input type="date" class="municipal-form-control with-icon" v-model="fec_fin" />
              </div>
            </div>
          </div>

          <div class="action-row">
            <button class="btn-municipal-primary" :disabled="loading" @click="ejecutar">
              <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" /> Ejecutar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>

          <div class="info-notice">
            <font-awesome-icon icon="info-circle" class="notice-icon" />
            <span>El rango maximo permitido es de 31 dias para optimizar el rendimiento de la consulta.</span>
          </div>
        </div>
      </div>

      <!-- Seccion de Resultados -->
      <div class="form-section">
        <div class="section-header header-with-badge" :class="getHeaderClass()">
          <div class="section-icon"><font-awesome-icon icon="table" /></div>
          <div class="section-title-group">
            <h3>Resultados del Reporte</h3>
            <span class="section-subtitle">
              <span v-if="rows.length > 0">{{ rows.length }} folio(s) encontrado(s) - {{ getOpcionLabel() }}</span>
              <span v-else>Esperando consulta</span>
            </span>
          </div>
          <div class="section-actions" v-if="rows.length > 0">
            <button class="btn-export" @click="exportarCSV">
              <font-awesome-icon icon="file-csv" /> Exportar CSV
            </button>
          </div>
        </div>
        <div class="section-body">
          <!-- Tabla de resultados - Opciones 1-5 -->
          <div v-if="rows.length > 0 && opc !== 6" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-if="opc !== 1"><font-awesome-icon icon="info-circle" class="th-icon" /> Descripcion</th>
                  <th v-if="opc !== 1"><font-awesome-icon icon="calendar" class="th-icon" /> Fec.Movto</th>
                  <th class="text-center"><font-awesome-icon icon="calendar-alt" class="th-icon" /> Ano</th>
                  <th class="text-center"><font-awesome-icon icon="file-alt" class="th-icon" /> Folio</th>
                  <th><font-awesome-icon icon="car" class="th-icon" /> Placa</th>
                  <th><font-awesome-icon icon="calendar-day" class="th-icon" /> Fec.Folio</th>
                  <th class="text-end"><font-awesome-icon icon="dollar-sign" class="th-icon" /> Tarifa</th>
                  <th v-if="opc === 2" class="text-center"><font-awesome-icon icon="percent" class="th-icon" /> %Dcto</th>
                  <th v-if="opc === 2" class="text-end"><font-awesome-icon icon="tag" class="th-icon" /> Descuento</th>
                  <th v-if="opc === 2" class="text-end"><font-awesome-icon icon="coins" class="th-icon" /> Pago</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx">
                  <td v-if="opc !== 1">{{ r.descrip || '—' }}</td>
                  <td v-if="opc !== 1">{{ formatDate(r.fecha_movto) }}</td>
                  <td class="text-center"><span class="year-badge">{{ r.axo }}</span></td>
                  <td class="text-center"><strong class="folio-number">{{ r.folio }}</strong></td>
                  <td><code class="placa-code">{{ r.placa || '—' }}</code></td>
                  <td>{{ formatDate(r.fecha_folio) }}</td>
                  <td class="text-end"><strong>{{ formatMoney(r.tarifa) }}</strong></td>
                  <td v-if="opc === 2" class="text-center"><span class="badge-porc">{{ r.porc }}%</span></td>
                  <td v-if="opc === 2" class="text-end text-danger">{{ formatMoney(r.dscto) }}</td>
                  <td v-if="opc === 2" class="text-end text-success"><strong>{{ formatMoney(r.pago) }}</strong></td>
                </tr>
              </tbody>
              <tfoot v-if="rows.length > 0">
                <tr class="totals-row">
                  <td :colspan="opc === 1 ? 5 : (opc === 2 ? 6 : 6)" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong class="total-amount">{{ formatMoney(totalTarifa) }}</strong></td>
                  <td v-if="opc === 2"></td>
                  <td v-if="opc === 2" class="text-end text-danger"><strong>{{ formatMoney(totalDscto) }}</strong></td>
                  <td v-if="opc === 2" class="text-end text-success"><strong>{{ formatMoney(totalPago) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Tabla de resultados - Opcion 6: Descuentos Otorgados -->
          <div v-if="rows.length > 0 && opc === 6" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th><font-awesome-icon icon="car" class="th-icon" /> Placa</th>
                  <th class="text-center"><font-awesome-icon icon="calendar-alt" class="th-icon" /> Ano</th>
                  <th class="text-center"><font-awesome-icon icon="file-alt" class="th-icon" /> Folio</th>
                  <th class="text-center"><font-awesome-icon icon="hashtag" class="th-icon" /> Clave</th>
                  <th><font-awesome-icon icon="calendar-day" class="th-icon" /> Fec.Folio</th>
                  <th class="text-end"><font-awesome-icon icon="dollar-sign" class="th-icon" /> Tarifa</th>
                  <th class="text-center"><font-awesome-icon icon="percent" class="th-icon" /> %Dcto</th>
                  <th class="text-end"><font-awesome-icon icon="coins" class="th-icon" /> A Pagar</th>
                  <th><font-awesome-icon icon="building" class="th-icon" /> Autoridad</th>
                  <th><font-awesome-icon icon="user" class="th-icon" /> Otorgo</th>
                  <th><font-awesome-icon icon="calendar-check" class="th-icon" /> Fec.Otorga</th>
                  <th><font-awesome-icon icon="calendar" class="th-icon" /> Fec.Pago</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx">
                  <td><code class="placa-code">{{ r.placa || '—' }}</code></td>
                  <td class="text-center"><span class="year-badge">{{ r.axo }}</span></td>
                  <td class="text-center"><strong class="folio-number">{{ r.folio }}</strong></td>
                  <td class="text-center">{{ r.clave }}</td>
                  <td>{{ formatDate(r.fecha_folio) }}</td>
                  <td class="text-end"><strong>{{ formatMoney(r.tarifa) }}</strong></td>
                  <td class="text-center"><span class="badge-porc">{{ r.porc }}%</span></td>
                  <td class="text-end text-success"><strong>{{ formatMoney(r.apagar) }}</strong></td>
                  <td class="text-truncate" style="max-width: 150px;" :title="r.autoridad_otorga">{{ r.autoridad_otorga || '—' }}</td>
                  <td>{{ r.nombre_otorgo || '—' }}</td>
                  <td>{{ formatDate(r.fecha_otorga) }}</td>
                  <td>{{ formatDate(r.fecha_pago) }}</td>
                </tr>
              </tbody>
              <tfoot v-if="rows.length > 0">
                <tr class="totals-row">
                  <td colspan="5" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong class="total-amount">{{ formatMoney(totalTarifa) }}</strong></td>
                  <td></td>
                  <td class="text-end text-success"><strong>{{ formatMoney(totalApagar) }}</strong></td>
                  <td colspan="4"></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Estado vacio -->
          <div v-if="rows.length === 0" class="empty-state-panel">
            <div class="empty-icon-container empty-state-icon">
              <font-awesome-icon icon="clipboard-list" size="3x" />
            </div>
            <h4>Solicitud de Reporte de Folios</h4>
            <p>Configure los parametros y presione "Ejecutar Reporte" para consultar</p>
          </div>

          <!-- Paginacion -->
          <div class="pagination-footer" v-if="rows.length > pageSize">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * pageSize) + 1 }} a {{ Math.min(currentPage * pageSize, rows.length) }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="currentPage = 1" :disabled="currentPage === 1">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Pagina {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage = totalPages" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label>Por pagina:</label>
              <select class="municipal-form-control" v-model.number="pageSize" @change="currentPage = 1">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'SolicRepFoliosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Solicitud de Reporte de Folios'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const cveinf = ref(0)
const opc = ref(1)
const fec_ini = ref('')
const fec_fin = ref('')
const rows = ref([])
const infracciones = ref([])
const loadingInfracciones = ref(false)

// Paginacion
const currentPage = ref(1)
const pageSize = ref(10)

const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value) || 1)

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return rows.value.slice(start, end)
})

const totalTarifa = computed(() => {
  return rows.value.reduce((sum, r) => sum + (Number(r.tarifa) || 0), 0)
})

const totalDscto = computed(() => {
  return rows.value.reduce((sum, r) => sum + (Number(r.dscto) || 0), 0)
})

const totalPago = computed(() => {
  return rows.value.reduce((sum, r) => sum + (Number(r.pago) || 0), 0)
})

const totalApagar = computed(() => {
  return rows.value.reduce((sum, r) => sum + (Number(r.apagar) || 0), 0)
})

function formatDate(d) {
  if (!d) return '—'
  const dt = new Date(d)
  return dt.toLocaleDateString('es-MX')
}

function formatMoney(n) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n) || 0)
}

function getOpcionLabel() {
  const labels = {
    1: 'Adeudos',
    2: 'Pagados',
    3: 'Cancelados',
    4: 'Condonados',
    5: 'Cancelados y Condonados',
    6: 'Descuentos Otorgados'
  }
  return labels[opc.value] || ''
}

function getHeaderClass() {
  const classes = {
    1: 'section-header-warning',
    2: 'section-header-success',
    3: 'section-header-danger',
    4: 'section-header-info',
    5: 'section-header-help',
    6: 'section-header-purple'
  }
  return classes[opc.value] || 'section-header-info'
}

function onTipoReporteChange() {
  rows.value = []
  currentPage.value = 1
}

async function cargarInfracciones() {
  loadingInfracciones.value = true
  try {
    const response = await execute('sp_get_infracciones', BASE_DB, [], '', null, SCHEMA)
    const data = response?.result || response?.data?.result || response?.data || []
    if (Array.isArray(data)) {
      infracciones.value = data
    }
  } catch (e) {
    console.error('Error cargando infracciones:', e)
  } finally {
    loadingInfracciones.value = false
  }
}

function limpiar() {
  cveinf.value = 0
  opc.value = 1
  fec_ini.value = ''
  fec_fin.value = ''
  rows.value = []
  currentPage.value = 1
}

function exportarCSV() {
  if (rows.value.length === 0) return

  let headers = []
  const csvRows = []

  if (opc.value === 6) {
    // Opcion 6: Descuentos Otorgados
    headers = ['Placa', 'Ano', 'Folio', 'Clave', 'Fecha_Folio', 'Tarifa', 'Porc_Dcto', 'A_Pagar', 'Autoridad', 'Otorgo', 'Fecha_Otorga', 'Fecha_Pago']
    csvRows.push(headers.join(','))
    rows.value.forEach(r => {
      csvRows.push([
        r.placa || '',
        r.axo || '',
        r.folio || '',
        r.clave || '',
        r.fecha_folio || '',
        r.tarifa || 0,
        r.porc || 0,
        r.apagar || 0,
        `"${(r.autoridad_otorga || '').replace(/"/g, '""')}"`,
        r.nombre_otorgo || '',
        r.fecha_otorga || '',
        r.fecha_pago || ''
      ].join(','))
    })
  } else {
    // Opciones 1-5
    headers = ['Ano', 'Folio', 'Placa', 'Fecha_Folio', 'Tarifa']
    if (opc.value !== 1) {
      headers = ['Descripcion', 'Fecha_Movto', ...headers]
    }
    if (opc.value === 2) {
      headers.push('Porc_Dcto', 'Descuento', 'Pago')
    }
    csvRows.push(headers.join(','))

    rows.value.forEach(r => {
      let row = [r.axo || '', r.folio || '', r.placa || '', r.fecha_folio || '', r.tarifa || 0]
      if (opc.value !== 1) {
        row = [`"${(r.descrip || '').replace(/"/g, '""')}"`, r.fecha_movto || '', ...row]
      }
      if (opc.value === 2) {
        row.push(r.porc || 0, r.dscto || 0, r.pago || 0)
      }
      csvRows.push(row.join(','))
    })
  }

  const blob = new Blob(['\uFEFF' + csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `reporte_folios_${getOpcionLabel().replace(/ /g, '_')}_${new Date().toISOString().slice(0,10)}.csv`
  a.click()
  URL.revokeObjectURL(url)
  showToast('success', 'Archivo CSV exportado correctamente')
}

async function ejecutar() {
  if (!fec_ini.value || !fec_fin.value) {
    showToast('warning', 'Ingrese las fechas de inicio y fin')
    return
  }

  if (new Date(fec_ini.value) > new Date(fec_fin.value)) {
    showToast('warning', 'La fecha inicial debe ser menor o igual a la fecha final')
    return
  }

  const diffDays = Math.ceil((new Date(fec_fin.value) - new Date(fec_ini.value)) / (1000 * 60 * 60 * 24))
  if (diffDays > 31) {
    showToast('warning', 'El rango maximo permitido es de 31 dias')
    return
  }

  showLoading('Consultando...', 'Generando reporte de folios')
  rows.value = []
  currentPage.value = 1

  try {
    let response
    let data

    // Opcion 6: Descuentos Otorgados (SP diferente)
    if (opc.value === 6) {
      response = await execute('sp_solicrep_descuentos', BASE_DB, [
        { nombre: 'p_fec_ini', valor: fec_ini.value, tipo: 'date' },
        { nombre: 'p_fec_fin', valor: fec_fin.value, tipo: 'date' }
      ], '', null, SCHEMA)

      data = response?.result || response?.data?.result || response?.data || []
      if (Array.isArray(data)) {
        data.forEach(r => {
          rows.value.push({
            placa: r.placa,
            axo: r.axo,
            folio: r.folio,
            clave: r.clave,
            fecha_folio: r.fecha_folio,
            tarifa: Number(r.tarifa) || 0,
            porc: Number(r.porc) || 0,
            apagar: Number(r.apagar) || 0,
            autoridad_otorga: r.autoridad_otorga,
            nombre_otorgo: r.nombre_otorgo,
            fecha_otorga: r.fecha_otorga,
            fecha_pago: r.fecha_pago
          })
        })
      }
    } else {
      // Opciones 1-5: Reporte de folios
      response = await execute('sp_solicrep_folios', BASE_DB, [
        { nombre: 'p_cveinf', valor: cveinf.value, tipo: 'integer' },
        { nombre: 'p_opc', valor: opc.value, tipo: 'integer' },
        { nombre: 'p_fec_ini', valor: fec_ini.value, tipo: 'date' },
        { nombre: 'p_fec_fin', valor: fec_fin.value, tipo: 'date' }
      ], '', null, SCHEMA)

      data = response?.result || response?.data?.result || response?.data || []
      if (Array.isArray(data)) {
        data.forEach(r => {
          rows.value.push({
            descrip: r.descrip,
            fecha_movto: r.fecha_movto,
            axo: r.axo,
            folio: r.folio,
            fecha_folio: r.fecha_folio,
            placa: r.placa,
            fecha_captura: r.fecha_captura,
            porc: Number(r.porc) || 0,
            tarifa: Number(r.tarifa) || 0,
            dscto: Number(r.dscto) || 0,
            pago: Number(r.pago) || 0,
            infraccion: r.infraccion
          })
        })
      }
    }

    if (rows.value.length > 0) {
      showToast('success', `Se encontraron ${rows.value.length} registro(s)`)
    } else {
      showToast('info', 'No se encontraron registros en el rango especificado')
    }
  } catch (e) {
    handleApiError(e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Inicializacion
onMounted(() => {
  cargarInfracciones()
  // Establecer fechas por defecto (hoy)
  const today = new Date().toISOString().split('T')[0]
  fec_ini.value = today
  fec_fin.value = today
})
</script>

<style scoped>
/* Secciones */
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5rem;
  overflow: hidden;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-success { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); }
.section-header-warning { background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%); }
.section-header-danger { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); }
.section-header-info { background: linear-gradient(135deg, #17a2b8 0%, #138496 100%); }
.section-header-help { background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%); }
.section-header-purple { background: linear-gradient(135deg, #6f42c1 0%, #9b59b6 100%); }

.section-icon {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.section-title-group { flex: 1; }
.section-title-group h3 { margin: 0; font-size: 1.1rem; font-weight: 600; }
.section-subtitle { font-size: 0.85rem; opacity: 0.9; }
.section-actions { margin-left: auto; }
.section-body { padding: 1.5rem; }

/* Form Grid */
.form-grid { display: grid; gap: 1.5rem; }
.form-grid.cols-4 { grid-template-columns: repeat(4, 1fr); }

@media (max-width: 1200px) { .form-grid.cols-4 { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { .form-grid.cols-4 { grid-template-columns: 1fr; } }

.form-field label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #495057; }
.form-field .required { color: #dc3545; }
.field-hint { font-size: 0.8rem; color: #6c757d; margin-top: 0.25rem; display: block; }

.input-group { position: relative; }
.input-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #6c757d; z-index: 1; }
.municipal-form-control.with-icon { padding-left: 38px; }

/* Action Row */
.action-row { display: flex; gap: 1rem; margin-top: 1.5rem; padding-top: 1.5rem; border-top: 1px solid #e9ecef; }

/* Info Notice */
.info-notice {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background: #e7f3ff;
  border-radius: 6px;
  margin-top: 1rem;
  font-size: 0.9rem;
  color: #0c5460;
}
.notice-icon { color: #17a2b8; }

/* Table styles */
.th-icon { margin-right: 0.5rem; opacity: 0.7; }

.year-badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
}

.folio-number { color: #667eea; font-size: 1.05rem; }

.badge-porc {
  background: #e3f2fd;
  color: #1565c0;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
  font-size: 0.85rem;
}

.text-danger { color: #dc3545; }
.text-success { color: #28a745; }

.placa-code {
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: monospace;
}

.totals-row { background: #f8f9fa; }
.totals-row td { border-top: 2px solid #dee2e6; padding: 1rem; }
.total-amount { color: #28a745; font-size: 1.1rem; }

/* Export Button */
.btn-export {
  background: rgba(255,255,255,0.2);
  border: 1px solid rgba(255,255,255,0.3);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}
.btn-export:hover { background: rgba(255,255,255,0.3); }

/* Empty state */
.empty-state-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  color: #6c757d;
}

.empty-icon-container {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.empty-state-panel h4 { margin: 0 0 0.5rem; color: #495057; }
.empty-state-panel p { margin: 0; }

/* Pagination */
.pagination-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
  padding-top: 1rem;
  margin-top: 1rem;
  border-top: 1px solid #e9ecef;
}

.pagination-info { color: #6c757d; font-size: 0.9rem; }
.pagination-controls { display: flex; align-items: center; gap: 0.5rem; }
.pagination-current { padding: 0 1rem; font-weight: 500; }
.pagination-size { display: flex; align-items: center; gap: 0.5rem; }
.pagination-size label { color: #6c757d; font-size: 0.9rem; }
.pagination-size select { width: auto; padding: 0.25rem 0.5rem; }

.text-center { text-align: center; }
.text-end { text-align: right; }
</style>
