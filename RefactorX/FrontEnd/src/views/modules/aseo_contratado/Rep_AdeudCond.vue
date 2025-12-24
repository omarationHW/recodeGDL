<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos Condonados</h1>
        <p>Aseo Contratado - Historial de condonaciones aplicadas a contratos</p>
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
        <h5>Parámetros del Reporte</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Desde</label>
            <input type="date" class="municipal-form-control" v-model="parametros.fechaDesde" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Hasta</label>
            <input type="date" class="municipal-form-control" v-model="parametros.fechaHasta" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="parametros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="parametros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="generarReporte" :disabled="cargando">
              <font-awesome-icon icon="file-invoice-dollar" /> Generar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="datosReporte.length > 0">
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-lines" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosReporte.length }}</div>
            <div class="stat-label-mini">Total Condonaciones</div>
          </div>
        </div>
        <div class="stat-item stat-danger">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(montoTotalCondonado) }}</div>
            <div class="stat-label-mini">Monto Total Condonado</div>
          </div>
        </div>
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="calculator" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(promedioCondonacion) }}</div>
            <div class="stat-label-mini">Promedio por Condonación</div>
          </div>
        </div>
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="users" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ contratosBeneficiados }}</div>
            <div class="stat-label-mini">Contratos Beneficiados</div>
          </div>
        </div>
      </div>

      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Detalle de Condonaciones</h6>
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
            <table class="municipal-table-sm table-bordered table-hover">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Fecha</th>
                  <th>Contrato</th>
                  <th>Contribuyente</th>
                  <th>Zona</th>
                  <th>Tipo</th>
                  <th class="text-end">Monto Condonado</th>
                  <th class="text-end">Periodos</th>
                  <th>Motivo</th>
                  <th>Autorizado Por</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in datosReporte" :key="index">
                  <td>{{ index + 1 }}</td>
                  <td>{{ formatFecha(item.fecha_condonacion) }}</td>
                  <td>{{ item.num_contrato }}</td>
                  <td>{{ item.contribuyente }}</td>
                  <td class="text-center">{{ item.zona }}</td>
                  <td class="text-center">{{ formatTipoAseo(item.tipo_aseo) }}</td>
                  <td class="text-end">
                    <strong class="text-danger">${{ formatCurrency(item.monto_condonado) }}</strong>
                  </td>
                  <td class="text-end">{{ item.periodos_condonados }}</td>
                  <td>{{ item.motivo_condonacion }}</td>
                  <td>{{ item.autorizado_por }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <th colspan="6" class="text-end">TOTALES:</th>
                  <th class="text-end">${{ formatCurrency(montoTotalCondonado) }}</th>
                  <th class="text-end">{{ totalPeriodos }}</th>
                  <th colspan="2"></th>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Distribución por Tipo de Aseo</h5>
            </div>
            <div class="municipal-card-body">
              <div v-for="tipo in resumenPorTipo" :key="tipo.tipo_aseo" class="mb-3">
                <div class="d-flex justify-content-between mb-1">
                  <span><strong>{{ formatTipoAseo(tipo.tipo_aseo) }}</strong></span>
                  <span>{{ tipo.cantidad }} condonaciones - ${{ formatCurrency(tipo.monto) }}</span>
                </div>
                <div class="progress" style="height: 25px;">
                  <div class="progress-bar" :class="getColorTipo(tipo.tipo_aseo)"
                    :style="{ width: calcularPorcentaje(tipo.monto, montoTotalCondonado) + '%' }">
                    {{ calcularPorcentaje(tipo.monto, montoTotalCondonado) }}%
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Distribución por Zona</h5>
            </div>
            <div class="municipal-card-body">
              <div v-for="zona in resumenPorZona" :key="zona.zona" class="mb-3">
                <div class="d-flex justify-content-between mb-1">
                  <span><strong>Zona {{ zona.zona }}</strong></span>
                  <span>{{ zona.cantidad }} condonaciones - ${{ formatCurrency(zona.monto) }}</span>
                </div>
                <div class="progress" style="height: 25px;">
                  <div class="progress-bar bg-warning"
                    :style="{ width: calcularPorcentaje(zona.monto, montoTotalCondonado) + '%' }">
                    {{ calcularPorcentaje(zona.monto, montoTotalCondonado) }}%
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Reporte de Adeudos Condonados">
      <h6>Descripción</h6>
      <p>Genera reporte detallado de todas las condonaciones de adeudos aplicadas a contratos de aseo.</p>
      <h6>Información Incluida</h6>
      <ul>
        <li>Fecha y monto de cada condonación</li>
        <li>Contrato y contribuyente beneficiado</li>
        <li>Número de periodos condonados</li>
        <li>Motivo de la condonación</li>
        <li>Funcionario que autorizó</li>
        <li>Estadísticas por tipo y zona</li>
      </ul>
      <h6>Filtros Disponibles</h6>
      <ul>
        <li>Rango de fechas de condonación</li>
        <li>Zona específica</li>
        <li>Tipo de aseo</li>
      </ul>
      <h6>Uso</h6>
      <p>Este reporte es útil para auditorías y control de las condonaciones autorizadas.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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
const datosReporte = ref([])
const zonas = ref([])

const parametros = ref({
  fechaDesde: '',
  fechaHasta: new Date().toISOString().split('T')[0],
  zona: '',
  tipoAseo: ''
})

const montoTotalCondonado = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseFloat(item.monto_condonado || 0), 0)
})

