<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-monument"></i>
        Consulta Cementerio Guadalajara
      </h1>
      <DocumentationModal
        title="Ayuda - Cementerio Guadalajara"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Filtros de Consulta
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label">Buscar por Titular</label>
            <input
              v-model="filtros.nombre"
              type="text"
              class="form-control"
              placeholder="Nombre del titular..."
            />
          </div>
          <div class="form-group">
            <label class="form-label">Buscar por Folio</label>
            <input
              v-model.number="filtros.folio"
              type="number"
              class="form-control"
              placeholder="Número de folio..."
            />
          </div>
        </div>
        <div class="form-actions">
          <button @click="buscarFolios" class="btn-municipal-primary">
            <i class="fas fa-search"></i>
            Buscar
          </button>
          <button @click="limpiarFiltros" class="btn-municipal-secondary">
            <i class="fas fa-eraser"></i>
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="folios.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Folios del Cementerio Guadalajara ({{ folios.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
                    <i class="fas fa-eye"></i>
                    Ver
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="hayMasResultados" class="text-center mt-3">
          <button @click="cargarMas" class="btn-municipal-primary">
            <i class="fas fa-chevron-down"></i>
            Cargar Más Resultados
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <i class="fas fa-info-circle"></i>
      No se encontraron folios en este cementerio
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()
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

    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_CEMENTERIO', {
      p_cementerio: CEMENTERIO_CODIGO,
      p_ultimo_folio: 0,
      p_limite: LIMITE_RESULTADOS
    })

    let resultados = response.data || []

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
    console.error('Error al buscar folios:', error)
    toast.error('Error al buscar folios')
  }
}

const cargarMas = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_CEMENTERIO', {
      p_cementerio: CEMENTERIO_CODIGO,
      p_ultimo_folio: ultimoFolio.value,
      p_limite: LIMITE_RESULTADOS
    })

    const nuevosFolios = response.data || []

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
    console.error('Error al cargar más folios:', error)
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
