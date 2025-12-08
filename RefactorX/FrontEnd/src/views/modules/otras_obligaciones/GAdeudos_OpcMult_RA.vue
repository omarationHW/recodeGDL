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
          <span class="badge" :class="getStatusBadgeClass(datosRegistro.statusregistro)">
            <font-awesome-icon :icon="getStatusIcon(datosRegistro.statusregistro)" />
            {{ datosRegistro.statusregistro || 'N/A' }}
          </span>
        </div>

        <div class="municipal-card-body">
          <!-- Header con Control y Concesionario destacado -->
          <div class="registro-header">
            <div class="registro-control">
              <span class="control-label">Control</span>
              <span class="control-value">{{ datosRegistro.control || 'N/A' }}</span>
            </div>
            <div class="registro-concesionario">
              <font-awesome-icon icon="user" class="concesionario-icon" />
              <div class="concesionario-info">
                <span class="concesionario-label">{{ etiquetas.concesionario || 'Concesionario' }}</span>
                <span class="concesionario-value">{{ datosRegistro.concesionario || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <!-- Grid de información principal -->
          <div class="registro-grid">
            <!-- Ubicación -->
            <div class="registro-item registro-item-full">
              <div class="item-icon">
                <font-awesome-icon icon="map-marker-alt" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.ubicacion || 'Ubicación' }}</span>
                <span class="item-value">{{ datosRegistro.ubicacion || 'N/A' }}</span>
              </div>
            </div>

            <!-- Nombre Comercial -->
            <div class="registro-item registro-item-full" v-if="datosRegistro.nomcomercial">
              <div class="item-icon">
                <font-awesome-icon icon="store" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}</span>
                <span class="item-value">{{ datosRegistro.nomcomercial }}</span>
              </div>
            </div>

            <!-- Lugar -->
            <div class="registro-item registro-item-full" v-if="datosRegistro.lugar">
              <div class="item-icon">
                <font-awesome-icon icon="building" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.lugar || 'Lugar' }}</span>
                <span class="item-value">{{ datosRegistro.lugar }}</span>
              </div>
            </div>

            <!-- Fechas -->
            <div class="registro-item">
              <div class="item-icon item-icon-success">
                <font-awesome-icon icon="calendar-check" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.fecha_inicio || 'Inicio Obligación' }}</span>
                <span class="item-value">{{ formatDate(datosRegistro.fechainicio) }}</span>
              </div>
            </div>

            <div class="registro-item">
              <div class="item-icon item-icon-danger">
                <font-awesome-icon icon="calendar-times" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.fecha_fin || 'Fin Obligación' }}</span>
                <span class="item-value">{{ formatDate(datosRegistro.fechafin) || 'Vigente' }}</span>
              </div>
            </div>

            <!-- Tipo/Unidad y Licencia -->
            <div class="registro-item">
              <div class="item-icon item-icon-info">
                <font-awesome-icon icon="tag" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.unidad || 'Tipo' }}</span>
                <span class="item-value">{{ datosRegistro.unidades || 'N/A' }}</span>
              </div>
            </div>

            <div class="registro-item">
              <div class="item-icon item-icon-warning">
                <font-awesome-icon icon="id-card" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.licencia || 'No. Licencia' }}</span>
                <span class="item-value">{{ datosRegistro.licencia || 'N/A' }}</span>
              </div>
            </div>

            <!-- Superficie y Sector -->
            <div class="registro-item">
              <div class="item-icon">
                <font-awesome-icon icon="ruler-combined" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.superficie || 'Superficie' }}</span>
                <span class="item-value">{{ formatNumber(datosRegistro.superficie) }} m²</span>
              </div>
            </div>

            <div class="registro-item">
              <div class="item-icon">
                <font-awesome-icon icon="city" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.sector || 'Sector' }}</span>
                <span class="item-value">{{ datosRegistro.sector || 'N/A' }}</span>
              </div>
            </div>

            <!-- Recaudadora y Zona -->
            <div class="registro-item">
              <div class="item-icon item-icon-purple">
                <font-awesome-icon icon="cash-register" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.recaudadora || 'Recaudadora' }}</span>
                <span class="item-value">{{ datosRegistro.recaudadora || 'N/A' }}</span>
              </div>
            </div>

            <div class="registro-item">
              <div class="item-icon item-icon-purple">
                <font-awesome-icon icon="map" />
              </div>
              <div class="item-content">
                <span class="item-label">{{ etiquetas.zona || 'Zona' }}</span>
                <span class="item-value">{{ datosRegistro.zona || 'N/A' }}</span>
              </div>
            </div>
          </div>

          <!-- Observaciones -->
          <div class="registro-observaciones" v-if="datosRegistro.obs">
            <div class="obs-header">
              <font-awesome-icon icon="comment-alt" />
              <span>{{ etiquetas.obs || 'Observaciones' }}</span>
            </div>
            <div class="obs-content">{{ datosRegistro.obs }}</div>
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
import { ref, onMounted } from 'vue'
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
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const loading = ref(false)

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
  router.push('/otras-obligaciones/menu')
}

