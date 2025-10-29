<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="redo" />
      </div>
      <div class="module-view-info">
        <h1>Reactivación de Adeudos</h1>
        <p v-if="nombreTabla">{{ nombreTabla }}</p>
        <p v-else>Otras Obligaciones - Reactivación de Registros</p>
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
      <!-- Panel de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Registro
          </h5>
        </div>

        <div class="municipal-card-body">
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
            <div class="form-group" style="display: flex; align-items: flex-end;">
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
            <div class="form-group" style="display: flex; align-items: flex-end;">
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
        </div>

        <div class="municipal-card-body">
          <!-- Status del registro -->
          <div class="alert" :class="getStatusClass(datosRegistro.statusregistro)">
            <strong>STATUS:</strong> {{ datosRegistro.statusregistro || 'N/A' }}
          </div>

          <!-- Datos generales -->
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">{{ etiquetas.concesionario || 'Concesionario' }}</label>
              <div class="form-control-static">{{ datosRegistro.concesionario || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">{{ etiquetas.ubicacion || 'Ubicación' }}</label>
              <div class="form-control-static">{{ datosRegistro.ubicacion || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}</label>
              <div class="form-control-static">{{ datosRegistro.nomcomercial || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">{{ etiquetas.lugar || 'Lugar' }}</label>
              <div class="form-control-static">{{ datosRegistro.lugar || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">{{ etiquetas.obs || 'Observaciones' }}</label>
              <div class="form-control-static">{{ datosRegistro.obs || 'N/A' }}</div>
            </div>
          </div>

          <!-- Datos adicionales en dos columnas -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.unidad || 'Tipo' }}</label>
              <div class="form-control-static">{{ datosRegistro.unidades || 'N/A' }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.fecha_inicio || 'Inicio Oblig.' }}</label>
              <div class="form-control-static">{{ formatDate(datosRegistro.fechainicio) }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.fecha_fin || 'Fin Oblig.' }}</label>
              <div class="form-control-static">{{ formatDate(datosRegistro.fechafin) }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.licencia || 'No. Licencia' }}</label>
              <div class="form-control-static">{{ datosRegistro.licencia || 'N/A' }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.superficie || 'Superficie Mts.2' }}</label>
              <div class="form-control-static">{{ formatNumber(datosRegistro.superficie) }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.sector || 'Sector' }}</label>
              <div class="form-control-static">{{ datosRegistro.sector || 'N/A' }}</div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.recaudadora || 'Recaudadora' }}</label>
              <div class="form-control-static">{{ datosRegistro.recaudadora || 'N/A' }}</div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">{{ etiquetas.zona || 'Zona' }}</label>
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

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando...</p>
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
  setLoading(true, 'Cargando configuración...')

  try {
    // Cargar información de la tabla
    const responseTabla = await execute(
      'SP_GADEUDOS_OPCMULT_TABLAS_GET',
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
      'SP_GADEUDOS_OPCMULT_ETIQUETAS_GET',
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
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
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

  setLoading(true, 'Buscando registro...')

  try {
    const response = await execute(
      'SP_GADEUDOS_OPCMULT_DATOS_GET',
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
        showToast('success', 'Registro encontrado')
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
        <p style="font-weight: bold; color: #ea8215; margin: 10px 0;">Concesionario: ${datosRegistro.value.concesionario || 'N/A'}</p>
        <p style="font-size: 0.9em; color: #666;">Esta acción cambiará el status del registro y sus adeudos asociados.</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, reactivar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  procesando.value = true

  try {
    const response = await execute(
      'SP_GADEUDOS_OPCMULT_REACTIVAR',
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
        await Swal.fire({
          icon: 'success',
          title: 'Reactivación Exitosa',
          text: result.message || 'El registro ha sido reactivado correctamente',
          confirmButtonColor: '#ea8215',
          timer: 3000
        })

        // Recargar datos del registro
        buscarRegistro()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error al Reactivar',
          text: result.message || 'No se pudo reactivar el registro',
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
      title: 'Error de Conexión',
      text: 'No se pudo reactivar el registro',
      confirmButtonColor: '#ea8215'
    })
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
