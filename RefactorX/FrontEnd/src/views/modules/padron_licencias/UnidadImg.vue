<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="folder-open" />
      </div>
      <div class="module-view-info">
        <h1>Unidad de Imágenes</h1>
        <p>Padrón de Licencias - Configuración de Rutas de Imágenes del Sistema</p></div>
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

    <!-- Configuración de Rutas -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="cog" />
          Configuración de Rutas de Imágenes
        </h5>
        <div class="button-group">
          <button
            class="btn-municipal-secondary"
            @click="cargarConfiguracion"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="guardarConfiguracion">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Unidad de Disco: <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="configuracion.unidad"
                placeholder="Ej: C:, D:, E:"
                maxlength="10"
                required
              >
              <small class="form-text">Unidad de disco donde se almacenarán las imágenes</small>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Directorio Base: <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="configuracion.directorioBase"
                placeholder="Ej: \Imagenes\Sistema"
                required
              >
              <small class="form-text">Directorio raíz para todas las imágenes</small>
            </div>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Directorio de Licencias: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="configuracion.directorioLicencias"
              placeholder="Ej: \Licencias"
              required
            >
            <small class="form-text">Subdirectorio para imágenes de licencias</small>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Directorio de Trámites: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="configuracion.directorioTramites"
              placeholder="Ej: \Tramites"
              required
            >
            <small class="form-text">Subdirectorio para imágenes de trámites</small>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Directorio de Anuncios: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="configuracion.directorioAnuncios"
              placeholder="Ej: \Anuncios"
              required
            >
            <small class="form-text">Subdirectorio para imágenes de anuncios</small>
          </div>
        </form>
      </div>
    </div>

    <!-- Vista Previa de Rutas -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="eye" />
          Vista Previa de Rutas Completas
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="path-preview-grid">
          <div class="path-preview-item">
            <label>
              <font-awesome-icon icon="folder" class="text-primary" />
              Ruta Base:
            </label>
            <code class="path-code">{{ rutaBase }}</code>
          </div>
          <div class="path-preview-item">
            <label>
              <font-awesome-icon icon="id-card" class="text-success" />
              Ruta Licencias:
            </label>
            <code class="path-code">{{ rutaLicencias }}</code>
          </div>
          <div class="path-preview-item">
            <label>
              <font-awesome-icon icon="file-alt" class="text-info" />
              Ruta Trámites:
            </label>
            <code class="path-code">{{ rutaTramites }}</code>
          </div>
          <div class="path-preview-item">
            <label>
              <font-awesome-icon icon="bullhorn" class="text-warning" />
              Ruta Anuncios:
            </label>
            <code class="path-code">{{ rutaAnuncios }}</code>
          </div>
        </div>
      </div>
    </div>

    <!-- Validación de Rutas -->
    <div v-if="validacionRutas.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" />
          Estado de Validación de Rutas
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="validation-grid">
          <div
            v-for="validacion in validacionRutas"
            :key="validacion.tipo"
            class="validation-item"
            :class="validacion.valida ? 'valid' : 'invalid'"
          >
            <font-awesome-icon
              :icon="validacion.valida ? 'check-circle' : 'exclamation-triangle'"
              :class="validacion.valida ? 'text-success' : 'text-danger'"
            />
            <span>{{ validacion.tipo }}</span>
            <small>{{ validacion.mensaje }}</small>
          </div>
        </div>
      </div>
    </div>

    <!-- Botones de Acción -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="guardarConfiguracion"
            :disabled="loading"
          >
            <font-awesome-icon icon="save" />
            Guardar Configuración
          </button>
          <button
            class="btn-municipal-info"
            @click="probarRutas"
            :disabled="loading || !configuracion.unidad || !configuracion.directorioBase"
          >
            <font-awesome-icon icon="vial" />
            Probar Rutas
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFormulario"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
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
      :componentName="'UnidadImg'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  loadingMessage,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const configuracion = ref({
  unidad: '',
  directorioBase: '',
  directorioLicencias: '',
  directorioTramites: '',
  directorioAnuncios: ''
})

const validacionRutas = ref([])

// Computed - Vista Previa de Rutas
const rutaBase = computed(() => {
  if (!configuracion.value.unidad || !configuracion.value.directorioBase) {
    return 'Ingrese unidad y directorio base'
  }
  return `${configuracion.value.unidad}${configuracion.value.directorioBase}`
})

const rutaLicencias = computed(() => {
  if (!rutaBase.value || rutaBase.value === 'Ingrese unidad y directorio base') {
    return 'Ruta base incompleta'
  }
  return `${rutaBase.value}${configuracion.value.directorioLicencias || ''}`
})

const rutaTramites = computed(() => {
  if (!rutaBase.value || rutaBase.value === 'Ingrese unidad y directorio base') {
    return 'Ruta base incompleta'
  }
  return `${rutaBase.value}${configuracion.value.directorioTramites || ''}`
})

const rutaAnuncios = computed(() => {
  if (!rutaBase.value || rutaBase.value === 'Ingrese unidad y directorio base') {
    return 'Ruta base incompleta'
  }
  return `${rutaBase.value}${configuracion.value.directorioAnuncios || ''}`
})

