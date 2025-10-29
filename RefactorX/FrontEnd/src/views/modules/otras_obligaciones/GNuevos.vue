<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="plus-circle" />
      </div>
      <div class="module-view-info">
        <h1>{{ nombreTabla ? 'ALTA DE: ' + nombreTabla : 'Nuevos Registros' }}</h1>
        <p>Otras Obligaciones - Registro de nuevos contratos y obligaciones</p>
      </div>
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Información del tipo de registro -->
      <div class="municipal-card" v-if="nombreTabla">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <font-awesome-icon icon="info-circle" />
            <strong>{{ labelBusqueda }}</strong>
          </div>
        </div>
      </div>

      <!-- Formulario de Alta -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="plus-circle" />
            Datos del Nuevo Registro
          </h5>
        </div>

        <div class="municipal-card-body">
          <!-- Sección 1: Número de Control/Expediente -->
          <div class="form-section">
            <h6 class="section-title">Identificación</h6>

            <!-- Para tianguis, vía pública, centrales y otros: Número de expediente -->
            <div class="form-row" v-if="tipoTabla !== 3">
              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetaControl }}</label>
                <div class="input-group">
                  <span class="input-group-text">{{ etiquetas.abreviatura || '' }}</span>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="formData.numeroExpediente"
                    @keyup.enter="focusConcesionario"
                    placeholder="Número"
                    maxlength="6"
                    ref="numeroExpInput"
                  >
                </div>
                <small class="form-text text-muted">Ingrese solo el número (máx. 6 dígitos)</small>
              </div>
            </div>

            <!-- Para mercados: Número de local + letra -->
            <div class="form-row" v-if="tipoTabla === 3">
              <div class="form-group">
                <label class="municipal-form-label required">Número de Local</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.numeroLocal"
                  @keyup.enter="focusLetra"
                  placeholder="Número"
                  maxlength="3"
                  style="width: 150px; display: inline-block; margin-right: 10px;"
                  ref="numeroLocalInput"
                >
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.letra"
                  @keyup.enter="focusConcesionario"
                  placeholder="Letra (opcional)"
                  maxlength="1"
                  style="width: 100px; display: inline-block;"
                  ref="letraInput"
                >
              </div>
            </div>
          </div>

          <!-- Sección 2: Datos Generales -->
          <div class="form-section">
            <h6 class="section-title">Datos Generales</h6>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.concesionario || 'Concesionario' }}</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.concesionario"
                  @keyup.enter="focusUbicacion"
                  placeholder="Nombre del concesionario"
                  maxlength="255"
                  ref="concesionarioInput"
                >
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.ubicacion || 'Ubicación' }}</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.ubicacion"
                  @keyup.enter="focusNomComercial"
                  placeholder="Dirección o ubicación"
                  maxlength="255"
                  ref="ubicacionInput"
                >
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.nomComercial"
                  @keyup.enter="focusLugar"
                  placeholder="Nombre del negocio (opcional)"
                  maxlength="255"
                  ref="nomComercialInput"
                >
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">{{ etiquetas.lugar || 'Lugar' }}</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.lugar"
                  @keyup.enter="focusObs"
                  placeholder="Lugar de referencia (opcional)"
                  maxlength="255"
                  ref="lugarInput"
                >
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">{{ etiquetas.obs || 'Observaciones' }}</label>
                <textarea
                  class="municipal-form-control"
                  v-model="formData.obs"
                  @keyup.enter="focusSuperficie"
                  placeholder="Observaciones adicionales (opcional)"
                  maxlength="255"
                  rows="2"
                  ref="obsInput"
                ></textarea>
              </div>
            </div>
          </div>

          <!-- Sección 3: Datos Específicos -->
          <div class="form-section">
            <h6 class="section-title">Datos Específicos</h6>

            <div class="form-row">
              <!-- Superficie (no visible para tipo 5 - Otros) -->
              <div class="form-group" v-if="mostrarSuperficie">
                <label class="municipal-form-label required">{{ etiquetas.superficie || 'Superficie' }} (m²)</label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="formData.superficie"
                  @keyup.enter="focusTipoLocal"
                  placeholder="0.00"
                  maxlength="7"
                  ref="superficieInput"
                >
              </div>

              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.unidad || 'Tipo de Local / Unidades' }}</label>
                <select
                  class="municipal-form-control"
                  v-model="formData.tipoLocal"
                  ref="tipoLocalInput"
                >
                  <option value="">Seleccione...</option>
                  <option v-for="tipo in tiposLocal" :key="tipo.cve_tab" :value="tipo.descripcion">
                    {{ tipo.descripcion }}
                  </option>
                </select>
              </div>
            </div>
          </div>

          <!-- Sección 4: Datos Administrativos -->
          <div class="form-section">
            <h6 class="section-title">Datos Administrativos</h6>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.recaudadora || 'Oficina' }}</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.oficina"
                  placeholder="Número de oficina"
                  maxlength="2"
                  style="width: 150px;"
                >
              </div>

              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.sector || 'Sector' }}</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.sector"
                  placeholder="Sector"
                  maxlength="10"
                  style="width: 150px;"
                >
              </div>

              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.zona || 'Zona' }}</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.zona"
                  placeholder="Zona"
                  maxlength="2"
                  style="width: 150px;"
                >
              </div>

              <div class="form-group">
                <label class="municipal-form-label required">{{ etiquetas.licencia || 'Licencia' }}</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.licencia"
                  placeholder="Número de licencia"
                  maxlength="7"
                  style="width: 200px;"
                >
              </div>
            </div>
          </div>

          <!-- Sección 5: Inicio de Obligación -->
          <div class="form-section">
            <h6 class="section-title">{{ etiquetas.fecha_inicio || 'Fecha de Inicio de Obligación' }}</h6>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Año</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="formData.axoInicio"
                  placeholder="Año"
                  maxlength="4"
                  min="2020"
                  :max="axoActual"
                  style="width: 150px;"
                >
                <small class="form-text text-muted">
                  Año {{ axoActual - 1 }} o {{ axoActual }}
                </small>
              </div>

              <div class="form-group">
                <label class="municipal-form-label required">Mes</label>
                <select class="municipal-form-control" v-model.number="formData.mesInicio" style="width: 200px;">
                  <option :value="1">01 - Enero</option>
                  <option :value="2">02 - Febrero</option>
                  <option :value="3">03 - Marzo</option>
                  <option :value="4">04 - Abril</option>
                  <option :value="5">05 - Mayo</option>
                  <option :value="6">06 - Junio</option>
                  <option :value="7">07 - Julio</option>
                  <option :value="8">08 - Agosto</option>
                  <option :value="9">09 - Septiembre</option>
                  <option :value="10">10 - Octubre</option>
                  <option :value="11">11 - Noviembre</option>
                  <option :value="12">12 - Diciembre</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Botones de Acción -->
          <div class="form-actions">
            <button
              class="btn-municipal-primary"
              @click="aplicarAlta"
              :disabled="saving"
            >
              <font-awesome-icon icon="save" />
              {{ saving ? 'Guardando...' : 'Aplicar Alta' }}
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFormulario"
              :disabled="saving"
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
          <p>Cargando datos...</p>
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

  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GNuevos'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, onMounted, computed, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const router = useRouter()
