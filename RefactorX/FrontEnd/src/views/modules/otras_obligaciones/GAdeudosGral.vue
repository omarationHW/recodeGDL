<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Generales</h1>
        <p>Otras Obligaciones - Consulta de Adeudos Totales</p>
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
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Configuración de Consulta -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cog" />
            {{ tablaInfo.nombre || 'Configuración de Consulta' }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="handleConsultar">
            <!-- Fila 0: Selección de Tabla -->
            <div class="form-row">
              <div class="form-group" style="flex: 2;">
                <label class="municipal-form-label">
                  <strong>Tabla/Rubro</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model="tablaId"
                  @change="onTablaChange"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                >
                  <option value="">-- Seleccione una tabla --</option>
                  <option
                    v-for="tabla in tablas"
                    :key="tabla.cve_tab"
                    :value="tabla.cve_tab"
                  >
                    {{ tabla.cve_tab }} - {{ tabla.nombre }}
                  </option>
                </select>
              </div>
            </div>

            <!-- Fila 1: Tipo de Periodo y Tipo de Reporte -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  <strong>Tipo de Adeudos</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model="filtros.tipoPeriodo"
                  @change="onTipoPeriodoChange"
                  class="municipal-form-control"
                  required
                  :disabled="loading || !tablaId"
                >
                  <option value="vencidos">Vencidos a la Fecha</option>
                  <option value="periodo">Por Periodo Específico</option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">
                  <strong>Tipo de Reporte</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model="filtros.tipoReporte"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                >
                  <option value="A">A - Resumen de Adeudos</option>
                  <option value="B">B - Adeudos Anualizados</option>
                  <option value="C">C - Adeudos y Pagos</option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">
                  <strong>Tipo de Opción</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model="filtros.tipoOpcion"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                >
                  <option value="A">A - Adeudos</option>
                  <option value="R">R - Recargos</option>
                  <option value="T">T - Total (Adeudos + Recargos)</option>
                </select>
              </div>
            </div>

            <!-- Fila 2: Año y Mes (solo visible si es por periodo específico) -->
            <div class="form-row" v-if="filtros.tipoPeriodo === 'periodo'">
              <div class="form-group">
                <label class="municipal-form-label">
                  <strong>Año</strong>
                  <span class="required">*</span>
                </label>
                <input
                  type="number"
                  v-model.number="filtros.anio"
                  class="municipal-form-control"
                  min="2000"
                  :max="currentYear + 1"
                  required
                  :disabled="loading"
                  placeholder="YYYY"
                />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">
                  <strong>Mes</strong>
                  <span class="required">*</span>
                </label>
                <select
                  v-model.number="filtros.mes"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                >
                  <option :value="1">01 - Enero</option>
                  <option :value="2">02 - Febrero</option>
                  <option :value="3">03 - Marzo</option>
                  <option :value="4">04 - Abril</option>
                  <option :value="5">05 - Mayo</option>
                  <option :value="6">06 - Junio</option>
                  <option :value="7">07 - Julio</option>
                  <option :value="8">08 - Agosto</option>
                  <option :value="9">09 - Septiembre</option>
                  <option :value="10">10 - Octubre</option>
                  <option :value="11">11 - Noviembre</option>
                  <option :value="12">12 - Diciembre</option>
                </select>
              </div>
            </div>

            <!-- Botones de Acción -->
            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading || consultando || !tablaId"
              >
                <font-awesome-icon icon="search" />
                {{ consultando ? 'Consultando...' : 'Consultar Vista Previa' }}
              </button>

              <button
                type="button"
                class="btn-municipal-success"
                @click="handleExportar"
                :disabled="loading || adeudos.length === 0"
              >
                <font-awesome-icon icon="file-excel" />
                Exportar a Excel
              </button>

              <button
                type="button"
                class="btn-municipal-info"
                @click="handleImprimir"
                :disabled="loading || adeudos.length === 0"
              >
                <font-awesome-icon icon="print" />
                Imprimir Reporte
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card" v-if="adeudos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados de Adeudos
            <span class="badge bg-primary ms-2">{{ adeudos.length }} registro(s)</span>
          </h5>
        </div>

        <div class="municipal-card-body">
          <!-- Resumen -->
          <div class="alert alert-info mb-3">
            <div class="row">
              <div class="col-md-4">
                <strong>Total Adeudos:</strong> {{ formatCurrency(totales.adeudos) }}
              </div>
              <div class="col-md-4">
                <strong>Total Recargos:</strong> {{ formatCurrency(totales.recargos) }}
              </div>
              <div class="col-md-4">
                <strong>Total General:</strong> {{ formatCurrency(totales.general) }}
              </div>
            </div>
          </div>

          <!-- Tabla de datos -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>{{ etiquetas.etiq_control || 'Control' }}</th>
                  <th>{{ etiquetas.concesionario || 'Concesionario' }}</th>
                  <th v-if="filtros.tipoReporte !== 'A'">{{ etiquetas.ubicacion || 'Ubicación' }}</th>
                  <th v-if="filtros.tipoReporte === 'B'">Periodos</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-right" v-if="filtros.tipoReporte !== 'A'">Recargos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(adeudo, index) in adeudos"
                  :key="index"
                  class="row-hover"
                >
                  <td>{{ adeudo.control }}</td>
                  <td>{{ adeudo.concesionario || adeudo.nombre }}</td>
                  <td v-if="filtros.tipoReporte !== 'A'">{{ adeudo.ubicacion }}</td>
                  <td v-if="filtros.tipoReporte === 'B'">{{ adeudo.periodos }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.adeudo || adeudo.total_adeudos) }}</td>
                  <td class="text-right" v-if="filtros.tipoReporte !== 'A'">
                    {{ formatCurrency(adeudo.recargos || adeudo.total_recargos) }}
                  </td>
                  <td class="text-right">
                    {{ formatCurrency(adeudo.total || adeudo.total_general) }}
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-header">
                <tr>
                  <td colspan="3" class="text-right"><strong>TOTALES:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.adeudos) }}</strong></td>
                  <td class="text-right" v-if="filtros.tipoReporte !== 'A'">
                    <strong>{{ formatCurrency(totales.recargos) }}</strong>
                  </td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.general) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div v-if="!loading && !consultando && adeudos.length === 0 && consultoAlMenosUnaVez" class="municipal-card">
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-info">
            <font-awesome-icon icon="info-circle" />
            No se encontraron adeudos con los criterios especificados
          </div>
        </div>
      </div>

    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GAdeudosGral'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />

  <!-- Modal de Documentacion Tecnica -->
  <TechnicalDocsModal
    :show="showTechDocs"
    :componentName="'GAdeudosGral'"
    :moduleName="'otras_obligaciones'"
    @close="showTechDocs = false"
  />
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { usePdfExport } from '@/composables/usePdfExport'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

