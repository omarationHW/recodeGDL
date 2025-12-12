<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-alt" />
      </div>
      <div class="module-view-info">
        <h1>Listado de Movimientos</h1>
        <p>Cementerios - Consulta de movimientos por rango de fechas</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
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
                <th>Ubicación</th>
                <th>Titular</th>
                <th>Usuario</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="mov in movimientos" :key="`${mov.control_rcm}-${mov.fecha_mov}`">
                <td>
                  <strong>{{ formatearFecha(mov.fecha_mov) }}</strong>
                </td>
                <td>
                  <span class="badge badge-primary">{{ mov.control_rcm }}</span>
                </td>
                <td>
                  <small>{{ mov.nombre_cementerio || mov.cementerio }}</small>
                </td>
                <td>
                  <small class="text-muted">{{ mov.ubicacion || '-' }}</small>
                </td>
                <td>{{ mov.nombre }}</td>
                <td>
                  <small>{{ mov.nombre_usuario || mov.usuario }}</small>
                </td>
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
      :componentName="'List_Mov'"
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
  fecha_inicio: '',
  fecha_fin: '',
  cementerio: ''
})

const movimientos = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const buscarMovimientos = async () => {
  if (!filtros.fecha_inicio || !filtros.fecha_fin) {
    showToast('warning', 'Debe especificar el rango de fechas')
    return
  }

  if (new Date(filtros.fecha_inicio) > new Date(filtros.fecha_fin)) {
    showToast('warning', 'La fecha de inicio no puede ser mayor a la fecha fin')
    return
  }

  showLoading('Buscando movimientos...', 'Consultando base de datos')

  try {
    const params = [
      { nombre: 'p_fecha_inicio', valor: filtros.fecha_inicio, tipo: 'date' },
      { nombre: 'p_fecha_fin', valor: filtros.fecha_fin, tipo: 'date' },
      { nombre: 'p_cementerio', valor: filtros.cementerio || null, tipo: 'string' }
    ]

    const response = await execute(
      'sp_listmov_buscar_movimientos',
      'cementerio',
      params,
      'cementerio',
      null,
      'public'
    )

    movimientos.value = response?.result || []
    busquedaRealizada.value = true

    if (movimientos.value.length > 0) {
      showToast('success', `Se encontraron ${movimientos.value.length} movimiento(s)`)
    } else {
      showToast('info', 'No se encontraron movimientos en el período especificado')
    }
  } catch (error) {
    console.error('Error al buscar movimientos:', error)
    showToast('error', 'Error al buscar movimientos')
  } finally {
    hideLoading()
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
    // Para evitar SP adicionales llamamos el SP que ya existe para listar cementerios
    const response = await execute(
      //'sp_listmov_listar_cementerios',
      'sp_get_cementerios_list',
      'cementerio',
      [],
      'cementerio',
      null,
      'public'
    )

    if (response?.result?.length > 0) {
      cementerios.value = response.result
    }
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
