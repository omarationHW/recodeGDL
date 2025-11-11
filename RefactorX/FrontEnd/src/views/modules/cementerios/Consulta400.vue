<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="search-plus" />
        Consulta Especial 400
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta 400"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Criterios de Búsqueda Avanzada
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="municipal-form-label">Rango de Folios Desde</label>
            <input v-model.number="filtros.folio_desde" type="number" class="municipal-form-control" min="1" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Rango de Folios Hasta</label>
            <input v-model.number="filtros.folio_hasta" type="number" class="municipal-form-control" min="1" />
          </div>
        </div>
        <div class="form-grid-two">
          <div class="form-group">
            <label class="municipal-form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="municipal-form-control">
              <option value="">-- Todos --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Año de Pago Menor a</label>
            <input v-model.number="filtros.anio_menor" type="number" class="municipal-form-control" :max="new Date().getFullYear()" />
          </div>
        </div>
        <div class="form-actions">
          <button @click="buscarFolios" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
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
                <th>Cementerio</th>
                <th>Titular</th>
                <th>Ubicación</th>
                <th>Año Pagado</th>
                <th>Años Atrasado</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="folio in folios" :key="folio.control_rcm">
                <td>{{ folio.control_rcm }}</td>
                <td>{{ folio.cementerio }}</td>
                <td>{{ folio.nombre }}</td>
                <td>{{ formatearUbicacion(folio) }}</td>
                <td>{{ folio.axo_pagado }}</td>
                <td><span class="badge badge-danger">{{ calcularAniosAtrasados(folio.axo_pagado) }}</span></td>
                <td>
                  <button @click="verDetalle(folio.control_rcm)" class="btn-municipal-secondary btn-sm">
                    <font-awesome-icon icon="eye" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron folios con los criterios especificados
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
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

const filtros = reactive({
  folio_desde: null,
  folio_hasta: null,
  cementerio: '',
  anio_menor: new Date().getFullYear() - 1
})

const folios = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Consulta Especial 400',
    content: `
      <p>Búsqueda avanzada de folios con criterios especiales.</p>
      <h4>Filtros Disponibles:</h4>
      <ul>
        <li><strong>Rango de Folios:</strong> Busca dentro de un rango específico</li>
        <li><strong>Cementerio:</strong> Filtra por cementerio</li>
        <li><strong>Año de Pago:</strong> Encuentra folios con año de pago menor al especificado</li>
      </ul>
      <p>Esta consulta es útil para identificar folios con pagos atrasados o que requieren atención especial.</p>
    `
  }
]

const buscarFolios = async () => {
  try {
    const params = [
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio || null,
        tipo: 'string'
      },
      {
        nombre: 'p_ultimo_folio',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_limite',
        valor: 1000,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_consultar_cementerio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    let resultados = response.result || []

    // Aplicar filtros localmente
    if (filtros.folio_desde) {
      resultados = resultados.filter(f => f.control_rcm >= filtros.folio_desde)
    }
    if (filtros.folio_hasta) {
      resultados = resultados.filter(f => f.control_rcm <= filtros.folio_hasta)
    }
    if (filtros.anio_menor) {
      resultados = resultados.filter(f => f.axo_pagado < filtros.anio_menor)
    }

    folios.value = resultados
    busquedaRealizada.value = true

    if (resultados.length > 0) {
      toast.success(`Se encontraron ${resultados.length} folio(s)`)
    } else {
      toast.info('No se encontraron folios con los criterios especificados')
    }
  } catch (error) {
    console.error('Error al buscar folios:', error)
    toast.error('Error al buscar folios')
  }
}

const limpiar = () => {
  filtros.folio_desde = null
  filtros.folio_hasta = null
  filtros.cementerio = ''
  filtros.anio_menor = new Date().getFullYear() - 1
  folios.value = []
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

const verDetalle = (folio) => {
  router.push({
    name: 'cementerios-conindividual',
    query: { folio }
  })
}

const formatearUbicacion = (folio) => {
  return `Cl:${folio.clase}${folio.clase_alfa || ''} Sec:${folio.seccion}${folio.seccion_alfa || ''}`
}

const calcularAniosAtrasados = (anioPagado) => {
  return new Date().getFullYear() - anioPagado
}

onMounted(() => {
  cargarCementerios()
})
</script>
