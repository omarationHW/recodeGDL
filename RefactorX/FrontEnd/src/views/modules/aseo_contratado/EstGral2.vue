<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Estadísticas Generales Avanzadas</h1>
        <p>Aseo Contratado - Dashboard con análisis comparativo y tendencias</p>
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

    <!-- Botón de actualización -->
    <div class="mb-3 text-end">
      <button class="btn-municipal-primary" @click="actualizarDatos">
        <font-awesome-icon icon="refresh" class="me-2" /> Actualizar Datos
      </button>
    </div>

    <div v-if="cargando" class="text-center py-5">
      <div class="spinner-border text-warning" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-3">Generando estadísticas avanzadas...</p>
    </div>

    <div v-else-if="estadisticas">
      <div class="stats-dashboard mb-4">
        <div class="stat-item stat-primary">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.total_contratos }}</div>
            <div class="stat-label-mini">Total Contratos</div>
          </div>
        </div>
        <div class="stat-item stat-success">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.activos }}</div>
            <div class="stat-label-mini">Activos - {{ calcularPorcentaje(estadisticas.activos, estadisticas.total_contratos) }}%</div>
          </div>
        </div>
        <div class="stat-item stat-danger">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="times-circle" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">{{ estadisticas.cancelados }}</div>
            <div class="stat-label-mini">Cancelados - {{ calcularPorcentaje(estadisticas.cancelados, estadisticas.total_contratos) }}%</div>
          </div>
        </div>
        <div class="stat-item stat-warning">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(estadisticas.ingresos_mensuales) }}</div>
            <div class="stat-label-mini">Ingresos Mensuales</div>
          </div>
        </div>
        <div class="stat-item stat-info">
          <div class="stat-icon-mini">
            <font-awesome-icon icon="chart-line" />
          </div>
          <div class="stat-details">
            <div class="stat-value-mini">${{ formatCurrency(estadisticas.ingresos_mensuales * 12) }}</div>
            <div class="stat-label-mini">Ingresos Anuales Proyectados</div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Comparativo por Tipo de Aseo</h5>
            </div>
