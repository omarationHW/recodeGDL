<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-bar" /></div>
      <div class="module-view-info">
        <h1>Reportes — Estacionamientos Publicos</h1>
        <p>Listados, Resumen por Sector, Estado de Cuenta y Adeudos</p>
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
      <!-- Seccion de Selector de Reporte -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="cog" /></div>
          <div class="section-title-group">
            <h3>Seleccionar Reporte</h3>
            <span class="section-subtitle">Configure el tipo de reporte a generar</span>
          </div>
        </div>
        <div class="section-body">
          <div class="form-grid cols-4">
            <div class="form-field">
              <label class="municipal-form-label">Tipo de Reporte</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="file-alt" /></span>
                <select class="municipal-form-control with-icon" v-model="tipoReporte" @change="limpiarResultados">
                  <option value="listado">Listado de Estacionamientos</option>
                  <option value="sector">Resumen por Sector</option>
                  <option value="edocta">Estado de Cuenta Individual</option>
                  <option value="adeudos">Relacion de Adeudos</option>
                </select>
              </div>
            </div>

            <div class="form-field" v-if="tipoReporte === 'listado'">
              <label class="municipal-form-label">Ordenar por</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="sort" /></span>
                <select class="municipal-form-control with-icon" v-model.number="opcOrdenamiento">
                  <option value="1">Categoria</option>
                  <option value="2">Sector</option>
                  <option value="3">Numero</option>
                  <option value="4">Nombre</option>
                  <option value="5">Calle</option>
                  <option value="7">Zona/Subzona</option>
                </select>
              </div>
            </div>

            <div class="form-field" v-if="tipoReporte === 'edocta'">
              <label class="municipal-form-label">No. Estacionamiento <span class="required">*</span></label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="parking" /></span>
                <input class="municipal-form-control with-icon" type="number" v-model.number="numEsta" placeholder="Ingrese numero" @keyup.enter="ejecutarReporte" />
              </div>
            </div>

            <div class="form-field form-field-actions">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="btn-group-actions">
                <button class="btn-municipal-primary" @click="ejecutarReporte" :disabled="loading">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" /> Ejecutar
                </button>
                <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading || (resultados.length === 0 && !edoctaData)" v-if="consultaEjecutada">
                  <font-awesome-icon icon="file-excel" /> Excel
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados: Listado de Estacionamientos -->
      <div v-if="tipoReporte === 'listado' && resultados.length > 0" class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="list" /></div>
          <div class="section-title-group">
            <h3>Listado de Estacionamientos</h3>
            <span class="section-subtitle">{{ resultados.length }} registros encontrados</span>
          </div>
          <div class="section-actions">
            <span class="header-with-badge"><font-awesome-icon icon="car" /> Total Cajones: {{ totalCajones }}</span>
          </div>
        </div>
        <div class="section-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No.Esta</th>
                  <th>Sector</th>
                  <th>Categoria</th>
                  <th>Nombre</th>
                  <th>Calle</th>
                  <th>No.Ext</th>
                  <th class="text-center">Cajones</th>
                  <th>Zona</th>
                  <th>Telefono</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in resultadosPaginados" :key="r.numesta">
                  <td><code class="numero-code">{{ r.numesta }}</code></td>
                  <td>{{ r.nomsector }}</td>
                  <td><span class="badge-categoria">{{ r.descripcion }}</span></td>
                  <td>{{ r.nombre }}</td>
                  <td>{{ r.calle }}</td>
                  <td>{{ r.numext }}</td>
                  <td class="text-center"><span class="badge-cajones">{{ r.cupo }}</span></td>
                  <td>{{ r.zona }}-{{ r.subzona }}</td>
                  <td>{{ r.telefono }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="totals-row">
                  <td colspan="6"><strong>TOTAL</strong></td>
                  <td class="text-center"><strong>{{ totalCajones }}</strong></td>
                  <td colspan="2"></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <!-- Paginacion -->
          <div class="pagination-footer" v-if="totalPaginas > 1">
            <div class="pagination-info">
              Mostrando {{ ((paginaActual - 1) * registrosPorPagina) + 1 }} a {{ Math.min(paginaActual * registrosPorPagina, resultados.length) }} de {{ resultados.length }}
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(1)" :disabled="paginaActual === 1">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Pagina {{ paginaActual }} de {{ totalPaginas }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(totalPaginas)" :disabled="paginaActual === totalPaginas">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados: Resumen por Sector -->
      <div v-if="tipoReporte === 'sector' && resultados.length > 0" class="form-section">
        <div class="section-header section-header-success">
          <div class="section-icon"><font-awesome-icon icon="chart-pie" /></div>
          <div class="section-title-group">
            <h3>Resumen por Categoria y Sector</h3>
            <span class="section-subtitle">Distribucion de estacionamientos</span>
          </div>
        </div>
        <div class="section-body">
          <div class="table-responsive">
            <table class="municipal-table table-sector">
              <thead class="municipal-table-header">
                <tr>
                  <th rowspan="2">Categoria</th>
                  <th rowspan="2">Descripcion</th>
                  <th colspan="2" class="text-center sector-juarez">JUAREZ</th>
                  <th colspan="2" class="text-center sector-reforma">REFORMA</th>
                  <th colspan="2" class="text-center sector-libertad">LIBERTAD</th>
                  <th colspan="2" class="text-center sector-hidalgo">HIDALGO</th>
                  <th colspan="2" class="text-center sector-total">TOTAL</th>
                </tr>
                <tr>
                  <th class="text-center">Cant</th>
                  <th class="text-center">Cap</th>
                  <th class="text-center">Cant</th>
                  <th class="text-center">Cap</th>
                  <th class="text-center">Cant</th>
                  <th class="text-center">Cap</th>
                  <th class="text-center">Cant</th>
                  <th class="text-center">Cap</th>
                  <th class="text-center">Cant</th>
                  <th class="text-center">Cap</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in resultados" :key="r.categoria">
                  <td><strong>{{ r.categoria }}</strong></td>
                  <td>{{ r.descripcion }}</td>
                  <td class="text-center">{{ r.cant_j }}</td>
                  <td class="text-center">{{ r.capac_j }}</td>
                  <td class="text-center">{{ r.cant_r }}</td>
                  <td class="text-center">{{ r.capac_r }}</td>
                  <td class="text-center">{{ r.cant_l }}</td>
                  <td class="text-center">{{ r.capac_l }}</td>
                  <td class="text-center">{{ r.cant_h }}</td>
                  <td class="text-center">{{ r.capac_h }}</td>
                  <td class="text-center"><strong>{{ r.cant_t }}</strong></td>
                  <td class="text-center"><strong>{{ r.capac_t }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="totals-row">
                  <td colspan="2"><strong>TOTALES</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.cant_j }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.capac_j }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.cant_r }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.capac_r }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.cant_l }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.capac_l }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.cant_h }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.capac_h }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.cant_t }}</strong></td>
                  <td class="text-center"><strong>{{ totalesSector.capac_t }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Resultados: Estado de Cuenta Individual -->
      <div v-if="tipoReporte === 'edocta' && edoctaData" class="form-section">
        <div class="section-header section-header-warning">
          <div class="section-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
          <div class="section-title-group">
            <h3>Estado de Cuenta - Estacionamiento #{{ edoctaData.numesta }}</h3>
            <span class="section-subtitle">Informacion completa del registro</span>
          </div>
          <div class="section-actions">
            <span class="status-badge" :class="edoctaData.movto_cve === 'C' ? 'status-danger' : 'status-success'">
              {{ edoctaData.movto_cve === 'C' ? 'CANCELADO' : 'VIGENTE' }}
            </span>
          </div>
        </div>
        <div class="section-body">
          <div class="info-grid-3">
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="user" /> Datos Generales</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">Nombre:</span><span class="info-value">{{ edoctaData.nombre }}</span></div>
                <div class="info-row"><span class="info-label">Direccion:</span><span class="info-value">{{ edoctaData.calle }} {{ edoctaData.numext }}</span></div>
                <div class="info-row"><span class="info-label">Telefono:</span><span class="info-value">{{ edoctaData.telefono }}</span></div>
                <div class="info-row"><span class="info-label">RFC:</span><span class="info-value"><code>{{ edoctaData.rfc }}</code></span></div>
                <div class="info-row"><span class="info-label">Categoria:</span><span class="info-value">{{ edoctaData.descripcion }}</span></div>
              </div>
            </div>
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="map-marker-alt" /> Informacion del Registro</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">Sector:</span><span class="info-value">{{ edoctaData.sector }}</span></div>
                <div class="info-row"><span class="info-label">Zona/Subzona:</span><span class="info-value">{{ edoctaData.zona }}-{{ edoctaData.subzona }}</span></div>
                <div class="info-row"><span class="info-label">Cajones:</span><span class="info-value"><span class="badge-cajones">{{ edoctaData.cupo }}</span></span></div>
                <div class="info-row"><span class="info-label">Cve. Cuenta:</span><span class="info-value"><code>{{ edoctaData.cvecuenta }}</code></span></div>
                <div class="info-row"><span class="info-label">No. Licencia:</span><span class="info-value">{{ edoctaData.numlicencia }}</span></div>
              </div>
            </div>
            <div class="info-card">
              <div class="info-card-header"><font-awesome-icon icon="calendar" /> Fechas y Control</div>
              <div class="info-card-body">
                <div class="info-row"><span class="info-label">Fecha Alta:</span><span class="info-value">{{ formatDate(edoctaData.fecha_at) }}</span></div>
                <div class="info-row"><span class="info-label">Fecha Inicial:</span><span class="info-value">{{ formatDate(edoctaData.fecha_inicial) }}</span></div>
                <div class="info-row"><span class="info-label">Fecha Venc:</span><span class="info-value">{{ formatDate(edoctaData.fecha_vencimiento) }}</span></div>
                <div class="info-row"><span class="info-label">Solicitud:</span><span class="info-value">{{ edoctaData.solicitud }}</span></div>
                <div class="info-row"><span class="info-label">Control:</span><span class="info-value">{{ edoctaData.control }}</span></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados: Relacion de Adeudos -->
      <div v-if="tipoReporte === 'adeudos' && resultados.length > 0" class="form-section">
        <div class="section-header section-header-danger">
          <div class="section-icon"><font-awesome-icon icon="money-bill-wave" /></div>
          <div class="section-title-group">
            <h3>Relacion de Adeudos</h3>
            <span class="section-subtitle">{{ resultados.length }} registros con adeudos</span>
          </div>
          <div class="section-actions">
            <span class="header-with-badge">Total: {{ formatMoney(totalesAdeudos.ant + totalesAdeudos.act) }}</span>
          </div>
        </div>
        <div class="section-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No.Esta</th>
                  <th>Sector</th>
                  <th>Categoria</th>
                  <th>Nombre</th>
                  <th class="text-center">Cajones</th>
                  <th>Ano/Mes</th>
                  <th class="text-end">Adeudos Ant</th>
                  <th class="text-end">Adeudos Act</th>
                  <th class="text-end">Proyectado</th>
                  <th>Ult. Pago</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in resultadosPaginados" :key="r.numesta" :class="{ 'row-warning': (Number(r.adeudos_ant || 0) + Number(r.adeudos_act || 0)) > 0 }">
                  <td><code class="numero-code">{{ r.numesta }}</code></td>
                  <td>{{ r.nomsector }}</td>
                  <td>{{ r.descripcion }}</td>
                  <td>{{ r.nombre }}</td>
                  <td class="text-center">{{ r.cupo }}</td>
                  <td>{{ r.axo_adeudo }}/{{ r.mes_ini_adeudo }}</td>
                  <td class="text-end"><span class="money-value">{{ formatMoney(r.adeudos_ant) }}</span></td>
                  <td class="text-end"><span class="money-value text-danger">{{ formatMoney(r.adeudos_act) }}</span></td>
                  <td class="text-end"><span class="money-value">{{ formatMoney(r.proyectado) }}</span></td>
                  <td>{{ r.axo_ult_pago }}/{{ r.mes_ult_pago }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="totals-row">
                  <td colspan="6"><strong>TOTALES</strong></td>
                  <td class="text-end"><strong>{{ formatMoney(totalesAdeudos.ant) }}</strong></td>
                  <td class="text-end"><strong>{{ formatMoney(totalesAdeudos.act) }}</strong></td>
                  <td class="text-end"><strong>{{ formatMoney(totalesAdeudos.proy) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <!-- Paginacion -->
          <div class="pagination-footer" v-if="totalPaginas > 1">
            <div class="pagination-info">
              Mostrando {{ ((paginaActual - 1) * registrosPorPagina) + 1 }} a {{ Math.min(paginaActual * registrosPorPagina, resultados.length) }} de {{ resultados.length }}
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(1)" :disabled="paginaActual === 1">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Pagina {{ paginaActual }} de {{ totalPaginas }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(totalPaginas)" :disabled="paginaActual === totalPaginas">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="consultaEjecutada && resultados.length === 0 && !edoctaData" class="form-section">
        <div class="section-header section-header-help">
          <div class="section-icon"><font-awesome-icon icon="info-circle" /></div>
          <div class="section-title-group">
            <h3>Sin Resultados</h3>
            <span class="section-subtitle">No se encontraron datos</span>
          </div>
        </div>
        <div class="section-body">
          <div class="empty-state-panel">
            <font-awesome-icon icon="search" size="3x" class="empty-state-icon" />
            <p>No se encontraron datos para el reporte seleccionado</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ReportesPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Reportes Estacionamientos'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const tipoReporte = ref('listado')
const opcOrdenamiento = ref(1)
const numEsta = ref(null)
const resultados = ref([])
const edoctaData = ref(null)
const consultaEjecutada = ref(false)

// Paginacion
const paginaActual = ref(1)
const registrosPorPagina = ref(15)

// Computed
const totalCajones = computed(() => resultados.value.reduce((sum, r) => sum + Number(r.cupo || 0), 0))

const resultadosPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * registrosPorPagina.value
  const fin = inicio + registrosPorPagina.value
  return resultados.value.slice(inicio, fin)
})

const totalPaginas = computed(() => Math.ceil(resultados.value.length / registrosPorPagina.value) || 1)

const totalesSector = computed(() => {
  return resultados.value.reduce((acc, r) => ({
    cant_j: acc.cant_j + Number(r.cant_j || 0),
    capac_j: acc.capac_j + Number(r.capac_j || 0),
    cant_r: acc.cant_r + Number(r.cant_r || 0),
    capac_r: acc.capac_r + Number(r.capac_r || 0),
    cant_l: acc.cant_l + Number(r.cant_l || 0),
    capac_l: acc.capac_l + Number(r.capac_l || 0),
    cant_h: acc.cant_h + Number(r.cant_h || 0),
    capac_h: acc.capac_h + Number(r.capac_h || 0),
    cant_t: acc.cant_t + Number(r.cant_t || 0),
    capac_t: acc.capac_t + Number(r.capac_t || 0)
  }), { cant_j: 0, capac_j: 0, cant_r: 0, capac_r: 0, cant_l: 0, capac_l: 0, cant_h: 0, capac_h: 0, cant_t: 0, capac_t: 0 })
})

const totalesAdeudos = computed(() => {
  return resultados.value.reduce((acc, r) => ({
    ant: acc.ant + Number(r.adeudos_ant || 0),
    act: acc.act + Number(r.adeudos_act || 0),
    proy: acc.proy + Number(r.proyectado || 0)
  }), { ant: 0, act: 0, proy: 0 })
})

// Helpers
function formatMoney(n) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n || 0))
}

