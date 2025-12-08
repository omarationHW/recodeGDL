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
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
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
              :disabled="loading || !folioABuscar"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
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
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="money-bill-wave" />
            Historial de Pagos ({{ pagos.length }})
          </h5>
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
                <tr v-for="(pago, index) in pagos" :key="index">
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
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" />
            Adeudos ({{ adeudos.length }})
          </h5>
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
                <tr v-for="(adeudo, index) in adeudos" :key="index" :class="{'table-warning': adeudo.pagado === 'N'}">
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
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Consulta de Folio"
    >
      <h6>Descripción</h6>
      <p>Módulo para consultar información completa de un folio/cuenta RCM en cementerios municipales.</p>

      <h6>Funcionalidades</h6>
      <ul>
        <li>Búsqueda de folio por número de control RCM</li>
        <li>Visualización completa de datos de la fosa</li>
        <li>Información del propietario</li>
        <li>Historial completo de pagos</li>
        <li>Listado de adeudos (pagados y pendientes)</li>
        <li>Resumen financiero con totales</li>
      </ul>

      <h6>Instrucciones</h6>
      <ol>
        <li>Ingrese el número de folio (control RCM)</li>
        <li>Haga clic en "Buscar" o presione Enter</li>
        <li>Revise la información de la fosa y propietario</li>
        <li>Consulte el historial de pagos y adeudos</li>
        <li>Verifique el resumen financiero</li>
      </ol>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ConsultaFol'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const folioABuscar = ref(null)
const datosfolio = ref(null)
const pagos = ref([])
const adeudos = ref([])
const mostrarAyuda = ref(false)

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
    showToast('Debe ingresar un número de folio', 'warning')
    return
  }

  loading.value = true
  try {
    // Consultar datos del folio
    const response = await execute(
      'sp_cem_consultar_folio',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value
      },
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.resultado === 'S') {
        datosfolio.value = result
        showToast(result.mensaje, 'success')

        // Cargar pagos
        await cargarPagos()

        // Cargar adeudos
        await cargarAdeudos()
      } else {
        showToast(result.mensaje, 'error')
        datosfolio.value = null
        pagos.value = []
        adeudos.value = []
      }
    }
  } catch (error) {
    showToast('Error al buscar folio: ' + error.message, 'error')
    datosfolio.value = null
    pagos.value = []
    adeudos.value = []
  } finally {
    loading.value = false
  }
}

const cargarPagos = async () => {
  try {
    const response = await execute(
      'sp_cem_obtener_pagos_folio',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value
      },
      '',
      null,
      'comun'
    )

    pagos.value = response.result || []
  } catch (error) {
    pagos.value = []
  }
}

const cargarAdeudos = async () => {
  try {
    const response = await execute(
      'sp_cem_obtener_adeudos_folio',
      'cementerios',
      {
        p_control_rcm: folioABuscar.value
      },
      '',
      null,
      'comun'
    )

    adeudos.value = response || []
  } catch (error) {
    adeudos.value = []
  }
}

const limpiar = () => {
  folioABuscar.value = null
  datosfolio.value = null
  pagos.value = []
  adeudos.value = []
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

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
