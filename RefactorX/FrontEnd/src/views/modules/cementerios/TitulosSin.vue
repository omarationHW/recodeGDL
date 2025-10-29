<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-file-contract"></i>
        Generación de Títulos sin Número
      </h1>
      <DocumentationModal
        title="Ayuda - Títulos sin Número"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda de Folio -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Buscar Folio para Generar Título
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="form-control"
              @keyup.enter="buscarFolio"
              autofocus
            />
          </div>
          <div class="form-actions">
            <button @click="buscarFolio" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información del Folio y Generación de Título -->
    <div v-if="folio" class="card mb-3">
      <div class="card-header">
        <i class="fas fa-info-circle"></i>
        Información del Folio {{ folio.control_rcm }}
      </div>
      <div class="card-body">
        <div class="folio-details-grid">
          <div class="detail-section">
            <h5><i class="fas fa-user"></i> Datos del Titular</h5>
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
            <h5><i class="fas fa-map-marker-alt"></i> Ubicación</h5>
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
          <h5><i class="fas fa-file-signature"></i> Datos del Título</h5>
          <div class="form-grid-three">
            <div class="form-group">
              <label class="form-label required">Fecha de Emisión</label>
              <input v-model="tituloData.fecha_emision" type="date" class="form-control" />
            </div>
            <div class="form-group">
              <label class="form-label required">Importe</label>
              <input
                v-model.number="tituloData.importe"
                type="number"
                class="form-control"
                step="0.01"
                min="0"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Recaudación</label>
              <select v-model="tituloData.recaudacion" class="form-control">
                <option value="">-- Seleccione --</option>
                <option v-for="rec in recaudaciones" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.nombre }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Observaciones</label>
            <textarea
              v-model="tituloData.observaciones"
              class="form-control"
              rows="3"
              maxlength="255"
            ></textarea>
          </div>
        </div>

        <div class="form-actions mt-3">
          <button @click="generarTitulo" class="btn-municipal-primary">
            <i class="fas fa-file-alt"></i>
            Generar Título
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
            <i class="fas fa-eraser"></i>
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Títulos Generados -->
    <div v-if="titulos.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-history"></i>
        Títulos Generados Recientemente
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
                    <i class="fas fa-print"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
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

const helpSections = [
  {
    title: 'Generación de Títulos sin Número',
    content: `
      <p>Permite generar títulos de propiedad sin asignar un número específico previamente.</p>
      <h4>Proceso:</h4>
      <ol>
        <li>Buscar el folio para el cual se emitirá el título</li>
        <li>Verificar la información del titular y ubicación</li>
        <li>Ingresar los datos del título (fecha, importe, recaudación)</li>
        <li>Generar el título automáticamente</li>
        <li>El sistema asignará automáticamente el número de título</li>
      </ol>
      <h4>Nota:</h4>
      <p>Los títulos generados quedan registrados en el historial y pueden imprimirse posteriormente.</p>
    `
  }
]

const buscarFolio = async () => {
  if (!folioABuscar.value) {
    toast.warning('Ingrese un número de folio')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIO', {
      p_control_rcm: folioABuscar.value
    })

    if (response.data && response.data.length > 0) {
      const result = response.data[0]

      if (result.resultado === 'N') {
        folio.value = null
        toast.warning(result.mensaje)
        return
      }

      folio.value = result
      await cargarTitulosRecientes()
      toast.success('Folio encontrado')
    } else {
      folio.value = null
      toast.warning('No se encontró el folio')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    toast.error('Error al buscar folio')
    folio.value = null
  }
}

const cargarRecaudaciones = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_RECAUDACIONES', {})
    recaudaciones.value = response.data || []
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

    const response = await api.callStoredProcedure('SP_CEM_REPORTE_TITULOS', {
      p_fecha_desde: fechaDesde,
      p_fecha_hasta: fechaHoy,
      p_cementerio: null
    })

    titulos.value = response.data?.slice(0, 10) || []
  } catch (error) {
    console.error('Error al cargar títulos recientes:', error)
    titulos.value = []
  }
}

const generarTitulo = async () => {
  if (!tituloData.fecha_emision || tituloData.importe <= 0) {
    toast.warning('Complete los campos requeridos: Fecha de Emisión e Importe')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_GENERAR_TITULO', {
      p_control_rcm: folioABuscar.value,
      p_fecha: tituloData.fecha_emision,
      p_importe: tituloData.importe,
      p_recaudacion: tituloData.recaudacion || 1,
      p_observaciones: tituloData.observaciones || '',
      p_usuario: 1
    })

    if (response.data && response.data[0]?.resultado === 'S') {
      const numeroTitulo = response.data[0].titulo
      toast.success(`Título #${numeroTitulo} generado exitosamente`)

      // Limpiar formulario
      tituloData.fecha_emision = new Date().toISOString().split('T')[0]
      tituloData.importe = 0
      tituloData.recaudacion = ''
      tituloData.observaciones = ''

      await cargarTitulosRecientes()
    } else {
      toast.error(response.data[0]?.mensaje || 'Error al generar título')
    }
  } catch (error) {
    console.error('Error al generar título:', error)
    toast.error('Error al generar título')
  }
}

const imprimirTitulo = (numeroTitulo) => {
  toast.info(`Impresión de título #${numeroTitulo} en desarrollo`)
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

<style scoped>
.folio-details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.detail-section {
  padding: 1rem;
  background-color: var(--color-bg-secondary);
  border-radius: 0.375rem;
  border-left: 4px solid var(--color-primary);
}

.detail-section h5 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1rem;
  margin-bottom: 1rem;
  color: var(--color-primary);
}

.detail-item {
  display: flex;
  justify-content: space-between;
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border);
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-item label {
  font-weight: 500;
  color: var(--color-text-secondary);
}

.detail-item span {
  color: var(--color-text-primary);
  font-weight: 600;
}

.titulo-form-section {
  padding-top: 1.5rem;
  border-top: 2px solid var(--color-border);
}

.titulo-form-section h5 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  color: var(--color-primary);
}

.form-grid-three {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}
</style>
