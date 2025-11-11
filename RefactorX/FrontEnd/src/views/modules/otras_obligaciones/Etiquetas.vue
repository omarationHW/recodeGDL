<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="tags" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Etiquetas</h1>
        <p>Otras Obligaciones - Configuración de Etiquetas por Tabla</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Selector de Tabla -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Seleccionar Tabla
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body">
          <div class="form-group">
            <label class="municipal-form-label">Tabla <span class="required">*</span></label>
            <select
              class="municipal-form-control"
              v-model="selectedTabla"
              @change="onTablaChange"
              :disabled="loading || loadingEtiquetas"
            >
              <option value="">-- Seleccione una tabla --</option>
              <option
                v-for="tabla in tablas"
                :key="tabla.cve_tab"
                :value="tabla.cve_tab"
              >
                {{ tabla.cve_tab }} - {{ tabla.nombre }}
              </option>
            </select>
          </div>
        </div>
      </div>

      <!-- Formulario de Etiquetas -->
      <div class="municipal-card" v-if="selectedTabla">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Configuración de Etiquetas para Tabla "{{ selectedTabla }}"
          </h5>
          <div v-if="loadingEtiquetas" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando etiquetas...</span>
          </div>
        </div>

        <div class="municipal-card-body" v-if="!loadingEtiquetas && etiquetas">
          <form @submit.prevent="saveEtiquetas">
            <!-- Fila 1: Abreviatura, Control, Concesionario -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Abreviatura</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.abreviatura"
                  maxlength="4"
                  placeholder="Abreviatura (máx. 4 caracteres)"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Control</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.etiq_control"
                  maxlength="20"
                  placeholder="Etiqueta Control"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Concesionario</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.concesionario"
                  maxlength="20"
                  placeholder="Etiqueta Concesionario"
                >
              </div>
            </div>

            <!-- Fila 2: Ubicación, Superficie, Fecha Inicio -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Ubicación</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.ubicacion"
                  maxlength="20"
                  placeholder="Etiqueta Ubicación"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Superficie</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.superficie"
                  maxlength="20"
                  placeholder="Etiqueta Superficie"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Inicio</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.fecha_inicio"
                  maxlength="20"
                  placeholder="Etiqueta Fecha Inicio"
                >
              </div>
            </div>

            <!-- Fila 3: Fecha Fin, Recaudadora, Sector -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Fin</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.fecha_fin"
                  maxlength="20"
                  placeholder="Etiqueta Fecha Fin"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.recaudadora"
                  maxlength="20"
                  placeholder="Etiqueta Recaudadora"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sector</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.sector"
                  maxlength="20"
                  placeholder="Etiqueta Sector"
                >
              </div>
            </div>

            <!-- Fila 4: Zona, Licencia, Fecha Cancelación -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Zona</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.zona"
                  maxlength="20"
                  placeholder="Etiqueta Zona"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Licencia</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.licencia"
                  maxlength="20"
                  placeholder="Etiqueta Licencia"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Cancelación</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.fecha_cancelacion"
                  maxlength="20"
                  placeholder="Etiqueta Fecha Cancelación"
                >
              </div>
            </div>

            <!-- Fila 5: Unidad, Categoría, Sección -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Unidad</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.unidad"
                  maxlength="20"
                  placeholder="Etiqueta Unidad"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Categoría</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.categoria"
                  maxlength="20"
                  placeholder="Etiqueta Categoría"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.seccion"
                  maxlength="20"
                  placeholder="Etiqueta Sección"
                >
              </div>
            </div>

            <!-- Fila 6: Bloque, Nombre Comercial, Lugar -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.bloque"
                  maxlength="20"
                  placeholder="Etiqueta Bloque"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Nombre Comercial</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.nombre_comercial"
                  maxlength="20"
                  placeholder="Etiqueta Nombre Comercial"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Lugar</label>
                <input
                  type="text"
                  class="municipal-form-control text-uppercase"
                  v-model="etiquetas.lugar"
                  maxlength="20"
                  placeholder="Etiqueta Lugar"
                >
              </div>
            </div>

            <!-- Fila 7: Observaciones (full width) -->
            <div class="form-group full-width">
              <label class="municipal-form-label">Observaciones</label>
              <input
                type="text"
                class="municipal-form-control text-uppercase"
                v-model="etiquetas.obs"
                maxlength="20"
                placeholder="Etiqueta Observaciones"
              >
            </div>

            <!-- Botones -->
            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="saving || !hasChanges"
              >
                <font-awesome-icon icon="save" />
                {{ saving ? 'Guardando...' : 'Actualizar' }}
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="cancelar"
                :disabled="saving"
              >
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </form>
        </div>

        <div class="municipal-card-body" v-else-if="!loadingEtiquetas && !etiquetas">
          <div class="text-center text-muted">
            <font-awesome-icon icon="info-circle" size="2x" class="empty-icon" />
            <p>No se encontraron etiquetas para esta tabla.</p>
            <p class="small">Se crearán nuevas etiquetas al guardar.</p>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading || loadingEtiquetas" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>{{ loading ? 'Cargando tablas...' : 'Cargando etiquetas...' }}</p>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'Etiquetas'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const router = useRouter()

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
const tablas = ref([])
const selectedTabla = ref('')
const etiquetas = ref(null)
const etiquetasOriginal = ref(null)
const loadingEtiquetas = ref(false)
const saving = ref(false)

