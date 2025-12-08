<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="monument" />
        Consulta Cementerio Guadalajara
      </h1>
      <DocumentationModal
        title="Ayuda - Cementerio Guadalajara"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Filtros de Consulta
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="municipal-form-label">Buscar por Titular</label>
            <input
              v-model="filtros.nombre"
              type="text"
              class="municipal-form-control"
              placeholder="Nombre del titular..."
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Buscar por Folio</label>
            <input
              v-model.number="filtros.folio"
              type="number"
              class="municipal-form-control"
              placeholder="Número de folio..."
            />
          </div>
        </div>
        <div class="form-actions">
          <button @click="buscarFolios" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar
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
        Folios del Cementerio Guadalajara ({{ folios.length }})
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Folio</th>
                <th>Titular</th>
                <th>Domicilio</th>
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
                <td>{{ formatearUbicacion(folio) }}</td>
                <td>{{ folio.axo_pagado }}</td>
                <td>{{ folio.metros }} m²</td>
                <td>
                  <button
                    @click="verDetalle(folio.control_rcm)"
                    class="btn-municipal-secondary btn-sm"
                  >
                    <font-awesome-icon icon="eye" />
                    Ver
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="hayMasResultados" class="text-center mt-3">
          <button @click="cargarMas" class="btn-municipal-primary">
            <font-awesome-icon icon="chevron-down" />
            Cargar Más Resultados
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron folios en este cementerio
    </div>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ConsultaGuad'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const router = useRouter()

const CEMENTERIO_CODIGO = 'GUADAL'
const LIMITE_RESULTADOS = 100

const filtros = reactive({
  nombre: '',
  folio: null
})

const folios = ref([])
const busquedaRealizada = ref(false)
const hayMasResultados = ref(false)
const ultimoFolio = ref(0)

const helpSections = [
  {
    title: 'Consulta Cementerio Guadalajara',
    content: `
      <p>Consulta y visualización de folios del Cementerio Municipal de Guadalajara.</p>
      <h4>Opciones de Búsqueda:</h4>
      <ul>
        <li><strong>Por Titular:</strong> Busca por nombre del propietario</li>
        <li><strong>Por Folio:</strong> Busca un folio específico</li>
        <li><strong>Sin Filtros:</strong> Lista todos los folios (paginados)</li>
      </ul>
      <h4>Uso:</h4>
      <ol>
        <li>Ingrese un criterio de búsqueda o deje en blanco para listar todos</li>
        <li>Haga clic en "Buscar"</li>
        <li>Use "Cargar Más" para ver siguientes 100 registros</li>
        <li>Haga clic en "Ver" para detalle completo del folio</li>
      </ol>
    `
  }
]

const buscarFolios = async () => {
  try {
    ultimoFolio.value = 0
    folios.value = []

    const params = [
      {
        nombre: 'p_cementerio',
        valor: CEMENTERIO_CODIGO,
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

    const response = await execute('sp_cem_consultar_cementerio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    let resultados = response.result || []

    // Filtrar por nombre si se especificó
    if (filtros.nombre.trim()) {
      const nombreBusqueda = filtros.nombre.toLowerCase()
      resultados = resultados.filter(f =>
        f.nombre && f.nombre.toLowerCase().includes(nombreBusqueda)
      )
    }

    // Filtrar por folio si se especificó
    if (filtros.folio) {
      resultados = resultados.filter(f => f.control_rcm === filtros.folio)
    }

    folios.value = resultados
    busquedaRealizada.value = true
    hayMasResultados.value = resultados.length === LIMITE_RESULTADOS && !filtros.nombre && !filtros.folio

    if (resultados.length > 0) {
      ultimoFolio.value = resultados[resultados.length - 1].control_rcm
      toast.success(`Se encontraron ${resultados.length} folio(s)`)
    } else {
      toast.info('No se encontraron folios con los criterios especificados')
    }
  } catch (error) {
    toast.error('Error al buscar folios')
  }
}

const cargarMas = async () => {
  try {
    const params = [
      {
        nombre: 'p_cementerio',
        valor: CEMENTERIO_CODIGO,
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

    const response = await execute('sp_cem_consultar_cementerio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    const nuevosFolios = response.result || []

    if (nuevosFolios.length === 0) {
      hayMasResultados.value = false
      toast.info('No hay más registros')
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
  filtros.folio = null
  folios.value = []
  busquedaRealizada.value = false
  hayMasResultados.value = false
  ultimoFolio.value = 0
}

const verDetalle = (folio) => {
  router.push({
    name: 'cementerios-conindividual',
    query: { folio }
  })
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
  if (folio.colonia) partes.push(folio.colonia)
  return partes.filter(p => p).join(', ')
}
</script>
