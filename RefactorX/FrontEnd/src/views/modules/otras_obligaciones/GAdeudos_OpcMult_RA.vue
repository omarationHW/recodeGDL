<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="redo" />
      </div>
      <div class="module-view-info">
        <h1>Reactivación de Adeudos</h1>
        <p v-if="nombreTabla">{{ nombreTabla }}</p>
        <p v-else>Otras Obligaciones - Reactivación de Registros</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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
      <!-- Panel de Estadísticas -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 2" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <!-- Cards de estadísticas con datos -->
      <div class="stats-grid" v-else-if="!loadingEstadisticas && registroEncontrado">
        <div class="stat-card stat-activos">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="file-alt" />
            </div>
            <h3 class="stat-number">1</h3>
            <p class="stat-label">Registro Encontrado</p>
          </div>
        </div>

        <div class="stat-card stat-pendientes">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="sync-alt" />
            </div>
            <h3 class="stat-number">
              <span :class="getBadgeClass(datosRegistro.statusregistro)">
                {{ datosRegistro.statusregistro || 'N/A' }}
              </span>
            </h3>
            <p class="stat-label">Estado Actual</p>
          </div>
        </div>
      </div>

      <!-- Panel de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable" @click="toggleBusqueda">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Registro
          </h5>
          <font-awesome-icon
            :icon="showBusqueda ? 'chevron-up' : 'chevron-down'"
            class="accordion-icon"
          />
        </div>

        <div class="municipal-card-body" v-show="showBusqueda">
          <!-- Para Mercados (tabla 3): Local + Letra -->
          <div v-if="tablaActual === '3'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Local <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="numeroLocal"
                @keyup.enter="buscarRegistro"
                placeholder="Número de local"
                maxlength="10"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra</label>
              <input
                type="text"
                class="municipal-form-control text-uppercase"
                v-model="letra"
                @keyup.enter="buscarRegistro"
                placeholder="Letra (opcional)"
                maxlength="5"
              >
            </div>
            <div class="form-group align-self-end">
              <button
                class="btn-municipal-primary"
                @click="buscarRegistro"
                :disabled="loading || !numeroLocal"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>

          <!-- Para otras tablas: Número de expediente -->
          <div v-else class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                Número de Expediente <span class="required">*</span>
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="numeroExpediente"
                @keyup.enter="buscarRegistro"
                placeholder="Número de expediente"
                maxlength="10"
              >
            </div>
            <div class="form-group align-self-end">
              <button
                class="btn-municipal-primary"
                @click="buscarRegistro"
                :disabled="loading || !numeroExpediente"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel de datos del registro -->
      <div class="municipal-card" v-if="registroEncontrado">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Registro
          </h5>
          <span class="badge badge-purple ms-auto">
            <font-awesome-icon icon="check-circle" />
            Registro Activo
          </span>
        </div>

        <div class="municipal-card-body">
          <!-- Status del registro -->
          <div class="alert" :class="getStatusClass(datosRegistro.statusregistro)">
            <font-awesome-icon :icon="getStatusIcon(datosRegistro.statusregistro)" class="me-2" />
            <strong>STATUS:</strong> {{ datosRegistro.statusregistro || 'N/A' }}
          </div>

          <!-- Datos generales -->
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" class="me-1" />
                {{ etiquetas.concesionario || 'Concesionario' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.concesionario || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map-marker-alt" class="me-1" />
                {{ etiquetas.ubicacion || 'Ubicación' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.ubicacion || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <font-awesome-icon icon="store" class="me-1" />
                {{ etiquetas.nombre_comercial || 'Nombre Comercial' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.nomcomercial || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" class="me-1" />
                {{ etiquetas.lugar || 'Lugar' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.lugar || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <font-awesome-icon icon="comment-alt" class="me-1" />
                {{ etiquetas.obs || 'Observaciones' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.obs || 'N/A' }}</div>
            </div>
          </div>

          <!-- Datos adicionales en dos columnas -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" class="me-1" />
                {{ etiquetas.unidad || 'Tipo' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.unidades || 'N/A' }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" class="me-1" />
                {{ etiquetas.fecha_inicio || 'Inicio Oblig.' }}
              </label>
              <div class="form-control-static">{{ formatDate(datosRegistro.fechainicio) }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-times" class="me-1" />
                {{ etiquetas.fecha_fin || 'Fin Oblig.' }}
              </label>
              <div class="form-control-static">{{ formatDate(datosRegistro.fechafin) }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="id-card" class="me-1" />
                {{ etiquetas.licencia || 'No. Licencia' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.licencia || 'N/A' }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="ruler-combined" class="me-1" />
                {{ etiquetas.superficie || 'Superficie Mts.2' }}
              </label>
              <div class="form-control-static">{{ formatNumber(datosRegistro.superficie) }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="city" class="me-1" />
                {{ etiquetas.sector || 'Sector' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.sector || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="cash-register" class="me-1" />
                {{ etiquetas.recaudadora || 'Recaudadora' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.recaudadora || 'N/A' }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="map" class="me-1" />
                {{ etiquetas.zona || 'Zona' }}
              </label>
              <div class="form-control-static">{{ datosRegistro.zona || 'N/A' }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel de opciones -->
      <div class="municipal-card" v-if="registroEncontrado">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cogs" />
            Opciones Disponibles
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Operación a Realizar <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model="opcionSeleccionada"
                :disabled="loading || procesando"
              >
                <option value="">-- Seleccione una opción --</option>
                <option value="P">P - RE-ACTIVACION DE REGISTRO</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="ejecutarOperacion"
              :disabled="loading || procesando || !opcionSeleccionada"
            >
              <font-awesome-icon :icon="procesando ? 'spinner' : 'play'" :spin="procesando" />
              {{ procesando ? 'Procesando...' : 'Ejecutar Operación' }}
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFormulario"
              :disabled="loading || procesando"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="!registroEncontrado && !loading" class="empty-state">
        <font-awesome-icon icon="search" class="empty-icon" />
        <h3>Buscar Registro</h3>
        <p>Ingrese los datos de búsqueda para localizar el registro a reactivar</p>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <small v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ formatDuration(toast.duration) }}
        </small>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GAdeudos_OpcMult_RA'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const router = useRouter()
const route = useRoute()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { isLoading: globalLoading, setLoading: setGlobalLoading } = useGlobalLoading()
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
const tablaActual = ref('')
const nombreTabla = ref('')
const loadingEstadisticas = ref(false)
const showBusqueda = ref(true)
const etiquetas = ref({
  concesionario: 'Concesionario',
  ubicacion: 'Ubicación',
  nombre_comercial: 'Nombre Comercial',
  lugar: 'Lugar',
  obs: 'Observaciones',
  unidad: 'Tipo',
  fecha_inicio: 'Inicio Oblig.',
  fecha_fin: 'Fin Oblig.',
  licencia: 'No. Licencia',
  superficie: 'Superficie Mts.2',
  sector: 'Sector',
  recaudadora: 'Recaudadora',
  zona: 'Zona'
})

// Campos de búsqueda
const numeroLocal = ref('')
const letra = ref('')
const numeroExpediente = ref('')

// Datos del registro
const registroEncontrado = ref(false)
const datosRegistro = ref({})

// Opciones
const opcionSeleccionada = ref('P')
const procesando = ref(false)

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

const toggleBusqueda = () => {
  showBusqueda.value = !showBusqueda.value
}

// Obtener número de tabla del query param
const obtenerTabla = () => {
  const tabla = route.query.tabla || route.params.tabla
  if (tabla) {
    tablaActual.value = tabla
    cargarDatosIniciales()
  } else {
    showToast('error', 'No se especificó la tabla')
    setTimeout(() => goBack(), 2000)
  }
}

// Cargar información de la tabla y etiquetas
const cargarDatosIniciales = async () => {
  const startTime = performance.now()
  setLoading(true, 'Cargando configuración...')
  setGlobalLoading(true)
  loadingEstadisticas.value = true

  try {
    // Cargar información de la tabla
    const responseTabla = await execute(
      'SP_GADEUDOS_OPCMULT_RA_TABLAS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: tablaActual.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (responseTabla && responseTabla.result && responseTabla.result.length > 0) {
      const tabla = responseTabla.result[0]
      nombreTabla.value = `RE-ACTIVACION DE ADEUDOS EN: ${tabla.nombre || ''}`
    }

    // Cargar etiquetas
    const responseEtiq = await execute(
      'SP_GADEUDOS_OPCMULT_RA_ETIQUETAS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: tablaActual.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (responseEtiq && responseEtiq.result && responseEtiq.result.length > 0) {
      const etiq = responseEtiq.result[0]
      etiquetas.value = {
        concesionario: etiq.concesionario || 'Concesionario',
        ubicacion: etiq.ubicacion || 'Ubicación',
        nombre_comercial: etiq.nombre_comercial || 'Nombre Comercial',
        lugar: etiq.lugar || 'Lugar',
        obs: etiq.obs || 'Observaciones',
        unidad: etiq.unidad || 'Tipo',
        fecha_inicio: etiq.fecha_inicio || 'Inicio Oblig.',
        fecha_fin: etiq.fecha_fin || 'Fin Oblig.',
        licencia: etiq.licencia || 'No. Licencia',
        superficie: etiq.superficie || 'Superficie Mts.2',
        sector: etiq.sector || 'Sector',
        recaudadora: etiq.recaudadora || 'Recaudadora',
        zona: etiq.zona || 'Zona'
      }
    }

    const endTime = performance.now()
    const duration = endTime - startTime
    showToast('success', 'Configuración cargada correctamente', duration)
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
    setGlobalLoading(false)
    loadingEstadisticas.value = false
  }
}

// Construir número de control según el tipo de tabla
const construirNumeroControl = () => {
  if (tablaActual.value === '3') {
    // Mercados: Local + Letra (si existe)
    if (!numeroLocal.value || numeroLocal.value.trim() === '' || numeroLocal.value === '0') {
      showToast('error', 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo')
      return null
    }
    if (letra.value && letra.value.trim() !== '') {
      return `${numeroLocal.value.trim()}-${letra.value.trim().toUpperCase()}`
    }
    return numeroLocal.value.trim()
  } else {
    // Otras tablas: Abreviatura + Número de expediente
    if (!numeroExpediente.value || numeroExpediente.value.trim() === '' || numeroExpediente.value === '0') {
      showToast('error', 'Falta el dato del NUMERO DE EXPEDIENTE, intentalo de nuevo')
      return null
    }
    // Obtener abreviatura de etiquetas si existe
    const abreviatura = etiquetas.value.abreviatura || ''
    return `${abreviatura}${numeroExpediente.value.trim()}`
  }
}

// Buscar registro
const buscarRegistro = async () => {
  const numeroControl = construirNumeroControl()
  if (!numeroControl) {
    return
  }

  const startTime = performance.now()
  setLoading(true, 'Buscando registro...')
  setGlobalLoading(true)

  try {
    const response = await execute(
      'SP_GADEUDOS_OPCMULT_RA_DATOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: tablaActual.value, tipo: 'string' },
        { nombre: 'par_control', valor: numeroControl, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]

      if (data.status === -1) {
        showToast('error', 'No existe REGISTRO ALGUNO con este dato, intentalo de nuevo')
        registroEncontrado.value = false
        datosRegistro.value = {}
      } else {
        datosRegistro.value = data
        registroEncontrado.value = true
        const endTime = performance.now()
        const duration = endTime - startTime
        showToast('success', 'Registro encontrado', duration)
      }
    } else {
      showToast('error', 'No se encontró el registro')
      registroEncontrado.value = false
      datosRegistro.value = {}
    }
  } catch (error) {
    handleApiError(error)
    registroEncontrado.value = false
    datosRegistro.value = {}
  } finally {
    setLoading(false)
    setGlobalLoading(false)
  }
}

// Ejecutar operación seleccionada
const ejecutarOperacion = async () => {
  if (!opcionSeleccionada.value) {
    showToast('warning', 'Debe seleccionar una opción')
    return
  }

  if (!datosRegistro.value.id_datos) {
    showToast('error', 'No hay un registro válido seleccionado')
    return
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Reactivación',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">¿Está seguro de reactivar este registro?</p>
        <p style="font-weight: bold; color: #7c3aed; margin: 10px 0;">Concesionario: ${datosRegistro.value.concesionario || 'N/A'}</p>
        <p style="font-size: 0.9em; color: #666;">Esta acción cambiará el status del registro y sus adeudos asociados.</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#7c3aed',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, reactivar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = performance.now()
  procesando.value = true
  setGlobalLoading(true)

  try {
    const response = await execute(
      'SP_GADEUDOS_OPCMULT_RA_REACTIVAR',
      'otras_obligaciones',
      [
        { nombre: 'p_id_datos', valor: datosRegistro.value.id_datos, tipo: 'integer' },
        { nombre: 'p_cve_tab', valor: tablaActual.value, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]

      if (result.success === 1) {
        const endTime = performance.now()
        const duration = endTime - startTime

        await Swal.fire({
          icon: 'success',
          title: 'Reactivación Exitosa',
          text: result.message || 'El registro ha sido reactivado correctamente',
          confirmButtonColor: '#7c3aed',
          timer: 3000
        })

        showToast('success', 'Registro reactivado correctamente', duration)
        // Recargar datos del registro
        buscarRegistro()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error al Reactivar',
          text: result.message || 'No se pudo reactivar el registro',
          confirmButtonColor: '#7c3aed'
        })
      }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Respuesta inesperada del servidor',
        confirmButtonColor: '#7c3aed'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de Conexión',
      text: 'No se pudo reactivar el registro',
      confirmButtonColor: '#7c3aed'
    })
  } finally {
    procesando.value = false
    setGlobalLoading(false)
  }
}

// Limpiar formulario
const limpiarFormulario = () => {
  numeroLocal.value = ''
  letra.value = ''
  numeroExpediente.value = ''
  registroEncontrado.value = false
  datosRegistro.value = {}
  opcionSeleccionada.value = 'P'
  showToast('info', 'Formulario limpiado')
}

// Obtener clase de estilo según el status
const getStatusClass = (status) => {
  if (!status) return 'alert-info'

  const statusUpper = status.toUpperCase()
  if (statusUpper.includes('BAJA') || statusUpper.includes('CANCELADO')) {
    return 'alert-danger'
  } else if (statusUpper.includes('ADEUDO')) {
    return 'alert-warning'
  } else if (statusUpper.includes('PAGADO') || statusUpper.includes('CORRIENTE')) {
    return 'alert-success'
  }
  return 'alert-info'
}

// Obtener icono según el status
const getStatusIcon = (status) => {
  if (!status) return 'info-circle'

  const statusUpper = status.toUpperCase()
  if (statusUpper.includes('BAJA') || statusUpper.includes('CANCELADO')) {
    return 'times-circle'
  } else if (statusUpper.includes('ADEUDO')) {
    return 'exclamation-triangle'
  } else if (statusUpper.includes('PAGADO') || statusUpper.includes('CORRIENTE')) {
    return 'check-circle'
  }
  return 'info-circle'
}

// Obtener clase de badge según el status
const getBadgeClass = (status) => {
  if (!status) return 'badge badge-secondary'

  const statusUpper = status.toUpperCase()
  if (statusUpper.includes('BAJA') || statusUpper.includes('CANCELADO')) {
    return 'badge badge-danger'
  } else if (statusUpper.includes('ADEUDO')) {
    return 'badge badge-warning'
  } else if (statusUpper.includes('PAGADO') || statusUpper.includes('CORRIENTE')) {
    return 'badge badge-success'
  }
  return 'badge badge-purple'
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return 'N/A'
  try {
    const d = new Date(date)
    return d.toLocaleDateString('es-MX')
  } catch (e) {
    return date
  }
}

// Formatear número
const formatNumber = (num) => {
  if (!num && num !== 0) return 'N/A'
  try {
    return parseFloat(num).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  } catch (e) {
    return num
  }
}

// Formatear duración (ms -> s o ms)
const formatDuration = (ms) => {
  if (!ms) return ''
  return ms >= 1000 ? `${(ms / 1000).toFixed(2)}s` : `${ms.toFixed(0)}ms`
}

// Lifecycle
onMounted(() => {
  obtenerTabla()
})
</script>

<style scoped>
.align-self-end {
  align-self: flex-end;
}

.clickable {
  cursor: pointer;
  user-select: none;
}

.accordion-icon {
  transition: transform 0.3s ease;
  color: #7c3aed;
}

.toast-content {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.toast-duration {
  display: flex;
  align-items: center;
  gap: 4px;
  opacity: 0.8;
  font-size: 0.85em;
}

.me-1 {
  margin-right: 0.25rem;
}

.me-2 {
  margin-right: 0.5rem;
}

.ms-auto {
  margin-left: auto;
}
</style>
