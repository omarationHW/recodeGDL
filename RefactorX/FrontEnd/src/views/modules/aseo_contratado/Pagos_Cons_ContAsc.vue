<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="arrow-up-wide-short" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Ascendente de Pagos</h1>
        <p>Aseo Contratado - Historial de pagos ordenado cronológicamente (del más antiguo al más reciente)</p>
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
        <h5>Búsqueda de Contrato</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <input type="text" class="municipal-form-control" v-model="busqueda" @keyup.enter="buscar"
              placeholder="Número de contrato" />
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
        <div class="row">
          <div class="col-md-3">
            <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}
          </div>
          <div class="col-md-4">
            <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}
          </div>
          <div class="col-md-3">
            <strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}
          </div>
          <div class="col-md-2">
            <strong>Status:</strong>
            <span class="badge" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
              {{ contratoSeleccionado.status === 'A' ? 'Activo' : 'Inactivo' }}
            </span>
          </div>
        </div>
      </div>

      <div class="row mb-3">
        <div class="col-md-3">
          <div class="municipal-card bg-success text-white">
            <div class="municipal-card-body">
              <h6>Total Pagos</h6>
              <h2>{{ pagos.length }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-primary text-white">
            <div class="municipal-card-body">
              <h6>Monto Total Pagado</h6>
              <h2>${{ formatCurrency(montoTotal) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body">
              <h6>Primer Pago</h6>
              <h2>{{ formatFecha(primerPago) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-warning text-dark">
            <div class="municipal-card-body">
              <h6>Último Pago</h6>
              <h2>{{ formatFecha(ultimoPago) }}</h2>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <div>
            <h6 class="mb-0">Historial de Pagos (Orden Ascendente)</h6>
            <small class="text-muted">Mostrando desde el pago más antiguo hasta el más reciente</small>
          </div>
          <div>
            <button class="btn btn-sm btn-success me-2" @click="exportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table-sm table-striped">
              <thead>
                <tr>
                  <th>#</th>
                  <th>
                    Fecha Pago
                    <font-awesome-icon icon="arrow-up" class="text-success ms-1" />
                  </th>
                  <th>Recibo</th>
                  <th>Periodo Pagado</th>
                  <th>Forma Pago</th>
                  <th>Referencia</th>
                  <th class="text-end">Monto</th>
                  <th class="text-end">Acumulado</th>
                  <th>Usuario</th>
                  <th>Días Transcurridos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(pago, index) in pagos" :key="pago.control_pago">
                  <td>{{ index + 1 }}</td>
                  <td>{{ formatFechaCompleta(pago.fecha_pago) }}</td>
                  <td>
                    <span class="badge badge-primary">{{ pago.num_recibo }}</span>
                  </td>
                  <td>{{ pago.periodo }}</td>
                  <td>
                    <font-awesome-icon :icon="getIconoFormaPago(pago.forma_pago)" class="me-1" />
                    {{ pago.forma_pago }}
                  </td>
                  <td>{{ pago.referencia || 'N/A' }}</td>
                  <td class="text-end">${{ formatCurrency(pago.monto) }}</td>
                  <td class="text-end">
                    <strong>${{ formatCurrency(calcularAcumulado(index)) }}</strong>
                  </td>
                  <td>{{ pago.usuario }}</td>
                  <td>
                    <span v-if="index > 0" class="badge badge-secondary">
                      {{ calcularDiasTranscurridos(pagos[index-1].fecha_pago, pago.fecha_pago) }} días
                    </span>
                    <span v-else class="badge badge-info">Primer pago</span>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <th colspan="6" class="text-end">TOTAL:</th>
                  <th class="text-end">${{ formatCurrency(montoTotal) }}</th>
                  <th colspan="3"></th>
                </tr>
              </tfoot>
            </table>
          </div>

          <div v-if="pagos.length > 10" class="mt-3">
            <div class="alert alert-info">
              <font-awesome-icon icon="chart-line" class="me-2" />
              <strong>Análisis de Pagos:</strong>
              <ul class="mb-0 mt-2">
                <li>Promedio de pago: <strong>${{ formatCurrency(promedioMonto) }}</strong></li>
                <li>Promedio de días entre pagos: <strong>{{ promedioDias }} días</strong></li>
                <li>Periodo más largo sin pagar: <strong>{{ periodoMasLargo }} días</strong></li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta Ascendente de Pagos">
      <h6>Descripción</h6>
      <p>Muestra el historial completo de pagos de un contrato ordenado cronológicamente de forma ascendente (del más antiguo al más reciente).</p>
      <h6>Información Disponible</h6>
      <ul>
        <li>Orden cronológico ascendente de pagos</li>
        <li>Monto acumulado por cada pago</li>
        <li>Días transcurridos entre pagos consecutivos</li>
        <li>Análisis estadístico de comportamiento de pago</li>
      </ul>
      <h6>Utilidad</h6>
      <ul>
        <li>Análisis histórico de cumplimiento de pagos</li>
        <li>Identificación de patrones de pago</li>
        <li>Detección de periodos sin pagar</li>
        <li>Seguimiento de formas de pago utilizadas</li>
      </ul>
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
const contratoSeleccionado = ref(null)
const pagos = ref([])

const montoTotal = computed(() => pagos.value.reduce((sum, p) => sum + parseFloat(p.monto || 0), 0))
const primerPago = computed(() => pagos.value[0]?.fecha_pago || null)
const ultimoPago = computed(() => pagos.value[pagos.value.length - 1]?.fecha_pago || null)

const promedioMonto = computed(() => {
  return pagos.value.length > 0 ? montoTotal.value / pagos.value.length : 0
})

const promedioDias = computed(() => {
  if (pagos.value.length < 2) return 0
  let totalDias = 0
  for (let i = 1; i < pagos.value.length; i++) {
    totalDias += calcularDiasTranscurridos(pagos.value[i-1].fecha_pago, pagos.value[i].fecha_pago)
  }
  return Math.round(totalDias / (pagos.value.length - 1))
})

const periodoMasLargo = computed(() => {
  if (pagos.value.length < 2) return 0
  let maximo = 0
  for (let i = 1; i < pagos.value.length; i++) {
    const dias = calcularDiasTranscurridos(pagos.value[i-1].fecha_pago, pagos.value[i].fecha_pago)
    if (dias > maximo) maximo = dias
  }
  return maximo
})

const buscar = async () => {
  if (!busqueda.value) {
    return showToast('Ingrese un número de contrato', 'warning')
  }

  cargando.value = true
  try {
    const [respContrato] = await Promise.all([
      execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
        p_num_contrato: busqueda.value
      })
    ])
    if (respContrato?.length > 0) {
      contratoSeleccionado.value = respContrato[0]
      const respPagos = await execute('SP_ASEO_PAGOS_POR_CONTRATO_ASC', 'aseo_contratado', {
        p_control_contrato: respContrato[0].control_contrato
      })
      // Asegurar orden ascendente
      pagos.value = (respPagos || []).sort((a, b) =>
        new Date(a.fecha_pago) - new Date(b.fecha_pago)
      )
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

const calcularAcumulado = (index) => {
  return pagos.value.slice(0, index + 1).reduce((sum, p) => sum + parseFloat(p.monto || 0), 0)
}

const calcularDiasTranscurridos = (fecha1, fecha2) => {
  const d1 = new Date(fecha1)
  const d2 = new Date(fecha2)
  const diffTime = Math.abs(d2 - d1)
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24))
}

const getIconoFormaPago = (forma) => {
  const iconos = {
    'EFECTIVO': 'money-bill',
    'CHEQUE': 'money-check',
    'TRANSFERENCIA': 'exchange-alt',
    'TARJETA': 'credit-card',
    'DEPOSITO': 'university'
  }
  return iconos[forma] || 'circle'
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
}

const formatFechaCompleta = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}
</script>

