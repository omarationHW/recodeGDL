<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-pie" />
      </div>
      <div class="module-view-info">
        <h1>Estadísticas Generales</h1>
        <p>Aseo Contratado - Dashboard ejecutivo del sistema</p>
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

    <!-- Botón de actualización -->
    <div class="mb-3 text-end">
      <button class="btn-municipal-primary" @click="actualizarDatos">
        <font-awesome-icon icon="refresh" class="me-2" /> Actualizar Datos
      </button>
    </div>

    <div v-if="cargando" class="text-center py-5">
      <div class="spinner-border text-success" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-3">Generando estadísticas generales...</p>
    </div>

    <div v-else-if="datosGenerales">
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="building" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosGenerales.total_empresas }}</div>
            <div class="stat-label-mini">Empresas</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="map-marker-alt" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosGenerales.total_zonas }}</div>
            <div class="stat-label-mini">Zonas</div>
          </div>
        </div>
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosGenerales.contratos_activos }}</div>
            <div class="stat-label-mini">Activos</div>
          </div>
        </div>
        <div class="stat-item stat-danger">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="times-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosGenerales.contratos_cancelados }}</div>
            <div class="stat-label-mini">Cancelados</div>
          </div>
        </div>
        <div class="stat-item stat-secondary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="exclamation-triangle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosGenerales.contratos_adeudos }}</div>
            <div class="stat-label-mini">Con Adeudo</div>
          </div>
        </div>
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ datosGenerales.total_contratos }}</div>
            <div class="stat-label-mini">Total</div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-4">
          <div class="municipal-card shadow-sm border-0">
            <div class="municipal-card-body">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <h6 class="text-muted mb-0">Ingresos Mensuales</h6>
                  <h3 class="text-success mb-0">${{ formatCurrency(datosGenerales.ingresos_mensuales) }}</h3>
                </div>
                <div class="bg-success bg-opacity-10 p-3 rounded">
                  <font-awesome-icon icon="dollar-sign" size="2x" class="text-success" />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="municipal-card shadow-sm border-0">
            <div class="municipal-card-body">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <h6 class="text-muted mb-0">Ingresos Anuales</h6>
                  <h3 class="text-primary mb-0">${{ formatCurrency(datosGenerales.ingresos_mensuales * 12) }}</h3>
                </div>
                <div class="bg-primary bg-opacity-10 p-3 rounded">
                  <font-awesome-icon icon="chart-line" size="2x" class="text-primary" />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="municipal-card shadow-sm border-0">
            <div class="municipal-card-body">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <h6 class="text-muted mb-0">Cuota Promedio</h6>
                  <h3 class="text-info mb-0">${{ formatCurrency(datosGenerales.cuota_promedio) }}</h3>
                </div>
                <div class="bg-info bg-opacity-10 p-3 rounded">
                  <font-awesome-icon icon="calculator" size="2x" class="text-info" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>
                <font-awesome-icon icon="trash" class="me-2" />
                Distribución por Tipo de Aseo
              </h5>
            </div>