// Métodos
const cargarConfiguracion = async () => {
  setLoading(true, 'Cargando configuración...')

  try {
    const startTime = performance.now()

    const response = await execute(
      'unidadimg_get_unidad_img',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      const config = response.result[0]
      configuracion.value = {
        unidad: config.unidad || '',
        directorioBase: config.directorio_base || '',
        directorioLicencias: config.directorio_licencias || '',
        directorioTramites: config.directorio_tramites || '',
        directorioAnuncios: config.directorio_anuncios || ''
      }
      toast.value.duration = durationText
      showToast('success', 'Configuración cargada correctamente')
    } else {
      toast.value.duration = durationText
      showToast('info', 'No hay configuración guardada')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const guardarConfiguracion = async () => {
  if (!configuracion.value.unidad || !configuracion.value.directorioBase ||
      !configuracion.value.directorioLicencias || !configuracion.value.directorioTramites ||
      !configuracion.value.directorioAnuncios) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar configuración?',
    html: `
      <div class="swal-confirmation-text">
        <p>Se guardará la siguiente configuración:</p>
        <ul class="swal-selection-list">
          <li><strong>Ruta Base:</strong> <code>${rutaBase.value}</code></li>
          <li><strong>Licencias:</strong> <code>${rutaLicencias.value}</code></li>
          <li><strong>Trámites:</strong> <code>${rutaTramites.value}</code></li>
          <li><strong>Anuncios:</strong> <code>${rutaAnuncios.value}</code></li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  setLoading(true, 'Guardando configuración...')

  try {
    const startTime = performance.now()

    const response = await execute(
      'unidadimg_set_unidad_img',
      'padron_licencias',
      [
        { nombre: 'p_unidad', valor: configuracion.value.unidad, tipo: 'string' },
        { nombre: 'p_directorio_base', valor: configuracion.value.directorioBase, tipo: 'string' },
        { nombre: 'p_directorio_licencias', valor: configuracion.value.directorioLicencias, tipo: 'string' },
        { nombre: 'p_directorio_tramites', valor: configuracion.value.directorioTramites, tipo: 'string' },
        { nombre: 'p_directorio_anuncios', valor: configuracion.value.directorioAnuncios, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Configuración guardada!',
        text: 'La configuración de rutas ha sido guardada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      toast.value.duration = durationText
      showToast('success', 'Configuración guardada exitosamente')
      await cargarConfiguracion()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al guardar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo guardar la configuración',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    setLoading(false)
  }
}

const probarRutas = async () => {
  setLoading(true, 'Validando rutas...')

  try {
    const startTime = performance.now()

    // Simular validación de rutas
    validacionRutas.value = []

    // Validar ruta base
    const rutaDirResponse = await execute(
      'unidadimg_get_ruta_dir',
      'padron_licencias',
      [
        { nombre: 'p_ruta', valor: rutaBase.value, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    validacionRutas.value.push({
      tipo: 'Ruta Base',
      valida: rutaDirResponse?.result?.[0]?.existe || false,
      mensaje: rutaDirResponse?.result?.[0]?.existe ? 'Ruta accesible' : 'Ruta no encontrada o sin acceso'
    })

    // Validar ruta licencias
    const rutaLicResponse = await execute(
      'unidadimg_rutadir',
      'padron_licencias',
      [
        { nombre: 'p_ruta', valor: rutaLicencias.value, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    validacionRutas.value.push({
      tipo: 'Ruta Licencias',
      valida: rutaLicResponse?.result?.[0]?.existe || false,
      mensaje: rutaLicResponse?.result?.[0]?.existe ? 'Ruta accesible' : 'Ruta no encontrada o sin acceso'
    })

    // Validar ruta trámites
    const rutaTramResponse = await execute(
      'unidadimg_rutadir',
      'padron_licencias',
      [
        { nombre: 'p_ruta', valor: rutaTramites.value, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    validacionRutas.value.push({
      tipo: 'Ruta Trámites',
      valida: rutaTramResponse?.result?.[0]?.existe || false,
      mensaje: rutaTramResponse?.result?.[0]?.existe ? 'Ruta accesible' : 'Ruta no encontrada o sin acceso'
    })

    // Validar ruta anuncios
    const rutaAnunResponse = await execute(
      'unidadimg_rutadir',
      'padron_licencias',
      [
        { nombre: 'p_ruta', valor: rutaAnuncios.value, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    validacionRutas.value.push({
      tipo: 'Ruta Anuncios',
      valida: rutaAnunResponse?.result?.[0]?.existe || false,
      mensaje: rutaAnunResponse?.result?.[0]?.existe ? 'Ruta accesible' : 'Ruta no encontrada o sin acceso'
    })

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    const todasValidas = validacionRutas.value.every(v => v.valida)

    if (todasValidas) {
      await Swal.fire({
        icon: 'success',
        title: 'Validación exitosa',
        text: 'Todas las rutas son accesibles',
        confirmButtonColor: '#ea8215'
      })
      toast.value.duration = durationText
      showToast('success', 'Todas las rutas son válidas')
    } else {
      await Swal.fire({
        icon: 'warning',
        title: 'Validación con errores',
        text: 'Algunas rutas no son accesibles. Verifique la configuración.',
        confirmButtonColor: '#ea8215'
      })
      toast.value.duration = durationText
      showToast('warning', 'Algunas rutas no son accesibles')
    }
  } catch (error) {
    handleApiError(error)
    validacionRutas.value = []
  } finally {
    setLoading(false)
  }
}

const limpiarFormulario = () => {
  configuracion.value = {
    unidad: '',
    directorioBase: '',
    directorioLicencias: '',
    directorioTramites: '',
    directorioAnuncios: ''
  }
  validacionRutas.value = []
}

// Lifecycle
onMounted(() => {
  cargarConfiguracion()
})
</script>

