<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-map-marker-alt"></i>
        Consulta de Folios por Ubicación
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta por Ubicación"
        :sections="helpSections"
      />
    </div>

    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Criterios de Búsqueda
      </div>
      <div class="card-body">
        <div class="form-group">
          <label class="form-label required">Cementerio</label>
          <select v-model="filtros.cementerio" class="form-control">
            <option value="">-- Seleccione --</option>
            <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
              {{ cem.nombre }}
            </option>
          </select>
        </div>

        <div class="form-grid-four">
          <div class="form-group">
            <label class="form-label">Clase >=</label>
            <input v-model.number="filtros.clase" type="number" class="form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Clase Alfa</label>
            <input v-model="filtros.clase_alfa" type="text" class="form-control" maxlength="2" />
          </div>
          <div class="form-group">
            <label class="form-label">Sección >=</label>
            <input v-model.number="filtros.seccion" type="number" class="form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Sección Alfa</label>
            <input v-model="filtros.seccion_alfa" type="text" class="form-control" maxlength="2" />
          </div>
        </div>

        <div class="form-grid-four">
          <div class="form-group">
            <label class="form-label">Línea >=</label>
            <input v-model.number="filtros.linea" type="number" class="form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Línea Alfa</label>
            <input v-model="filtros.linea_alfa" type="text" class="form-control" maxlength="2" />
          </div>
          <div class="form-group">
            <label class="form-label">Fosa >=</label>
            <input v-model.number="filtros.fosa" type="number" class="form-control" min="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Fosa Alfa</label>
            <input v-model="filtros.fosa_alfa" type="text" class="form-control" maxlength="4" />
          </div>
        </div>

        <div class="form-actions">
          <button @click="buscarFolios" class="btn-municipal-primary">
            <i class="fas fa-search"></i>
            Buscar Folios
          </button>
          <button @click="limpiarFiltros" class="btn-municipal-secondary">
            <i class="fas fa-eraser"></i>
            Limpiar
          </button>
        </div>
      </div>
    </div>

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
                    <i class="fas fa-eye"></i>
                    Detalle
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="hayMasResultados" class="text-center mt-3">
          <button @click="cargarMasFolios" class="btn-municipal-primary">
            <i class="fas fa-chevron-down"></i>
            Cargar Más Resultados
          </button>
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
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

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
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIOS_POR_UBICACION', {
      p_cementerio: filtros.cementerio,
      p_clase: filtros.clase || 0,
      p_clase_alfa: filtros.clase_alfa || null,
      p_seccion: filtros.seccion || 0,
      p_seccion_alfa: filtros.seccion_alfa || null,
      p_linea: filtros.linea || 0,
      p_linea_alfa: filtros.linea_alfa || null,
      p_fosa: filtros.fosa || 0,
      p_fosa_alfa: filtros.fosa_alfa || null,
      p_ultimo_folio: 0,
      p_limite: LIMITE_RESULTADOS
    })

    folios.value = response.data || []
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

    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_FOLIOS_POR_UBICACION', {
      p_cementerio: filtros.cementerio,
      p_clase: ultimaUbicacion.clase,
      p_clase_alfa: ultimaUbicacion.clase_alfa || null,
      p_seccion: ultimaUbicacion.seccion,
      p_seccion_alfa: ultimaUbicacion.seccion_alfa || null,
      p_linea: ultimaUbicacion.linea,
      p_linea_alfa: ultimaUbicacion.linea_alfa || null,
      p_fosa: ultimaUbicacion.fosa,
      p_fosa_alfa: ultimaUbicacion.fosa_alfa || null,
      p_ultimo_folio: ultimoFolio.value,
      p_limite: LIMITE_RESULTADOS
    })

    const nuevosFolios = response.data || []

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
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
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
