<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Folio</h1>
        <p>Cementerios - Consulta completa de información de fosa/cuenta RCM</p>
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
      <!-- Búsqueda por Folio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Folio (Control RCM)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="folioABuscar"
                @keyup.enter="buscarFolio"
                placeholder="Número de folio..."
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarFolio"
              :disabled="!folioABuscar"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Datos del Folio -->
      <div class="municipal-card" v-if="datosfolio">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Folio {{ datosfolio.control_rcm }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos de la Fosa -->
          <h6 class="section-title">Ubicación de la Fosa</h6>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cementerio</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="`${datosfolio.cementerio} - ${datosfolio.nombre_cementerio}`"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clase</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.clase_alfa"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Sección</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.seccion_alfa"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Línea</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.linea_alfa"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fosa</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.fosa_alfa"
                readonly
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.tipo_nombre || 'N/A'"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Metros</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.metros || 'N/A'"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año Pagado</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.axo_pagado || 'N/A'"
                readonly
              />
            </div>
          </div>

          <!-- Datos del Propietario -->
          <h6 class="section-title">Datos del Propietario</h6>
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Nombre</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.nombre"
                readonly
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Domicilio</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="domicilioCompleto"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.colonia || 'N/A'"
                readonly
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.rfc || 'N/A'"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">CURP</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.curp || 'N/A'"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.telefono || 'N/A'"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Clave IFE</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="datosfolio.clave_ife || 'N/A'"
                readonly
              />
            </div>
          </div>

          <div class="form-row" v-if="datosfolio.observaciones">
            <div class="form-group full-width">
              <label class="municipal-form-label">Observaciones</label>
              <textarea
                class="municipal-form-control"
                :value="datosfolio.observaciones"
                rows="2"
                readonly
              ></textarea>
            </div>
          </div>

          <!-- Resumen Financiero -->
          <h6 class="section-title">Resumen Financiero</h6>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Total Pagos ({{ datosfolio.cuenta_pagos }})</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="formatCurrency(datosfolio.total_pagos)"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Total Adeudos ({{ datosfolio.cuenta_adeudos }})</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="formatCurrency(datosfolio.total_adeudos)"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Total Bonificaciones</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="formatCurrency(datosfolio.total_bonificaciones)"
                readonly
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Historial de Pagos -->
      <div class="municipal-card" v-if="pagos.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="money-bill-wave" />
            Historial de Pagos
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ pagos.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th>Recaudadora</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Año</th>
                  <th>Concepto</th>
                  <th>Importe</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(pago, index) in pagos"
                  :key="index"
                  @click="selectedRow = pago"
                  :class="{ 'table-row-selected': selectedRow === pago }"
                  class="row-hover"
                >
                  <td>{{ formatDate(pago.fecha) }}</td>
                  <td>{{ pago.id_rec }}</td>
                  <td>{{ pago.caja }}</td>
                  <td><strong>{{ pago.operacion }}</strong></td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.concepto || '-' }}</td>
                  <td class="text-end"><strong>${{ formatNumber(pago.importe) }}</strong></td>
                  <td>{{ pago.usuario || '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Adeudos -->
      <div class="municipal-card" v-if="adeudos.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" />
            Adeudos
          </h5>
          <div class="header-right">
            <span class="badge-purple">
              {{ adeudos.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Fecha Vencimiento</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Total</th>
                  <th>Estado</th>
                  <th>Fecha Pago</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(adeudo, index) in adeudos"
                  :key="index"
                  @click="selectedRow = adeudo"
                  :class="[
                    { 'table-row-selected': selectedRow === adeudo },
                    { 'table-warning': adeudo.pagado === 'N' }
                  ]"
                  class="row-hover"
                >
                  <td><strong>{{ adeudo.axo }}</strong></td>
                  <td>{{ formatDate(adeudo.fecha_venc) }}</td>
                  <td class="text-end">${{ formatNumber(adeudo.importe) }}</td>
                  <td class="text-end">${{ formatNumber(adeudo.recargos) }}</td>
                  <td class="text-end"><strong>${{ formatNumber(adeudo.total) }}</strong></td>
                  <td>
                    <span v-if="adeudo.pagado === 'S'" class="badge badge-success">Pagado</span>
                    <span v-else class="badge badge-warning">Pendiente</span>
                  </td>
                  <td>{{ adeudo.fecha_pago ? formatDate(adeudo.fecha_pago) : '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda/Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ConsultaFol'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Consulta de Folio'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Variables de estado
const selectedRow = ref(null)
const hasSearched = ref(false)

// Sistema de Toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 4000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
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

// Estado
const folioABuscar = ref(null)
const datosfolio = ref(null)
const pagos = ref([])
const adeudos = ref([])

// Computed
const domicilioCompleto = computed(() => {
  if (!datosfolio.value) return ''
  const parts = []
  if (datosfolio.value.domicilio) parts.push(datosfolio.value.domicilio)
  if (datosfolio.value.exterior) parts.push(`Ext: ${datosfolio.value.exterior}`)
  if (datosfolio.value.interior) parts.push(`Int: ${datosfolio.value.interior}`)
  return parts.join(', ')
})

// Métodos
const buscarFolio = async () => {
  if (!folioABuscar.value) {
    showToast('warning', 'Debe ingresar un número de folio')
    return
  }

  showLoading('Buscando folio...', 'Consultando información del cementerio')
  hasSearched.value = true
  selectedRow.value = null

  try {
    /* TODO FUTURO: Query SQL original (Pascal líneas 405-411, Vue líneas 427-436)
    const response = await execute(
      'SELECT d.*, c.nombre as nombre_cementerio, a.rfc, a.curp, a.telefono, a.clave_ife ' +
      'FROM ta_13_datosrcm d ' +
      'LEFT JOIN tc_13_cementerios c ON d.cementerio = c.cementerio ' +
      'LEFT JOIN ta_13_datosrcmadic a ON d.control_rcm = a.control_rcm ' +
      'WHERE d.control_rcm = :control_rcm AND d.vigencia = ''S''',
      'padron_licencias',
      [folioABuscar.value],
      'query',
      null,
      'publico'
    )
    */

    // Consultar datos del folio usando SP
    const response = await execute(
      'sp_consultafol_buscar_folio',
      'cementerio',
      [{ nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' } ],
      'function',
      null,
      'public'
    )

    if (response && response.length > 0) {
      datosfolio.value = response[0]
      showToast('success', 'Folio encontrado correctamente')

      // Cargar pagos y adeudos
      await cargarPagos()
      await cargarAdeudos()
    } else {
      showToast('warning', 'No se encontró el folio especificado')
      datosfolio.value = null
      pagos.value = []
      adeudos.value = []
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar folio: ' + error.message)
    datosfolio.value = null
    pagos.value = []
    adeudos.value = []
  } finally {
    hideLoading()
  }
}

const cargarPagos = async () => {
  try {
    /* TODO FUTURO: Query SQL original (Pascal líneas 437-439)
    const response = await execute(
      'SELECT * FROM ta_13_pagosrcm WHERE control_rcm = :folp ORDER BY fecing DESC',
      'cementerio',
      [folioABuscar.value],
      'query',
      null,
      'public'
    )
    */

    // Cargar pagos usando SP
    const response = await execute(
      'sp_consultafol_listar_pagos',
      'cementerio',
      [{ nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }],
      'function',
      null,
      'public'
    )

    pagos.value = response || []
  } catch (error) {
    console.error('Error al cargar pagos:', error)
    pagos.value = []
  }
}

const cargarAdeudos = async () => {
  try {
    /* TODO FUTURO: Query SQL original (Pascal líneas 440-442, 456-469)
    const response = await execute(
      'SELECT * FROM ta_13_adeudosrcm WHERE control_rcm = :control_rcm AND vigencia = ''S'' ORDER BY axo_adeudo DESC',
      'cementerio',
      [folioABuscar.value],
      'query',
      null,
      'public'
    )
    // Cálculo de totales en Pascal (líneas 456-469):
    // simporte := simporte + Qryadeudoimporte.Value
    // sdescto := sdescto + Qryadeudodescto_impote.Value
    // sdesctor := sdescto + Qryadeudodescto_recargos.Value
    // sreca := sreca + Qryadeudoimporte_recargos.Value
    */

    // Obtener año actual
    const anioActual = new Date().getFullYear()

    // Cargar adeudos usando SP (filtrados por año actual)
    const response = await execute(
      'sp_consultafol_listar_adeudos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
        { nombre: 'p_control_rcm', valor: anioActual, tipo: 'integer' }],
      'function',
      null,
      'public'
    )

    adeudos.value = response || []
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudos.value = []
  }
}

const limpiar = () => {
  folioABuscar.value = null
  datosfolio.value = null
  pagos.value = []
  adeudos.value = []
  hasSearched.value = false
  selectedRow.value = null
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

const formatNumber = (number) => {
  if (!number) return '0.00'
  return Number(number).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatCurrency = (number) => {
  if (!number) return '$0.00'
  return '$' + formatNumber(number)
}
</script>
