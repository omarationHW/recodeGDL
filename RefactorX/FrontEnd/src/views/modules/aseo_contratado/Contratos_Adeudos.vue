<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Contratos con Adeudos</h1>
        <p>Aseo Contratado - Reporte de contratos con adeudos pendientes</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentación Técnica">
          <font-awesome-icon icon="file-code" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control">
                <option v-for="tipo in tiposAseo" :key="tipo.value" :value="tipo.value">
                  {{ tipo.label }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Vigencia</label>
              <select v-model="vigenciaSeleccionada" class="municipal-form-control">
                <option v-for="vig in vigencias" :key="vig.value" :value="vig.value">
                  {{ vig.label }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Reporte</label>
              <select v-model="tipoReporteSeleccionado" class="municipal-form-control" @change="onTipoReporteChange">
                <option v-for="rep in tiposReporte" :key="rep.value" :value="rep.value">
                  {{ rep.label }}
                </option>
              </select>
            </div>
          </div>

          <!-- Periodo (visible solo cuando tipoReporte = 'T') -->
          <div v-if="tipoReporteSeleccionado === 'T'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Año</label>
              <input
                type="number"
                v-model.number="ejercicio"
                class="municipal-form-control"
                placeholder="Ej: 2025"
                min="2000"
                max="2099"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Mes</label>
              <select v-model="mesSeleccionado" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                  {{ mes.label }}
                </option>
              </select>
            </div>
          </div>

          <!-- Botones de Acción -->
          <div class="button-group mt-3">
            <button class="btn-municipal-primary" @click="buscarContratos">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-success"
              @click="exportarExcel"
              :disabled="contratos.length === 0"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resumen de Resultados -->
      <div v-if="contratos.length > 0" class="stats-row mt-3">
        <div class="stat-card stat-primary">
          <div class="stat-icon">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ contratos.length }}</span>
            <span class="stat-label">Contratos</span>
          </div>
        </div>
        <div class="stat-card stat-danger">
          <div class="stat-icon">
            <font-awesome-icon icon="exclamation-triangle" />
          </div>
          <div class="stat-info">
            <span class="stat-value">${{ formatCurrency(totalAdeudos) }}</span>
            <span class="stat-label">Total Adeudos</span>
          </div>
        </div>
        <div class="stat-card stat-warning">
          <div class="stat-icon">
            <font-awesome-icon icon="clock" />
          </div>
          <div class="stat-info">
            <span class="stat-value">${{ formatCurrency(totalRecargos) }}</span>
            <span class="stat-label">Recargos</span>
          </div>
        </div>
        <div class="stat-card stat-info">
          <div class="stat-icon">
            <font-awesome-icon icon="calculator" />
          </div>
          <div class="stat-info">
            <span class="stat-value">${{ formatCurrency(granTotal) }}</span>
            <span class="stat-label">Gran Total</span>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div v-if="contratos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Contratos con Adeudos ({{ contratos.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Domicilio</th>
                  <th>Colonia</th>
                  <th>Status</th>
                  <th>Empresa</th>
                  <th>Tipo Aseo</th>
                  <th>Inicio Oblig.</th>
                  <th>Primer Adeudo</th>
                  <th class="text-end">Adeudos</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Multas</th>
                  <th class="text-end">Gastos</th>
                  <th class="text-end">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in contratos" :key="contrato.control_contrato">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ formatDomicilio(contrato) }}</td>
                  <td>{{ contrato.colonia }}</td>
                  <td>
                    <span class="badge" :class="getBadgeClass(contrato.status_contrato)">
                      {{ getStatusLabel(contrato.status_contrato) }}
                    </span>
                  </td>
                  <td>{{ contrato.nombre_empresa }}</td>
                  <td>{{ contrato.tipo_aseo_descripcion }}</td>
                  <td>{{ contrato.inicio_oblig }}</td>
                  <td>{{ contrato.primer_adeudo || 'N/A' }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.adeudos) }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.recargos) }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.req_multa) }}</td>
                  <td class="text-end">${{ formatCurrency(contrato.req_gastos) }}</td>
                  <td class="text-end">
                    <strong>${{ formatCurrency(calcularTotalContrato(contrato)) }}</strong>
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="8" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end"><strong>${{ formatCurrency(totalAdeudos) }}</strong></td>
                  <td class="text-end"><strong>${{ formatCurrency(totalRecargos) }}</strong></td>
                  <td class="text-end"><strong>${{ formatCurrency(totalMultas) }}</strong></td>
                  <td class="text-end"><strong>${{ formatCurrency(totalGastos) }}</strong></td>
                  <td class="text-end"><strong>${{ formatCurrency(granTotal) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div v-if="sinResultados" class="alert-warning-box mt-3">
        <font-awesome-icon icon="info-circle" class="alert-icon" />
        <div class="alert-content">
          <strong>Sin resultados</strong>
          <p>No se encontraron contratos con adeudos para los filtros seleccionados.</p>
        </div>
      </div>

      <!-- Información/Ayuda -->
      <div class="alert-info-box mt-4">
        <font-awesome-icon icon="info-circle" class="alert-icon" />
        <div class="alert-content">
          <strong>Información:</strong>
          <p>Este reporte muestra todos los contratos que tienen adeudos pendientes según los filtros seleccionados.</p>
          <ul>
            <li><strong>Tipo de Aseo:</strong> C=Zona Centro, H=Hospitalario, O=Ordinario</li>
            <li><strong>Vigencia:</strong> V=Vigente, N=Conveniado, C=Cancelado, S=Suspendido</li>
            <li><strong>Tipo de Reporte:</strong> Vencidos (todos los periodos vencidos) u Otro Periodo (específico)</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Modal de Documentación -->
    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Contratos con Adeudos">
      <h3>Reporte de Contratos con Adeudos</h3>
      <p>Este módulo permite consultar todos los contratos que tienen adeudos pendientes según diferentes criterios de filtrado.</p>

      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Tipo de Aseo:</strong>
          <ul>
            <li>C = Zona Centro</li>
            <li>H = Hospitalario</li>
            <li>O = Ordinario</li>
          </ul>
        </li>
        <li><strong>Vigencia del Contrato:</strong>
          <ul>
            <li>V = Vigente</li>
            <li>N = Conveniado</li>
            <li>C = Cancelado</li>
            <li>S = Suspendido</li>
            <li>T = Todos</li>
          </ul>
        </li>
        <li><strong>Tipo de Reporte:</strong>
          <ul>
            <li>Periodos Vencidos: Muestra todos los adeudos con fecha vencida</li>
            <li>Otro Periodo: Permite especificar un año y mes específico</li>
          </ul>
        </li>
      </ul>

      <h4>Exportar a Excel:</h4>
      <p>Puede exportar los resultados a un archivo Excel haciendo clic en el botón "Exportar a Excel".</p>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Contratos_Adeudos'"
      :moduleName="'aseo_contratado'"
      @close="showTechDocs = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Configuración
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

// Estado de filtros
const tipoAseoSeleccionado = ref('C')
const vigenciaSeleccionada = ref('V')
const tipoReporteSeleccionado = ref('V')
const ejercicio = ref(new Date().getFullYear())
const mesSeleccionado = ref('01')

// Estado de resultados
const contratos = ref([])
const sinResultados = ref(false)

// Modales
const showDocumentation = ref(false)
const showTechDocs = ref(false)

// Catálogos estáticos (igual que en Delphi original)
const tiposAseo = [
  { value: 'C', label: 'C = Zona Centro' },
  { value: 'H', label: 'H = Hospitalario' },
  { value: 'O', label: 'O = Ordinario' }
]

const vigencias = [
  { value: 'V', label: 'V = VIGENTE' },
  { value: 'N', label: 'N = CONVENIADO' },
  { value: 'C', label: 'C = CANCELADO' },
  { value: 'S', label: 'S = SUSPENDIDO' },
  { value: 'T', label: 'T = TODOS' }
]

const tiposReporte = [
  { value: 'V', label: 'V - Periodos Vencidos' },
  { value: 'T', label: 'T - Otro Periodo' }
]

const meses = [
  { value: '01', label: '01 - Enero' },
  { value: '02', label: '02 - Febrero' },
  { value: '03', label: '03 - Marzo' },
  { value: '04', label: '04 - Abril' },
  { value: '05', label: '05 - Mayo' },
  { value: '06', label: '06 - Junio' },
  { value: '07', label: '07 - Julio' },
  { value: '08', label: '08 - Agosto' },
  { value: '09', label: '09 - Septiembre' },
  { value: '10', label: '10 - Octubre' },
  { value: '11', label: '11 - Noviembre' },
  { value: '12', label: '12 - Diciembre' }
]

// Computed: Totales
const totalAdeudos = computed(() => {
  return contratos.value.reduce((sum, c) => sum + parseFloat(c.adeudos || 0), 0)
})

const totalRecargos = computed(() => {
  return contratos.value.reduce((sum, c) => sum + parseFloat(c.recargos || 0), 0)
})

const totalMultas = computed(() => {
  return contratos.value.reduce((sum, c) => sum + parseFloat(c.req_multa || 0), 0)
})

const totalGastos = computed(() => {
  return contratos.value.reduce((sum, c) => sum + parseFloat(c.req_gastos || 0), 0)
})

const granTotal = computed(() => {
  return totalAdeudos.value + totalRecargos.value + totalMultas.value + totalGastos.value
})

// Cambio de tipo de reporte
const onTipoReporteChange = () => {
  if (tipoReporteSeleccionado.value === 'V') {
    ejercicio.value = new Date().getFullYear()
  } else {
    ejercicio.value = null
    mesSeleccionado.value = '01'
  }
}

// Buscar contratos con adeudos
const buscarContratos = async () => {
  // Validar periodo si es "Otro Periodo"
  if (tipoReporteSeleccionado.value === 'T' && (!ejercicio.value || !mesSeleccionado.value)) {
    showToast('Ingrese el año y mes del periodo', 'warning')
    return
  }

  showLoading()
  sinResultados.value = false
  contratos.value = []

  try {
    // Construir periodo
    const periodo = tipoReporteSeleccionado.value === 'V'
      ? `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}`
      : `${ejercicio.value}-${mesSeleccionado.value}`

    const params = [
      { nombre: 'p_tipo', valor: tipoAseoSeleccionado.value, tipo: 'string' },
      { nombre: 'p_vigencia', valor: vigenciaSeleccionada.value, tipo: 'string' },
      { nombre: 'p_reporte', valor: tipoReporteSeleccionado.value, tipo: 'string' },
      { nombre: 'p_periodo', valor: periodo, tipo: 'string' }
    ]

    const response = await execute(
      'sp16_contratos_adeudo',
      BASE_DB,
      params,
      '',
      null,
      SCHEMA
    )

    hideLoading()

    if (response && response.length > 0) {
      contratos.value = response
      showToast(`Se encontraron ${response.length} contratos con adeudos`, 'success')
    } else {
      sinResultados.value = true
      showToast('No se encontraron contratos con adeudos', 'info')
    }

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al buscar contratos')
  }
}

// Exportar a Excel
const exportarExcel = () => {
  if (contratos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  // Crear CSV para descarga
  const headers = [
    'Contrato', 'Calle', 'NumExt', 'NumInt', 'Colonia', 'Sector', 'Status',
    'Empresa', 'Tipo Aseo', 'Inicio Oblig', 'Primer Adeudo',
    'Adeudos', 'Recargos', 'Multas', 'Gastos', 'Total'
  ]

  const rows = contratos.value.map(c => [
    c.num_contrato,
    c.calle,
    c.numext,
    c.numint,
    c.colonia,
    c.sector,
    c.status_contrato,
    c.nombre_empresa,
    c.tipo_aseo_descripcion,
    c.inicio_oblig,
    c.primer_adeudo || '',
    c.adeudos,
    c.recargos,
    c.req_multa,
    c.req_gastos,
    calcularTotalContrato(c)
  ])

  // Agregar fila de totales
  rows.push([
    '', '', '', '', '', '', '', '', '', '', 'TOTALES:',
    totalAdeudos.value.toFixed(2),
    totalRecargos.value.toFixed(2),
    totalMultas.value.toFixed(2),
    totalGastos.value.toFixed(2),
    granTotal.value.toFixed(2)
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
  ].join('\n')

  const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `Contratos_Adeudos_${new Date().toISOString().slice(0, 10)}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  showToast('Archivo exportado correctamente', 'success')
}

// Limpiar filtros
const limpiarFiltros = () => {
  tipoAseoSeleccionado.value = 'C'
  vigenciaSeleccionada.value = 'V'
  tipoReporteSeleccionado.value = 'V'
  ejercicio.value = new Date().getFullYear()
  mesSeleccionado.value = '01'
  contratos.value = []
  sinResultados.value = false
}

// Helpers
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0)
}

const formatDomicilio = (contrato) => {
  let dom = contrato.calle || ''
  if (contrato.numext) dom += ` ${contrato.numext}`
  if (contrato.numint) dom += ` Int. ${contrato.numint}`
  return dom || 'S/D'
}

const calcularTotalContrato = (contrato) => {
  return parseFloat(contrato.adeudos || 0) +
         parseFloat(contrato.recargos || 0) +
         parseFloat(contrato.req_multa || 0) +
         parseFloat(contrato.req_gastos || 0)
}

const getBadgeClass = (status) => {
  const classes = {
    'V': 'bg-success',
    'N': 'bg-warning',
    'C': 'bg-danger',
    'S': 'bg-secondary'
  }
  return classes[status] || 'bg-secondary'
}

const getStatusLabel = (status) => {
  const labels = {
    'V': 'Vigente',
    'N': 'Conveniado',
    'C': 'Cancelado',
    'S': 'Suspendido'
  }
  return labels[status] || status
}

// Abrir documentación
const openDocumentation = () => {
  showDocumentation.value = true
}

// Mostrar documentación técnica
const mostrarDocumentacion = () => {
  showTechDocs.value = true
}
</script>

