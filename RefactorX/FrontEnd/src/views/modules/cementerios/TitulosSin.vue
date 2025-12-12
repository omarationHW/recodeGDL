<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Generación de Títulos sin Número</h1>
        <p>Cementerios - Generación automática de títulos de propiedad</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Búsqueda de Folio -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Buscar Folio para Generar Título
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="municipal-form-control"
              @keyup.enter="buscarFolio"
              autofocus
            />
          </div>
          <div class="form-actions">
            <button @click="buscarFolio" class="btn-municipal-primary">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información del Folio y Generación de Título -->
    <div v-if="folio" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="info-circle" />
        Información del Folio {{ folio.control_rcm }}
      </div>
      <div class="municipal-card-body">
        <div class="folio-details-grid">
          <div class="detail-section">
            <h5><font-awesome-icon icon="user" /> Datos del Titular</h5>
            <div class="detail-item">
              <label>Nombre:</label>
              <span>{{ folio.nombre }}</span>
            </div>
            <div class="detail-item">
              <label>Domicilio:</label>
              <span>{{ formatearDomicilio(folio) }}</span>
            </div>
          </div>

          <div class="detail-section">
            <h5><font-awesome-icon icon="map-marker-alt" /> Ubicación</h5>
            <div class="detail-item">
              <label>Cementerio:</label>
              <span>{{ folio.cementerio }}</span>
            </div>
            <div class="detail-item">
              <label>Ubicación:</label>
              <span>{{ formatearUbicacion(folio) }}</span>
            </div>
            <div class="detail-item">
              <label>Metros:</label>
              <span>{{ folio.metros }} m²</span>
            </div>
          </div>
        </div>

        <!-- Datos para el Título -->
        <div class="titulo-form-section mt-3">
          <h5><font-awesome-icon icon="file-signature" /> Datos del Título</h5>
          <div class="form-grid-three">
            <div class="form-group">
              <label class="form-label required">Fecha de Emisión</label>
              <input v-model="tituloData.fecha_emision" type="date" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="form-label required">Importe</label>
              <input
                v-model.number="tituloData.importe"
                type="number"
                class="municipal-form-control"
                step="0.01"
                min="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudación</label>
              <select v-model="tituloData.recaudacion" class="municipal-form-control">
                <option value="">-- Seleccione --</option>
                <option v-for="rec in recaudaciones" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.nombre }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Observaciones</label>
            <textarea
              v-model="tituloData.observaciones"
              class="municipal-form-control"
              rows="3"
              maxlength="255"
            ></textarea>
          </div>
        </div>

        <div class="form-actions mt-3">
          <button @click="generarTitulo" class="btn-municipal-primary">
            <font-awesome-icon icon="file-alt" />
            Generar Título
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Títulos Generados -->
    <div v-if="titulos.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="history" />
        Títulos Generados Recientemente
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Título #</th>
                <th>Folio</th>
                <th>Titular</th>
                <th>Fecha</th>
                <th>Importe</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="titulo in titulos" :key="titulo.titulo">
                <td><strong>{{ titulo.titulo }}</strong></td>
                <td>{{ titulo.control_rcm }}</td>
                <td>{{ titulo.nombre }}</td>
                <td>{{ formatearFecha(titulo.fecha) }}</td>
                <td>${{ formatearMoneda(titulo.importe) }}</td>
                <td>
                  <button @click="imprimirTitulo(titulo.titulo)" class="btn-municipal-secondary btn-sm">
                    <font-awesome-icon icon="print" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'TitulosSin'"
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

const folioABuscar = ref(null)
const folio = ref(null)
const titulos = ref([])
const recaudaciones = ref([])

const tituloData = reactive({
  fecha_emision: new Date().toISOString().split('T')[0],
  importe: 0,
  recaudacion: '',
  observaciones: ''
})