// Router
const router = useRouter()
const route = useRoute()

// Composables
const showDocumentation = ref(false)
const showTechDocs = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const mostrarDocumentacion = () => showTechDocs.value = true

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const { exportToPdf } = usePdfExport()
const {
  showToast,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local para controlar botones
const loading = ref(false)

// Estado
const tablas = ref([])
const tablaId = ref(route.params.tablaId || '')
const tablaInfo = ref({
  cve_tab: '',
  nombre: '',
  descripcion: ''
})
const etiquetas = ref({})
const adeudos = ref([])
const consultando = ref(false)
const consultoAlMenosUnaVez = ref(false)

// Fecha actual
const now = new Date()
const currentYear = now.getFullYear()
const currentMonth = now.getMonth() + 1

// Filtros
const filtros = ref({
  tipoPeriodo: 'vencidos',
  tipoReporte: 'A',
  tipoOpcion: 'T',
  anio: currentYear,
  mes: currentMonth
})

// Computed - Totales
const totales = computed(() => {
  if (adeudos.value.length === 0) {
    return { adeudos: 0, recargos: 0, general: 0 }
  }

  const totAdeudos = adeudos.value.reduce((sum, item) => {
    return sum + (item.adeudo || item.total_adeudos || 0)
  }, 0)

  const totRecargos = adeudos.value.reduce((sum, item) => {
    return sum + (item.recargos || item.total_recargos || 0)
  }, 0)

  const totGeneral = adeudos.value.reduce((sum, item) => {
    return sum + (item.total || item.total_general || 0)
  }, 0)

  return {
    adeudos: totAdeudos,
    recargos: totRecargos,
    general: totGeneral
  }
})

// Métodos de navegación
const goBack = () => {
  router.push('/otras_obligaciones')
}

// Cargar lista de tablas disponibles
const loadTablas = async () => {
  loading.value = true
  showLoading('Cargando tablas...')
  try {
    const response = await execute(
      'sp_otras_oblig_get_tablas_all',
      BASE_DB,
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tablas.value = response.result.map(t => ({
        cve_tab: String(t.cve_tab).trim(),
        nombre: (t.nombre || '').trim()
      }))
    } else {
      tablas.value = []
      showToast('warning', 'No se encontraron tablas disponibles')
    }
  } catch (error) {
    handleApiError(error)
    tablas.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Evento al cambiar la tabla seleccionada
const onTablaChange = async () => {
  // Limpiar datos previos
  adeudos.value = []
  consultoAlMenosUnaVez.value = false
  etiquetas.value = {}
  tablaInfo.value = { cve_tab: '', nombre: '', descripcion: '' }

  if (tablaId.value) {
    await loadTablaInfo()
    await loadEtiquetas()
  }
}

// Cargar información de la tabla
const loadTablaInfo = async () => {
  if (!tablaId.value) {
    return
  }

  try {
    const response = await execute(
      'sp_otras_oblig_get_tablas',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: parseInt(tablaId.value), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const tabla = response.result[0]
      tablaInfo.value = {
        cve_tab: String(tabla.cve_tab || '').trim(),
        nombre: (tabla.nombre || '').trim(),
        descripcion: (tabla.descripcion || '').trim()
      }
    }
  } catch (error) {
    console.error('Error al cargar info de tabla:', error)
  }
}

// Cargar etiquetas de la tabla
const loadEtiquetas = async () => {
  if (!tablaId.value) return

  try {
    // Usar sp_otras_oblig_get_etiquetas que tiene 1 argumento
    const response = await execute(
      'sp_otras_oblig_get_etiquetas',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: parseInt(tablaId.value), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const etiq = response.result[0]
      etiquetas.value = {
        cve_tab: String(etiq.cve_tab || '').trim(),
        abreviatura: (etiq.abreviatura || '').trim(),
        etiq_control: (etiq.etiq_control || 'Control').trim(),
        concesionario: (etiq.concesionario || 'Concesionario').trim(),
        ubicacion: (etiq.ubicacion || 'Ubicación').trim(),
        superficie: (etiq.superficie || 'Superficie').trim(),
        fecha_inicio: (etiq.fecha_inicio || 'Fecha Inicio').trim(),
        fecha_fin: (etiq.fecha_fin || 'Fecha Fin').trim(),
        recaudadora: (etiq.recaudadora || 'Recaudadora').trim(),
        sector: (etiq.sector || 'Sector').trim(),
        zona: (etiq.zona || 'Zona').trim(),
        licencia: (etiq.licencia || 'Licencia').trim(),
        fecha_cancelacion: (etiq.fecha_cancelacion || 'Fecha Cancelación').trim(),
        unidad: (etiq.unidad || 'Unidad').trim(),
        categoria: (etiq.categoria || 'Categoría').trim(),
        seccion: (etiq.seccion || 'Sección').trim(),
        bloque: (etiq.bloque || 'Bloque').trim(),
        nombre_comercial: (etiq.nombre_comercial || 'Nombre Comercial').trim(),
        lugar: (etiq.lugar || 'Lugar').trim(),
        obs: (etiq.obs || 'Observaciones').trim()
      }
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
  }
}

// Cambio de tipo de periodo
const onTipoPeriodoChange = () => {
  if (filtros.value.tipoPeriodo === 'vencidos') {
    filtros.value.anio = currentYear
    filtros.value.mes = currentMonth
  }
}

// Consultar adeudos
const handleConsultar = async () => {
  if (!tablaId.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Por favor seleccione una tabla para consultar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  consultando.value = true
  adeudos.value = []
  showLoading('Consultando adeudos...')

  try {
    // Construir fecha en formato YYYY-MM
    let fechaStr
    if (filtros.value.tipoPeriodo === 'vencidos') {
      // Para vencidos, usar fecha actual
      fechaStr = `${currentYear}-${String(currentMonth).padStart(2, '0')}`
    } else {
      // Para periodo específico, usar los valores seleccionados
      fechaStr = `${filtros.value.anio}-${String(filtros.value.mes).padStart(2, '0')}`
    }

    // Usar sp34_adeudototal que tiene 2 args: par_tabla (integer), par_fecha (varchar)
    const response = await execute(
      'sp34_adeudototal',
      BASE_DB,
      [
        { nombre: 'par_tabla', valor: parseInt(tablaId.value), tipo: 'integer' },
        { nombre: 'par_fecha', valor: fechaStr, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      adeudos.value = response.result
      consultoAlMenosUnaVez.value = true
      showToast('success', `Se encontraron ${adeudos.value.length} registro(s)`)
    } else {
      adeudos.value = []
      consultoAlMenosUnaVez.value = true
      showToast('info', 'No se encontraron adeudos con los criterios especificados')
    }
  } catch (error) {
    handleApiError(error)
    adeudos.value = []
  } finally {
    consultando.value = false
    hideLoading()
  }
}

// Exportar a Excel
const handleExportar = async () => {
  if (adeudos.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    // Preparar datos para Excel
    const dataToExport = adeudos.value.map(item => {
      const row = {
        [etiquetas.value.etiq_control || 'Control']: item.control,
        [etiquetas.value.concesionario || 'Concesionario']: item.concesionario || item.nombre
      }

      if (filtros.value.tipoReporte !== 'A') {
        row[etiquetas.value.ubicacion || 'Ubicación'] = item.ubicacion
      }

      if (filtros.value.tipoReporte === 'B') {
        row['Periodos'] = item.periodos
      }

      row['Adeudo'] = item.adeudo || item.total_adeudos || 0

      if (filtros.value.tipoReporte !== 'A') {
        row['Recargos'] = item.recargos || item.total_recargos || 0
      }

      row['Total'] = item.total || item.total_general || 0

      return row
    })

    // Agregar fila de totales
    const rowTotales = {
      [etiquetas.value.etiq_control || 'Control']: '',
      [etiquetas.value.concesionario || 'Concesionario']: 'TOTALES'
    }

    if (filtros.value.tipoReporte !== 'A') {
      rowTotales[etiquetas.value.ubicacion || 'Ubicación'] = ''
    }

    if (filtros.value.tipoReporte === 'B') {
      rowTotales['Periodos'] = ''
    }

    rowTotales['Adeudo'] = totales.value.adeudos

    if (filtros.value.tipoReporte !== 'A') {
      rowTotales['Recargos'] = totales.value.recargos
    }

    rowTotales['Total'] = totales.value.general

    dataToExport.push(rowTotales)

    // Crear libro y hoja de Excel
    const ws = XLSX.utils.json_to_sheet(dataToExport)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Adeudos')

    // Generar nombre de archivo
    const fileName = `AdeudosGral_${tablaInfo.value.cve_tab}_${filtros.value.anio}${String(filtros.value.mes).padStart(2, '0')}.xlsx`

    // Descargar archivo
    XLSX.writeFile(wb, fileName)

    showToast('success', 'Archivo Excel generado correctamente')
  } catch (error) {
    console.error('Error al exportar:', error)
    showToast('error', 'Error al generar archivo Excel')
  }
}

// Imprimir reporte
const handleImprimir = () => {
  if (adeudos.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  // Definir columnas para el PDF
  const columns = [
    { header: etiquetas.value.etiq_control || 'Control', key: 'control', type: 'text' },
    { header: etiquetas.value.concesionario || 'Concesionario', key: 'nombre', type: 'text' },
    { header: 'Superficie', key: 'superficie', type: 'number' },
    { header: 'Periodos', key: 'periodos', type: 'text' },
    { header: 'Adeudo', key: 'adeudo', type: 'currency' },
    { header: 'Recargos', key: 'recargos', type: 'currency' },
    { header: 'Total', key: 'total', type: 'currency' }
  ]

  // Opciones del reporte
  const options = {
    title: `Reporte de Adeudos Generales - ${tablaInfo.value.nombre || 'Otras Obligaciones'}`,
    subtitle: filtros.value.tipoPeriodo === 'vencidos'
      ? 'Adeudos Vencidos a la Fecha'
      : `Periodo: ${filtros.value.anio}-${String(filtros.value.mes).padStart(2, '0')}`,
    showDate: true,
    showTotal: true,
    totalColumns: ['adeudo', 'recargos', 'total'],
    orientation: 'landscape'
  }

  // Generar PDF
  const success = exportToPdf(adeudos.value, columns, options)

  if (success) {
    showToast('success', 'Reporte generado correctamente')
  } else {
    showToast('error', 'Error al generar el reporte. Verifique que no tenga bloqueador de popups activo.')
  }
}

// Utilidades
const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return `$${value}`
  }
}

// Lifecycle
onMounted(async () => {
  await loadTablas()
  // Si hay tablaId de params, cargar info
  if (tablaId.value) {
    await loadTablaInfo()
    await loadEtiquetas()
  }
})
</script>
