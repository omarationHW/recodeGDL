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
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
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

      <!-- Empty State - Sin búsqueda -->
      <div v-if="folios.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="user" size="3x" />
        </div>
        <h4>Consulta por Nombre del Titular</h4>
        <p>Ingrese el nombre del titular para buscar folios en cementerios</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="folios.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron folios con el nombre especificado</p>
      </div>

      <!-- Resultados -->
      <div v-else class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Folios Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="folios.length > 0">
              {{ folios.length }} registros
            </span>
          </div>
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
                <tr
                  v-for="folio in folios"
                  :key="folio.control_rcm"
                  @click="selectedRow = folio"
                  :class="{ 'table-row-selected': selectedRow === folio }"
                  class="row-hover"
                >
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
                    <button @click.stop="verDetalle(folio.control_rcm)" class="btn-municipal-secondary btn-sm">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda/Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ConsultaNombre'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Consulta por Nombre del Titular'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
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

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Variables de estado
const nombreBuscar = ref('')
const folios = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)

const buscarPorNombre = async () => {
  if (!nombreBuscar.value || nombreBuscar.value.trim().length < 3) {
    showToast('warning', 'Ingrese al menos 3 caracteres para buscar')
    return
  }

  showLoading('Buscando folios...', 'Consultando en cementerios')
  hasSearched.value = true
  selectedRow.value = null

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
