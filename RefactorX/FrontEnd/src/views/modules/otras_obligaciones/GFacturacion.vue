<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Facturación</h1>
        <p>Generación de reportes de facturación por período</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-info"
          @click="cargarConfiguracion"
          :disabled="loading"
          title="Actualizar"
        >
          <font-awesome-icon icon="sync" :spin="loading" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de Estadísticas -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 3" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <!-- Cards de estadísticas con datos -->
      <div class="stats-grid" v-else-if="nombreTabla">
        <div class="stat-card stat-primary">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="building" />
            </div>
            <h3 class="stat-number">{{ nombreTabla }}</h3>
            <p class="stat-label">Tabla Seleccionada</p>
          </div>
        </div>

        <div class="stat-card stat-info">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="calendar-alt" />
            </div>
            <h3 class="stat-number">{{ filtros.axo }}</h3>
            <p class="stat-label">Año Consulta</p>
          </div>
        </div>

        <div class="stat-card stat-warning">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="clock" />
            </div>
            <h3 class="stat-number">{{ getMesNombre(filtros.mes) }}</h3>
            <p class="stat-label">Mes Consulta</p>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFiltros" style="cursor: pointer;">
          <h5>
            <font-awesome-icon :icon="showFiltros ? 'chevron-up' : 'chevron-down'" />
            Criterios de Búsqueda
          </h5>
          <span class="badge badge-purple">
            <font-awesome-icon icon="filter" />
            {{ contadorFiltros }} filtro(s) activo(s)
          </span>
        </div>

        <div class="municipal-card-body" v-show="showFiltros">
          <div class="form-row">
            <!-- Período -->
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" class="me-1" />
                Período
              </label>
              <select class="municipal-form-control" v-model="filtros.periodo" @change="cambiarPeriodo">
                <option value="vencidos">
                  <font-awesome-icon icon="exclamation-triangle" /> Vencidos
                </option>
                <option value="especifico">
                  <font-awesome-icon icon="calendar-day" /> Período Específico
                </option>
              </select>
            </div>

            <!-- Año (solo visible si es período específico) -->
            <div class="form-group" v-show="filtros.periodo === 'especifico'">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar" class="me-1" />
                Año
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.axo"
                placeholder="Año"
                maxlength="4"
                min="1900"
                :max="new Date().getFullYear()"
              >
            </div>

            <!-- Mes (solo visible si es período específico) -->
            <div class="form-group" v-show="filtros.periodo === 'especifico'">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-alt" class="me-1" />
                Mes
              </label>
              <select class="municipal-form-control" v-model.number="filtros.mes">
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

          <div class="form-row">
            <!-- Estado de Adeudos -->
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="list-check" class="me-1" />
                Estado de Adeudos
              </label>
              <select class="municipal-form-control" v-model="filtros.estado" @change="cambiarEstado">
                <option value="A">Vigentes (Adeudos + Pagados)</option>
                <option value="B">Suspendidos (Solo Adeudos)</option>
                <option value="C">Cancelados (Solo Pagados)</option>
              </select>
            </div>

            <!-- Recargos -->
            <div class="form-group" v-show="filtros.estado !== 'C'">
              <label class="municipal-form-label d-flex align-items-center">
                <input
                  type="checkbox"
                  v-model="filtros.conRecargos"
                  class="form-check-input me-2"
                >
                <font-awesome-icon icon="percentage" class="me-1" />
                Incluir Recargos
              </label>
            </div>
          </div>

          <div class="button-group mt-3">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="loading || generando"
            >
              <font-awesome-icon :icon="generando ? 'spinner' : 'file-invoice-dollar'" :spin="generando" />
              {{ generando ? 'Generando...' : 'Generar Reporte' }}
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
              :disabled="loading || generando"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar Filtros
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="datosFacturacion.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados de Facturación
          </h5>
          <div class="d-flex gap-2">
            <span class="badge badge-purple">
              <font-awesome-icon icon="list-ol" />
              {{ datosFacturacion.length }} registro(s)
            </span>
            <span class="badge badge-success" v-if="performanceTime">
              <font-awesome-icon icon="clock" />
              {{ performanceTime }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Título del reporte -->
          <div class="alert alert-primary d-flex align-items-center mb-3">
            <font-awesome-icon icon="file-invoice" class="me-2" />
            <strong>{{ tituloReporte }}</strong>
          </div>

          <!-- Tabla de datos -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    {{ etiquetas.etiq_control || 'Control' }}
                  </th>
                  <th>
                    <font-awesome-icon icon="user" class="me-1" />
                    {{ etiquetas.concesionario || 'Concesionario' }}
                  </th>
                  <th v-if="tipoTabla !== '5'">
                    <font-awesome-icon icon="ruler-combined" class="me-1" />
                    {{ etiquetas.superficie || 'Superficie' }}
                  </th>
                  <th>
                    <font-awesome-icon icon="box" class="me-1" />
                    {{ etiquetas.unidad || 'Unidades' }}
                  </th>
                  <th>
                    <font-awesome-icon icon="id-card" class="me-1" />
                    {{ etiquetas.licencia || 'Licencia' }}
                  </th>
                  <th class="text-end">
                    <font-awesome-icon icon="dollar-sign" class="me-1" />
                    Importe
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in datosFacturacion" :key="index" class="row-hover">
                  <td><span class="badge badge-purple">{{ item.control }}</span></td>
                  <td>{{ item.concesionario }}</td>
                  <td v-if="tipoTabla !== '5'">{{ formatNumber(item.superficie, 2) }}</td>
                  <td>{{ item.tipo }}</td>
                  <td>{{ item.licencia || '-' }}</td>
                  <td class="text-end fw-bold text-success">{{ formatCurrency(item.importe) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td :colspan="tipoTabla !== '5' ? 5 : 4" class="text-end">
                    <strong>
                      <font-awesome-icon icon="calculator" class="me-1" />
                      Total:
                    </strong>
                  </td>
                  <td class="text-end">
                    <strong>{{ formatCurrency(totalImporte) }}</strong>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Botones de acción -->
          <div class="button-group mt-3">
            <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading">
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
            <button class="btn-municipal-info" @click="imprimirReporte" :disabled="loading">
              <font-awesome-icon icon="print" />
              Imprimir
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay resultados -->
      <div class="municipal-card" v-if="!loading && datosFacturacion.length === 0 && busquedaRealizada">
        <div class="municipal-card-body">
          <div class="alert alert-warning d-flex align-items-center">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            <span>No se encontraron registros para los criterios especificados.</span>
          </div>
        </div>
      </div>
    </div>

  </div>

  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GFacturacion'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />

</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { usePdfExport } from '@/composables/usePdfExport'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

const router = useRouter()
const route = useRoute()
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

// Estado local de loading
const loading = ref(false)

// Estado
const tipoTabla = ref(route.params.tipo || route.query.tipo || '1')
const nombreTabla = ref('')
const etiquetas = ref({})
const datosFacturacion = ref([])
const busquedaRealizada = ref(false)
const generando = ref(false)
const loadingEstadisticas = ref(true)
const showFiltros = ref(true)
const performanceTime = ref('')

// Filtros
const filtros = ref({
  periodo: 'vencidos',
  axo: new Date().getFullYear(),
  mes: new Date().getMonth() + 1,
  estado: 'A',
  conRecargos: false
})

// Computed
const tituloReporte = computed(() => {
  const mesNombre = getMesNombre(filtros.value.mes)
  return `Facturación por el mes de ${mesNombre} del ${filtros.value.axo} de: ${nombreTabla.value}`
})

const totalImporte = computed(() => {
  return datosFacturacion.value.reduce((sum, item) => sum + (item.importe || 0), 0)
})

const contadorFiltros = computed(() => {
  let count = 0
  if (filtros.value.periodo === 'especifico') count++
  if (filtros.value.estado !== 'A') count++
  if (filtros.value.conRecargos) count++
  return count
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

const toggleFiltros = () => {
  showFiltros.value = !showFiltros.value
}

const getMesNombre = (mes) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[mes - 1] || 'N/A'
}

const cambiarPeriodo = () => {
  if (filtros.value.periodo === 'vencidos') {
    const now = new Date()
    filtros.value.axo = now.getFullYear()
    filtros.value.mes = now.getMonth() + 1
  } else {
    filtros.value.axo = new Date().getFullYear()
    filtros.value.mes = 1
  }
}

const cambiarEstado = () => {
  // Limpiar checkbox de recargos al cambiar estado
  // Los recargos solo aplican para estados A y B
  if (filtros.value.estado === 'C') {
    filtros.value.conRecargos = false
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    periodo: 'vencidos',
    axo: new Date().getFullYear(),
    mes: new Date().getMonth() + 1,
    estado: 'A',
    conRecargos: false
  }
  datosFacturacion.value = []
  busquedaRealizada.value = false
  showToast('info', 'Filtros limpiados correctamente')
}

const formatNumber = (value, decimals = 2) => {
  if (value === null || value === undefined) return '0.00'
  return parseFloat(value).toFixed(decimals)
}

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(value)
}

// Cargar datos iniciales
const loadEtiquetas = async () => {
  try {
    const response = await execute(
      'sp_gfacturacion_get_etiquetas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' }],
      '',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
    handleApiError(error)
  }
}

const loadTablas = async () => {
  try {
    const response = await execute(
      'sp_gfacturacion_get_tablas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' }],
      '',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      nombreTabla.value = response.result[0].nombre
    }
  } catch (error) {
    console.error('Error al cargar tablas:', error)
    handleApiError(error)
  }
}