function formatDate(date) {
  if (!date) return '—'
  return new Date(date).toLocaleDateString('es-MX')
}

function limpiarResultados() {
  resultados.value = []
  edoctaData.value = null
  consultaEjecutada.value = false
  paginaActual.value = 1
}

function cambiarPagina(pagina) {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    paginaActual.value = pagina
  }
}

async function ejecutarReporte() {
  limpiarResultados()

  try {
    showLoading('Ejecutando...', 'Generando reporte')

    let resp
    let params = []

    switch (tipoReporte.value) {
      case 'listado':
        params = [{ nombre: 'p_opc', valor: opcOrdenamiento.value, tipo: 'integer' }]
        resp = await execute('spubreports_list', BASE_DB, params, '', null, SCHEMA)
        resultados.value = resp?.result || resp?.data?.result || resp?.data || []
        break

      case 'sector':
        resp = await execute('spubreports_sector_summary', BASE_DB, [], '', null, SCHEMA)
        resultados.value = resp?.result || resp?.data?.result || resp?.data || []
        break

      case 'edocta':
        if (!numEsta.value) {
          hideLoading()
          showToast('warning', 'Ingrese el numero de estacionamiento')
          return
        }
        params = [{ nombre: 'p_numesta', valor: numEsta.value, tipo: 'integer' }]
        resp = await execute('spubreports_edocta', BASE_DB, params, '', null, SCHEMA)
        const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || null
        if (data) {
          edoctaData.value = data
        } else {
          showToast('info', 'No se encontro el estacionamiento')
        }
        break

      case 'adeudos':
        resp = await execute('spubreports_adeudos', BASE_DB, [], '', null, SCHEMA)
        resultados.value = resp?.result || resp?.data?.result || resp?.data || []
        break
    }

    consultaEjecutada.value = true

    if (resultados.value.length > 0) {
      showToast('success', `${resultados.value.length} registro(s) encontrado(s)`)
    } else if (edoctaData.value) {
      showToast('success', 'Estado de cuenta encontrado')
    }

  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function exportarExcel() {
  if (resultados.value.length === 0 && !edoctaData.value) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  let csvContent = ''
  let filename = ''

  if (tipoReporte.value === 'listado') {
    filename = 'listado_estacionamientos.csv'
    csvContent = 'No.Esta,Sector,Categoria,Nombre,Calle,No.Ext,Cajones,Zona,Telefono\n'
    resultados.value.forEach(r => {
      csvContent += `${r.numesta},"${r.nomsector}","${r.descripcion}","${r.nombre}","${r.calle}","${r.numext}",${r.cupo},${r.zona}-${r.subzona},"${r.telefono}"\n`
    })
  } else if (tipoReporte.value === 'sector') {
    filename = 'resumen_sector.csv'
    csvContent = 'Categoria,Descripcion,Cant_J,Cap_J,Cant_R,Cap_R,Cant_L,Cap_L,Cant_H,Cap_H,Cant_T,Cap_T\n'
    resultados.value.forEach(r => {
      csvContent += `"${r.categoria}","${r.descripcion}",${r.cant_j},${r.capac_j},${r.cant_r},${r.capac_r},${r.cant_l},${r.capac_l},${r.cant_h},${r.capac_h},${r.cant_t},${r.capac_t}\n`
    })
  } else if (tipoReporte.value === 'adeudos') {
    filename = 'relacion_adeudos.csv'
    csvContent = 'No.Esta,Sector,Categoria,Nombre,Cajones,Año_Adeudo,Mes_Adeudo,Adeudos_Ant,Adeudos_Act,Proyectado,Ult_Pago_Año,Ult_Pago_Mes\n'
    resultados.value.forEach(r => {
      csvContent += `${r.numesta},"${r.nomsector}","${r.descripcion}","${r.nombre}",${r.cupo},${r.axo_adeudo},${r.mes_ini_adeudo},${r.adeudos_ant || 0},${r.adeudos_act || 0},${r.proyectado || 0},${r.axo_ult_pago || ''},${r.mes_ult_pago || ''}\n`
    })
  } else if (tipoReporte.value === 'edocta' && edoctaData.value) {
    filename = `edocta_${edoctaData.value.numesta}.csv`
    csvContent = 'Campo,Valor\n'
    Object.entries(edoctaData.value).forEach(([key, value]) => {
      csvContent += `"${key}","${value}"\n`
    })
  }

  const BOM = '\uFEFF'
  const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = filename
  link.click()

  showToast('success', `Archivo ${filename} descargado`)
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

.section-header-info { background: linear-gradient(135deg, #17a2b8 0%, #138496 100%); }
.section-header-success { background: linear-gradient(135deg, #28a745 0%, #20c997 100%); }
.section-header-warning { background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%); }
.section-header-danger { background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); }
.section-header-help { background: linear-gradient(135deg, #6c757d 0%, #495057 100%); }

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

.header-with-badge, .status-badge {
  background: rgba(255,255,255,0.2);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
}

.status-success { background: #28a745; }
.status-danger { background: #dc3545; }

.section-body { padding: 1.5rem; }

/* Form grid */
.form-grid { display: grid; gap: 1.5rem; }
.form-grid.cols-4 { grid-template-columns: repeat(4, 1fr); }

@media (max-width: 992px) { .form-grid.cols-4 { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 576px) { .form-grid.cols-4 { grid-template-columns: 1fr; } }

.form-field label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #495057; }
.required { color: #dc3545; }

.input-group { position: relative; }
.input-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); color: #6c757d; z-index: 1; }
.municipal-form-control.with-icon { padding-left: 38px; }

.btn-group-actions { display: flex; gap: 0.5rem; }

/* Table styles */
.numero-code { background: #f8f9fa; padding: 0.25rem 0.5rem; border-radius: 4px; font-family: 'Consolas', monospace; }
.badge-categoria { background: #e3f2fd; color: #1976d2; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.85rem; }
.badge-cajones { background: #28a745; color: white; padding: 0.25rem 0.75rem; border-radius: 12px; font-weight: 600; }
.money-value { font-family: 'Consolas', monospace; }

.totals-row { background: #f8f9fa; }
.totals-row td { border-top: 2px solid #dee2e6; }
.row-warning { background: #fff3cd !important; }

/* Sector table */
.sector-juarez { background: #e3f2fd !important; }
.sector-reforma { background: #e8f5e9 !important; }
.sector-libertad { background: #fff3e0 !important; }
.sector-hidalgo { background: #fce4ec !important; }
.sector-total { background: #fff9c4 !important; }

/* Info grid */
.info-grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; }
@media (max-width: 992px) { .info-grid-3 { grid-template-columns: 1fr; } }

.info-card { background: #f8f9fa; border-radius: 8px; overflow: hidden; }
.info-card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 0.75rem 1rem; font-weight: 600; }
.info-card-body { padding: 1rem; }
.info-row { display: flex; padding: 0.5rem 0; border-bottom: 1px solid #e9ecef; }
.info-row:last-child { border-bottom: none; }
.info-label { flex: 0 0 120px; font-weight: 500; color: #6c757d; }
.info-value { flex: 1; color: #212529; }

/* Pagination */
.pagination-footer { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1rem; padding-top: 1rem; margin-top: 1rem; border-top: 1px solid #e9ecef; }
.pagination-info { color: #6c757d; font-size: 0.9rem; }
.pagination-controls { display: flex; align-items: center; gap: 0.5rem; }
.pagination-current { padding: 0 1rem; font-weight: 500; }

/* Empty state */
.empty-state-panel { display: flex; flex-direction: column; align-items: center; padding: 3rem; text-align: center; color: #6c757d; }
.empty-state-icon { margin-bottom: 1rem; opacity: 0.5; }

.text-center { text-align: center; }
.text-end { text-align: right; }
.text-danger { color: #dc3545; }

.btn-municipal-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  border: none;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
}
.btn-municipal-success:disabled { opacity: 0.6; cursor: not-allowed; }
</style>
