<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-percentage"></i>
        Reporte de Bonificaciones
      </h1>
      <DocumentationModal
        title="Ayuda - Reporte de Bonificaciones"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Parámetros del Reporte
      </div>
      <div class="card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha Inicio</label>
            <input v-model="filtros.fecha_inicio" type="date" class="form-control" />
          </div>
          <div class="form-group">
            <label class="form-label required">Fecha Fin</label>
            <input v-model="filtros.fecha_fin" type="date" class="form-control" />
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
            <i class="fas fa-file-pdf"></i>
            Generar Reporte
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="bonificaciones.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Bonificaciones Aplicadas ({{ bonificaciones.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Folio</th>
                <th>Titular</th>
                <th>Cementerio</th>
                <th>Porcentaje</th>
                <th>Importe</th>
                <th>Usuario</th>
                <th>Motivo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bon in bonificaciones" :key="bon.id_bonificacion">
                <td>{{ formatearFecha(bon.fecha_aplicacion) }}</td>
                <td>{{ bon.control_rcm }}</td>
                <td>{{ bon.nombre }}</td>
                <td>{{ bon.cementerio }}</td>
                <td>{{ bon.porcentaje }}%</td>
                <td>${{ formatearMoneda(bon.importe_bonificado) }}</td>
                <td>{{ bon.nombre_usuario || bon.usuario }}</td>
                <td>{{ bon.motivo }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="totals-row">
                <td colspan="5"><strong>TOTAL:</strong></td>
                <td><strong>${{ formatearMoneda(calcularTotal()) }}</strong></td>
                <td colspan="2"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <i class="fas fa-info-circle"></i>
      No se encontraron bonificaciones en el período especificado
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
  fecha_inicio: '',
  fecha_fin: '',
  cementerio: ''
})

const bonificaciones = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Reporte de Bonificaciones',
    content: `
      <p>Genera un reporte de todas las bonificaciones aplicadas en un período.</p>
      <h4>Información Incluida:</h4>
      <ul>
        <li>Fecha de aplicación</li>
        <li>Folio y titular beneficiado</li>
        <li>Porcentaje e importe bonificado</li>
        <li>Usuario que autorizó</li>
        <li>Motivo de la bonificación</li>
      </ul>
    `
  }
]

const generarReporte = async () => {
  if (!filtros.fecha_inicio || !filtros.fecha_fin) {
    toast.warning('Debe especificar el rango de fechas')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_REPORTE_BONIFICACIONES', {
      p_fecha_inicio: filtros.fecha_inicio,
      p_fecha_fin: filtros.fecha_fin,
      p_cementerio: filtros.cementerio || null
    })

    bonificaciones.value = response.data || []
    busquedaRealizada.value = true

    if (bonificaciones.value.length > 0) {
      toast.success(`Se encontraron ${bonificaciones.value.length} bonificación(es)`)
    } else {
      toast.info('No se encontraron bonificaciones en el período')
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

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

const calcularTotal = () => {
  return bonificaciones.value.reduce((sum, b) => sum + parseFloat(b.importe_bonificado || 0), 0)
}

onMounted(() => {
  cargarCementerios()

  // Establecer fechas por defecto (mes actual)
  const hoy = new Date()
  const primerDia = new Date(hoy.getFullYear(), hoy.getMonth(), 1)

  filtros.fecha_inicio = primerDia.toISOString().split('T')[0]
  filtros.fecha_fin = hoy.toISOString().split('T')[0]
})
</script>

<style scoped>
.totals-row {
  background-color: var(--color-bg-secondary);
  font-weight: bold;
}

.form-grid-three {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}
</style>
