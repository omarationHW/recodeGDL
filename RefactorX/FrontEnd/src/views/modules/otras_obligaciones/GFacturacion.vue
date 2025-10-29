<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Facturación</h1>
        <p>Otras Obligaciones - Generación de reportes de facturación por período</p>
      </div>
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Información de la tabla -->
      <div class="municipal-card" v-if="nombreTabla">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <strong>{{ nombreTabla }}</strong>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Criterios de Búsqueda
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <!-- Período -->
            <div class="form-group">
              <label class="municipal-form-label">Período</label>
              <select class="municipal-form-control" v-model="filtros.periodo" @change="cambiarPeriodo">
                <option value="vencidos">Vencidos</option>
                <option value="especifico">Período Específico</option>
              </select>
            </div>

            <!-- Año (solo visible si es período específico) -->
            <div class="form-group" v-show="filtros.periodo === 'especifico'">
              <label class="municipal-form-label">Año</label>
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
              <label class="municipal-form-label">Mes</label>
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
              <label class="municipal-form-label">Estado de Adeudos</label>
              <select class="municipal-form-control" v-model="filtros.estado" @change="cambiarEstado">
                <option value="A">Adeudos</option>
                <option value="B">Pagados</option>
                <option value="C">Cancelados</option>
              </select>
            </div>

            <!-- Recargos -->
            <div class="form-group" v-show="filtros.estado !== 'C'">
              <label class="municipal-form-label">
                <input
                  type="checkbox"
                  v-model="filtros.conRecargos"
                  style="margin-right: 8px;"
                >
                Incluir Recargos
              </label>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <button
                class="btn-municipal-primary"
                @click="generarReporte"
                :disabled="loading || generando"
              >
                <font-awesome-icon :icon="generando ? 'spinner' : 'print'" :spin="generando" />
                {{ generando ? 'Generando...' : 'Generar Reporte' }}
              </button>
            </div>
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
          <span class="badge badge-info">
            {{ datosFacturacion.length }} registro(s)
          </span>
        </div>

        <div class="municipal-card-body">
          <!-- Título del reporte -->
          <div class="report-title">
            <h6>{{ tituloReporte }}</h6>
          </div>

          <!-- Tabla de datos -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>{{ etiquetas.etiq_control || 'Control' }}</th>
                  <th>{{ etiquetas.concesionario || 'Concesionario' }}</th>
                  <th v-if="tipoTabla !== '5'">{{ etiquetas.superficie || 'Superficie' }}</th>
                  <th>{{ etiquetas.unidad || 'Unidades' }}</th>
                  <th>{{ etiquetas.licencia || 'Licencia' }}</th>
                  <th class="text-right">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in datosFacturacion" :key="index" class="row-hover">
                  <td>{{ item.control }}</td>
                  <td>{{ item.concesionario }}</td>
                  <td v-if="tipoTabla !== '5'">{{ formatNumber(item.superficie, 2) }}</td>
                  <td>{{ item.tipo }}</td>
                  <td>{{ item.licencia || '-' }}</td>
                  <td class="text-right">{{ formatCurrency(item.importe) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td :colspan="tipoTabla !== '5' ? 5 : 4" class="text-right">
                    <strong>Total:</strong>
                  </td>
                  <td class="text-right">
                    <strong>{{ formatCurrency(totalImporte) }}</strong>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Botones de acción -->
          <div class="form-row mt-3">
            <div class="form-group">
              <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading">
                <font-awesome-icon icon="file-excel" />
                Exportar a Excel
              </button>
            </div>
            <div class="form-group">
              <button class="btn-municipal-info" @click="imprimirReporte" :disabled="loading">
                <font-awesome-icon icon="print" />
                Imprimir
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay resultados -->
      <div class="municipal-card" v-if="!loading && datosFacturacion.length === 0 && busquedaRealizada">
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            No se encontraron registros para los criterios especificados.
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos...</p>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
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
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

const router = useRouter()
const route = useRoute()
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const tipoTabla = ref(route.params.tipo || route.query.tipo || '1')
const nombreTabla = ref('')
const etiquetas = ref({})
const datosFacturacion = ref([])
const busquedaRealizada = ref(false)
const generando = ref(false)

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
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  const mesNombre = meses[filtros.value.mes - 1]
  return `Facturación por el mes de ${mesNombre} del ${filtros.value.axo} de: ${nombreTabla.value}`
})

const totalImporte = computed(() => {
  return datosFacturacion.value.reduce((sum, item) => sum + (item.importe || 0), 0)
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
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
  // Si es cancelado, no mostrar checkbox de recargos
  if (filtros.value.estado === 'C') {
    filtros.value.conRecargos = false
  }
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
      'SP_GACTUALIZA_ETIQUETAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
  }
}

const loadTablas = async () => {
  try {
    const response = await execute(
      'SP_GACTUALIZA_TABLAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      nombreTabla.value = response.result[0].nombre
    }
  } catch (error) {
    console.error('Error al cargar tablas:', error)
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
  setLoading(true, 'Generando reporte...')
  busquedaRealizada.value = true

  try {
    const response = await execute(
      'SP_GFACTURACION_DATOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_Tab', valor: tipoTabla.value, tipo: 'string' },
        { nombre: 'par_Ade', valor: filtros.value.estado, tipo: 'string' },
        { nombre: 'Par_Rcgo', valor: filtros.value.conRecargos ? 'S' : 'N', tipo: 'string' },
        { nombre: 'par_Axo', valor: filtros.value.axo, tipo: 'integer' },
        { nombre: 'par_Mes', valor: filtros.value.mes, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      // Filtrar resultados exitosos (status = 0)
      datosFacturacion.value = response.result.filter(r => r.status === 0)

      if (datosFacturacion.value.length > 0) {
        showToast('success', `Se encontraron ${datosFacturacion.value.length} registro(s)`)
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
    handleApiError(error)
    datosFacturacion.value = []
  } finally {
    generando.value = false
    setLoading(false)
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
  window.print()
}

// Lifecycle
onMounted(async () => {
  await loadEtiquetas()
  await loadTablas()

  // Inicializar con período actual
  const now = new Date()
  filtros.value.axo = now.getFullYear()
  filtros.value.mes = now.getMonth() + 1
})
</script>
