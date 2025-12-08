<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="user-tag" />
        Consulta de Folios por Nombre
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta por Nombre"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Criterios de Búsqueda
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Nombre del Titular</label>
            <input
              v-model="filtros.nombre"
              type="text"
              class="municipal-form-control"
              placeholder="Ingrese nombre a buscar"
              @keyup.enter="buscarFolios"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Filtro de Cementerio</label>
            <div class="radio-group">
              <label class="radio-option">
                <input type="radio" v-model="filtros.tipoBusqueda" value="todos" />
                <span>Todos los Cementerios</span>
              </label>
              <label class="radio-option">
                <input type="radio" v-model="filtros.tipoBusqueda" value="especifico" />
                <span>Cementerio Específico</span>
              </label>
            </div>
          </div>
        </div>

        <div v-if="filtros.tipoBusqueda === 'especifico'" class="form-group">
          <label class="municipal-form-label">Seleccione Cementerio</label>
          <select v-model="filtros.cementerio" class="municipal-form-control">
            <option value="">-- Seleccione --</option>
            <option
              v-for="cem in cementerios"
              :key="cem.cementerio"
              :value="cem.cementerio"
            >
              {{ cem.nombre }}
            </option>
          </select>
        </div>

        <div class="form-actions">
          <button @click="buscarFolios" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar Folios
          </button>
          <button @click="limpiarFiltros" class="btn-municipal-secondary">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="folios.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Folios Encontrados ({{ folios.length }})
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Folio</th>
                <th>Nombre</th>
                <th>Domicilio</th>
                <th>Cementerio</th>
                <th>Ubicación</th>
                <th>Año Pagado</th>
                <th>Metros</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="folio in folios" :key="folio.control_rcm">
                <td>{{ folio.control_rcm }}</td>
                <td>{{ folio.nombre }}</td>
                <td>{{ formatearDomicilio(folio) }}</td>
                <td>{{ folio.cementerio }}</td>
                <td>{{ formatearUbicacion(folio) }}</td>
                <td>{{ folio.axo_pagado }}</td>
                <td>{{ folio.metros }}</td>
                <td>
                  <button
                    @click="verDetalleFolio(folio.control_rcm)"
                    class="btn-municipal-secondary btn-sm"
                    title="Ver detalle del folio"
                  >
                    <font-awesome-icon icon="eye" />
                    Detalle
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Botón cargar más -->
        <div v-if="hayMasResultados" class="text-center mt-3">
          <button @click="cargarMasFolios" class="btn-municipal-primary">
            <font-awesome-icon icon="chevron-down" />
            Cargar Más Resultados
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron folios con el nombre especificado
    </div>

    <!-- Modal de detalle -->
    <div v-if="folioSeleccionado" class="modal-overlay" @click="cerrarDetalle">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>
            <font-awesome-icon icon="file-alt" />
            Detalle del Folio {{ folioSeleccionado }}
          </h3>
          <button @click="cerrarDetalle" class="btn-close">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="alert-info">
            <font-awesome-icon icon="info-circle" />
            El detalle completo del folio se implementará en el componente ConIndividual
          </div>
          <p><strong>Folio:</strong> {{ folioSeleccionado }}</p>
        </div>
        <div class="modal-footer">
          <button @click="cerrarDetalle" class="btn-municipal-secondary">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </div>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'MultipleNombre'"
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
  nombre: '',
  tipoBusqueda: 'todos',
  cementerio: ''
})

const folios = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)
const hayMasResultados = ref(false)
const ultimoFolio = ref(0)
const folioSeleccionado = ref(null)
const LIMITE_RESULTADOS = 50

const helpSections = [
  {
    title: 'Consulta de Folios por Nombre',
    content: `
      <p>Este módulo permite buscar folios de cementerio por el nombre del titular.</p>
      <h4>Uso:</h4>
      <ol>
        <li><strong>Nombre:</strong> Ingrese el nombre completo o parcial del titular</li>
        <li><strong>Cementerio:</strong> Seleccione si desea buscar en todos los cementerios o uno específico</li>
        <li><strong>Buscar:</strong> El sistema mostrará hasta 50 resultados iniciales</li>
        <li><strong>Cargar Más:</strong> Si hay más resultados, puede cargar los siguientes 50</li>
        <li><strong>Ver Detalle:</strong> Acceda a la información completa de cada folio</li>
      </ol>
    `
  },
  {
    title: 'Consejos de Búsqueda',
    content: `
      <ul>
        <li>Puede buscar por nombre parcial (ej: "GARCIA" encontrará "GARCIA LOPEZ")</li>
        <li>La búsqueda no distingue entre mayúsculas y minúsculas</li>
        <li>Use filtro específico de cementerio para resultados más precisos</li>
        <li>Los resultados se ordenan por número de folio</li>
      </ul>
    `
  }
]

