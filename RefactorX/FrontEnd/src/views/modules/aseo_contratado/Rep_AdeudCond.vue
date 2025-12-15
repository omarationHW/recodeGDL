<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos Condonados</h1>
        <p>Aseo Contratado - Consulta de adeudos condonados por contrato</p>
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
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Parámetros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Ingrese número de contrato"
                @keyup.enter="generarReporte"
                min="1"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control">
                <option value="">Seleccione tipo de aseo...</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Reporte</label>
              <select v-model="tipoReporte" class="municipal-form-control">
                <option value="1">Detallado</option>
                <option value="2">Resumido</option>
              </select>
            </div>
          </div>
          <div class="button-group mt-3">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="!validarFormulario()"
            >
              <font-awesome-icon icon="file-invoice-dollar" />
              Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Información del Contrato -->
      <div v-if="contratoInfo" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-contract" /> Información del Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-cards-grid">
            <div class="info-card">
              <span class="info-label">Contrato</span>
              <span class="info-value">{{ contratoInfo.num_contrato }}</span>
            </div>
            <div class="info-card">
              <span class="info-label">Tipo Aseo</span>
              <span class="info-value">{{ contratoInfo.tipo_aseo_desc || contratoInfo.ctrol_aseo }}</span>
            </div>
            <div class="info-card">
              <span class="info-label">Unidad Recolección</span>
              <span class="info-value">{{ contratoInfo.ctrol_recolec }}</span>
            </div>
            <div class="info-card">
              <span class="info-label">Costo Unidad</span>
              <span class="info-value">{{ formatCurrency(contratoInfo.costo_unidad) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados del Reporte -->
      <div v-if="datosReporte.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Adeudos Condonados ({{ datosReporte.length }})
          </h5>
          <div class="button-group">
            <button class="btn-municipal-success btn-sm" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn-municipal-danger btn-sm" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <!-- Resumen estadístico -->
          <div class="stats-row mb-3">
            <div class="stat-box stat-info">
              <div class="stat-number">{{ datosReporte.length }}</div>
              <div class="stat-label">Total Registros</div>
            </div>
            <div class="stat-box stat-success">
              <div class="stat-number">{{ formatCurrency(montoTotalCondonado) }}</div>
              <div class="stat-label">Monto Total Condonado</div>
            </div>
          </div>

          <!-- Tabla de resultados -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Periodo</th>
                  <th>Operación</th>
                  <th>Fecha Condonación</th>
                  <th class="text-right">Importe</th>
                  <th>Folio Oficio</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in datosReporte" :key="index">
                  <td>{{ index + 1 }}</td>
                  <td>{{ formatPeriodo(item.aso_mes_pago) }}</td>
                  <td>{{ item.descripcion_operacion || item.ctrol_operacion }}</td>
                  <td>{{ formatFecha(item.fecha_hora_pago) }}</td>
                  <td class="text-right">
                    <strong class="text-success">{{ formatCurrency(item.importe || item.monto) }}</strong>
                  </td>
                  <td>{{ item.folio_rcbo || 'N/A' }}</td>
                  <td>{{ item.usuario }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="4" class="text-right"><strong>TOTAL:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(montoTotalCondonado) }}</strong></td>
                  <td colspan="2"></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Estado vacío -->
      <div v-if="!contratoInfo && !datosReporte.length" class="empty-state mt-4">
        <div class="empty-state-icon">
          <font-awesome-icon icon="file-invoice-dollar" />
        </div>
        <h4>Reporte de Adeudos Condonados</h4>
        <p>Ingrese el número de contrato y tipo de aseo para consultar los adeudos condonados.</p>
        <div class="steps-guide">
          <div class="step">
            <span class="step-number">1</span>
            <span class="step-text">Ingrese el número de contrato</span>
          </div>
          <div class="step">
            <span class="step-number">2</span>
            <span class="step-text">Seleccione el tipo de aseo</span>
          </div>
          <div class="step">
            <span class="step-number">3</span>
            <span class="step-text">Elija el tipo de reporte</span>
          </div>
          <div class="step">
            <span class="step-number">4</span>
            <span class="step-text">Haga clic en "Generar Reporte"</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Documentación -->
    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Reporte Adeudos Condonados">
      <h3>Reporte de Adeudos Condonados</h3>
      <p>Consulta los adeudos que han sido condonados para un contrato específico.</p>

      <h4>Información del Reporte:</h4>
      <ul>
        <li><strong>Periodo:</strong> Año y mes del adeudo condonado</li>
        <li><strong>Operación:</strong> Tipo de operación (Cuota Normal, Excedente, etc.)</li>
        <li><strong>Fecha Condonación:</strong> Cuándo se aplicó la condonación</li>
        <li><strong>Importe:</strong> Monto que fue condonado</li>
        <li><strong>Folio Oficio:</strong> Número del documento de autorización</li>
        <li><strong>Usuario:</strong> Quién realizó la condonación</li>
      </ul>

      <h4>Tipos de Reporte:</h4>
      <ul>
        <li><strong>Detallado:</strong> Muestra cada registro de condonación individual</li>
        <li><strong>Resumido:</strong> Agrupa las condonaciones por periodo</li>
      </ul>

      <h4>Nota:</h4>
      <p>Los adeudos condonados tienen status_vigencia = 'S' (Saldado por condonación).</p>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_AdeudCond'"
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
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Configuración
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Estado del formulario
const numContrato = ref(null)
const tipoAseoSeleccionado = ref('')
const tipoReporte = ref('1')

// Datos
const tiposAseo = ref([])
const contratoInfo = ref(null)
const datosReporte = ref([])

// Modales
const showDocumentation = ref(false)
const showTechDocs = ref(false)

// Computed
const montoTotalCondonado = computed(() => {
  return datosReporte.value.reduce((sum, item) => {
    return sum + parseFloat(item.importe || item.monto || 0)
  }, 0)
})

// Cargar catálogos al montar
onMounted(async () => {
  await cargarCatalogos()
})

// Cargar catálogos
const cargarCatalogos = async () => {
  showLoading()
  try {
    const resTiposAseo = await execute('sp_aseo_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)
    tiposAseo.value = resTiposAseo || []
    console.log('Tipos Aseo cargados:', tiposAseo.value)
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar catálogos')
  } finally {
    hideLoading()
  }
}

// Validar formulario
const validarFormulario = () => {
  return numContrato.value && tipoAseoSeleccionado.value
}

// Generar reporte
const generarReporte = async () => {
  if (!validarFormulario()) {
    showToast('Ingrese el número de contrato y seleccione el tipo de aseo', 'warning')
    return
  }

  showLoading()
  try {
    // Primero buscar el contrato
    const paramsContrato = [
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: parseInt(tipoAseoSeleccionado.value), tipo: 'integer' }
    ]

    const resContrato = await execute('sp_aseo_contrato_buscar_por_numero', BASE_DB, paramsContrato, '', null, SCHEMA)

    if (!resContrato || resContrato.length === 0) {
      hideLoading()
      await Swal.fire({
        title: 'Contrato no encontrado',
        text: 'No existe un contrato con ese número y tipo de aseo.',
        icon: 'warning',
        confirmButtonText: 'Aceptar',
        confirmButtonColor: '#dc3545'
      })
      return
    }

    contratoInfo.value = resContrato[0]

    // Buscar adeudos condonados del contrato
    const paramsAdeudos = [
      { nombre: 'p_control_contrato', valor: contratoInfo.value.control_contrato, tipo: 'integer' }
    ]

    const resAdeudos = await execute('sp_aseo_adeudos_condonados_por_contrato', BASE_DB, paramsAdeudos, '', null, SCHEMA)

    datosReporte.value = resAdeudos || []

    hideLoading()

    if (datosReporte.value.length === 0) {
      await Swal.fire({
        title: 'Sin adeudos condonados',
        text: 'El contrato no tiene adeudos condonados registrados.',
        icon: 'info',
        confirmButtonText: 'Aceptar',
        confirmButtonColor: '#007bff'
      })
    } else {
      showToast(`Se encontraron ${datosReporte.value.length} adeudos condonados`, 'success')
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al generar reporte')
  }
}

// Limpiar filtros
const limpiarFiltros = () => {
  numContrato.value = null
  tipoAseoSeleccionado.value = ''
  tipoReporte.value = '1'
  contratoInfo.value = null
  datosReporte.value = []
}

// Exportar a Excel
const exportarExcel = () => {
  showToast('Exportación a Excel en desarrollo', 'info')
}

// Imprimir
const imprimir = () => {
  showToast('Impresión en desarrollo', 'info')
}

// Formateo de datos
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'
  const fecha = new Date(periodo)
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
  return `${meses[fecha.getMonth()]} ${fecha.getFullYear()}`
}

// Documentación
const openDocumentation = () => {
  showDocumentation.value = true
}

const mostrarDocumentacion = () => {
  showTechDocs.value = true
}
</script>

