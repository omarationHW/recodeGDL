<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <!-- Header del Módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill-wave" />
      </div>
      <div class="module-view-info">
        <h1>Pagos de Estacionamientos Públicos</h1>
        <p>Registro y consulta de pagos</p>
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

    <!-- Contenido Principal -->
    <div class="module-view-content">
      <div class="form-container">

        <!-- Sección: Búsqueda de Folio -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="search" />
            </div>
            <div class="section-title-group">
              <h3>Buscar Folio con Adeudos</h3>
              <span class="section-subtitle">Ingrese el número de folio o licencia</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-3">
              <div class="form-field">
                <label class="municipal-form-label">Número de Folio <span class="required">*</span></label>
                <div class="input-with-icon">
                  <font-awesome-icon icon="hashtag" class="field-icon" />
                  <input
                    type="number"
                    v-model="numFolio"
                    class="municipal-form-control"
                    placeholder="Ej: 12345"
                    @keyup.enter="buscarAdeudos"
                  />
                </div>
              </div>
              <div class="form-field span-2">
                <label class="municipal-form-label">Nombre / Razón Social</label>
                <input
                  type="text"
                  v-model="nombreContribuyente"
                  class="municipal-form-control"
                  placeholder="Se autocompleta al buscar"
                  disabled
                />
              </div>
            </div>
            <div class="action-buttons">
              <button
                class="btn-municipal-primary"
                @click="buscarAdeudos"
                :disabled="loading || !numFolio"
              >
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                Buscar Adeudos
              </button>
            </div>
          </div>
        </div>

        <!-- Sección: Adeudos Pendientes -->
        <div v-if="adeudosPendientes.length > 0" class="form-section">
          <div class="section-header section-header-warning header-with-badge">
            <div class="section-icon section-icon-warning">
              <font-awesome-icon icon="exclamation-triangle" />
            </div>
            <div class="section-title-group">
              <h3>Adeudos Pendientes</h3>
              <span class="section-subtitle">{{ adeudosPendientes.length }} periodo(s) con adeudo</span>
            </div>
            <div class="section-badge">
              <span class="badge badge-warning">Total: {{ formatMoney(totalGeneral) }}</span>
            </div>
          </div>
          <div class="section-body p-0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th style="width: 40px;">
                      <input
                        type="checkbox"
                        @change="seleccionarTodos"
                        v-model="todosSeleccionados"
                        class="form-check-input"
                      />
                    </th>
                    <th>Periodo</th>
                    <th>Concepto</th>
                    <th class="text-right">Adeudo</th>
                    <th class="text-right">Recargo</th>
                    <th class="text-right">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in adeudosPendientes" :key="adeudo.id" :class="{ 'table-row-selected': adeudo.seleccionado }" class="row-hover">
                    <td>
                      <input type="checkbox" v-model="adeudo.seleccionado" class="form-check-input" />
                    </td>
                    <td><strong>{{ adeudo.periodo }}</strong></td>
                    <td>{{ adeudo.concepto }}</td>
                    <td class="text-right">{{ formatMoney(adeudo.importe_adeudo) }}</td>
                    <td class="text-right text-danger">{{ formatMoney(adeudo.importe_recargo) }}</td>
                    <td class="text-right"><strong>{{ formatMoney(adeudo.total_periodo) }}</strong></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr class="table-footer-total">
                    <td colspan="5" class="text-right"><strong>TOTAL SELECCIONADO:</strong></td>
                    <td class="text-right total-amount">{{ formatMoney(totalSeleccionado) }}</td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
        </div>

        <!-- Sección: Formulario de Pago -->
        <div v-if="adeudosPendientes.length > 0" class="form-section">
          <div class="section-header section-header-success">
            <div class="section-icon section-icon-success">
              <font-awesome-icon icon="cash-register" />
            </div>
            <div class="section-title-group">
              <h3>Datos del Pago</h3>
              <span class="section-subtitle">Complete la información para registrar el pago</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-4">
              <div class="form-field">
                <label class="municipal-form-label">Importe a Pagar <span class="required">*</span></label>
                <div class="input-currency">
                  <span class="currency-symbol">$</span>
                  <input
                    type="number"
                    v-model="formPago.importe"
                    class="municipal-form-control"
                    :max="totalSeleccionado"
                    step="0.01"
                    min="0"
                    placeholder="0.00"
                  />
                </div>
                <small class="field-hint">Máximo: {{ formatMoney(totalSeleccionado) }}</small>
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Recaudadora</label>
                <select v-model="formPago.id_rec" class="municipal-form-control">
                  <option value="1">Recaudadora 1</option>
                  <option value="2">Recaudadora 2</option>
                  <option value="3">Recaudadora 3</option>
                  <option value="9">Todas</option>
                </select>
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Caja</label>
                <input
                  type="text"
                  v-model="formPago.caja"
                  class="municipal-form-control"
                  placeholder="001"
                  maxlength="10"
                />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">No. Operación</label>
                <input
                  type="number"
                  v-model="formPago.operacion"
                  class="municipal-form-control"
                  placeholder="Automático"
                />
              </div>
            </div>
            <div class="action-buttons">
              <button
                class="btn-municipal-primary btn-lg"
                @click="registrarPago"
                :disabled="loading || !formPago.importe || formPago.importe <= 0"
              >
                <font-awesome-icon :icon="loading ? 'spinner' : 'check-circle'" :spin="loading" />
                {{ loading ? 'Procesando...' : 'Registrar Pago' }}
              </button>
              <button
                class="btn-municipal-secondary"
                @click="cancelarPago"
                :disabled="loading"
              >
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </div>
        </div>

        <!-- Sección: Historial de Pagos de Sesión -->
        <div v-if="historialPagos.length > 0" class="form-section">
          <div class="section-header section-header-info">
            <div class="section-icon section-icon-info">
              <font-awesome-icon icon="history" />
            </div>
            <div class="section-title-group">
              <h3>Pagos Registrados (Sesión Actual)</h3>
              <span class="section-subtitle">{{ historialPagos.length }} pago(s) en esta sesión</span>
            </div>
          </div>
          <div class="section-body p-0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Folio Recibo</th>
                    <th>Folio Esta.</th>
                    <th class="text-right">Importe</th>
                    <th>Periodos</th>
                    <th>Fecha/Hora</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="pago in historialPagos" :key="pago.folio">
                    <td><strong>{{ pago.folio_recibo }}</strong></td>
                    <td>{{ pago.num_folio }}</td>
                    <td class="text-right">{{ formatMoney(pago.importe) }}</td>
                    <td>{{ pago.periodos_pagados }}</td>
                    <td>{{ formatDateTime(pago.fecha) }}</td>
                    <td>
                      <span :class="['badge', pago.success ? 'badge-success' : 'badge-danger']">
                        <font-awesome-icon :icon="pago.success ? 'check' : 'times'" />
                        {{ pago.success ? 'Aplicado' : 'Error' }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Sección: Consulta de Pagos -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="file-invoice-dollar" />
            </div>
            <div class="section-title-group">
              <h3>Consulta de Pagos Registrados</h3>
              <span class="section-subtitle">Buscar pagos por recaudadora y fecha</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-3">
              <div class="form-field">
                <label class="municipal-form-label">Recaudadora</label>
                <select v-model="filters.recaudadora" class="municipal-form-control">
                  <option value="1">Recaudadora 1</option>
                  <option value="2">Recaudadora 2</option>
                  <option value="3">Recaudadora 3</option>
                  <option value="9">Todas</option>
                </select>
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Fecha</label>
                <input type="date" v-model="filters.fecha" class="municipal-form-control" />
              </div>
              <div class="form-field flex-end">
                <button class="btn-municipal-secondary" :disabled="loading" @click="consultar">
                  <font-awesome-icon icon="search" /> Consultar Pagos
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Sección: Resultados de Consulta -->
        <div v-if="resultados.length > 0" class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="list-alt" />
            </div>
            <div class="section-title-group">
              <h3>Resultados de Consulta</h3>
              <span class="section-subtitle">{{ resultados.length }} registro(s) encontrado(s)</span>
            </div>
          </div>
          <div class="section-body p-0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Fecha</th>
                    <th>Folio/Año</th>
                    <th>Placa</th>
                    <th class="text-right">Importe</th>
                    <th>Caja</th>
                    <th>Operación</th>
                    <th>Reca</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(r, idx) in paginatedResultados" :key="idx">
                    <td>{{ r.fecha }}</td>
                    <td><strong>{{ r.concepto }}</strong></td>
                    <td>{{ r.placa || '-' }}</td>
                    <td class="text-right">{{ formatMoney(r.importe) }}</td>
                    <td>{{ r.cajero }}</td>
                    <td>{{ r.operacion }}</td>
                    <td>{{ r.recaudadora }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Paginación -->
            <div v-if="totalPages > 1" class="pagination-footer">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} - {{ Math.min(currentPage * itemsPerPage, resultados.length) }} de {{ resultados.length }}
              </span>
              <nav>
                <ul class="pagination">
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="prevPage" :disabled="currentPage === 1">
                      <font-awesome-icon icon="chevron-left" />
                    </button>
                  </li>
                  <li class="page-item active">
                    <span class="page-link">{{ currentPage }} / {{ totalPages }}</span>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <button class="page-link" @click="nextPage" :disabled="currentPage === totalPages">
                      <font-awesome-icon icon="chevron-right" />
                    </button>
                  </li>
                </ul>
              </nav>
            </div>
          </div>
        </div>

        <!-- Estado vacío para resultados -->
        <div v-if="resultados.length === 0 && consultaRealizada" class="empty-table-state">
          <font-awesome-icon icon="inbox" class="empty-state-icon" />
          <p>No se encontraron pagos para la fecha y recaudadora indicadas</p>
        </div>

      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'PagosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Pagos de Estacionamientos Públicos'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { reactive, ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estados
const loading = ref(false)
const consultaRealizada = ref(false)
const numFolio = ref(null)
const pubmainId = ref(null)
const nombreContribuyente = ref('')
const adeudosPendientes = ref([])
const todosSeleccionados = ref(false)
const historialPagos = ref([])
const resultados = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(20)

const filters = reactive({
  numlicencia: '',
  recaudadora: 1,
  fecha: new Date().toISOString().slice(0, 10)
})

const formPago = ref({
  importe: null,
  id_rec: 1,
  caja: '001',
  operacion: null
})

// Computed
const totalGeneral = computed(() => {
  return adeudosPendientes.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const totalSeleccionado = computed(() => {
  return adeudosPendientes.value
    .filter(a => a.seleccionado)
    .reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const totalPages = computed(() => {
  return Math.ceil(resultados.value.length / itemsPerPage.value)
})

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return resultados.value.slice(start, end)
})

// Funciones de paginación
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

// Funciones de formato
function formatMoney(n) {
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(Number(n || 0))
  } catch {
    return n
  }
}

const formatDateTime = (date) => {
  if (!date) return '-'
  try {
    return new Date(date).toLocaleString('es-MX')
  } catch {
    return date
  }
}

// Buscar estacionamiento y adeudos
async function buscarAdeudos() {
  if (!numFolio.value) {
    showToast('warning', 'Ingrese un número de licencia/folio')
    return
  }

  loading.value = true
  showLoading('Buscando...', 'Consultando estacionamiento')

  try {
    const listaResp = await execute('sp_get_public_parking_list', BASE_DB, [], '', null, SCHEMA)
    const listaData = listaResp?.result || listaResp?.data?.result || listaResp?.data || []

    if (!Array.isArray(listaData) || listaData.length === 0) {
      showToast('warning', 'No se pudo obtener la lista de estacionamientos')
      adeudosPendientes.value = []
      nombreContribuyente.value = ''
      return
    }

    const folioData = listaData.find(
      e => e.numlicencia === parseInt(numFolio.value) || e.numesta === parseInt(numFolio.value)
    )

    if (!folioData) {
      showToast('warning', 'Folio/Licencia no encontrado')
      adeudosPendientes.value = []
      nombreContribuyente.value = ''
      pubmainId.value = null
      return
    }

    pubmainId.value = folioData.id
    nombreContribuyente.value = folioData.nombre || ''

    const respAdeudos = await execute('cajero_pub_detalle', BASE_DB, [
      { nombre: 'p_opc', valor: 3, tipo: 'integer' },
      { nombre: 'p_pubid', valor: pubmainId.value, tipo: 'integer' },
      { nombre: 'p_axo', valor: 0, tipo: 'integer' },
      { nombre: 'p_mes', valor: 0, tipo: 'integer' }
    ], '', null, SCHEMA)

    const adeudosData = respAdeudos?.result || respAdeudos?.data?.result || respAdeudos?.data || []

    if (Array.isArray(adeudosData) && adeudosData.length > 0) {
      adeudosPendientes.value = adeudosData.map((a, idx) => ({
        id: idx + 1,
        concepto: a.concepto,
        axo: a.axo,
        mes: a.mes,
        periodo: `${a.axo}/${String(a.mes).padStart(2, '0')}`,
        importe_adeudo: parseFloat(a.adeudo || 0),
        importe_recargo: parseFloat(a.recargos || 0),
        total_periodo: parseFloat(a.adeudo || 0) + parseFloat(a.recargos || 0),
        seleccionado: false
      }))
      showToast('success', `Se encontraron ${adeudosPendientes.value.length} adeudo(s) pendiente(s)`)
    } else {
      adeudosPendientes.value = []
      showToast('info', 'No hay adeudos pendientes para este folio')
    }
  } catch (e) {
    handleApiError(e)
    adeudosPendientes.value = []
    nombreContribuyente.value = ''
    pubmainId.value = null
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Seleccionar todos los adeudos
const seleccionarTodos = () => {
  adeudosPendientes.value.forEach(a => a.seleccionado = todosSeleccionados.value)
}

// Registrar pago
async function registrarPago() {
  if (!formPago.value.importe || formPago.value.importe <= 0) {
    showToast('warning', 'Ingrese un importe válido')
    return
  }

  if (formPago.value.importe > totalSeleccionado.value) {
    showToast('warning', 'El importe excede el total de adeudos seleccionados')
    return
  }

  const adeudosSeleccionados = adeudosPendientes.value.filter(a => a.seleccionado)
  if (adeudosSeleccionados.length === 0) {
    showToast('warning', 'Seleccione al menos un periodo para pagar')
    return
  }

  if (!pubmainId.value) {
    showToast('error', 'No se ha identificado el estacionamiento')
    return
  }

  showLoading('Registrando pago...', 'Procesando transacción')

  try {
    const pagosExitosos = []
    const pagosError = []
    const fechaHoy = new Date().toISOString().slice(0, 10)

    for (const adeudo of adeudosSeleccionados) {
      try {
        const response = await execute('actualiza_pub_pago', BASE_DB, [
          { nombre: 'p_opc', valor: 1, tipo: 'integer' },
          { nombre: 'p_pubmain_id', valor: pubmainId.value, tipo: 'integer' },
          { nombre: 'p_axo', valor: adeudo.axo, tipo: 'integer' },
          { nombre: 'p_mes', valor: adeudo.mes, tipo: 'integer' },
          { nombre: 'p_tipo', valor: 10, tipo: 'integer' },
          { nombre: 'p_fecha', valor: fechaHoy, tipo: 'date' },
          { nombre: 'p_reca', valor: formPago.value.id_rec, tipo: 'integer' },
          { nombre: 'p_caja', valor: formPago.value.caja || '001', tipo: 'string' },
          { nombre: 'p_operacion', valor: formPago.value.operacion || 0, tipo: 'integer' }
        ], '', null, SCHEMA)

        const respData = response?.result || response?.data?.result || response?.data || []
        const resultado = Array.isArray(respData) ? respData[0] : respData
        if (resultado?.id === 1 || resultado?.mensaje?.includes('correctamente')) {
          pagosExitosos.push({
            periodo: adeudo.periodo,
            mensaje: resultado?.mensaje || 'Aplicado'
          })
        } else {
          pagosError.push({
            periodo: adeudo.periodo,
            error: resultado?.mensaje || 'Error desconocido'
          })
        }
      } catch (err) {
        pagosError.push({ periodo: adeudo.periodo, error: err.message })
      }
    }

    if (pagosExitosos.length > 0) {
      historialPagos.value.unshift({
        folio_recibo: formPago.value.operacion || '-',
        num_folio: numFolio.value,
        importe: formPago.value.importe,
        periodos_pagados: pagosExitosos.length,
        fecha: new Date(),
        success: true
      })

      showToast('success', `${pagosExitosos.length} periodo(s) aplicado(s) correctamente`)
      cancelarPago()
      await buscarAdeudos()
    }

    if (pagosError.length > 0) {
      showToast('warning', `${pagosError.length} periodo(s) con error: ${pagosError[0].error}`)
    }

  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

// Cancelar pago
const cancelarPago = () => {
  formPago.value = {
    importe: null,
    id_rec: 1,
    caja: '001',
    operacion: null
  }
  todosSeleccionados.value = false
  adeudosPendientes.value.forEach(a => a.seleccionado = false)
}

// Consultar pagos registrados
async function consultar() {
  if (!filters.recaudadora || !filters.fecha) {
    showToast('warning', 'Seleccione recaudadora y fecha para consultar')
    return
  }

  resultados.value = []
  consultaRealizada.value = true
  loading.value = true
  showLoading('Consultando...', 'Buscando pagos registrados')

  try {
    const resp = await execute('report_folios_pagados', BASE_DB, [
      { nombre: 'p_reca', valor: parseInt(filters.recaudadora), tipo: 'integer' },
      { nombre: 'p_fechora', valor: filters.fecha, tipo: 'date' }
    ], '', null, SCHEMA)

    const data = resp?.result || resp?.data?.result || resp?.data || []

    if (Array.isArray(data) && data.length > 0) {
      resultados.value = data.map(r => ({
        fecha: r.fecha_folio,
        concepto: `Folio ${r.folio} - ${r.axo}`,
        importe: r.tarifa,
        cajero: r.caja,
        recaudadora: r.reca,
        placa: r.placa,
        operacion: r.operacion
      }))
      currentPage.value = 1
      showToast('success', `Se encontraron ${resultados.value.length} pago(s)`)
    } else {
      resultados.value = []
      currentPage.value = 1
      showToast('info', 'No se encontraron pagos para la fecha y recaudadora indicadas')
    }
  } catch (e) {
    handleApiError(e)
    resultados.value = []
  } finally {
    loading.value = false
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
</script>

<style scoped>
/* Contenedor del formulario */
.form-container {
  padding: 1.5rem;
}

/* Secciones del formulario */
.form-section {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.form-section:last-child {
  margin-bottom: 0;
}

/* Header de sección */
.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-bottom: 2px solid #ea8215;
}

.section-header-warning {
  border-bottom-color: #f59e0b;
}

.section-header-success {
  border-bottom-color: #10b981;
}

.section-header-info {
  border-bottom-color: #3b82f6;
}

.header-with-badge {
  display: flex;
  justify-content: space-between;
}

.section-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.1rem;
  flex-shrink: 0;
}

.section-icon-warning {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
}

.section-icon-success {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

.section-icon-info {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.section-title-group {
  flex: 1;
}

.section-title-group h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 700;
  color: #1e293b;
}

.section-subtitle {
  font-size: 0.85rem;
  color: #64748b;
  margin-top: 0.15rem;
  display: block;
}

.section-badge {
  margin-left: auto;
}

/* Body de sección */
.section-body {
  padding: 1.5rem;
}

.section-body.p-0 {
  padding: 0;
}

/* Grid de formulario */
.form-grid {
  display: grid;
  gap: 1.25rem;
  margin-bottom: 1.25rem;
}

.form-grid:last-child {
  margin-bottom: 0;
}

.form-grid.cols-2 { grid-template-columns: repeat(2, 1fr); }
.form-grid.cols-3 { grid-template-columns: repeat(3, 1fr); }
.form-grid.cols-4 { grid-template-columns: repeat(4, 1fr); }

.form-field.span-2 { grid-column: span 2; }
.form-field.flex-end {
  display: flex;
  align-items: flex-end;
}

/* Campos del formulario */
.form-field {
  display: flex;
  flex-direction: column;
}

.form-field .municipal-form-label {
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #334155;
  font-size: 0.9rem;
}

.form-field .required {
  color: #dc3545;
  margin-left: 0.25rem;
}

.form-field .municipal-form-control {
  padding: 0.65rem 0.85rem;
  border: 2px solid #e2e8f0;
  border-radius: 6px;
  font-size: 0.95rem;
  transition: all 0.2s ease;
}

.form-field .municipal-form-control:focus {
  border-color: #ea8215;
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
  outline: none;
}

/* Input con icono */
.input-with-icon {
  position: relative;
}

.input-with-icon .field-icon {
  position: absolute;
  left: 0.85rem;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
  font-size: 0.9rem;
}

.input-with-icon .municipal-form-control {
  padding-left: 2.5rem;
}

/* Input de moneda */
.input-currency {
  position: relative;
}

.input-currency .currency-symbol {
  position: absolute;
  left: 0.85rem;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
  font-weight: 600;
  font-size: 1rem;
}

.input-currency .municipal-form-control {
  padding-left: 2rem;
  font-weight: 600;
}

.field-hint {
  font-size: 0.8rem;
  color: #64748b;
  margin-top: 0.35rem;
}

/* Botones de acción */
.action-buttons {
  display: flex;
  gap: 0.75rem;
  margin-top: 1.25rem;
  padding-top: 1.25rem;
  border-top: 1px solid #e2e8f0;
}

.btn-lg {
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
}

/* Tablas */
.table-responsive {
  overflow-x: auto;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
}

.municipal-table thead tr {
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
}

.municipal-table th {
  padding: 0.85rem 1rem;
  text-align: left;
  color: white;
  font-weight: 600;
  font-size: 0.9rem;
  white-space: nowrap;
}

.municipal-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #e2e8f0;
  font-size: 0.9rem;
}

.row-hover:hover {
  background-color: #f8fafc;
}

.table-row-selected {
  background-color: rgba(234, 130, 21, 0.1);
}

.table-footer-total {
  background: #f1f5f9;
}

.table-footer-total td {
  padding: 1rem;
  font-weight: 600;
}

.total-amount {
  font-size: 1.1rem;
  color: #ea8215;
}

/* Badges */
.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.35rem 0.75rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
}

.badge-success {
  background: rgba(16, 185, 129, 0.15);
  color: #059669;
}

.badge-danger {
  background: rgba(239, 68, 68, 0.15);
  color: #dc2626;
}

.badge-warning {
  background: rgba(245, 158, 11, 0.15);
  color: #d97706;
}

/* Estado vacío */
.empty-table-state {
  text-align: center;
  padding: 3rem 2rem;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px dashed #cbd5e1;
}

.empty-state-icon {
  font-size: 3rem;
  color: #94a3b8;
  margin-bottom: 1rem;
}

.empty-table-state p {
  color: #64748b;
  margin: 0;
}

/* Responsive */
@media (max-width: 1024px) {
  .form-grid.cols-4 { grid-template-columns: repeat(2, 1fr); }
  .form-grid.cols-3 { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 768px) {
  .form-container { padding: 1rem; }
  .form-grid.cols-2,
  .form-grid.cols-3,
  .form-grid.cols-4 { grid-template-columns: 1fr; }
  .form-field.span-2 { grid-column: span 1; }
  .section-header { flex-wrap: wrap; }
  .action-buttons { flex-direction: column; }
  .action-buttons .btn-lg { width: 100%; }
}
</style>