const buscarFolios = async () => {
  if (!filtros.nombre.trim()) {
    toast.warning('Ingrese un nombre para buscar')
    return
  }

  if (filtros.tipoBusqueda === 'especifico' && !filtros.cementerio) {
    toast.warning('Seleccione un cementerio')
    return
  }

  try {
    const patron = `%${filtros.nombre}%`
    let cemInicio = 'A'
    let cemFin = 'z'

    if (filtros.tipoBusqueda === 'especifico') {
      cemInicio = filtros.cementerio
      cemFin = filtros.cementerio
    }

    const params = [
      {
        nombre: 'p_nombre',
        valor: patron,
        tipo: 'string'
      },
      {
        nombre: 'p_cementerio_inicio',
        valor: cemInicio,
        tipo: 'string'
      },
      {
        nombre: 'p_cementerio_fin',
        valor: cemFin,
        tipo: 'string'
      },
      {
        nombre: 'p_ultimo_folio',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_limite',
        valor: LIMITE_RESULTADOS,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_consultar_folios_por_nombre', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    folios.value = response.result || []
    busquedaRealizada.value = true
    hayMasResultados.value = folios.value.length === LIMITE_RESULTADOS

    if (folios.value.length > 0) {
      ultimoFolio.value = folios.value[folios.value.length - 1].control_rcm
      toast.success(`Se encontraron ${folios.value.length} folio(s)`)
    } else {
      toast.info('No existe Registro con esos Datos')
      ultimoFolio.value = 0
    }
  } catch (error) {
    toast.error('Error al buscar folios')
  }
}

const cargarMasFolios = async () => {
  try {
    const patron = `%${filtros.nombre}%`
    let cemInicio = 'A'
    let cemFin = 'Z'

    if (filtros.tipoBusqueda === 'especifico') {
      cemInicio = filtros.cementerio
      cemFin = filtros.cementerio
    }

    const params = [
      {
        nombre: 'p_nombre',
        valor: patron,
        tipo: 'string'
      },
      {
        nombre: 'p_cementerio_inicio',
        valor: cemInicio,
        tipo: 'string'
      },
      {
        nombre: 'p_cementerio_fin',
        valor: cemFin,
        tipo: 'string'
      },
      {
        nombre: 'p_ultimo_folio',
        valor: ultimoFolio.value,
        tipo: 'string'
      },
      {
        nombre: 'p_limite',
        valor: LIMITE_RESULTADOS,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_consultar_folios_por_nombre', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    const nuevosFolios = response.result || []

    if (nuevosFolios.length === 0) {
      hayMasResultados.value = false
      toast.info('Ya No existe Registro con esos Datos')
    } else {
      folios.value = [...folios.value, ...nuevosFolios]
      ultimoFolio.value = folios.value[folios.value.length - 1].control_rcm
      hayMasResultados.value = nuevosFolios.length === LIMITE_RESULTADOS
      toast.success(`Se cargaron ${nuevosFolios.length} folio(s) adicionales`)
    }
  } catch (error) {
    toast.error('Error al cargar más folios')
  }
}

const limpiarFiltros = () => {
  filtros.nombre = ''
  filtros.tipoBusqueda = 'todos'
  filtros.cementerio = ''
  folios.value = []
  busquedaRealizada.value = false
  hayMasResultados.value = false
  ultimoFolio.value = 0
  folioSeleccionado.value = null
}

const verDetalleFolio = (controlRcm) => {
  folioSeleccionado.value = controlRcm
  // TODO: Integrar con componente ConIndividual
}

const cerrarDetalle = () => {
  folioSeleccionado.value = null
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('sp_cem_listar_cementerios', {})
    cementerios.value = response.result || []
  } catch (error) {
    toast.error('Error al cargar cementerios')
  }
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
  const partes = [folio.domicilio]
  if (folio.exterior) partes.push(`#${folio.exterior}`)
  if (folio.interior) partes.push(`Int.${folio.interior}`)
  if (folio.colonia) partes.push(folio.colonia)
  return partes.filter(p => p).join(', ')
}

onMounted(() => {
  cargarCementerios()
})
</script>

<style scoped>
.radio-group {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.radio-option {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
}

.radio-option input[type="radio"] {
  cursor: pointer;
}

.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}

.text-center {
  text-align: center;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 0.5rem;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--color-border);
}

.modal-header h3 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--color-text-secondary);
  padding: 0.25rem;
  line-height: 1;
}

.btn-close:hover {
  color: var(--color-danger);
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid var(--color-border);
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>