const route = useRoute()
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

// Referencias a inputs
const numeroExpInput = ref(null)
const numeroLocalInput = ref(null)
const letraInput = ref(null)
const concesionarioInput = ref(null)
const ubicacionInput = ref(null)
const nomComercialInput = ref(null)
const lugarInput = ref(null)
const obsInput = ref(null)
const superficieInput = ref(null)
const tipoLocalInput = ref(null)

// Estado
const tipoTabla = ref(route.params.tipo || route.query.tipo || 1) // 1=Tianguis, 2=VíaPública, 3=Mercados, 4=Centrales, 5=Otros
const nombreTabla = ref('')
const etiquetas = ref({})
const tiposLocal = ref([])
const saving = ref(false)
const axoActual = new Date().getFullYear()

// Formulario
const formData = ref({
  numeroExpediente: '',
  numeroLocal: '',
  letra: '',
  concesionario: '',
  ubicacion: '',
  nomComercial: '',
  lugar: '',
  obs: '',
  superficie: 0,
  tipoLocal: '',
  oficina: 0,
  sector: '',
  zona: 0,
  licencia: 0,
  axoInicio: axoActual,
  mesInicio: new Date().getMonth() + 1
})

// Computed
const labelBusqueda = computed(() => {
  return `REGISTRO POR: ${etiquetas.value.etiq_control || 'Control'}`
})

const etiquetaControl = computed(() => {
  return etiquetas.value.etiq_control || 'Número de Control'
})