// Función de actualización para el botón
const cargarConfiguracion = async () => {
  loading.value = true
  showLoading('Actualizando configuración...')

  try {
    await Promise.all([
      loadEtiquetas(),
      loadTablas()
    ])
    loading.value = false
    hideLoading()
    showToast('success', 'Configuración actualizada')
  } catch (error) {
    loading.value = false
    hideLoading()
    handleApiError(error)
  }
}

// Generar reporte
const generarReporte = async () => {
  // Validar datos
  if (filtros.value.periodo === 'especifico') {
    if (!filtros.value.axo || filtros.value.axo <= 0) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Ingrese un año válido',
        confirmButtonColor: '#ea8215'
      })
      return
    }

    if (!filtros.value.mes || filtros.value.mes < 1 || filtros.value.mes > 12) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Seleccione un mes válido',
        confirmButtonColor: '#ea8215'
      })
      return
    }
  }

  generando.value = true
  loading.value = true
  showLoading('Generando reporte de facturación...')
  busquedaRealizada.value = true

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_gfacturacion_generar_reporte',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tipoTabla.value, tipo: 'varchar' },
        { nombre: 'par_ade', valor: filtros.value.estado, tipo: 'varchar' },
        { nombre: 'par_rcgo', valor: filtros.value.conRecargos ? 'S' : 'N', tipo: 'varchar' },
        { nombre: 'par_axo', valor: filtros.value.axo, tipo: 'integer' },
        { nombre: 'par_mes', valor: filtros.value.mes, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    )

    const endTime = performance.now()
    const totalTime = endTime - startTime

    // Calcular tiempo en formato apropiado
    if (totalTime < 1000) {
      performanceTime.value = `${totalTime.toFixed(0)}ms`
    } else {
      performanceTime.value = `${(totalTime / 1000).toFixed(2)}s`
    }

    generando.value = false
    loading.value = false
    hideLoading()

    if (response && response.result) {
      // Los resultados ya vienen filtrados del SP
      datosFacturacion.value = response.result || []

      if (datosFacturacion.value.length > 0) {
        showToast('success', `Se encontraron ${datosFacturacion.value.length} registro(s) en ${performanceTime.value}`)
      } else {
        await Swal.fire({
          icon: 'info',
          title: 'Sin resultados',
          text: 'No se encontraron registros para los criterios especificados',
          confirmButtonColor: '#ea8215'
        })
        datosFacturacion.value = []
      }
    } else {
      datosFacturacion.value = []
      await Swal.fire({
        icon: 'info',
        title: 'Sin resultados',
        text: 'No se encontraron registros',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    generando.value = false
    loading.value = false
    hideLoading()
    handleApiError(error)
    datosFacturacion.value = []
  }
}

// Exportar a Excel
const exportarExcel = () => {
  try {
    // Preparar datos para exportar
    const dataToExport = datosFacturacion.value.map(item => {
      const row = {
        [etiquetas.value.etiq_control || 'Control']: item.control,
        [etiquetas.value.concesionario || 'Concesionario']: item.concesionario
      }

      if (tipoTabla.value !== '5') {
        row[etiquetas.value.superficie || 'Superficie'] = item.superficie
      }

      row[etiquetas.value.unidad || 'Unidades'] = item.tipo
      row[etiquetas.value.licencia || 'Licencia'] = item.licencia || ''
      row['Importe'] = item.importe

      return row
    })

    // Agregar fila de total
    const totalRow = {}
    const keys = Object.keys(dataToExport[0])
    keys.forEach((key, index) => {
      if (index === keys.length - 1) {
        totalRow[key] = totalImporte.value
      } else if (index === keys.length - 2) {
        totalRow[key] = 'TOTAL:'
      } else {
        totalRow[key] = ''
      }
    })
    dataToExport.push(totalRow)

    // Crear libro de Excel
    const wb = XLSX.utils.book_new()
    const ws = XLSX.utils.json_to_sheet(dataToExport)

    // Ajustar anchos de columna
    const colWidths = keys.map(key => ({
      wch: Math.max(key.length, 15)
    }))
    ws['!cols'] = colWidths

    XLSX.utils.book_append_sheet(wb, ws, 'Facturación')

    // Guardar archivo
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ]
    const mesNombre = meses[filtros.value.mes - 1]
    const filename = `Facturacion_${mesNombre}_${filtros.value.axo}.xlsx`

    XLSX.writeFile(wb, filename)

    showToast('success', 'Archivo exportado correctamente')
  } catch (error) {
    console.error('Error al exportar:', error)
    showToast('error', 'Error al exportar el archivo')
  }
}

