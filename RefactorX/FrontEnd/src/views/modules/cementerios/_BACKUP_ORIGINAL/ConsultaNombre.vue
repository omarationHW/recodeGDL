<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-user-search"></i>
        Consulta por Nombre del Titular
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta por Nombre"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Buscar por Nombre
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Nombre del Titular</label>
            <input
              v-model="nombreBuscar"
              type="text"
              class="form-control"
              placeholder="Ingrese nombre o parte del nombre..."
              @keyup.enter="buscarPorNombre"
              autofocus
            />
          </div>
          <div class="form-actions">
            <button @click="buscarPorNombre" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
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
                <th>Nombre</th>
                <th>Cementerio</th>
                <th>Ubicación</th>
                <th>Tipo</th>
                <th>Año Pagado</th>
                <th>Domicilio</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="folio in folios" :key="folio.control_rcm">
                <td><strong>{{ folio.control_rcm }}</strong></td>
                <td>{{ folio.nombre }}</td>
                <td>{{ folio.cementerio }}</td>
                <td>{{ formatearUbicacion(folio) }}</td>
                <td>{{ folio.tipo || 'N/A' }}</td>
                <td>
                  <span :class="`badge badge-${getAnioPagadoBadge(folio.axo_pagado)}`">
                    {{ folio.axo_pagado }}
                  </span>
                </td>
                <td>{{ formatearDomicilio(folio) }}</td>
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
      No se encontraron folios con el nombre especificado
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()
const router = useRouter()

const nombreBuscar = ref('')
const folios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Consulta por Nombre del Titular',
    content: `
      <p>Búsqueda de folios por nombre del titular.</p>
      <h4>Uso:</h4>
      <ol>
        <li>Ingrese el nombre completo o parte del nombre del titular</li>
        <li>La búsqueda no distingue mayúsculas/minúsculas</li>
        <li>Se mostrarán todos los folios que coincidan</li>
        <li>Haga clic en el ícono de ojo para ver el detalle completo</li>
      </ol>
      <h4>Columnas de Año Pagado:</h4>
      <ul>
        <li><span style="color: green;">Verde:</span> Al corriente</li>
        <li><span style="color: orange;">Naranja:</span> 1-2 años atrasado</li>
        <li><span style="color: red;">Rojo:</span> 3+ años atrasado</li>
      </ul>
    `
  }
]

const buscarPorNombre = async () => {
  if (!nombreBuscar.value || nombreBuscar.value.trim().length < 3) {
    toast.warning('Ingrese al menos 3 caracteres para buscar')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_CONSULTAR_POR_NOMBRE', {
      p_nombre: nombreBuscar.value.trim()
    })

    folios.value = response.data || []
    busquedaRealizada.value = true

    if (folios.value.length > 0) {
      toast.success(`Se encontraron ${folios.value.length} folio(s)`)
    } else {
      toast.info('No se encontraron folios con el nombre especificado')
    }
  } catch (error) {
    console.error('Error al buscar por nombre:', error)
    toast.error('Error al buscar folios')
    folios.value = []
  }
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
  const partes = []
  if (folio.domicilio) partes.push(folio.domicilio)
  if (folio.exterior) partes.push(`#${folio.exterior}`)
  if (folio.interior) partes.push(`Int. ${folio.interior}`)
  if (folio.colonia) partes.push(folio.colonia)
  return partes.join(' ') || 'No especificado'
}

const getAnioPagadoBadge = (anioPagado) => {
  const anioActual = new Date().getFullYear()
  const aniosAtrasados = anioActual - anioPagado

  if (aniosAtrasados <= 0) return 'success'
  if (aniosAtrasados <= 2) return 'warning'
  return 'danger'
}
</script>
