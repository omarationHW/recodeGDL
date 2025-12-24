<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Estadísticas de Contratos</h1>
        <p>Aseo Contratado - Análisis detallado del estado de los contratos</p>
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
        <h5>Filtros de Análisis</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Empresa</label>
            <select class="municipal-form-control" v-model="filtros.empresa">
              <option value="">Todas</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filtros.zona">
              <option value="">Todas</option>
              <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                Zona {{ z.zona }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.tipoAseo">
              <option value="">Todos</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="generarEstadisticas" :disabled="cargando">
              <font-awesome-icon icon="chart-bar" /> Generar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="estadisticas">
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.total_activos }}</div>
            <div class="stat-label-mini">Contratos Activos - {{ calcularPorcentaje(estadisticas.total_activos, estadisticas.total_general) }}% del total</div>
          </div>
        </div>
        <div class="stat-item stat-danger">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="ban" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.total_cancelados }}</div>
            <div class="stat-label-mini">Contratos Cancelados - {{ calcularPorcentaje(estadisticas.total_cancelados, estadisticas.total_general) }}% del total</div>
          </div>
        </div>
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(estadisticas.ingresos_mensuales) }}</div>
            <div class="stat-label-mini">Ingresos Mensuales - Solo contratos activos</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="chart-line" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(estadisticas.cuota_promedio) }}</div>
            <div class="stat-label-mini">Cuota Promedio - Promedio activos</div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Distribución por Tipo de Aseo</h5>
            </div>
            <div class="municipal-card-body">
              <div v-if="estadisticas.por_tipo && estadisticas.por_tipo.length > 0">
                <div v-for="tipo in estadisticas.por_tipo" :key="tipo.tipo_aseo" class="mb-3">
                  <div class="d-flex justify-content-between mb-1">
                    <strong>{{ formatTipoAseo(tipo.tipo_aseo) }}</strong>
                    <span>{{ tipo.cantidad }} contratos ({{ calcularPorcentaje(tipo.cantidad, estadisticas.total_general) }}%)</span>
                  </div>
                  <div class="progress" style="height: 25px;">
                    <div class="progress-bar" :class="getColorTipo(tipo.tipo_aseo)"
                      :style="{ width: calcularPorcentaje(tipo.cantidad, estadisticas.total_general) + '%' }">
                      ${{ formatCurrency(tipo.ingresos) }}
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="text-muted text-center">
                No hay datos disponibles
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
              <div v-if="estadisticas.por_zona && estadisticas.por_zona.length > 0">
                <div v-for="zona in estadisticas.por_zona" :key="zona.zona" class="mb-3">
                  <div class="d-flex justify-content-between mb-1">
                    <strong>Zona {{ zona.zona }}</strong>
                    <span>{{ zona.cantidad }} contratos ({{ calcularPorcentaje(zona.cantidad, estadisticas.total_general) }}%)</span>
                  </div>
                  <div class="progress" style="height: 25px;">
                    <div class="progress-bar bg-info"
                      :style="{ width: calcularPorcentaje(zona.cantidad, estadisticas.total_general) + '%' }">
                      ${{ formatCurrency(zona.ingresos) }}
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="text-muted text-center">
                No hay datos disponibles
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-12">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Análisis de Cuotas</h5>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-3">
                  <div class="text-center p-3 border rounded">
                    <h6 class="text-muted">Cuota Mínima</h6>
                    <h4 class="text-success">${{ formatCurrency(estadisticas.cuota_minima) }}</h4>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="text-center p-3 border rounded">
                    <h6 class="text-muted">Cuota Promedio</h6>
                    <h4 class="text-primary">${{ formatCurrency(estadisticas.cuota_promedio) }}</h4>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="text-center p-3 border rounded">
                    <h6 class="text-muted">Cuota Máxima</h6>
                    <h4 class="text-danger">${{ formatCurrency(estadisticas.cuota_maxima) }}</h4>
                  </div>
                </div>
                <div class="col-md-3">
                  <div class="text-center p-3 border rounded">
                    <h6 class="text-muted">Desviación Est.</h6>
                    <h4 class="text-warning">${{ formatCurrency(estadisticas.desviacion_std) }}</h4>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Resumen Ejecutivo</h6>
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
            <table class="municipal-table-bordered">
              <thead>
                <tr>
                  <th>Concepto</th>
                  <th class="text-end">Valor</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><strong>Total de Contratos</strong></td>
                  <td class="text-end">{{ estadisticas.total_general }}</td>
                </tr>
                <tr>
                  <td>Contratos Activos</td>
                  <td class="text-end">{{ estadisticas.total_activos }}</td>
                </tr>
                <tr>
                  <td>Contratos Cancelados</td>
                  <td class="text-end">{{ estadisticas.total_cancelados }}</td>
                </tr>
                <tr>
                  <td>Contratos con Adeudos</td>
                  <td class="text-end">{{ estadisticas.con_adeudos || 0 }}</td>
                </tr>
                <tr class="table-light">
                  <td><strong>Ingresos Mensuales Totales</strong></td>
                  <td class="text-end"><strong>${{ formatCurrency(estadisticas.ingresos_mensuales) }}</strong></td>
                </tr>
                <tr>
                  <td>Ingresos Anuales Proyectados</td>
                  <td class="text-end">${{ formatCurrency(estadisticas.ingresos_mensuales * 12) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Estadísticas de Contratos">
      <h6>Descripción</h6>
      <p>Genera análisis estadístico completo del estado actual de los contratos de aseo.</p>
      <h6>Información Incluida</h6>
      <ul>
        <li>Contratos activos vs cancelados</li>
        <li>Ingresos mensuales y proyecciones</li>
        <li>Distribución por tipo de aseo y zona</li>
        <li>Análisis de cuotas (mínima, promedio, máxima)</li>
        <li>Desviación estándar</li>
      </ul>
      <h6>Uso de Filtros</h6>
      <p>Puede filtrar por empresa, zona o tipo de aseo para análisis específicos.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
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
const estadisticas = ref(null)
const empresas = ref([])
const zonas = ref([])

const filtros = ref({
  empresa: '',
  zona: '',
  tipoAseo: ''
})

const generarEstadisticas = async () => {
  cargando.value = true
  try {
    const params = {
      p_empresa: filtros.value.empresa || null,
      p_zona: filtros.value.zona || null,
      p_tipo_aseo: filtros.value.tipoAseo || null
    }
    const response = await execute('SP_ASEO_ESTADISTICAS_CONTRATOS', 'aseo_contratado', params)

    if (response && response.length > 0) {
      estadisticas.value = response[0]
    } else {
      estadisticas.value = null
    }

    showToast('Estadísticas generadas correctamente', 'success')
  } catch (error) {
    handleError(error, 'Error al generar estadísticas')
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

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
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
    const [respEmpresas, respZonas] = await Promise.all([
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {})
    ])
    empresas.value = respEmpresas || []
    zonas.value = respZonas || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>

