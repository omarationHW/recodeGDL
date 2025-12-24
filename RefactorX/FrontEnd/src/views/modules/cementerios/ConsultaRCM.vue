<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search-location" />
      </div>
      <div class="module-view-info">
        <h1>Consulta RCM por Ubicación</h1>
        <p>Cementerios - Búsqueda por ubicación física</p>
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
      <!-- Búsqueda por Ubicación -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="map-marker-alt" />
          Búsqueda por Ubicación Física
        </div>
        <div class="municipal-card-body">
          <!-- Cementerio -->
          <div class="form-group">
            <label class="form-label required">Cementerio</label>
            <select
              v-model="formBusqueda.cementerio"
              class="municipal-form-control"
              @change="onCementerioChange"
            >
              <option value="">Seleccione...</option>
              <option
                v-for="cem in cementerios"
                :key="cem.cementerio"
                :value="cem.cementerio"
              >
                {{ cem.cementerio }} - {{ cem.nombre }}
              </option>
            </select>
          </div>

          <!-- Ubicación en 2 filas -->
          <div class="form-grid-four">
            <!-- Clase -->
            <div class="form-group">
              <label class="form-label required">Clase</label>
              <input
                v-model.number="formBusqueda.clase"
                type="number"
                min="1"
                max="3"
                class="municipal-form-control"
                placeholder="1-3"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Clase Alfa</label>
              <input
                v-model="formBusqueda.clase_alfa"
                type="text"
                maxlength="3"
                class="municipal-form-control"
                placeholder="Opcional"
              />
            </div>

            <!-- Sección -->
            <div class="form-group">
              <label class="form-label required">Sección</label>
              <input
                v-model.number="formBusqueda.seccion"
                type="number"
                min="1"
                class="municipal-form-control"
                placeholder="Número"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Sección Alfa</label>
              <input
                v-model="formBusqueda.seccion_alfa"
                type="text"
                maxlength="3"
                class="municipal-form-control"
                placeholder="Opcional"
              />
            </div>
          </div>

          <div class="form-grid-four">
            <!-- Línea -->
            <div class="form-group">
              <label class="form-label required">Línea</label>
              <input
                v-model.number="formBusqueda.linea"
                type="number"
                min="1"
                class="municipal-form-control"
                placeholder="Número"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Línea Alfa</label>
              <input
                v-model="formBusqueda.linea_alfa"
                type="text"
                maxlength="3"
                class="municipal-form-control"
                placeholder="Opcional"
              />
            </div>

            <!-- Fosa -->
            <div class="form-group">
              <label class="form-label required">Fosa</label>
              <input
                v-model.number="formBusqueda.fosa"
                type="number"
                min="1"
                class="municipal-form-control"
                placeholder="Número"
              />
            </div>
            <div class="form-group">
              <label class="form-label">Fosa Alfa</label>
              <input
                v-model="formBusqueda.fosa_alfa"
                type="text"
                maxlength="3"
                class="municipal-form-control"
                placeholder="Opcional"
              />
            </div>
          </div>

          <div class="form-actions">
            <button @click="buscarPorUbicacion" class="btn-municipal-primary" :disabled="!formValido">
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

      <!-- Empty State - Sin búsqueda -->
      <div v-if="!folio && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="search-location" size="3x" />
        </div>
        <h4>Consulta RCM por Ubicación</h4>
        <p>Complete los campos de ubicación física para buscar un registro de cementerio</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="!folio && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontró ningún registro con la ubicación especificada</p>
      </div>

      <!-- Resultado -->
      <div v-if="folio" class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="info-circle" />
          Información del RCM {{ folio.control_rcm }}
        </div>
        <div class="municipal-card-body">
          <div class="rcm-info-grid">
            <div class="info-section">
              <h5><font-awesome-icon icon="user" /> Titular</h5>
              <p class="info-value">{{ folio.nombre }}</p>
            </div>
            <div class="info-section">
              <h5><font-awesome-icon icon="map-marked-alt" /> Control RCM</h5>
              <p class="info-value highlight">{{ folio.control_rcm }}</p>
            </div>
            <div class="info-section">
              <h5><font-awesome-icon icon="map-pin" /> Ubicación</h5>
              <p class="info-value">{{ formatearUbicacion(folio) }}</p>
            </div>
            <div class="info-section">
              <h5><font-awesome-icon icon="calendar-alt" /> Año Pagado</h5>
              <p class="info-value">{{ folio.axo_pagado }}</p>
            </div>
          </div>

          <div class="form-actions mt-3">
            <button @click="verDetalleCompleto" class="btn-municipal-primary">
              <font-awesome-icon icon="eye" />
              Ver Detalle Completo
            </button>
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
        :componentName="'ConsultaRCM'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Consulta RCM por Ubicación'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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

const cementerios = ref([])
const folio = ref(null)
const hasSearched = ref(false)
const busquedaRealizada = ref(false)

