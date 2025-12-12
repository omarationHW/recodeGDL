<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="user" />
      </div>
      <div class="module-view-info">
        <h1>Consulta por Nombre del Titular</h1>
        <p>Cementerios - Búsqueda de folios por nombre</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Búsqueda -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Buscar por Nombre
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Nombre del Titular</label>
            <input
              v-model="nombreBuscar"
              type="text"
              class="municipal-form-control"
              placeholder="Ingrese nombre o parte del nombre..."
              @keyup.enter="buscarPorNombre"
              autofocus
            />
          </div>
          <div class="form-actions">
            <button @click="buscarPorNombre" class="btn-municipal-primary">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
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
      No se encontraron folios con el nombre especificado
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda/Documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsultaNombre'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Sistema de Toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 4000)
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

// Modal de documentación
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const nombreBuscar = ref('')
const folios = ref([])
const busquedaRealizada = ref(false)

const buscarPorNombre = async () => {
  if (!nombreBuscar.value || nombreBuscar.value.trim().length < 3) {
    showToast('warning', 'Ingrese al menos 3 caracteres para buscar')
    return
  }

  showLoading('Buscando folios...')
  try {
    // Usar SP: sp_consultanombre_buscar
    // Base: cementerio.public (según 07_SP_CEMENTERIOS_CONSULTANOMBRE_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_consultanombre_buscar',
      'cementerio',
      [
         { nombre: 'p_nombre', valor: nombreBuscar.value.trim(), tipo: 'string' }
      ],
      '',
      null,
      'publico'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT FIRST 50 *
    FROM padron_licencias.comun.ta_13_datosrcm
    WHERE UPPER(nombre) LIKE UPPER([nombre] || '%')
      AND vigencia = 'A'
    ORDER BY nombre
    */

    if (response && response.result) {
      folios.value = response.result
    }
    busquedaRealizada.value = true

    if (folios.value.length > 0) {
      showToast('success', `Se encontraron ${folios.value.length} folio(s)`)
    } else {
      showToast('info', 'No se encontraron folios con el nombre especificado')
    }
  } catch (error) {
    console.error('Error al buscar por nombre:', error)
    showToast('error', 'Error al buscar folios')
    folios.value = []
  } finally {
    hideLoading()
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
