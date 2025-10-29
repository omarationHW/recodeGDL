<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-file-certificate"></i>
        Reporte de Títulos de Propiedad
      </h1>
      <DocumentationModal
        title="Ayuda - Reporte de Títulos"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Criterios de Búsqueda
      </div>
      <div class="card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha Desde</label>
            <input v-model="filtros.fecha_desde" type="date" class="form-control" />
          </div>
          <div class="form-group">
            <label class="form-label required">Fecha Hasta</label>
            <input v-model="filtros.fecha_hasta" type="date" class="form-control" />
          </div>
          <div class="form-group">
            <label class="form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="form-control">
              <option value="">-- Todos --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
        </div>
        <div class="form-actions">
          <button @click="generarReporte" class="btn-municipal-primary">
            <i class="fas fa-file-alt"></i>
            Generar Reporte
          </button>
          <button @click="exportarPDF" :disabled="titulos.length === 0" class="btn-municipal-secondary">
            <i class="fas fa-file-pdf"></i>
            Exportar a PDF
          </button>
        </div>
      </div>
    </div>

    <!-- Reporte de Títulos -->
    <div v-if="titulos.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Títulos Emitidos ({{ titulos.length }})
        <span class="float-right total-label">
          Total: ${{ calcularTotal().toFixed(2) }}
        </span>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
      <i class="fas fa-info-circle"></i>
      No se encontraron títulos emitidos en el rango de fechas especificado
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const filtros = reactive({
  fecha_desde: '',
  fecha_hasta: '',
  cementerio: ''
})

const titulos = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Reporte de Títulos de Propiedad',
    content: `
      <p>Genera un reporte de todos los títulos de propiedad emitidos en un período específico.</p>
      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Fecha Desde/Hasta:</strong> Rango de fechas de emisión</li>
        <li><strong>Cementerio:</strong> Filtrar por cementerio específico (opcional)</li>
      </ul>
      <h4>Funcionalidades:</h4>
      <ul>
        <li>Vista en pantalla con totales</li>
        <li>Exportación a PDF para impresión</li>
        <li>Información completa de cada título emitido</li>
      </ul>
    `
  }
]

const generarReporte = async () => {
  if (!filtros.fecha_desde || !filtros.fecha_hasta) {
    toast.warning('Seleccione el rango de fechas')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_REPORTE_TITULOS', {
      p_fecha_desde: filtros.fecha_desde,
      p_fecha_hasta: filtros.fecha_hasta,
      p_cementerio: filtros.cementerio || null
    })

    titulos.value = response.data || []
    busquedaRealizada.value = true

    if (titulos.value.length > 0) {
      toast.success(`Se encontraron ${titulos.value.length} título(s)`)
    } else {
      toast.info('No se encontraron títulos en el rango especificado')
    }
  } catch (error) {
    console.error('Error al generar reporte:', error)
    toast.error('Error al generar reporte')
  }
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
}

const exportarPDF = () => {
  toast.info('Funcionalidad de exportación a PDF en desarrollo')
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

<style scoped>
.float-right {
  float: right;
}

.total-label {
  font-weight: bold;
  color: var(--color-primary);
}

.text-right {
  text-align: right;
}

.total-row {
  background-color: var(--color-bg-secondary);
  font-weight: bold;
}

.total-row td {
  padding: 1rem;
}

.form-grid-three {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}
</style>
