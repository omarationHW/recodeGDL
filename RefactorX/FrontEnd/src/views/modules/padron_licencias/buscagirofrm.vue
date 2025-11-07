<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Giros</h1>
        <p>Padrón de Licencias - Búsqueda y Selección de Giros</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Descripción del Giro</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.descripcion"
                placeholder="Ingrese descripción..."
                @keyup.enter="buscarGiros"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="filters.tipo">
                <option value="L">Licencia</option>
                <option value="A">Anuncio</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Autoevaluación</label>
              <select class="municipal-form-control" v-model="filters.autoev">
                <option value="N">Todos</option>
                <option value="S">Solo Autoevaluación</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Pacto</label>
              <select class="municipal-form-control" v-model="filters.pacto">
                <option value="N">Todos</option>
                <option value="S">Pacto para homologar requisitos</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarGiros"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
          </h5>
          <span class="record-count">{{ giros.length }} giros encontrados</span>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table-municipal">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Descripción</th>
                  <th>Costo</th>
                  <th>Características</th>
                  <th>Clasificación</th>
                  <th>Vigente</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="giro in giros" :key="giro.id_giro">
                  <td>{{ giro.id_giro }}</td>
                  <td>{{ giro.descripcion }}</td>
                  <td>{{ formatCurrency(giro.costo) }}</td>
                  <td>{{ giro.caracteristicas || 'N/A' }}</td>
                  <td>
                    <span class="badge" :class="getClasificacionClass(giro.clasificacion)">
                      {{ giro.clasificacion }}
                    </span>
                  </td>
                  <td>
                    <span class="badge" :class="giro.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                      {{ giro.vigente === 'V' ? 'VIGENTE' : 'CANCELADO' }}
                    </span>
                  </td>
                  <td>
                    <button
                      class="btn-action btn-success"
                      @click="seleccionarGiro(giro)"
                      title="Seleccionar"
                    >
                      <font-awesome-icon icon="check" />
                    </button>
                  </td>
                </tr>
                <tr v-if="giros.length === 0 && !loading">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="mb-2" />
                    <p>No se encontraron giros con los criterios especificados</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Giro seleccionado -->
      <div v-if="selectedGiro" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="check-circle" />
            Giro Seleccionado
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="detail-grid">
            <div class="detail-item">
              <label>ID Giro:</label>
              <span>{{ selectedGiro.id_giro }}</span>
            </div>
            <div class="detail-item">
              <label>Descripción:</label>
              <span>{{ selectedGiro.descripcion }}</span>
            </div>
            <div class="detail-item">
              <label>Costo:</label>
              <span>{{ formatCurrency(selectedGiro.costo) }}</span>
            </div>
            <div class="detail-item">
              <label>Clasificación:</label>
              <span class="badge" :class="getClasificacionClass(selectedGiro.clasificacion)">
                {{ selectedGiro.clasificacion }}
              </span>
            </div>
          </div>
          <div class="button-group mt-3">
            <button class="btn-municipal-secondary" @click="selectedGiro = null">
              <font-awesome-icon icon="times" />
              Quitar Selección
            </button>
            <button class="btn-municipal-primary" @click="confirmarSeleccion">
              <font-awesome-icon icon="check" />
              Confirmar Selección
            </button>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Buscando giros...</p>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'buscagirofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const giros = ref([])
const selectedGiro = ref(null)

// Filtros
const filters = ref({
  descripcion: '',
  tipo: 'L',
  autoev: 'N',
  pacto: 'N'
})

// Métodos
const buscarGiros = async () => {
  setLoading(true, 'Buscando giros...')

  try {
    const currentYear = new Date().getFullYear()

    const response = await execute(
      'SP_BUSCAGIRO_LIST',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: filters.value.descripcion || null, tipo: 'string' },
        { nombre: 'p_tipo', valor: filters.value.tipo, tipo: 'string' },
        { nombre: 'p_autoev', valor: filters.value.autoev, tipo: 'string' },
        { nombre: 'p_pacto', valor: filters.value.pacto, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SYSTEM', tipo: 'string' },
        { nombre: 'p_year', valor: currentYear, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      giros.value = response.result
      showToast('success', `Se encontraron ${giros.value.length} giros`)
    } else {
      giros.value = []
      showToast('info', 'No se encontraron giros')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar giros')
    giros.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    descripcion: '',
    tipo: 'L',
    autoev: 'N',
    pacto: 'N'
  }
  giros.value = []
  selectedGiro.value = null
  showToast('info', 'Filtros limpiados')
}

const seleccionarGiro = (giro) => {
  selectedGiro.value = giro
  showToast('success', 'Giro seleccionado correctamente')
}

const confirmarSeleccion = () => {
  if (selectedGiro.value) {
    // 1. Guardar en localStorage para uso en otros formularios
    const giroData = {
      id: selectedGiro.value.id,
      codigo: selectedGiro.value.codigo,
      descripcion: selectedGiro.value.descripcion,
      categoria: selectedGiro.value.categoria_nombre || selectedGiro.value.categoria,
      tipo: selectedGiro.value.tipo,
      costo: selectedGiro.value.costo,
      timestamp: new Date().toISOString()
    }
    localStorage.setItem('giroSeleccionado', JSON.stringify(giroData))

    // 2. Copiar descripción al portapapeles
    const textoParaCopiar = `${selectedGiro.value.codigo} - ${selectedGiro.value.descripcion}`
    navigator.clipboard.writeText(textoParaCopiar).then(() => {
      // 3. Mostrar mensaje de éxito
      showToast(
        'success',
        `Giro confirmado: "${selectedGiro.value.descripcion}". Se copió al portapapeles y está disponible para otros formularios.`
      )
    }).catch(err => {
      // Si falla el portapapeles, aún guardar en localStorage
      console.warn('No se pudo copiar al portapapeles:', err)
      showToast(
        'success',
        `Giro confirmado y guardado: "${selectedGiro.value.descripcion}".`
      )
    })
  } else {
    showToast('error', 'Por favor selecciona un giro primero')
  }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const getClasificacionClass = (clasificacion) => {
  const classes = {
    'A': 'badge-danger',
    'B': 'badge-warning',
    'C': 'badge-info',
    'D': 'badge-success'
  }
  return classes[clasificacion] || 'badge-secondary'
}

// Lifecycle
onMounted(() => {
  showToast('info', 'Ingrese criterios de búsqueda')
})
</script>
