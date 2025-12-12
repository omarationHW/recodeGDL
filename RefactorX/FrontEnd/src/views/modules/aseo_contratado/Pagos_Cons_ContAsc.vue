<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="arrow-up-wide-short" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos por Contrato (Ascendente)</h1>
        <p>Aseo Contratado - Historial de pagos ordenado por numero de contrato ascendente</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Busqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="search-row">
            <div class="search-field">
              <label class="municipal-label">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control">
                <option value="">Seleccione...</option>
                <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo_id" :value="tipo.tipo_aseo_id">
                  {{ tipo.tipo_aseo_id }} - {{ tipo.cve_tipo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="search-field">
              <label class="municipal-label">Numero de Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Numero inicial"
                @keyup.enter="buscarContratos"
              />
            </div>
            <div class="search-field search-field-buttons">
              <button type="button" class="btn-municipal-primary" @click="buscarContratos" :disabled="cargando">
                <font-awesome-icon :icon="cargando ? 'spinner' : 'search'" :spin="cargando" />
                Buscar
              </button>
              <button type="button" class="btn-municipal-secondary" @click="salir">
                <font-awesome-icon icon="door-open" /> Salir
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Navegador de Contratos -->
      <div v-if="contratos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-contract" /> Contrato Actual</h5>
        </div>
        <div class="municipal-card-body">
          <div class="navigator-row">
            <div class="navigator-buttons">
              <button type="button" class="btn-municipal-secondary" @click="irPrimero" :disabled="indiceContrato === 0" title="Primero">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button type="button" class="btn-municipal-secondary" @click="irAnterior" :disabled="indiceContrato === 0" title="Anterior">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button type="button" class="btn-municipal-secondary" @click="irSiguiente" :disabled="indiceContrato >= contratos.length - 1" title="Siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button type="button" class="btn-municipal-secondary" @click="irUltimo" :disabled="indiceContrato >= contratos.length - 1" title="Ultimo">
                <font-awesome-icon icon="angle-double-right" />
              </button>
              <span class="navigator-info">
                {{ indiceContrato + 1 }} de {{ contratos.length }}
              </span>
            </div>
            <div class="contract-info">
              <div class="info-item">
                <span class="info-label">Contrato:</span>
                <span class="info-value info-value-highlight">{{ contratoActual?.num_contrato }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Tipo:</span>
                <span class="info-value">{{ contratoActual?.tipo_aseo }} - {{ contratoActual?.descripcion }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Grid de Pagos -->
      <div v-if="pagos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="money-bill-wave" /> Pagos Realizados (Status P)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-container">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Periodo</th>
                  <th>Operacion</th>
                  <th>Exed.</th>
                  <th>Importe</th>
                  <th>Status</th>
                  <th>Fecha Pago</th>
                  <th>Ofna</th>
                  <th>Caja</th>
                  <th>Consec. Op.</th>
                  <th>Folio Rcbo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.control_contrato + '-' + pago.aso_mes_pago + '-' + pago.ctrol_operacion">
                  <td>{{ formatPeriodo(pago.aso_mes_pago) }}</td>
                  <td>{{ pago.descripcion }}</td>
                  <td class="text-center">{{ pago.exedencias || 0 }}</td>
                  <td class="text-right">${{ formatCurrency(pago.importe) }}</td>
                  <td class="text-center">{{ pago.status_vigencia }}</td>
                  <td>{{ formatFecha(pago.fecha_hora_pago) }}</td>
                  <td class="text-center">{{ pago.id_rec }}</td>
                  <td class="text-center">{{ pago.caja }}</td>
                  <td class="text-center">{{ pago.consec_operacion }}</td>
                  <td>{{ pago.folio_rcbo }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="table-footer">
            <span>Total registros: {{ pagos.length }}</span>
          </div>
        </div>
      </div>

      <!-- Mensaje sin datos -->
      <div v-if="contratos.length > 0 && pagos.length === 0" class="municipal-alert municipal-alert-info mt-3">
        <font-awesome-icon icon="info-circle" />
        No hay pagos registrados para este contrato con status "P" (Pagado).
      </div>

      <!-- Mensaje sin contratos -->
      <div v-if="buscado && contratos.length === 0" class="municipal-alert municipal-alert-warning mt-3">
        <font-awesome-icon icon="exclamation-triangle" />
        No se encontraron contratos con numero >= {{ numContrato }} para el tipo de aseo seleccionado.
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Consulta Pagos Ascendente"
      componentName="Pagos_Cons_ContAsc"
    >
      <h3>Consulta de Pagos por Contrato (Ascendente)</h3>
      <p>Este modulo permite consultar los pagos realizados de contratos de aseo ordenados de forma ascendente por numero de contrato.</p>

      <h4>Uso:</h4>
      <ol>
        <li>Seleccione el tipo de aseo</li>
        <li>Ingrese el numero de contrato inicial</li>
        <li>Presione "Buscar"</li>
        <li>Use los botones de navegacion para moverse entre contratos</li>
        <li>Al cambiar de contrato se actualizan los pagos automaticamente</li>
      </ol>

      <h4>Informacion Mostrada:</h4>
      <ul>
        <li><strong>Periodo:</strong> Mes/Anio del pago</li>
        <li><strong>Operacion:</strong> Tipo de operacion realizada</li>
        <li><strong>Exedencias:</strong> Numero de unidades adicionales</li>
        <li><strong>Importe:</strong> Monto del pago</li>
        <li><strong>Status:</strong> P=Pagado</li>
        <li><strong>Fecha Pago:</strong> Fecha y hora del pago</li>
        <li><strong>Oficina/Caja:</strong> Lugar de pago</li>
        <li><strong>Folio Recibo:</strong> Numero de recibo</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Estado
const showDocumentation = ref(false)
const cargando = ref(false)
const buscado = ref(false)
const tiposAseo = ref([])
const tipoAseoSeleccionado = ref('')
const numContrato = ref(null)
const contratos = ref([])
const indiceContrato = ref(0)
const pagos = ref([])

// Contrato actual
const contratoActual = ref(null)

// Cargar tipos de aseo al montar
onMounted(async () => {
  await cargarTiposAseo()
})

// Watch para cambio de contrato
watch(indiceContrato, () => {
  if (contratos.value.length > 0) {
    contratoActual.value = contratos.value[indiceContrato.value]
    cargarPagos()
  }
})

// Cargar tipos de aseo
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo', BASE_DB, [], '', null, SCHEMA)
    tiposAseo.value = data || []
    // Seleccionar el tercero por defecto (indice 2) como en Delphi
    if (tiposAseo.value.length > 2) {
      tipoAseoSeleccionado.value = tiposAseo.value[2].tipo_aseo_id
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

// Buscar contratos
const buscarContratos = async () => {
  if (!tipoAseoSeleccionado.value) {
    showToast('Seleccione un tipo de aseo', 'warning')
    return
  }
  if (!numContrato.value || numContrato.value <= 0) {
    showToast('Ingrese un numero de contrato valido', 'warning')
    return
  }

  cargando.value = true
  buscado.value = true
  showLoading()

  try {
    const params = [
      { nombre: 'p_tipo_aseo_id', valor: tipoAseoSeleccionado.value, tipo: 'integer' },
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' }
    ]

    const data = await execute('sp_aseo_contratos_ascendente', BASE_DB, params, '', null, SCHEMA)
    contratos.value = data || []

    hideLoading()

    if (contratos.value.length > 0) {
      indiceContrato.value = 0
      contratoActual.value = contratos.value[0]
      await cargarPagos()
      showToast(`${contratos.value.length} contrato(s) encontrado(s)`, 'success')
    } else {
      pagos.value = []
      contratoActual.value = null
      showToast('No se encontraron contratos', 'info')
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al buscar contratos')
  } finally {
    cargando.value = false
  }
}

// Cargar pagos del contrato actual
const cargarPagos = async () => {
  if (!contratoActual.value) {
    pagos.value = []
    return
  }

  try {
    const params = [
      { nombre: 'p_control_contrato', valor: contratoActual.value.control_contrato, tipo: 'integer' }
    ]

    const data = await execute('sp_aseo_pagos_contrato', BASE_DB, params, '', null, SCHEMA)
    pagos.value = data || []
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar pagos')
    pagos.value = []
  }
}

// Navegacion
const irPrimero = () => {
  indiceContrato.value = 0
}

const irAnterior = () => {
  if (indiceContrato.value > 0) {
    indiceContrato.value--
  }
}

const irSiguiente = () => {
  if (indiceContrato.value < contratos.value.length - 1) {
    indiceContrato.value++
  }
}

const irUltimo = () => {
  indiceContrato.value = contratos.value.length - 1
}

// Formateo
const formatPeriodo = (fecha) => {
  if (!fecha) return ''
  const d = new Date(fecha)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

const formatFecha = (fecha) => {
  if (!fecha) return ''
  const d = new Date(fecha)
  return d.toLocaleDateString('es-MX') + ' ' + d.toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' })
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0)
}

// Salir
const salir = () => {
  router.push('/aseo-contratado')
}
</script>
