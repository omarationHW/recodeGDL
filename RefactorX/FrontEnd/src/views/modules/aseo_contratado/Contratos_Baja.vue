<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Contratos</h1>
        <p>Aseo Contratado - Cancelacion de contratos vigentes</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Busqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="search-form-inline">
            <div class="search-field">
              <label class="municipal-form-label required">No. Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Ej: 12345"
                @keyup.enter="buscarContrato"
              />
            </div>
            <div class="search-field search-field-large">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="ctrolAseo" class="municipal-form-control">
                <option value="">-- Seleccione tipo de aseo --</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.display_text }}
                </option>
              </select>
            </div>
            <div class="search-field-button">
              <button type="button" class="btn-municipal-primary" @click="buscarContrato">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Informacion del Contrato -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-alt" /> Datos del Contrato</h5>
          <span class="municipal-badge" :class="getBadgeClass(contrato.status_vigencia)">
            {{ getStatusLabel(contrato.status_vigencia) }}
          </span>
        </div>
        <div class="municipal-card-body">
          <!-- Info Principal -->
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Contrato</span>
              <span class="info-value info-value-highlight">{{ contrato.num_contrato }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Tipo Aseo</span>
              <span class="info-value">{{ contrato.tipo_aseo }} - {{ contrato.descripcion_aseo }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Inicio Obligacion</span>
              <span class="info-value">{{ formatDate(contrato.aso_mes_oblig) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Recaudadora</span>
              <span class="info-value">{{ contrato.id_rec }} - {{ contrato.recaudadora }}</span>
            </div>
          </div>

          <!-- Empresa -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="building" /> Empresa</h6>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">No. Empresa</span>
                <span class="info-value">{{ contrato.num_empresa }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Nombre</span>
                <span class="info-value">{{ contrato.nombre_empresa }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Representante</span>
                <span class="info-value">{{ contrato.representante }}</span>
              </div>
            </div>
          </div>

          <!-- Servicio -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="truck" /> Servicio</h6>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Tipo Empresa</span>
                <span class="info-value">{{ contrato.tipo_empresa }} - {{ contrato.descripcion_tipo_emp }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Unidad Recoleccion</span>
                <span class="info-value">{{ contrato.cve_recolec }} - {{ contrato.descripcion_recolec }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Cantidad</span>
                <span class="info-value info-value-highlight">{{ contrato.cantidad_recolec }}</span>
              </div>
            </div>
          </div>

          <!-- Ubicacion -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="map-marker-alt" /> Ubicacion</h6>
            <div class="info-grid">
              <div class="info-item info-item-wide">
                <span class="info-label">Domicilio</span>
                <span class="info-value">{{ contrato.domicilio }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Sector</span>
                <span class="info-value">{{ contrato.sector }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Zona</span>
                <span class="info-value">{{ contrato.zona }}-{{ contrato.sub_zona }} {{ contrato.descripcion_zona }}</span>
              </div>
            </div>
          </div>

          <!-- Alertas -->
          <div v-if="infoAdeudos" class="mt-3">
            <div v-if="infoAdeudos.status === 1" class="municipal-alert municipal-alert-warning">
              <font-awesome-icon icon="exclamation-triangle" />
              <div>
                <strong>Atencion - Adeudos Pendientes</strong>
                <p class="mb-0">{{ infoAdeudos.leyenda }}</p>
              </div>
            </div>
            <div v-else class="municipal-alert municipal-alert-success">
              <font-awesome-icon icon="check-circle" />
              <span>{{ infoAdeudos.leyenda }}</span>
            </div>
          </div>

          <div v-if="contrato.status_vigencia === 'N' && infoConvenio" class="mt-3">
            <div class="municipal-alert municipal-alert-info">
              <font-awesome-icon icon="file-signature" />
              <div>
                <strong>Contrato Conveniado</strong>
                <p class="mb-0">Convenio: {{ infoConvenio.convenio }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel de Baja -->
      <div v-if="contratoEncontrado && contrato.status_vigencia === 'V' && mostrarPanelBaja" class="municipal-card mt-3">
        <div class="municipal-card-header municipal-card-header-danger">
          <h5><font-awesome-icon icon="ban" /> Datos para la Baja</h5>
        </div>
        <div class="municipal-card-body">
          <div class="baja-form">
            <!-- Periodo -->
            <div class="baja-form-row">
              <div class="baja-form-field">
                <label class="municipal-form-label required">Anio Cancelacion</label>
                <input
                  type="number"
                  v-model.number="datosCancel.anio"
                  class="municipal-form-control"
                  :min="anioMinimo"
                  :max="ejercicioActual"
                />
              </div>
              <div class="baja-form-field">
                <label class="municipal-form-label required">Mes</label>
                <select v-model="datosCancel.mes" class="municipal-form-control">
                  <option value="01">01 - Enero</option>
                  <option value="02">02 - Febrero</option>
                  <option value="03">03 - Marzo</option>
                  <option value="04">04 - Abril</option>
                  <option value="05">05 - Mayo</option>
                  <option value="06">06 - Junio</option>
                  <option value="07">07 - Julio</option>
                  <option value="08">08 - Agosto</option>
                  <option value="09">09 - Septiembre</option>
                  <option value="10">10 - Octubre</option>
                  <option value="11">11 - Noviembre</option>
                  <option value="12">12 - Diciembre</option>
                </select>
              </div>
              <div class="baja-form-field">
                <label class="municipal-form-label required">Fecha de Baja</label>
                <input
                  type="date"
                  v-model="datosCancel.fechaBaja"
                  class="municipal-form-control"
                  :max="fechaHoy"
                />
              </div>
            </div>

            <!-- Documento y Descripcion -->
            <div class="baja-form-row">
              <div class="baja-form-field">
                <label class="municipal-form-label required">Documento (min 10 caracteres)</label>
                <input
                  type="text"
                  v-model="datosCancel.documento"
                  class="municipal-form-control"
                  maxlength="100"
                  placeholder="Numero de documento que avala la baja"
                />
                <small class="field-counter">{{ datosCancel.documento.length }}/100</small>
              </div>
              <div class="baja-form-field baja-form-field-wide">
                <label class="municipal-form-label required">Descripcion (min 10 caracteres)</label>
                <textarea
                  v-model="datosCancel.descripcion"
                  class="municipal-form-control"
                  rows="3"
                  maxlength="500"
                  placeholder="Descripcion detallada del motivo de la baja"
                ></textarea>
                <small class="field-counter">{{ datosCancel.descripcion.length }}/500</small>
              </div>
            </div>
          </div>

          <!-- Errores -->
          <div v-if="erroresValidacion.length > 0" class="municipal-alert municipal-alert-danger mt-3">
            <font-awesome-icon icon="exclamation-circle" />
            <div>
              <strong>Corrija los siguientes errores:</strong>
              <ul class="error-list">
                <li v-for="(error, idx) in erroresValidacion" :key="idx">{{ error }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje si no es Vigente -->
      <div v-if="contratoEncontrado && contrato.status_vigencia !== 'V'" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="info-circle" />
            <div>
              <strong>No se puede dar de baja</strong>
              <p class="mb-0">Este contrato tiene status <strong>{{ getStatusLabel(contrato.status_vigencia) }}</strong>. Solo se pueden dar de baja contratos con status <strong>Vigente (V)</strong>.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Botones -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              v-if="contrato.status_vigencia === 'V' && mostrarPanelBaja"
              type="button"
              class="btn-municipal-danger"
              @click="ejecutarBaja"
              :disabled="!isFormValid"
            >
              <font-awesome-icon icon="ban" /> Confirmar Baja
            </button>
            <button type="button" class="btn-municipal-secondary" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="empty-state">
            <font-awesome-icon icon="search" class="empty-state-icon" />
            <h4>No se encontro el contrato</h4>
            <p>No existe contrato con el numero y tipo de aseo especificados. Verifique los datos e intente nuevamente.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Baja de Contratos"
      componentName="Contratos_Baja"
    >
      <h3>Baja de Contratos</h3>
      <p>Este modulo permite dar de baja contratos de aseo contratado.</p>

      <h4>Procedimiento:</h4>
      <ol>
        <li>Ingrese el numero de contrato y seleccione el tipo de aseo</li>
        <li>Presione Buscar</li>
        <li>Verifique la informacion del contrato</li>
        <li>Si tiene adeudos vencidos, confirme que desea continuar</li>
        <li>Ingrese el periodo de cancelacion (Anio y Mes)</li>
        <li>Ingrese la fecha de baja</li>
        <li>Ingrese el documento que avala la baja (minimo 10 caracteres)</li>
        <li>Ingrese la descripcion del motivo (minimo 10 caracteres)</li>
        <li>Presione Confirmar Baja</li>
      </ol>

      <h4>Status de Contratos:</h4>
      <ul>
        <li><strong>V - Vigente:</strong> Contrato activo, puede darse de baja</li>
        <li><strong>N - Conveniado:</strong> Contrato con convenio de pago</li>
        <li><strong>C - Cancelado:</strong> Contrato ya dado de baja</li>
        <li><strong>S - Suspendido:</strong> Contrato temporalmente suspendido</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Estado
const showDocumentation = ref(false)
const tiposAseo = ref([])
const numContrato = ref(null)
const ctrolAseo = ref('')
const contratoEncontrado = ref(false)
const busquedaRealizada = ref(false)
const contrato = ref({})
const infoAdeudos = ref(null)
const infoConvenio = ref(null)
const mostrarPanelBaja = ref(false)

// Ejercicio actual y fecha
const ejercicioActual = new Date().getFullYear()
const fechaHoy = new Date().toISOString().split('T')[0]

// Datos de cancelacion
const datosCancel = ref({
  anio: ejercicioActual,
  mes: '01',
  fechaBaja: fechaHoy,
  documento: '',
  descripcion: ''
})

// Anio minimo
const anioMinimo = computed(() => {
  if (contrato.value.aso_mes_oblig) {
    return new Date(contrato.value.aso_mes_oblig).getFullYear()
  }
  return 1989
})

// Errores de validacion
const erroresValidacion = computed(() => {
  const errores = []
  if (datosCancel.value.anio < anioMinimo.value) {
    errores.push(`El Anio de Cancelacion no puede ser MENOR al Inicio de Obligacion (${anioMinimo.value})`)
  }
  if (datosCancel.value.anio > ejercicioActual) {
    errores.push(`El Anio de Cancelacion no puede ser mayor al Ejercicio Actual (${ejercicioActual})`)
  }
  if (datosCancel.value.documento.trim().length < 10) {
    errores.push('El Documento debe tener al menos 10 caracteres')
  }
  if (datosCancel.value.descripcion.trim().length < 10) {
    errores.push('La Descripcion debe tener al menos 10 caracteres')
  }
  if (!datosCancel.value.fechaBaja) {
    errores.push('La Fecha de Baja es requerida')
  }
  return errores
})

// Validacion del formulario
const isFormValid = computed(() => {
  return erroresValidacion.value.length === 0
})

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX', { year: 'numeric', month: 'long' })
}

// Status label
const getStatusLabel = (status) => {
  const labels = { V: 'Vigente', N: 'Conveniado', C: 'Cancelado', S: 'Suspendido' }
  return labels[status] || status
}

// Badge class
const getBadgeClass = (status) => {
  const classes = {
    V: 'municipal-badge-success',
    N: 'municipal-badge-warning',
    C: 'municipal-badge-danger',
    S: 'municipal-badge-secondary'
  }
  return classes[status] || ''
}

// Cargar tipos de aseo
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo_combo', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      tiposAseo.value = data
      if (data.length >= 3) {
        ctrolAseo.value = data[2].ctrol_aseo
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

// Buscar contrato
const buscarContrato = async () => {
  if (!numContrato.value || numContrato.value === 0) {
    showToast('Ingrese un numero de contrato', 'warning')
    return
  }
  if (!ctrolAseo.value) {
    showToast('Seleccione un tipo de aseo', 'warning')
    return
  }

  showLoading()
  busquedaRealizada.value = true
  contratoEncontrado.value = false
  infoAdeudos.value = null
  infoConvenio.value = null
  mostrarPanelBaja.value = false

  try {
    const params = [
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: ctrolAseo.value, tipo: 'integer' }
    ]

    const data = await execute('sp_aseo_buscar_contrato_baja', BASE_DB, params, '', null, SCHEMA)

    if (data && data.length > 0) {
      contrato.value = data[0]
      contratoEncontrado.value = true

      if (contrato.value.status_vigencia === 'V') {
        await verificarAdeudos()
      }
      if (contrato.value.status_vigencia === 'N') {
        await buscarConvenio()
      }
      datosCancel.value.anio = ejercicioActual
    } else {
      hideLoading()
      showToast('No se encontro contrato con esos datos', 'warning')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
  } finally {
    hideLoading()
  }
}

// Verificar adeudos
const verificarAdeudos = async () => {
  try {
    const params = [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' }
    ]
    const data = await execute('sp16_ade_x_contrato', BASE_DB, params, '', null, SCHEMA)

    if (data && data.length > 0) {
      infoAdeudos.value = data[0]
      if (data[0].status === 1) {
        hideLoading()
        const result = await Swal.fire({
          title: 'Adeudos Pendientes',
          text: `${data[0].leyenda}. ¿Aun asi desea dar de BAJA el contrato?`,
          icon: 'warning',
          showCancelButton: true,
          confirmButtonText: 'Si, continuar',
          cancelButtonText: 'No, cancelar',
          confirmButtonColor: '#dc3545'
        })
        mostrarPanelBaja.value = result.isConfirmed
      } else {
        mostrarPanelBaja.value = true
      }
    } else {
      mostrarPanelBaja.value = true
    }
  } catch (error) {
    hideLoading()
    mostrarPanelBaja.value = true
  }
}

// Buscar convenio
const buscarConvenio = async () => {
  try {
    const params = [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_buscar_convenio_contrato', BASE_DB, params, '', null, SCHEMA)
    if (data && data.length > 0) {
      infoConvenio.value = data[0]
    }
  } catch (error) {
    hideLoading()
    // Sin convenio
  }
}

// Ejecutar baja
const ejecutarBaja = async () => {
  if (!isFormValid.value) {
    showToast('Corrija los errores antes de continuar', 'warning')
    return
  }

  const result = await Swal.fire({
    title: 'Confirmar Baja de Contrato',
    html: `
      <div style="text-align: left; padding: 1rem 0;">
        <p><strong>Contrato:</strong> ${contrato.value.num_contrato}</p>
        <p><strong>Empresa:</strong> ${contrato.value.nombre_empresa}</p>
        <p><strong>Periodo cancelacion:</strong> ${datosCancel.value.anio}-${datosCancel.value.mes}</p>
        <p style="color: #dc3545; margin-top: 1rem;"><strong>Esta accion no se puede deshacer.</strong></p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Si, dar de baja',
    cancelButtonText: 'No, cancelar',
    confirmButtonColor: '#dc3545'
  })

  if (!result.isConfirmed) {
    showToast('Operacion cancelada', 'info')
    return
  }

  showLoading()
  try {
    const periodo = `${datosCancel.value.anio}-${datosCancel.value.mes}`
    const params = [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_fecha_canc', valor: datosCancel.value.fechaBaja, tipo: 'string' },
      { nombre: 'p_periodo', valor: periodo, tipo: 'string' },
      { nombre: 'p_docto', valor: datosCancel.value.documento.trim(), tipo: 'string' },
      { nombre: 'p_descrip', valor: datosCancel.value.descripcion.trim(), tipo: 'string' }
    ]

    const data = await execute('sp16_cancela_contrato', BASE_DB, params, '', null, SCHEMA)
    hideLoading()

    if (data && data.length > 0) {
      if (data[0].status === 0) {
        await Swal.fire({
          title: 'Baja Exitosa',
          text: data[0].leyenda,
          icon: 'success'
        })
        cancelar()
      } else {
        await Swal.fire({
          title: 'Error',
          text: data[0].leyenda || 'Ocurrio un error al procesar la baja',
          icon: 'error'
        })
      }
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al dar de baja el contrato')
  }
}

// Cancelar
const cancelar = () => {
  router.push('/aseo-contratado')
}

// Inicializar
onMounted(async () => {
  showLoading()
  try {
    await cargarTiposAseo()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al inicializar')
  } finally {
    hideLoading()
  }
})
</script>