const toggleBusqueda = () => {
  showBusqueda.value = !showBusqueda.value
}

// Obtener número de tabla del query param (default: 3 = Rastro)
const obtenerTabla = () => {
  tablaActual.value = route.query.tabla || route.params.tabla || '3'
  cargarDatosIniciales()
}

// Cargar información de la tabla y etiquetas
const cargarDatosIniciales = async () => {
  loading.value = true
  loadingEstadisticas.value = true

  try {
    // Cargar información de la tabla
    const responseTabla = await execute(
      'sp_gadeudos_opcmult_ra_tablas_get',
      BASE_DB,
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
      'sp_gadeudos_opcmult_ra_etiquetas_get',
      BASE_DB,
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
  } catch (error) {
    console.error('Error cargando datos iniciales:', error)
  } finally {
    loading.value = false
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

  loading.value = true
  showLoading('Buscando registro...')

  try {
    const response = await execute(
      'sp_gadeudos_opcmult_ra_datos_get',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tablaActual.value, tipo: 'string' },
        { nombre: 'par_control', valor: numeroControl, tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]

      if (data.status === -1) {
        showToast('error', 'No existe REGISTRO ALGUNO con este dato, intentalo de nuevo')
        registroEncontrado.value = false
        datosRegistro.value = {}
      } else {
        datosRegistro.value = data
        registroEncontrado.value = true
        showToast('success', 'Registro encontrado')
      }
    } else {
      showToast('error', 'No se encontró el registro')
      registroEncontrado.value = false
      datosRegistro.value = {}
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    registroEncontrado.value = false
    datosRegistro.value = {}
  } finally {
    loading.value = false
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

  procesando.value = true
  showLoading('Reactivando registro...')

  try {
    const response = await execute(
      'sp_gadeudos_opcmult_ra_reactivar',
      BASE_DB,
      [
        { nombre: 'p_id_datos', valor: datosRegistro.value.id_datos, tipo: 'integer' },
        { nombre: 'p_cve_tab', valor: tablaActual.value, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]

      if (result.success === 1) {
        await Swal.fire({
          icon: 'success',
          title: 'Reactivación Exitosa',
          text: result.message || 'El registro ha sido reactivado correctamente',
          confirmButtonColor: '#7c3aed',
          timer: 3000
        })

        showToast('success', 'Registro reactivado correctamente')
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
    hideLoading()
    handleApiError(error)
  } finally {
    procesando.value = false
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

// Obtener clase de badge para el header
const getStatusBadgeClass = (status) => {
  if (!status) return 'badge-secondary'

  const statusUpper = status.toUpperCase()
  if (statusUpper.includes('BAJA') || statusUpper.includes('CANCELADO')) {
    return 'badge-danger'
  } else if (statusUpper.includes('ADEUDO')) {
    return 'badge-warning'
  } else if (statusUpper.includes('PAGADO') || statusUpper.includes('CORRIENTE') || statusUpper.includes('VIGENTE')) {
    return 'badge-success'
  }
  return 'badge-purple'
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

// Lifecycle
onMounted(() => {
  obtenerTabla()
})
</script>

