<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-search-plus"></i>
        Consulta Especial 400
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta 400"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Criterios de Búsqueda Avanzada
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label">Rango de Folios Desde</label>
            <input v-model.number="filtros.folio_desde" type="number" class="form-control" min="1" />
          </div>
          <div class="form-group">
            <label class="form-label">Rango de Folios Hasta</label>
            <input v-model.number="filtros.folio_hasta" type="number" class="form-control" min="1" />
          </div>
        </div>
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="form-control">
              <option value="">-- Todos --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="form-label">Año de Pago Menor a</label>
            <input v-model.number="filtros.anio_menor" type="number" class="form-control" :max="new Date().getFullYear()" />
          </div>
        </div>
        <div class="form-actions">
          <button @click="buscarFolios" class="btn-municipal-primary">
            <i class="fas fa-search"></i>
            Buscar
          </button>
          <button @click="limpiar" class="btn-municipal-secondary">
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
        Folios Encontrados ({{ folios.length }})
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
                <td class="text-danger"><strong>{{ calcularAniosAtrasados(folio.axo_pagado) }}</strong></td>
                <td>
                  <button @click="verDetalle(folio.control_rcm)" class="btn-municipal-secondary btn-sm">
                    <i class="fas fa-eye"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <i class="fas fa-info-circle"></i>
      No se encontraron folios con los criterios especificados
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()
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
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_CEMENTERIO', {
      p_cementerio: filtros.cementerio || null,
      p_ultimo_folio: 0,
      p_limite: 1000
    })

    let resultados = response.data || []

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
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
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

<style scoped>
.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}

.text-danger {
  color: var(--color-danger);
}
</style>
