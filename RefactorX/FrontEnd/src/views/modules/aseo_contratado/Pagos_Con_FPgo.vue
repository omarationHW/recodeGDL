<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="credit-card" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos por Forma de Pago</h1>
        <p>Aseo Contratado - Análisis de pagos agrupados por método de pago</p>
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
        <h5>Filtros de Consulta</h5>
      </div>
<div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Desde</label>
            <input type="date" class="municipal-form-control" v-model="filtros.fechaDesde" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Hasta</label>
            <input type="date" class="municipal-form-control" v-model="filtros.fechaHasta" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Forma de Pago</label>
            <select class="municipal-form-control" v-model="filtros.formaPago">
              <option value="">Todas</option>
              <option value="EFECTIVO">Efectivo</option>
              <option value="CHEQUE">Cheque</option>
              <option value="TRANSFERENCIA">Transferencia</option>
              <option value="TARJETA">Tarjeta</option>
              <option value="DEPOSITO">Depósito</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="consultar" :disabled="cargando">
              <font-awesome-icon icon="search" /> Consultar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="pagos.length > 0">
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="money-bill" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.efectivo.value }}</div>
            <div class="stat-label-mini">Efectivo - ${{ formatCurrency(estadisticas.efectivo.monto) }}</div>
          </div>
        </div>
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="money-check" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.cheque.value }}</div>
            <div class="stat-label-mini">Cheque - ${{ formatCurrency(estadisticas.cheque.monto) }}</div>
          </div>
        </div>
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="exchange-alt" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.transferencia.value }}</div>
            <div class="stat-label-mini">Transferencia - ${{ formatCurrency(estadisticas.transferencia.monto) }}</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="credit-card" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.tarjeta.value }}</div>
            <div class="stat-label-mini">Tarjeta - ${{ formatCurrency(estadisticas.tarjeta.monto) }}</div>
          </div>
        </div>
        <div class="stat-item stat-secondary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="university" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.deposito.value }}</div>
            <div class="stat-label-mini">Depósito - ${{ formatCurrency(estadisticas.deposito.monto) }}</div>
          </div>
        </div>
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="coins" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.total.value }}</div>
            <div class="stat-label-mini">Total - ${{ formatCurrency(estadisticas.total.monto) }}</div>
          </div>
        </div>
      </div>

      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Resumen por Forma de Pago</h6>
          <button class="btn btn-sm btn-success" @click="exportarResumen">
            <font-awesome-icon icon="file-excel" /> Excel
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Forma de Pago</th>
                  <th class="text-end">Cantidad</th>
                  <th class="text-end">Monto Total</th>
                  <th class="text-end">Promedio</th>
                  <th class="text-end">% del Total</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="resumen in resumenPorFormaPago" :key="resumen.forma_pago">
                  <td>
                    <font-awesome-icon :icon="getIconoFormaPago(resumen.forma_pago)" class="me-2" />
                    <strong>{{ resumen.forma_pago }}</strong>
                  </td>
                  <td class="text-end">{{ resumen.cantidad }}</td>
                  <td class="text-end">${{ formatCurrency(resumen.monto_total) }}</td>
                  <td class="text-end">${{ formatCurrency(resumen.promedio) }}</td>
                  <td class="text-end">
                    <span class="badge badge-primary">{{ resumen.porcentaje }}%</span>
                  </td>
                  <td>
                    <button class="btn btn-sm btn-info" @click="verDetalle(resumen.forma_pago)">
                      <font-awesome-icon icon="eye" /> Ver Detalle
                    </button>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <th>TOTAL</th>
                  <th class="text-end">{{ totalGeneral.cantidad }}</th>
                  <th class="text-end">${{ formatCurrency(totalGeneral.monto) }}</th>
                  <th class="text-end">${{ formatCurrency(totalGeneral.promedio) }}</th>
                  <th class="text-end">100%</th>
                  <th></th>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div v-if="detalleSeleccionado" class="municipal-card">
        <div class="municipal-card-header bg-info text-white d-flex justify-content-between">
          <h6 class="mb-0">Detalle: {{ detalleSeleccionado }}</h6>
          <button class="btn btn-sm btn-light" @click="cerrarDetalle">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Fecha</th>
                  <th>Recibo</th>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>Referencia</th>
                  <th class="text-end">Monto</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagosFiltradosDetalle" :key="pago.control_pago">
                  <td>{{ formatFecha(pago.fecha_pago) }}</td>
                  <td>{{ pago.num_recibo }}</td>
                  <td>{{ pago.num_contrato }}</td>
                  <td>{{ pago.contribuyente }}</td>
                  <td>{{ pago.referencia || 'N/A' }}</td>
                  <td class="text-end">${{ formatCurrency(pago.monto) }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="d-flex justify-content-between align-items-center mt-3">
            <div>
              Mostrando {{ pagosFiltradosDetalle.length }} registros
            </div>
            <button class="btn btn-sm btn-success" @click="exportarDetalle">
              <font-awesome-icon icon="file-excel" /> Exportar Detalle
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="!cargando && consultaRealizada" class="alert alert-info">
      <font-awesome-icon icon="info-circle" class="me-2" />
      No se encontraron pagos con los criterios especificados.

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Consulta de Pagos por Forma de Pago">
      <h6>Descripción</h6>
      <p>Genera análisis estadístico de pagos agrupados por método de pago utilizado.</p>
      <h6>Formas de Pago</h6>
      <ul>
        <li><strong>Efectivo:</strong> Pagos en efectivo en caja</li>
        <li><strong>Cheque:</strong> Pagos mediante cheque</li>
        <li><strong>Transferencia:</strong> Transferencias electrónicas</li>
        <li><strong>Tarjeta:</strong> Pagos con tarjeta de débito/crédito</li>
        <li><strong>Depósito:</strong> Depósitos bancarios</li>
      </ul>
      <h6>Información Disponible</h6>
      <ul>
        <li>Cantidad de pagos por forma de pago</li>
        <li>Monto total y promedio</li>
        <li>Porcentaje del total recaudado</li>
        <li>Detalle completo de cada pago</li>
      </ul>
    </DocumentationModal>
  </div>
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
const consultaRealizada = ref(false)
const detalleSeleccionado = ref(null)

const filtros = ref({
  fechaDesde: '',
  fechaHasta: new Date().toISOString().split('T')[0],
  formaPago: ''
})

const pagos = ref([])

const resumenPorFormaPago = computed(() => {
  const grupos = {}
  pagos.value.forEach(pago => {
    const forma = pago.forma_pago || 'SIN ESPECIFICAR'
    if (!grupos[forma]) {
      grupos[forma] = {
        forma_pago: forma,
        cantidad: 0,
        monto_total: 0
      }
    }
    grupos[forma].cantidad++
    grupos[forma].monto_total += parseFloat(pago.monto || 0)
  })

  const total = Object.values(grupos).reduce((sum, g) => sum + g.monto_total, 0)

  return Object.values(grupos).map(grupo => ({
    ...grupo,
    promedio: grupo.monto_total / grupo.cantidad,
    porcentaje: ((grupo.monto_total / total) * 100).toFixed(2)
  })).sort((a, b) => b.monto_total - a.monto_total)
})

const estadisticas = computed(() => {
  const total = pagos.value.length
  const montoTotal = pagos.value.reduce((sum, p) => sum + parseFloat(p.monto || 0), 0)

  const porForma = {}
  pagos.value.forEach(p => {
    const forma = p.forma_pago || 'OTRO'
    porForma[forma] = (porForma[forma] || 0) + parseFloat(p.monto || 0)
  })

  return {
    efectivo: {
      label: 'Efectivo',
      value: pagos.value.filter(p => p.forma_pago === 'EFECTIVO').length,
      monto: porForma['EFECTIVO'] || 0,
      color: 'success'
    },
    cheque: {
      label: 'Cheque',
      value: pagos.value.filter(p => p.forma_pago === 'CHEQUE').length,
      monto: porForma['CHEQUE'] || 0,
      color: 'primary'
    },
    transferencia: {
      label: 'Transferencia',
      value: pagos.value.filter(p => p.forma_pago === 'TRANSFERENCIA').length,
      monto: porForma['TRANSFERENCIA'] || 0,
      color: 'info'
    },
    tarjeta: {
      label: 'Tarjeta',
      value: pagos.value.filter(p => p.forma_pago === 'TARJETA').length,
      monto: porForma['TARJETA'] || 0,
      color: 'warning'
    },
    deposito: {
      label: 'Depósito',
      value: pagos.value.filter(p => p.forma_pago === 'DEPOSITO').length,
      monto: porForma['DEPOSITO'] || 0,
      color: 'secondary'
    },
    total: {
      label: 'Total',
      value: total,
      monto: montoTotal,
      color: 'dark'
    }
  }
})

const totalGeneral = computed(() => {
  const total = pagos.value.reduce((sum, p) => sum + parseFloat(p.monto || 0), 0)
  return {
    cantidad: pagos.value.length,
    monto: total,
    promedio: pagos.value.length > 0 ? total / pagos.value.length : 0
  }
})

const pagosFiltradosDetalle = computed(() => {
  if (!detalleSeleccionado.value) return []
  return pagos.value.filter(p => p.forma_pago === detalleSeleccionado.value)
})

const consultar = async () => {
  if (!filtros.value.fechaHasta) {
    return showToast('Seleccione al menos la fecha hasta', 'warning')
  }

  cargando.value = true
  consultaRealizada.value = false
  try {
    const response = await execute('SP_ASEO_PAGOS_POR_FORMA_PAGO', 'aseo_contratado', {
      p_fecha_desde: filtros.value.fechaDesde || null,
      p_fecha_hasta: filtros.value.fechaHasta,
      p_forma_pago: filtros.value.formaPago || null
    })
    pagos.value = response || []
    consultaRealizada.value = true
    detalleSeleccionado.value = null
    showToast(`${pagos.value.length} pago(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al consultar pagos')
  } finally {
    cargando.value = false
  }
}

const verDetalle = (formaPago) => {
  detalleSeleccionado.value = formaPago
}

const cerrarDetalle = () => {
  detalleSeleccionado.value = null
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

const exportarResumen = () => {
  showToast('Exportando resumen a Excel...', 'info')
}

const exportarDetalle = () => {
  showToast('Exportando detalle a Excel...', 'info')
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  return fecha ? new Date(fecha).toLocaleDateString('es-MX') : 'N/A'
}
</script>

