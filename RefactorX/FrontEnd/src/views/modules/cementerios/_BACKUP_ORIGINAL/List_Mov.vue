<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-list-alt"></i>
        Listado de Movimientos
      </h1>
      <DocumentationModal
        title="Ayuda - Listado de Movimientos"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Filtros de Búsqueda
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
          <button @click="buscarMovimientos" class="btn-municipal-primary">
            <i class="fas fa-search"></i>
            Buscar Movimientos
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
            <i class="fas fa-eraser"></i>
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="movimientos.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Movimientos Encontrados ({{ movimientos.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
      <i class="fas fa-info-circle"></i>
      No se encontraron movimientos en el rango de fechas especificado
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
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_MOVIMIENTOS', {
      p_fecha_inicio: filtros.fecha_inicio,
      p_fecha_fin: filtros.fecha_fin,
      p_cementerio: filtros.cementerio || null
    })

    movimientos.value = response.data || []
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
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
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
