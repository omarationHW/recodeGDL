<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="map-marker-alt" />
        Consulta de Folios por Ubicación
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta por Ubicación"
        :sections="helpSections"
      />
    </div>

    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Criterios de Búsqueda
      </div>
      <div class="municipal-card-body">
        <div class="form-group">
          <label class="form-label required">Cementerio</label>
          <select v-model="filtros.cementerio" class="municipal-form-control">
            <option value="">-- Seleccione --</option>
            <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
              {{ cem.nombre }}
            </option>
          </select>
        </div>

        <div class="form-grid-four">
          <div class="form-group">
            <label class="municipal-form-label">Clase >=</label>
            <input v-model.number="filtros.clase" type="number" class="municipal-form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clase Alfa</label>
            <input v-model="filtros.clase_alfa" type="text" class="municipal-form-control" maxlength="2" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Sección >=</label>
            <input v-model.number="filtros.seccion" type="number" class="municipal-form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Sección Alfa</label>
            <input v-model="filtros.seccion_alfa" type="text" class="municipal-form-control" maxlength="2" />
          </div>
        </div>

        <div class="form-grid-four">
          <div class="form-group">
            <label class="municipal-form-label">Línea >=</label>
            <input v-model.number="filtros.linea" type="number" class="municipal-form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Línea Alfa</label>
            <input v-model="filtros.linea_alfa" type="text" class="municipal-form-control" maxlength="2" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fosa >=</label>
            <input v-model.number="filtros.fosa" type="number" class="municipal-form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fosa Alfa</label>
            <input v-model="filtros.fosa_alfa" type="text" class="municipal-form-control" maxlength="4" />
          </div>
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
                <td>{{ formatearUbicacion(folio) }}</td>
                <td>{{ folio.axo_pagado }}</td>
                <td>{{ folio.metros }}</td>
                <td>
                  <button @click="verDetalleFolio(folio.control_rcm)" class="btn-municipal-secondary btn-sm">
                    <font-awesome-icon icon="eye" />
                    Detalle
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

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
      No se encontraron folios con los criterios especificados
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
  cementerio: '',
  clase: 0,
  clase_alfa: '',
  seccion: 0,
  seccion_alfa: '',
  linea: 0,
  linea_alfa: '',
  fosa: 0,
  fosa_alfa: ''
})

const folios = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)
const hayMasResultados = ref(false)
const ultimoFolio = ref(0)
const LIMITE_RESULTADOS = 100

const helpSections = [
  {
    title: 'Consulta de Folios por Ubicación',
    content: `
      <p>Busca folios por ubicación física en el cementerio.</p>
      <h4>Uso:</h4>
      <ol>
        <li>Seleccione el cementerio</li>
        <li>Ingrese la ubicación mínima (clase, sección, línea, fosa)</li>
        <li>El sistema mostrará hasta 100 resultados ordenados por ubicación</li>
        <li>Use "Cargar Más" para ver los siguientes 100 resultados</li>
      </ol>
    `
  }
]

const buscarFolios = async () => {
  if (!filtros.cementerio) {
    toast.warning('Seleccione un cementerio')
    return
  }

  try {
    const params = [
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio,
        tipo: 'string'
      },
      {
        nombre: 'p_clase',
        valor: filtros.clase || 0,
        tipo: 'string'
      },
      {
        nombre: 'p_clase_alfa',
        valor: filtros.clase_alfa || null,
        tipo: 'string'
      },
      {
        nombre: 'p_seccion',
        valor: filtros.seccion || 0,
        tipo: 'string'
      },
      {
        nombre: 'p_seccion_alfa',
        valor: filtros.seccion_alfa || null,
        tipo: 'string'
      },
      {
        nombre: 'p_linea',
        valor: filtros.linea || 0,
        tipo: 'string'
      },
      {
        nombre: 'p_linea_alfa',
        valor: filtros.linea_alfa || null,
        tipo: 'string'
      },
      {
        nombre: 'p_fosa',
        valor: filtros.fosa || 0,
        tipo: 'string'
      },
      {
        nombre: 'p_fosa_alfa',
        valor: filtros.fosa_alfa || null,
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

    const response = await execute('sp_cem_consultar_folios_por_ubicacion', 'cementerios', params,
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
    console.error('Error al buscar folios:', error)
    toast.error('Error al buscar folios')
  }
}

const cargarMasFolios = async () => {
  try {
    // Actualizar filtros con la última ubicación encontrada
    const ultimaUbicacion = folios.value[folios.value.length - 1]

    const params = [
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio,
        tipo: 'string'
      },
      {
        nombre: 'p_clase',
        valor: ultimaUbicacion.clase,
        tipo: 'string'
      },
      {
        nombre: 'p_clase_alfa',
        valor: ultimaUbicacion.clase_alfa || null,
        tipo: 'string'
      },
      {
        nombre: 'p_seccion',
        valor: ultimaUbicacion.seccion,
        tipo: 'string'
      },
      {
        nombre: 'p_seccion_alfa',
        valor: ultimaUbicacion.seccion_alfa || null,
        tipo: 'string'
      },
      {
        nombre: 'p_linea',
        valor: ultimaUbicacion.linea,
        tipo: 'string'
      },
      {
        nombre: 'p_linea_alfa',
        valor: ultimaUbicacion.linea_alfa || null,
        tipo: 'string'
      },
      {
        nombre: 'p_fosa',
        valor: ultimaUbicacion.fosa,
        tipo: 'string'
      },
      {
        nombre: 'p_fosa_alfa',
        valor: ultimaUbicacion.fosa_alfa || null,
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

    const response = await execute('sp_cem_consultar_folios_por_ubicacion', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    const nuevosFolios = response.result || []

    if (nuevosFolios.length === 0) {
      hayMasResultados.value = false
      toast.info('No existen más registros')
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
  filtros.cementerio = ''
  filtros.clase = 0
  filtros.clase_alfa = ''
  filtros.seccion = 0
  filtros.seccion_alfa = ''
  filtros.linea = 0
  filtros.linea_alfa = ''
  filtros.fosa = 0
  filtros.fosa_alfa = ''
  folios.value = []
  busquedaRealizada.value = false
  hayMasResultados.value = false
  ultimoFolio.value = 0
}

const verDetalleFolio = (controlRcm) => {
  // TODO: Integrar con componente ConIndividual
  toast.info(`Ver folio ${controlRcm}`)
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('sp_cem_listar_cementerios', {})
    cementerios.value = response.result || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
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

onMounted(() => {
  cargarCementerios()
})
</script>

<style scoped>
.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}

.text-center {
  text-align: center;
}
</style>