const formBusqueda = ref({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

// Validación del formulario
const formValido = computed(() => {
  return (
    formBusqueda.value.cementerio &&
    formBusqueda.value.clase >= 1 &&
    formBusqueda.value.clase <= 3 &&
    formBusqueda.value.seccion > 0 &&
    formBusqueda.value.linea > 0 &&
    formBusqueda.value.fosa > 0
  )
})

// Cargar cementerios al montar
onMounted(async () => {
  await cargarCementerios()
})

const cargarCementerios = async () => {
  try {
    // Usar SP: sp_consultarcm_listar_cementerios
    // Base: cementerio.publico (según 08_SP_CEMENTERIOS_CONSULTARCM_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_consultarcm_listar_cementerios',
      'cementerio',
      [],
      '',
      null,
      'publico'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT cementerio, nombre, domicilio
    FROM cementerio.publico.tc_13_cementerios
    ORDER BY cementerio
    */
    if (response && response.result) {
      cementerios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar lista de cementerios')
  }
}

const onCementerioChange = () => {
  // Resetear folio si cambia cementerio
  if (folio.value) {
    folio.value = null
    hasSearched.value = false
    busquedaRealizada.value = false
  }
}

const buscarPorUbicacion = async () => {
  // Validaciones según Pascal original (línea 378-389)
  if (!formBusqueda.value.cementerio) {
    showToast('warning', 'Debe seleccionar un cementerio')
    return
  }

  if (formBusqueda.value.clase < 1 || formBusqueda.value.clase > 3) {
    showToast('warning', 'Clase debe ser de 1 a 3')
    return
  }

  if (!formBusqueda.value.seccion || formBusqueda.value.seccion <= 0) {
    showToast('warning', 'Sección debe tener información')
    return
  }

  if (!formBusqueda.value.linea || formBusqueda.value.linea <= 0) {
    showToast('warning', 'Línea debe tener información')
    return
  }

  if (!formBusqueda.value.fosa || formBusqueda.value.fosa <= 0) {
    showToast('warning', 'Fosa debe tener información')
    return
  }

  showLoading('Buscando folio...', 'Consultando en base de datos')
  hasSearched.value = true
  try {
    // Usar SP: sp_consultarcm_buscar_por_ubicacion
    // Base: cementerio.publico (según 08_SP_CEMENTERIOS_CONSULTARCM_EXACTO_all_procedures.sql)
    const response = await execute(
      'sp_consultarcm_buscar_por_ubicacion',
      'cementerio',
      [
        { nombre: 'p_cementerio', valor: formBusqueda.value.cementerio, tipo: 'varchar' },
        { nombre: 'p_clase', valor: formBusqueda.value.clase, tipo: 'smallint' },
        { nombre: 'p_clase_alfa', valor: formBusqueda.value.clase_alfa || '', tipo: 'varchar' },
        { nombre: 'p_seccion', valor: formBusqueda.value.seccion, tipo: 'smallint' },
        { nombre: 'p_seccion_alfa', valor: formBusqueda.value.seccion_alfa || '', tipo: 'varchar' },
        { nombre: 'p_linea', valor: formBusqueda.value.linea, tipo: 'smallint' },
        { nombre: 'p_linea_alfa', valor: formBusqueda.value.linea_alfa || '', tipo: 'varchar' },
        { nombre: 'p_fosa', valor: formBusqueda.value.fosa, tipo: 'smallint' },
        { nombre: 'p_fosa_alfa', valor: formBusqueda.value.fosa_alfa || '', tipo: 'varchar' }
      ],
      'function',
      null,
      'publico'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT * FROM padron_licencias.comun.ta_13_datosrcm
    WHERE cementerio = [cementerio]
      AND clase = [clase]
      AND clase_alfa = [clase_alfa]
      AND seccion = [seccion]
      AND seccion_alfa = [seccion_alfa]
      AND linea = [linea]
      AND linea_alfa = [linea_alfa]
      AND fosa = [fosa]
      AND fosa_alfa = [fosa_alfa]
      AND vigencia = 'A'
    */

    busquedaRealizada.value = true

    if (response?.result?.length > 0) {
      folio.value = response.result[0]
      showToast('success', 'Folio encontrado')
    } else {
      folio.value = null
      showToast('warning', 'No existe registro con esos datos')
    }
  } catch (error) {
    console.error('Error al buscar por ubicación:', error)
    showToast('error', 'Error al buscar folio')
    folio.value = null
  } finally {
    hideLoading()
  }
}

const verDetalleCompleto = () => {
  if (folio.value) {
    router.push({
      name: 'cementerios-conindividual',
      query: { folio: folio.value.control_rcm }
    })
  }
}

const limpiar = () => {
  formBusqueda.value = {
    cementerio: '',
    clase: null,
    clase_alfa: '',
    seccion: null,
    seccion_alfa: '',
    linea: null,
    linea_alfa: '',
    fosa: null,
    fosa_alfa: ''
  }
  folio.value = null
  hasSearched.value = false
  busquedaRealizada.value = false
}

const formatearUbicacion = (folio) => {
  const partes = []
  partes.push(`Cementerio: ${folio.cementerio}`)
  partes.push(`Cl: ${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec: ${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin: ${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa: ${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' - ')
}
</script>