const promedioCondonacion = computed(() => {
  return datosReporte.value.length > 0 ? montoTotalCondonado.value / datosReporte.value.length : 0
})

const contratosBeneficiados = computed(() => {
  const contratos = new Set(datosReporte.value.map(item => item.control_contrato))
  return contratos.size
})

const totalPeriodos = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseInt(item.periodos_condonados || 0), 0)
})

const resumenPorTipo = computed(() => {
  const agrupado = {}
  datosReporte.value.forEach(item => {
    if (!agrupado[item.tipo_aseo]) {
      agrupado[item.tipo_aseo] = { tipo_aseo: item.tipo_aseo, cantidad: 0, monto: 0 }
    }
    agrupado[item.tipo_aseo].cantidad++
    agrupado[item.tipo_aseo].monto += parseFloat(item.monto_condonado || 0)
  })
  return Object.values(agrupado).sort((a, b) => b.monto - a.monto)
})

const resumenPorZona = computed(() => {
  const agrupado = {}
  datosReporte.value.forEach(item => {
    if (!agrupado[item.zona]) {
      agrupado[item.zona] = { zona: item.zona, cantidad: 0, monto: 0 }
    }
    agrupado[item.zona].cantidad++
    agrupado[item.zona].monto += parseFloat(item.monto_condonado || 0)
  })
  return Object.values(agrupado).sort((a, b) => b.monto - a.monto)
})

const generarReporte = async () => {
  if (!parametros.value.fechaHasta) {
    return showToast('Debe especificar al menos la fecha hasta', 'warning')
  }

  cargando.value = true
  try {
    const params = {
      p_fecha_desde: parametros.value.fechaDesde || null,
      p_fecha_hasta: parametros.value.fechaHasta,
      p_zona: parametros.value.zona || null,
      p_tipo_aseo: parametros.value.tipoAseo || null
    }
    const response = await execute('SP_ASEO_REPORTE_ADEUDOS_CONDONADOS', 'aseo_contratado', params)
    datosReporte.value = response || []
    showToast(`Reporte generado: ${datosReporte.value.length} condonaciones`, 'success')
  } catch (error) {
    handleError(error, 'Error al generar reporte')
  } finally {
    cargando.value = false
  }
}

const calcularPorcentaje = (parte, total) => {
  if (!total || total === 0) return '0.00'
  return ((parte / total) * 100).toFixed(2)
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Dom', 'C': 'Com', 'I': 'Ind', 'S': 'Ser' }
  return tipos[tipo] || tipo
}

const getColorTipo = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    zonas.value = response || []
  } catch (error) {
    console.error('Error al cargar zonas:', error)
  }
})
</script>