const mostrarSuperficie = computed(() => {
  // La superficie no se muestra para tipo 5 (Otros)
  return tipoTabla.value !== 5
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

// Focus helpers
const focusConcesionario = () => {
  nextTick(() => {
    if (concesionarioInput.value) {
      concesionarioInput.value.focus()
    }
  })
}

const focusLetra = () => {
  nextTick(() => {
    if (letraInput.value) {
      letraInput.value.focus()
    }
  })
}

const focusUbicacion = () => {
  nextTick(() => {
    if (ubicacionInput.value) {
      ubicacionInput.value.focus()
    }
  })
}

const focusNomComercial = () => {
  nextTick(() => {
    if (nomComercialInput.value) {
      nomComercialInput.value.focus()
    }
  })
}

const focusLugar = () => {
  nextTick(() => {
    if (lugarInput.value) {
      lugarInput.value.focus()
    }
  })
}

const focusObs = () => {
  nextTick(() => {
    if (obsInput.value) {
      obsInput.value.focus()
    }
  })
}

const focusSuperficie = () => {
  nextTick(() => {
    if (superficieInput.value && mostrarSuperficie.value) {
      superficieInput.value.focus()
    } else if (tipoLocalInput.value) {
      tipoLocalInput.value.focus()
    }
  })
}

const focusTipoLocal = () => {
  nextTick(() => {
    if (tipoLocalInput.value) {
      tipoLocalInput.value.focus()
    }
  })
}

// Cargar etiquetas
const loadEtiquetas = async () => {
  try {
    const response = await execute(
      'SP_GNUEVOS_ETIQUETAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value.toString(), tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
  }
}

// Cargar tipos de local
const loadTablas = async () => {
  try {
    const response = await execute(
      'SP_GNUEVOS_TABLAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value.toString(), tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      nombreTabla.value = response.result[0].nombre
      tiposLocal.value = response.result

      // Seleccionar el primero por defecto
      if (tiposLocal.value.length > 0) {
        formData.value.tipoLocal = tiposLocal.value[0].descripcion
      }
    }
  } catch (error) {
    console.error('Error al cargar tablas:', error)
  }
}

// Validar formulario
const validarFormulario = () => {
  // Validar control
  if (tipoTabla.value === 3) {
    // Mercados
    if (!formData.value.numeroLocal || formData.value.numeroLocal.trim() === '' || formData.value.numeroLocal === '0') {
      return 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo'
    }
  } else {
    // Otros tipos
    if (!formData.value.numeroExpediente || formData.value.numeroExpediente.trim() === '' || formData.value.numeroExpediente === '0') {
      return 'Falta el dato del NUMERO DE EXPEDIENTE, intentalo de nuevo'
    }
  }

  // Validar campos obligatorios (ya se validan en el SP, pero es bueno hacerlo en frontend también)
  if (!formData.value.concesionario || formData.value.concesionario.trim() === '') {
    return 'Falta el dato del CONCESIONARIO, intentalo de nuevo'
  }

  if (!formData.value.ubicacion || formData.value.ubicacion.trim() === '') {
    return 'Falta el dato de la UBICACION, intentalo de nuevo'
  }

  if (mostrarSuperficie.value && (!formData.value.superficie || formData.value.superficie === 0)) {
    return 'Falta el dato de la SUPERFICIE, intentalo de nuevo'
  }

  if (!formData.value.licencia || formData.value.licencia === 0) {
    return 'Falta el dato de la LICENCIA, intentalo de nuevo'
  }

  if (!formData.value.axoInicio || formData.value.axoInicio === 0) {
    return 'Falta el dato del AÑO de inicio de OBLIGACION, INTENTA DE NUEVO'
  }

  if (!formData.value.tipoLocal || formData.value.tipoLocal.trim() === '') {
    return 'Seleccione el TIPO DE LOCAL / UNIDADES'
  }

  // Validar año
  if (formData.value.axoInicio < 2020) {
    return 'El año de inicio debe ser mayor o igual a 2020'
  }

  if (formData.value.axoInicio < (axoActual - 1) || formData.value.axoInicio > axoActual) {
    return `El año de inicio de obligación puede ser ${axoActual - 1} o ${axoActual}, intenta con otro`
  }

  return null
}

// Aplicar alta
const aplicarAlta = async () => {
  // Validar formulario
  const errorValidacion = validarFormulario()
  if (errorValidacion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos incompletos',
      text: errorValidacion,
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Construir control
  let control = ''
  if (tipoTabla.value === 3) {
    // Mercados: número-letra
    control = formData.value.numeroLocal.trim()
    if (formData.value.letra && formData.value.letra.trim() !== '') {
      control += '-' + formData.value.letra.trim()
    }
  } else {
    // Otros: abreviatura + número
    control = (etiquetas.value.abreviatura || '') + formData.value.numeroExpediente.trim()
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar alta?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p>Se dará de alta el siguiente registro:</p>
        <ul style="list-style: none; padding: 0;">
          <li><strong>Control:</strong> ${control}</li>
          <li><strong>Concesionario:</strong> ${formData.value.concesionario}</li>
          <li><strong>Ubicación:</strong> ${formData.value.ubicacion}</li>
          <li><strong>Tipo:</strong> ${formData.value.tipoLocal}</li>
          <li><strong>Inicio:</strong> ${formData.value.mesInicio}/${formData.value.axoInicio}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de alta',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true
  setLoading(true, 'Guardando registro...')

  try {
    // Si no se muestra superficie (tipo 5), usar 1 como valor por defecto
    const superficie = mostrarSuperficie.value ? formData.value.superficie : 1

    const response = await execute(
      'SP_GNUEVOS_INSERT',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_control', valor: control, tipo: 'string' },
        { nombre: 'par_conces', valor: formData.value.concesionario, tipo: 'string' },
        { nombre: 'par_ubica', valor: formData.value.ubicacion, tipo: 'string' },
        { nombre: 'par_sup', valor: superficie, tipo: 'decimal' },
        { nombre: 'par_Axo_Ini', valor: formData.value.axoInicio, tipo: 'integer' },
        { nombre: 'par_Mes_Ini', valor: formData.value.mesInicio, tipo: 'integer' },
        { nombre: 'par_ofna', valor: formData.value.oficina, tipo: 'integer' },
        { nombre: 'par_sector', valor: formData.value.sector, tipo: 'string' },
        { nombre: 'par_zona', valor: formData.value.zona, tipo: 'integer' },
        { nombre: 'par_lic', valor: formData.value.licencia, tipo: 'integer' },
        { nombre: 'par_Descrip', valor: formData.value.tipoLocal.substring(0, 100), tipo: 'string' },
        { nombre: 'par_NomCom', valor: formData.value.nomComercial || '', tipo: 'string' },
        { nombre: 'par_Lugar', valor: formData.value.lugar || '', tipo: 'string' },
        { nombre: 'par_Obs', valor: formData.value.obs || '', tipo: 'string' },
        { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      if (data.status === 1) {
        // Éxito
        await Swal.fire({
          icon: 'success',
          title: 'Alta exitosa',
          text: data.concepto_status,
          confirmButtonColor: '#ea8215',
          timer: 3000
        })

        showToast('success', 'Registro dado de alta correctamente')

        // Limpiar formulario
        limpiarFormulario()
      } else {
        // Error
        await Swal.fire({
          icon: 'error',
          title: 'Error al dar de alta',
          text: data.concepto_status,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
    setLoading(false)
  }
}

// Limpiar formulario
const limpiarFormulario = () => {
  formData.value = {
    numeroExpediente: '',
    numeroLocal: '',
    letra: '',
    concesionario: '',
    ubicacion: '',
    nomComercial: '',
    lugar: '',
    obs: '',
    superficie: 0,
    tipoLocal: tiposLocal.value.length > 0 ? tiposLocal.value[0].descripcion : '',
    oficina: 0,
    sector: '',
    zona: 0,
    licencia: 0,
    axoInicio: axoActual,
    mesInicio: new Date().getMonth() + 1
  }

  // Hacer foco en el primer campo
  nextTick(() => {
    if (tipoTabla.value === 3 && numeroLocalInput.value) {
      numeroLocalInput.value.focus()
    } else if (numeroExpInput.value) {
      numeroExpInput.value.focus()
    }
  })
}

// Lifecycle
onMounted(async () => {
  setLoading(true, 'Cargando datos iniciales...')

  try {
    await loadEtiquetas()
    await loadTablas()
  } finally {
    setLoading(false)
  }

  // Hacer foco en el primer campo
  nextTick(() => {
    if (tipoTabla.value === 3 && numeroLocalInput.value) {
      numeroLocalInput.value.focus()
    } else if (numeroExpInput.value) {
      numeroExpInput.value.focus()
    }
  })
})
</script>