<div class="municipal-card-body">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Tipo</th>
                    <th class="text-end">Contratos</th>
                    <th class="text-end">%</th>
                    <th class="text-end">Ingresos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="tipo in porTipo" :key="tipo.tipo_aseo">
                    <td>
                      <span class="badge" :class="getBadgeColor(tipo.tipo_aseo)">
                        {{ formatTipoAseo(tipo.tipo_aseo) }}
                      </span>
                    </td>
                    <td class="text-end">{{ tipo.cantidad }}</td>
                    <td class="text-end">{{ calcularPorcentaje(tipo.cantidad, datosGenerales.total_contratos) }}%</td>
                    <td class="text-end">${{ formatCurrency(tipo.ingresos) }}</td>
                  </tr>
                </tbody>
              </table>
              <div v-for="tipo in porTipo" :key="'bar-' + tipo.tipo_aseo" class="mb-2">
                <div class="progress" style="height: 20px;">
                  <div class="progress-bar" :class="getProgressColor(tipo.tipo_aseo)"
                    :style="{ width: calcularPorcentaje(tipo.cantidad, datosGenerales.total_contratos) + '%' }">
                    {{ tipo.cantidad }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>
                <font-awesome-icon icon="map" class="me-2" />
                Top 10 Zonas por Contratos
              </h5>
            </div>
            <div class="municipal-card-body">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Zona</th>
                    <th class="text-end">Contratos</th>
                    <th class="text-end">%</th>
                    <th class="text-end">Ingresos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(zona, index) in topZonas" :key="zona.zona">
                    <td>
                      <span class="badge badge-secondary">{{ zona.zona }}</span>
                    </td>
                    <td class="text-end">{{ zona.cantidad }}</td>
                    <td class="text-end">{{ calcularPorcentaje(zona.cantidad, datosGenerales.total_contratos) }}%</td>
                    <td class="text-end">${{ formatCurrency(zona.ingresos) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-12">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>
                <font-awesome-icon icon="building-columns" class="me-2" />
                Resumen por Empresa
              </h5>
            </div>
            <div class="municipal-card-body">
              <div class="table-responsive">
                <table class="municipal-table-bordered">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Empresa</th>
                      <th class="text-end">Contratos Activos</th>
                      <th class="text-end">Contratos Cancelados</th>
                      <th class="text-end">Total Contratos</th>
                      <th class="text-end">Ingresos Mensuales</th>
                      <th class="text-end">% Participación</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(emp, index) in porEmpresa" :key="emp.num_empresa">
                      <td>{{ index + 1 }}</td>
                      <td>{{ emp.nombre_empresa }}</td>
                      <td class="text-end">{{ emp.activos }}</td>
                      <td class="text-end">{{ emp.cancelados }}</td>
                      <td class="text-end"><strong>{{ emp.total }}</strong></td>
                      <td class="text-end">${{ formatCurrency(emp.ingresos) }}</td>
                      <td class="text-end">
                        <span class="badge badge-primary">{{ calcularPorcentaje(emp.total, datosGenerales.total_contratos) }}%</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>
            <font-awesome-icon icon="info-circle" class="me-2" />
            Información Adicional
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6">
              <p><strong>Última Actualización:</strong> {{ new Date().toLocaleString('es-MX') }}</p>
              <p><strong>Tasa de Activación:</strong> {{ calcularPorcentaje(datosGenerales.contratos_activos, datosGenerales.total_contratos) }}%</p>
              <p><strong>Tasa de Cancelación:</strong> {{ calcularPorcentaje(datosGenerales.contratos_cancelados, datosGenerales.total_contratos) }}%</p>
            </div>
            <div class="col-md-6">
              <p><strong>Cuota Mínima:</strong> ${{ formatCurrency(datosGenerales.cuota_minima) }}</p>
              <p><strong>Cuota Máxima:</strong> ${{ formatCurrency(datosGenerales.cuota_maxima) }}</p>
              <p><strong>Contratos con Adeudos:</strong> {{ datosGenerales.contratos_adeudos }} ({{ calcularPorcentaje(datosGenerales.contratos_adeudos, datosGenerales.contratos_activos) }}% de activos)</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Estadísticas Generales">
      <h6>Descripción</h6>
      <p>Dashboard ejecutivo con análisis completo del sistema de aseo contratado.</p>
      <h6>Información Presentada</h6>
      <ul>
        <li>Resumen de contratos por estado</li>
        <li>Proyecciones de ingresos mensuales y anuales</li>
        <li>Distribución por tipo de aseo</li>
        <li>Top 10 zonas más activas</li>
        <li>Análisis detallado por empresa</li>
        <li>Indicadores clave de rendimiento (KPIs)</li>
      </ul>
      <h6>Actualización</h6>
      <p>Los datos se actualizan automáticamente al cargar la pantalla. Use el botón "Actualizar" para refrescar manualmente.</p>
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
const datosGenerales = ref(null)
const porTipo = ref([])
const porEmpresa = ref([])
const topZonas = ref([])

const actualizarDatos = async () => {
  cargando.value = true
  try {
    const [respGenerales, respTipo, respEmpresa, respZonas] = await Promise.all([
      execute('SP_ASEO_ESTADISTICAS_GENERALES', 'aseo_contratado', {}),
      execute('SP_ASEO_ESTADISTICAS_POR_TIPO', 'aseo_contratado', {}),
      execute('SP_ASEO_ESTADISTICAS_POR_EMPRESA', 'aseo_contratado', {}),
      execute('SP_ASEO_ESTADISTICAS_POR_ZONA', 'aseo_contratado', {})
    ])

    datosGenerales.value = respGenerales && respGenerales.length > 0 ? respGenerales[0] : null
    porTipo.value = respTipo || []
    porEmpresa.value = respEmpresa || []
    topZonas.value = (respZonas || []).slice(0, 10)

    showToast('Estadísticas actualizadas correctamente', 'success')
  } catch (error) {
    handleError(error, 'Error al cargar estadísticas generales')
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

const getBadgeColor = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
}

const getProgressColor = (tipo) => {
  const colores = {
    'D': 'bg-success',
    'C': 'bg-primary',
    'I': 'bg-warning',
    'S': 'bg-info'
  }
  return colores[tipo] || 'bg-secondary'
}

onMounted(() => {
  actualizarDatos()
})
</script>