// Imprimir reporte
const imprimirReporte = () => {
  if (datosFacturacion.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  // Definir columnas para el PDF
  const columns = [
    { header: etiquetas.value.etiq_control || 'Control', key: 'control', type: 'string' },
    { header: etiquetas.value.concesionario || 'Concesionario', key: 'concesionario', type: 'string' }
  ]

  // Agregar superficie solo si no es tabla 5
  if (tipoTabla.value !== '5') {
    columns.push({ header: etiquetas.value.superficie || 'Superficie', key: 'superficie', type: 'number' })
  }

  columns.push(
    { header: etiquetas.value.unidad || 'Unidades', key: 'tipo', type: 'string' },
    { header: etiquetas.value.licencia || 'Licencia', key: 'licencia', type: 'string' },
    { header: 'Importe', key: 'importe', type: 'currency' }
  )

  // Opciones del reporte
  const options = {
    title: tituloReporte.value,
    subtitle: `Estado: ${filtros.value.estado === 'A' ? 'Vigentes' : filtros.value.estado === 'B' ? 'Suspendidos' : 'Cancelados'}`,
    showTotal: true,
    totalColumns: ['importe'],
    orientation: 'landscape'
  }

  const success = exportToPdf(datosFacturacion.value, columns, options)

  if (success) {
    showToast('success', 'Reporte generado correctamente')
  } else {
    showToast('error', 'Error al generar el reporte. Verifique el bloqueador de popups.')
  }
}

// Lifecycle
onMounted(async () => {
  loadingEstadisticas.value = true

  try {
    await Promise.all([
      loadEtiquetas(),
      loadTablas()
    ])
  } catch (error) {
    console.error('Error al cargar datos iniciales:', error)
  } finally {
    loadingEstadisticas.value = false
  }

  // Inicializar con período actual
  const now = new Date()
  filtros.value.axo = now.getFullYear()
  filtros.value.mes = now.getMonth() + 1
})
</script>