// Computed
const hasChanges = computed(() => {
  if (!etiquetas.value || !etiquetasOriginal.value) return false

  return JSON.stringify(etiquetas.value) !== JSON.stringify(etiquetasOriginal.value)
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

// Cargar tablas disponibles
const loadTablas = async () => {
  setLoading(true, 'Cargando tablas...')

  try {
    const response = await execute(
      'SP_ETIQUETAS_TABLAS_GET',
      'otras_obligaciones',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      tablas.value = response.result.map(tabla => ({
        id_34_tab: tabla.id_34_tab,
        cve_tab: tabla.cve_tab,
        nombre: tabla.nombre,
        cajero: tabla.cajero,
        auto_tab: tabla.auto_tab
      }))

      if (tablas.value.length > 0) {
        showToast('success', `${tablas.value.length} tabla(s) cargada(s)`)

        // Seleccionar la primera tabla automáticamente
        selectedTabla.value = tablas.value[0].cve_tab
        onTablaChange()
      } else {
        showToast('info', 'No se encontraron tablas disponibles')
      }
    } else {
      tablas.value = []
      showToast('info', 'No se encontraron tablas')
    }
  } catch (error) {
    handleApiError(error)
    tablas.value = []
  } finally {
    setLoading(false)
  }
}

// Cargar etiquetas de la tabla seleccionada
const onTablaChange = async () => {
  if (!selectedTabla.value) {
    etiquetas.value = null
    etiquetasOriginal.value = null
    return
  }

  loadingEtiquetas.value = true

  try {
    const response = await execute(
      'SP_ETIQUETAS_GET',
      'otras_obligaciones',
      [
        { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]

      // Crear objeto de etiquetas
      etiquetas.value = {
        cve_tab: data.cve_tab || selectedTabla.value,
        abreviatura: (data.abreviatura || '').trim(),
        etiq_control: (data.etiq_control || '').trim(),
        concesionario: (data.concesionario || '').trim(),
        ubicacion: (data.ubicacion || '').trim(),
        superficie: (data.superficie || '').trim(),
        fecha_inicio: (data.fecha_inicio || '').trim(),
        fecha_fin: (data.fecha_fin || '').trim(),
        recaudadora: (data.recaudadora || '').trim(),
        sector: (data.sector || '').trim(),
        zona: (data.zona || '').trim(),
        licencia: (data.licencia || '').trim(),
        fecha_cancelacion: (data.fecha_cancelacion || '').trim(),
        unidad: (data.unidad || '').trim(),
        categoria: (data.categoria || '').trim(),
        seccion: (data.seccion || '').trim(),
        bloque: (data.bloque || '').trim(),
        nombre_comercial: (data.nombre_comercial || '').trim(),
        lugar: (data.lugar || '').trim(),
        obs: (data.obs || '').trim()
      }

      // Guardar copia original para detectar cambios
      etiquetasOriginal.value = JSON.parse(JSON.stringify(etiquetas.value))

      showToast('success', 'Etiquetas cargadas correctamente')
    } else {
      // No existen etiquetas para esta tabla - crear objeto vacío
      etiquetas.value = {
        cve_tab: selectedTabla.value,
        abreviatura: '',
        etiq_control: '',
        concesionario: '',
        ubicacion: '',
        superficie: '',
        fecha_inicio: '',
        fecha_fin: '',
        recaudadora: '',
        sector: '',
        zona: '',
        licencia: '',
        fecha_cancelacion: '',
        unidad: '',
        categoria: '',
        seccion: '',
        bloque: '',
        nombre_comercial: '',
        lugar: '',
        obs: ''
      }

      etiquetasOriginal.value = JSON.parse(JSON.stringify(etiquetas.value))

      showToast('info', 'No se encontraron etiquetas. Se crearán nuevas al guardar.')
    }
  } catch (error) {
    handleApiError(error)
    etiquetas.value = null
    etiquetasOriginal.value = null
  } finally {
    loadingEtiquetas.value = false
  }
}

// Guardar etiquetas
const saveEtiquetas = async () => {
  if (!etiquetas.value || !selectedTabla.value) {
    showToast('error', 'No hay etiquetas para guardar')
    return
  }

  if (!hasChanges.value) {
    showToast('info', 'No hay cambios para guardar')
    return
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se actualizarán las etiquetas para la tabla:</p>
        <p style="font-weight: bold; color: #ea8215; margin: 10px 0;">${selectedTabla.value}</p>
        <p style="font-size: 0.9em; color: #666;">Esta acción modificará cómo se muestran los campos en la interfaz del padrón.</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true

  try {
    const params = [
      { nombre: 'p_cve_tab', valor: selectedTabla.value, tipo: 'string' },
      { nombre: 'p_abreviatura', valor: etiquetas.value.abreviatura || ' ', tipo: 'string' },
      { nombre: 'p_etiq_control', valor: etiquetas.value.etiq_control || ' ', tipo: 'string' },
      { nombre: 'p_concesionario', valor: etiquetas.value.concesionario || ' ', tipo: 'string' },
      { nombre: 'p_ubicacion', valor: etiquetas.value.ubicacion || ' ', tipo: 'string' },
      { nombre: 'p_superficie', valor: etiquetas.value.superficie || ' ', tipo: 'string' },
      { nombre: 'p_fecha_inicio', valor: etiquetas.value.fecha_inicio || ' ', tipo: 'string' },
      { nombre: 'p_fecha_fin', valor: etiquetas.value.fecha_fin || ' ', tipo: 'string' },
      { nombre: 'p_recaudadora', valor: etiquetas.value.recaudadora || ' ', tipo: 'string' },
      { nombre: 'p_sector', valor: etiquetas.value.sector || ' ', tipo: 'string' },
      { nombre: 'p_zona', valor: etiquetas.value.zona || ' ', tipo: 'string' },
      { nombre: 'p_licencia', valor: etiquetas.value.licencia || ' ', tipo: 'string' },
      { nombre: 'p_fecha_cancelacion', valor: etiquetas.value.fecha_cancelacion || ' ', tipo: 'string' },
      { nombre: 'p_unidad', valor: etiquetas.value.unidad || ' ', tipo: 'string' },
      { nombre: 'p_categoria', valor: etiquetas.value.categoria || ' ', tipo: 'string' },
      { nombre: 'p_seccion', valor: etiquetas.value.seccion || ' ', tipo: 'string' },
      { nombre: 'p_bloque', valor: etiquetas.value.bloque || ' ', tipo: 'string' },
      { nombre: 'p_nombre_comercial', valor: etiquetas.value.nombre_comercial || ' ', tipo: 'string' },
      { nombre: 'p_lugar', valor: etiquetas.value.lugar || ' ', tipo: 'string' },
      { nombre: 'p_obs', valor: etiquetas.value.obs || ' ', tipo: 'string' }
    ]

    const response = await execute(
      'SP_ETIQUETAS_UPDATE',
      'otras_obligaciones',
      params,
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const result = response.result[0]

      if (result.success === 1) {
        await Swal.fire({
          icon: 'success',
          title: '¡Actualización exitosa!',
          text: result.message || 'Las etiquetas han sido actualizadas correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        showToast('success', 'Etiquetas actualizadas correctamente')

        // Recargar etiquetas
        onTablaChange()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error al actualizar',
          text: result.message || 'No se pudieron actualizar las etiquetas',
          confirmButtonColor: '#ea8215'
        })
      }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Respuesta inesperada del servidor',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudieron actualizar las etiquetas',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    saving.value = false
  }
}

// Cancelar cambios
const cancelar = async () => {
  if (hasChanges.value) {
    const confirmResult = await Swal.fire({
      icon: 'warning',
      title: '¿Cancelar cambios?',
      text: 'Se perderán los cambios realizados',
      showCancelButton: true,
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, cancelar',
      cancelButtonText: 'No'
    })

    if (!confirmResult.isConfirmed) {
      return
    }
  }

  // Restaurar valores originales
  if (etiquetasOriginal.value) {
    etiquetas.value = JSON.parse(JSON.stringify(etiquetasOriginal.value))
  }

  showToast('info', 'Cambios cancelados')
}

// Lifecycle
onMounted(() => {
  loadTablas()
})
</script>
