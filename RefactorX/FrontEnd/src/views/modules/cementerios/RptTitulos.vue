<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-certificate" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Títulos de Propiedad</h1>
        <p>Cementerios - Reporte de títulos emitidos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Criterios de Búsqueda
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha Desde</label>
            <input v-model="filtros.fecha_desde" type="date" class="municipal-form-control" />
          </div>
          <div class="form-group">
            <label class="form-label required">Fecha Hasta</label>
            <input v-model="filtros.fecha_hasta" type="date" class="municipal-form-control" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="municipal-form-control">
              <option value="">-- Todos --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
        </div>
        <div class="form-actions">
          <button @click="generarReporte" class="btn-municipal-primary">
            <font-awesome-icon icon="file-alt" />
            Generar Reporte
          </button>
          <button @click="exportarPDF" :disabled="titulos.length === 0" class="btn-municipal-secondary">
            <font-awesome-icon icon="file-pdf" />
            Exportar a PDF
          </button>
        </div>
      </div>
    </div>

    <!-- Reporte de Títulos -->
    <div v-if="titulos.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Títulos Emitidos ({{ titulos.length }})
        <span class="float-right total-label">
          Total: ${{ calcularTotal().toFixed(2) }}
        </span>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Título</th>
                <th>Fecha</th>
                <th>Folio</th>
                <th>Titular</th>
                <th>Cementerio</th>
                <th>Ubicación</th>
                <th>Importe</th>
                <th>Recaudación</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="titulo in titulos" :key="titulo.titulo">
                <td><strong>{{ titulo.titulo }}</strong></td>
                <td>{{ formatearFecha(titulo.fecha) }}</td>
                <td>{{ titulo.control_rcm }}</td>
                <td>{{ titulo.nombre }}</td>
                <td>{{ titulo.cementerio }}</td>
                <td>{{ formatearUbicacion(titulo) }}</td>
                <td class="text-right">${{ formatearMoneda(titulo.importe) }}</td>
                <td>{{ titulo.recaudacion }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="total-row">
                <td colspan="6" class="text-right"><strong>Total General:</strong></td>
                <td class="text-right"><strong>${{ calcularTotal().toFixed(2) }}</strong></td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron títulos emitidos en el rango de fechas especificado
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RptTitulos'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Estado
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const filtros = reactive({
  fecha_desde: '',
  fecha_hasta: '',
  cementerio: ''
})

const titulos = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const generarReporte = async () => {
  if (!filtros.fecha_desde || !filtros.fecha_hasta) {
    showToast('warning', 'Seleccione el rango de fechas')
    return
  }

  showLoading()

  try {
    const params = [
      {
        nombre: 'p_fecha_desde',
        valor: filtros.fecha_desde,
        tipo: 'date'
      },
      {
        nombre: 'p_fecha_hasta',
        valor: filtros.fecha_hasta,
        tipo: 'date'
      },
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio || null,
        tipo: 'varchar'
      }
    ]

    const response = await execute(
      'sp_rpttitulos_reporte_titulos',
      'cementerio',
      params,
      'cementerio',
      null,
      'public'
    )

    titulos.value = response.result || []
    busquedaRealizada.value = true

    if (titulos.value.length > 0) {
      showToast('success', `Se encontraron ${titulos.value.length} título(s)`)
    } else {
      showToast('info', 'No se encontraron títulos en el rango especificado')
    }
  } catch (error) {
    console.error('Error al generar reporte:', error)
    showToast('error', 'Error al generar reporte')
  } finally {
    hideLoading()
  }
}

const cargarCementerios = async () => {
  try {
    const response = await execute(
      'sp_cem_listar_cementerios',
      'cementerio',
      [],
      'cementerio',
      null,
      'public'
    )
    cementerios.value = response.result || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
}

const exportarPDF = () => {
  showToast('info', 'Funcionalidad de exportación a PDF en desarrollo')
  // TODO: Implementar exportación a PDF usando jsPDF o similar
}

const calcularTotal = () => {
  return titulos.value.reduce((sum, t) => sum + parseFloat(t.importe || 0), 0)
}

const formatearUbicacion = (titulo) => {
  const partes = []
  partes.push(`Cl:${titulo.clase}${titulo.clase_alfa || ''}`)
  partes.push(`Sec:${titulo.seccion}${titulo.seccion_alfa || ''}`)
  partes.push(`Lin:${titulo.linea}${titulo.linea_alfa || ''}`)
  partes.push(`Fosa:${titulo.fosa}${titulo.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

onMounted(() => {
  cargarCementerios()

  // Establecer fechas por defecto (mes actual)
  const hoy = new Date()
  const primerDia = new Date(hoy.getFullYear(), hoy.getMonth(), 1)
  filtros.fecha_hasta = hoy.toISOString().split('T')[0]
  filtros.fecha_desde = primerDia.toISOString().split('T')[0]
})
</script>
