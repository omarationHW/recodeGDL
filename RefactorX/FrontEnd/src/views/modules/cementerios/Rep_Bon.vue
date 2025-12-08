<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="percentage" />
        Reporte de Bonificaciones
      </h1>
      <DocumentationModal
        title="Ayuda - Reporte de Bonificaciones"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Parámetros del Reporte
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha Inicio</label>
            <input v-model="filtros.fecha_inicio" type="date" class="municipal-form-control" />
          </div>
          <div class="form-group">
            <label class="form-label required">Fecha Fin</label>
            <input v-model="filtros.fecha_fin" type="date" class="municipal-form-control" />
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
            <font-awesome-icon icon="file-pdf" />
            Generar Reporte
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="bonificaciones.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Bonificaciones Aplicadas ({{ bonificaciones.length }})
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
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
      <font-awesome-icon icon="info-circle" />
      No se encontraron bonificaciones en el período especificado
    </div>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_Bon'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

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
    const params = [
      {
        nombre: 'p_fecha_inicio',
        valor: filtros.fecha_inicio,
        tipo: 'date'
      },
      {
        nombre: 'p_fecha_fin',
        valor: filtros.fecha_fin,
        tipo: 'date'
      },
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio || null,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_reporte_bonificaciones', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    bonificaciones.value = response.result || []
    busquedaRealizada.value = true

    if (bonificaciones.value.length > 0) {
      toast.success(`Se encontraron ${bonificaciones.value.length} bonificación(es)`)
    } else {
      toast.info('No se encontraron bonificaciones en el período')
    }
  } catch (error) {
    toast.error('Error al generar reporte')
  }
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('sp_cem_listar_cementerios', {})
    cementerios.value = response.result || []
  } catch (error) {
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
/* Row de totales única del reporte - Justificado mantener scoped */
.totals-row {
  background-color: var(--color-bg-secondary);
  font-weight: bold;
}
</style>