const buscarFolio = async () => {
  if (!folioABuscar.value) {
    showToast('warning', 'Ingrese un número de folio')
    return
  }

  showLoading()

  try {
    const params = [
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'sp_cem_consultar_folio',
      'cementerio',
      params,
      'cementerio',
      null,
      'public'
    )

    if (response.result && response.result.length > 0) {
      const result = response.result[0]

      if (result.resultado === 'N') {
        folio.value = null
        showToast('warning', result.mensaje)
        return
      }

      folio.value = result
      await cargarTitulosRecientes()
      showToast('success', 'Folio encontrado')
    } else {
      folio.value = null
      showToast('warning', 'No se encontró el folio')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar folio')
    folio.value = null
  } finally {
    hideLoading()
  }
}

const cargarRecaudaciones = async () => {
  try {
    const response = await api.callStoredProcedure('sp_cem_listar_recaudaciones', {})
    recaudaciones.value = response.result || []
  } catch (error) {
    console.error('Error al cargar recaudaciones:', error)
  }
}

const cargarTitulosRecientes = async () => {
  try {
    const fechaHoy = new Date().toISOString().split('T')[0]
    const fechaHaceMes = new Date()
    fechaHaceMes.setMonth(fechaHaceMes.getMonth() - 1)
    const fechaDesde = fechaHaceMes.toISOString().split('T')[0]

    const params = [
      {
        nombre: 'p_fecha_desde',
        valor: fechaDesde,
        tipo: 'date'
      },
      {
        nombre: 'p_fecha_hasta',
        valor: fechaHoy,
        tipo: 'date'
      },
      {
        nombre: 'p_cementerio',
        valor: null,
        tipo: 'varchar'
      }
    ]

    const response = await execute(
      'sp_cem_reporte_titulos',
      'cementerio',
      params,
      'cementerio',
      null,
      'public'
    )

    titulos.value = response.result?.slice(0, 10) || []
  } catch (error) {
    console.error('Error al cargar títulos recientes:', error)
    titulos.value = []
  }
}

const generarTitulo = async () => {
  if (!tituloData.fecha_emision || tituloData.importe <= 0) {
    showToast('warning', 'Complete los campos requeridos: Fecha de Emisión e Importe')
    return
  }

  showLoading()

  try {
    const params = [
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'integer'
      },
      {
        nombre: 'p_fecha',
        valor: tituloData.fecha_emision,
        tipo: 'date'
      },
      {
        nombre: 'p_importe',
        valor: tituloData.importe,
        tipo: 'numeric'
      },
      {
        nombre: 'p_recaudacion',
        valor: tituloData.recaudacion || 1,
        tipo: 'integer'
      },
      {
        nombre: 'p_observaciones',
        valor: tituloData.observaciones || '',
        tipo: 'varchar'
      },
      {
        nombre: 'p_usuario',
        valor: 1,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'sp_cem_generar_titulo',
      'cementerio',
      params,
      'cementerio',
      null,
      'public'
    )

    if (response.result && response.result.length > 0) {
      const result = response.result[0]

      // Validar con ambas estructuras posibles
      if (result.resultado === 'S' || result.success === true) {
        const numeroTitulo = result.titulo || result.message
        showToast('success', `Título #${numeroTitulo} generado exitosamente`)

        // Limpiar formulario
        tituloData.fecha_emision = new Date().toISOString().split('T')[0]
        tituloData.importe = 0
        tituloData.recaudacion = ''
        tituloData.observaciones = ''

        await cargarTitulosRecientes()
      } else {
        showToast('error', result.mensaje || result.message || 'Error al generar título')
      }
    } else {
      showToast('error', 'No se recibió respuesta del servidor')
    }
  } catch (error) {
    console.error('Error al generar título:', error)
    showToast('error', 'Error al generar título')
  } finally {
    hideLoading()
  }
}

const imprimirTitulo = (numeroTitulo) => {
  showToast('info', `Impresión de título #${numeroTitulo} en desarrollo`)
  // TODO: Implementar impresión de título
}

const limpiar = () => {
  folioABuscar.value = null
  folio.value = null
  tituloData.fecha_emision = new Date().toISOString().split('T')[0]
  tituloData.importe = 0
  tituloData.recaudacion = ''
  tituloData.observaciones = ''
}

const formatearUbicacion = (folio) => {
  const partes = []
  partes.push(`Cl:${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec:${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin:${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa:${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearDomicilio = (folio) => {
  const partes = []
  if (folio.domicilio) partes.push(folio.domicilio)
  if (folio.exterior) partes.push(`#${folio.exterior}`)
  if (folio.interior) partes.push(`Int. ${folio.interior}`)
  if (folio.colonia) partes.push(folio.colonia)
  return partes.join(' ') || 'No especificado'
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
  cargarRecaudaciones()
  cargarTitulosRecientes()
})
</script>
