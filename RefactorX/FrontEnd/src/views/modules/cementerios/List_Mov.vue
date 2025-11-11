<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="list-alt" />
        Listado de Movimientos
      </h1>
      <DocumentationModal
        title="Ayuda - Listado de Movimientos"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Filtros de Búsqueda
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
          <button @click="buscarMovimientos" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar Movimientos
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="movimientos.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Movimientos Encontrados ({{ movimientos.length }})
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Fecha</th>
                <th>Folio</th>
                <th>Cementerio</th>
                <th>Titular</th>
                <th>Usuario</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="mov in movimientos" :key="`${mov.control_rcm}-${mov.fecha_mov}`">
                <td>{{ formatearFecha(mov.fecha_mov) }}</td>
                <td>{{ mov.control_rcm }}</td>
                <td>{{ mov.cementerio }}</td>
                <td>{{ mov.nombre }}</td>
                <td>{{ mov.nombre_usuario || mov.usuario }}</td>
                <td>{{ mov.observaciones || '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron movimientos en el rango de fechas especificado
    </div>
  </div>
</template>

<script setup>
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

const movimientos = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Listado de Movimientos',
    content: `
      <p>Consulta y lista todos los movimientos de folios en un rango de fechas.</p>
      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Rango de Fechas:</strong> Obligatorio - define el período de consulta</li>
        <li><strong>Cementerio:</strong> Opcional - filtra por cementerio específico</li>
      </ul>
      <h4>Información Mostrada:</h4>
      <ul>
        <li>Fecha del movimiento</li>
        <li>Número de folio afectado</li>
        <li>Usuario que realizó el movimiento</li>
        <li>Observaciones registradas</li>
      </ul>
    `
  }
]

const buscarMovimientos = async () => {
  if (!filtros.fecha_inicio || !filtros.fecha_fin) {
    toast.warning('Debe especificar el rango de fechas')
    return
  }

  if (new Date(filtros.fecha_inicio) > new Date(filtros.fecha_fin)) {
    toast.warning('La fecha de inicio no puede ser mayor a la fecha fin')
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

    const response = await execute('sp_cem_listar_movimientos', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    movimientos.value = response.result || []
    busquedaRealizada.value = true

    if (movimientos.value.length > 0) {
      toast.success(`Se encontraron ${movimientos.value.length} movimiento(s)`)
    } else {
      toast.info('No se encontraron movimientos en el período especificado')
    }
  } catch (error) {
    console.error('Error al buscar movimientos:', error)
    toast.error('Error al buscar movimientos')
  }
}

const limpiar = () => {
  filtros.fecha_inicio = ''
  filtros.fecha_fin = ''
  filtros.cementerio = ''
  movimientos.value = []
  busquedaRealizada.value = false
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('sp_cem_listar_cementerios', {})
    cementerios.value = response.result || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  const date = new Date(fecha)
  return date.toLocaleDateString('es-MX')
}

onMounted(() => {
  cargarCementerios()

  // Establecer fechas por defecto (último mes)
  const hoy = new Date()
  const haceUnMes = new Date()
  haceUnMes.setMonth(haceUnMes.getMonth() - 1)

  filtros.fecha_fin = hoy.toISOString().split('T')[0]
  filtros.fecha_inicio = haceUnMes.toISOString().split('T')[0]
})
</script>