<div class="municipal-card-body">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Tipo</th>
                    <th class="text-end">Activos</th>
                    <th class="text-end">Cancelados</th>
                    <th class="text-end">Total</th>
                    <th class="text-end">Ingresos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="tipo in porTipo" :key="tipo.tipo_aseo">
                    <td>
                      <span class="badge" :class="getBadgeTipo(tipo.tipo_aseo)">
                        {{ formatTipoAseo(tipo.tipo_aseo) }}
                      </span>
                    </td>
                    <td class="text-end">{{ tipo.activos }}</td>
                    <td class="text-end">{{ tipo.cancelados }}</td>
                    <td class="text-end"><strong>{{ tipo.total }}</strong></td>
                    <td class="text-end">${{ formatCurrency(tipo.ingresos) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Distribución por Empresa</h5>
            </div>
            <div class="municipal-card-body">
              <div v-for="empresa in porEmpresa.slice(0, 5)" :key="empresa.num_empresa" class="mb-3">
                <div class="d-flex justify-content-between mb-1">
                  <strong>{{ empresa.nombre_empresa }}</strong>
                  <span>{{ empresa.total }} contratos - ${{ formatCurrency(empresa.ingresos) }}</span>
                </div>
                <div class="progress" style="height: 20px;">
                  <div class="progress-bar bg-warning"
                    :style="{ width: calcularPorcentaje(empresa.total, estadisticas.total_contratos) + '%' }">
                    {{ calcularPorcentaje(empresa.total, estadisticas.total_contratos) }}%
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-4">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Indicadores de Cuota</h5>
            </div>
            <div class="municipal-card-body">
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Cuota Mínima:</span>
                  <strong class="text-success">${{ formatCurrency(estadisticas.cuota_minima) }}</strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Cuota Promedio:</span>
                  <strong class="text-primary">${{ formatCurrency(estadisticas.cuota_promedio) }}</strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Cuota Máxima:</span>
                  <strong class="text-danger">${{ formatCurrency(estadisticas.cuota_maxima) }}</strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Desviación Estándar:</span>
                  <strong class="text-warning">${{ formatCurrency(estadisticas.desviacion_std) }}</strong>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Indicadores de Adeudos</h5>
            </div>
            <div class="municipal-card-body">
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Contratos con Adeudo:</span>
                  <strong class="text-danger">{{ estadisticas.con_adeudos || 0 }}</strong>
                </div>
                <small class="text-muted">
                  {{ calcularPorcentaje(estadisticas.con_adeudos, estadisticas.activos) }}% de activos
                </small>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Monto Total Adeudado:</span>
                  <strong class="text-danger">${{ formatCurrency(estadisticas.monto_adeudos) }}</strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Promedio por Adeudo:</span>
                  <strong class="text-warning">
                    ${{ formatCurrency(estadisticas.con_adeudos > 0 ? estadisticas.monto_adeudos / estadisticas.con_adeudos : 0) }}
                  </strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Tasa de Morosidad:</span>
                  <strong :class="getTasaMorosidadClass()">
                    {{ calcularPorcentaje(estadisticas.con_adeudos, estadisticas.activos) }}%
                  </strong>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Cobertura Territorial</h5>
            </div>
            <div class="municipal-card-body">
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Zonas Activas:</span>
                  <strong class="text-primary">{{ estadisticas.total_zonas }}</strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Colonias Atendidas:</span>
                  <strong class="text-success">{{ estadisticas.total_colonias || 0 }}</strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Promedio por Zona:</span>
                  <strong class="text-info">
                    {{ Math.round(estadisticas.activos / (estadisticas.total_zonas || 1)) }} contratos
                  </strong>
                </div>
              </div>
              <div class="mb-3">
                <div class="d-flex justify-content-between">
                  <span>Empresas Operando:</span>
                  <strong class="text-warning">{{ porEmpresa.length }}</strong>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="row mb-4">
        <div class="col-md-12">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Tendencias y Proyecciones</h5>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-3 text-center border-end">
                  <h6 class="text-muted">Tasa de Retención</h6>
                  <h3 class="text-success">
                    {{ calcularPorcentaje(estadisticas.activos, estadisticas.total_contratos) }}%
                  </h3>
                  <small class="text-muted">Contratos que permanecen activos</small>
                </div>
                <div class="col-md-3 text-center border-end">
                  <h6 class="text-muted">Ingreso Promedio por Contrato</h6>
                  <h3 class="text-primary">
                    ${{ formatCurrency(estadisticas.activos > 0 ? estadisticas.ingresos_mensuales / estadisticas.activos : 0) }}
                  </h3>
                  <small class="text-muted">Mensual</small>
                </div>
                <div class="col-md-3 text-center border-end">
                  <h6 class="text-muted">Potencial de Recuperación</h6>
                  <h3 class="text-warning">
                    ${{ formatCurrency(estadisticas.monto_adeudos) }}
                  </h3>
                  <small class="text-muted">Total en adeudos</small>
                </div>
                <div class="col-md-3 text-center">
                  <h6 class="text-muted">Eficiencia Operativa</h6>
                  <h3 :class="getEficienciaClass()">
                    {{ calcularEficiencia() }}%
                  </h3>
                  <small class="text-muted">Basado en morosidad y retención</small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Información del Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <p class="mb-1"><strong>Última Actualización:</strong> {{ new Date().toLocaleString('es-MX') }}</p>
          <p class="mb-1"><strong>Periodo de Análisis:</strong> Datos actuales del sistema</p>
          <p class="mb-0"><strong>Notas:</strong> Los indicadores se calculan en tiempo real basados en contratos activos y cancelados.</p>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Estadísticas Generales Avanzadas">
      <h6>Descripción</h6>
      <p>Dashboard ejecutivo con análisis avanzado, indicadores clave y proyecciones del sistema de aseo contratado.</p>
      <h6>Indicadores Principales</h6>
      <ul>
        <li><strong>Tasa de Retención:</strong> Porcentaje de contratos que se mantienen activos</li>
        <li><strong>Tasa de Morosidad:</strong> Porcentaje de contratos activos con adeudos</li>
        <li><strong>Eficiencia Operativa:</strong> Índice calculado con retención y morosidad</li>
        <li><strong>Potencial de Recuperación:</strong> Monto total de adeudos pendientes</li>
      </ul>
      <h6>Análisis Incluidos</h6>
      <ul>
        <li>Comparativo por tipo de aseo y empresa</li>
        <li>Indicadores de cuotas y adeudos</li>
        <li>Cobertura territorial</li>
        <li>Tendencias y proyecciones</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'EstGral2'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const estadisticas = ref(null)
const porTipo = ref([])
const porEmpresa = ref([])

const actualizarDatos = async () => {
  cargando.value = true
  try {
    const [respEst, respTipo, respEmpresa] = await Promise.all([
      execute('SP_ASEO_ESTADISTICAS_AVANZADAS', 'aseo_contratado', {}),
      execute('SP_ASEO_ESTADISTICAS_POR_TIPO', 'aseo_contratado', {}),
      execute('SP_ASEO_ESTADISTICAS_POR_EMPRESA', 'aseo_contratado', {})
    ])

    estadisticas.value = respEst && respEst.length > 0 ? respEst[0] : null
    porTipo.value = respTipo || []
    porEmpresa.value = respEmpresa || []

    showToast('Estadísticas actualizadas correctamente', 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar estadísticas')
  } finally {
    cargando.value = false
  }
}

const calcularPorcentaje = (parte, total) => {
  if (!total || total === 0) return '0.00'
  return ((parte / total) * 100).toFixed(2)
}

const calcularEficiencia = () => {
  if (!estadisticas.value) return 0
  const tasaRetencion = parseFloat(calcularPorcentaje(estadisticas.value.activos, estadisticas.value.total_contratos))
  const tasaMorosidad = parseFloat(calcularPorcentaje(estadisticas.value.con_adeudos, estadisticas.value.activos))
  // Eficiencia = 70% retención + 30% (100 - morosidad)
  const eficiencia = (tasaRetencion * 0.7) + ((100 - tasaMorosidad) * 0.3)
  return eficiencia.toFixed(2)
}

const getTasaMorosidadClass = () => {
  if (!estadisticas.value) return 'text-muted'
  const tasa = parseFloat(calcularPorcentaje(estadisticas.value.con_adeudos, estadisticas.value.activos))
  if (tasa < 10) return 'text-success'
  if (tasa < 25) return 'text-warning'
  return 'text-danger'
}

const getEficienciaClass = () => {
  const eficiencia = parseFloat(calcularEficiencia())
  if (eficiencia >= 80) return 'text-success'
  if (eficiencia >= 60) return 'text-warning'
  return 'text-danger'
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatTipoAseo = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

const getBadgeTipo = (tipo) => {
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

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

