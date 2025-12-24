<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="receipt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos por Contrato</h1>
        <p>Aseo Contratado - Historial de pagos realizados</p>
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
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Búsqueda</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <input type="text" class="municipal-form-control" v-model="busqueda" @keyup.enter="buscar"
              placeholder="Número de contrato" />
          </div>
          <div class="col-md-3">
            <input type="date" class="municipal-form-control" v-model="fechaDesde" />
          </div>
          <div class="col-md-3">
            <input type="date" class="municipal-form-control" v-model="fechaHasta" />
          </div>
          <div class="col-md-2">
            <button class="btn-municipal-primary w-100" @click="buscar" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contratoSeleccionado">
      <div class="alert alert-info">
        <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }} -
        <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}
      </div>

      <div class="row mb-3">
        <div class="col-md-4">
          <div class="municipal-card bg-success text-white">
            <div class="municipal-card-body">
              <h6>Total Pagos</h6>
              <h2>{{ pagos.length }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="municipal-card bg-primary text-white">
            <div class="municipal-card-body">
              <h6>Monto Total</h6>
              <h2>${{ formatCurrency(montoTotal) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body">
              <h6>Último Pago</h6>
              <h2>{{ formatFecha(ultimoPago) }}</h2>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Historial de Pagos</h6>
          <button class="btn btn-sm btn-success" @click="exportar">
            <font-awesome-icon icon="file-excel" /> Excel
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Fecha Pago</th>
                  <th>Recibo</th>
                  <th>Periodo</th>
                  <th>Forma Pago</th>
                  <th>Referencia</th>
                  <th class="text-end">Monto</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id">
                  <td>{{ formatFecha(pago.fecha_pago) }}</td>
                  <td>{{ pago.num_recibo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.forma_pago }}</td>
                  <td>{{ pago.referencia || 'N/A' }}</td>
                  <td class="text-end">${{ formatCurrency(pago.monto) }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta de Pagos">
      <p>Consulte el historial completo de pagos realizados por un contrato.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const busqueda = ref('')
const fechaDesde = ref('')
const fechaHasta = ref(new Date().toISOString().split('T')[0])
const contratoSeleccionado = ref(null)
const pagos = ref([])

const montoTotal = computed(() => pagos.value.reduce((sum, p) => sum + parseFloat(p.monto || 0), 0))
const ultimoPago = computed(() => pagos.value[0]?.fecha_pago || null)

const buscar = async () => {
  if (!busqueda.value) return showToast('Ingrese un número de contrato', 'warning')
  cargando.value = true
  try {
    const [respContrato] = await Promise.all([
      execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', { p_num_contrato: busqueda.value })
    ])
    if (respContrato?.length > 0) {
      contratoSeleccionado.value = respContrato[0]
      const respPagos = await execute('SP_ASEO_PAGOS_POR_CONTRATO', 'aseo_contratado', {
        p_control_contrato: respContrato[0].control_contrato,
        p_fecha_desde: fechaDesde.value || null,
        p_fecha_hasta: fechaHasta.value
      })
      pagos.value = respPagos || []
      showToast(`${pagos.value.length} pago(s) encontrado(s)`, 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
    }
  } catch (error) {
    handleError(error, 'Error al buscar')
  } finally {
    cargando.value = false
  }
}

const exportar = () => showToast('Exportando...', 'info')
const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
const formatFecha = (fecha) => fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
</script>
