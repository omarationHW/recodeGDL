<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-signature" />
      </div>
      <div class="module-view-info">
        <h1>Registro de Solicitud</h1>
        <p>Padrón de Licencias - Registro de Nuevas Solicitudes de Trámites</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="regresarConsulta"
        >
          <font-awesome-icon icon="arrow-left" />
          Regresar a Consulta
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Wizard Stepper -->
    <div class="wizard-container">
      <div class="wizard-steps">
        <div
          v-for="(step, index) in steps"
          :key="index"
          class="wizard-step"
          :class="{
            'active': currentStep === index + 1,
            'completed': currentStep > index + 1
          }"
          @click="goToStep(index + 1)"
        >
          <div class="step-number">
            <font-awesome-icon
              v-if="currentStep > index + 1"
              icon="check"
              class="step-icon-check"
            />
            <span v-else>{{ index + 1 }}</span>
          </div>
          <div class="step-info">
            <div class="step-title">{{ step.title }}</div>
            <div class="step-subtitle">{{ step.subtitle }}</div>
          </div>
        </div>
      </div>
      <div class="wizard-progress-indicator">
        <span class="badge-purple">
          Paso {{ currentStep }} de {{ steps.length }}
        </span>
      </div>
    </div>

    <!-- Formulario de Registro de Solicitud -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon :icon="steps[currentStep - 1].icon" />
          {{ steps[currentStep - 1].title }}
        </h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent>

          <!-- Paso 1: Información del Trámite -->
          <div v-show="currentStep === 1" class="wizard-step-content">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Trámite: <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="formData.tipo_tramite" required>
                  <option value="">Seleccionar...</option>
                  <option value="1">Licencia de Funcionamiento</option>
                  <option value="2">Licencia de Anuncio</option>
                  <option value="3">Constancia de Uso de Suelo</option>
                  <option value="4">Renovación de Licencia</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Giro: <span class="required">*</span></label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="formData.id_giro"
                  placeholder="ID del giro"
                  required
                >
              </div>
            </div>
            <div class="form-group full-width">
              <label class="municipal-form-label">Actividad a Realizar: <span class="required">*</span></label>
              <textarea
                class="municipal-form-control"
                v-model="formData.actividad"
                rows="4"
                maxlength="500"
                required
                placeholder="Describa detalladamente la actividad económica que se realizará en el establecimiento"
              ></textarea>
              <small class="form-text">{{ formData.actividad.length }} / 500 caracteres</small>
            </div>
          </div>

          <!-- Paso 2: Información del Propietario -->
          <div v-show="currentStep === 2" class="wizard-step-content">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nombre Completo: <span class="required">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.propietario"
                  maxlength="100"
                  required
                  placeholder="Nombre completo del propietario"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Teléfono: <span class="required">*</span></label>
                <input
                  type="tel"
                  class="municipal-form-control"
                  v-model="formData.telefono"
                  maxlength="20"
                  required
                  placeholder="Teléfono de contacto"
                >
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Email:</label>
                <input
                  type="email"
                  class="municipal-form-control"
                  v-model="formData.email"
                  maxlength="100"
                  placeholder="correo@ejemplo.com"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">RFC:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.rfc"
                  maxlength="13"
                  placeholder="RFC a 12 o 13 posiciones"
                  @input="formData.rfc = formData.rfc.toUpperCase()"
                >
              </div>
            </div>
            <div class="form-group full-width">
              <label class="municipal-form-label">CURP:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.curp"
                maxlength="18"
                placeholder="CURP a 18 posiciones"
                @input="formData.curp = formData.curp.toUpperCase()"
              >
            </div>
          </div>

          <!-- Paso 3: Ubicación del Establecimiento -->
          <div v-show="currentStep === 3" class="wizard-step-content">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Calle: <span class="required">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.calle"
                  maxlength="100"
                  required
                  placeholder="Nombre de la calle"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Colonia: <span class="required">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.colonia"
                  maxlength="100"
                  required
                  placeholder="Nombre de la colonia"
                >
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">No. Exterior:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.numext"
                  maxlength="10"
                  placeholder="Número exterior"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Letra Exterior:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.letraext"
                  maxlength="5"
                  placeholder="Letra"
                  @input="formData.letraext = formData.letraext.toUpperCase()"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">No. Interior:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.numint"
                  maxlength="10"
                  placeholder="Número interior"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Letra Interior:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.letraint"
                  maxlength="5"
                  placeholder="Letra"
                  @input="formData.letraint = formData.letraint.toUpperCase()"
                >
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">C.P.:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formData.cp"
                  maxlength="5"
                  placeholder="Código postal"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Zona:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="formData.zona"
                  placeholder="Zona"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Subzona:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="formData.subzona"
                  placeholder="Subzona"
                >
              </div>
            </div>
          </div>

          <!-- Paso 4: Datos Técnicos -->
          <div v-show="currentStep === 4" class="wizard-step-content">
            <div class="form-section">
              <h6 class="section-title">
                <font-awesome-icon icon="tools" />
                Datos Técnicos del Establecimiento
              </h6>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Superficie Construida (m²):</label>
                  <input
                    type="number"
                    step="0.01"
                    class="municipal-form-control"
                    v-model="formData.sup_const"
                    placeholder="Metros cuadrados"
                  >
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Superficie Autorizada (m²):</label>
                  <input
                    type="number"
                    step="0.01"
                    class="municipal-form-control"
                    v-model="formData.sup_autorizada"
                    placeholder="Metros cuadrados"
                  >
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Número de Cajones:</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="formData.num_cajones"
                    placeholder="Cajones de estacionamiento"
                  >
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Número de Empleados:</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model="formData.num_empleados"
                    placeholder="Empleados"
                  >
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Inversión ($):</label>
                  <input
                    type="number"
                    step="0.01"
                    class="municipal-form-control"
                    v-model="formData.inversion"
                    placeholder="Monto de inversión"
                  >
                </div>
              </div>
            </div>

            <div class="form-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Especificaciones Adicionales
              </h6>
              <div class="form-group full-width">
                <label class="municipal-form-label">Observaciones y Especificaciones:</label>
                <textarea
                  class="municipal-form-control"
                  v-model="formData.especificaciones"
                  rows="4"
                  maxlength="1000"
                  placeholder="Observaciones adicionales, especificaciones o comentarios relevantes"
                ></textarea>
                <small class="form-text">{{ formData.especificaciones.length }} / 1000 caracteres</small>
              </div>
            </div>

            <!-- Resumen de la solicitud -->
            <div class="solicitud-resumen">
              <h6 class="section-title">
                <font-awesome-icon icon="clipboard-check" />
                Resumen de la Solicitud
              </h6>
              <div class="resumen-grid">
                <div class="resumen-item">
                  <strong>Tipo de Trámite:</strong>
                  <span>{{ getTipoTramiteLabel(formData.tipo_tramite) }}</span>
                </div>
                <div class="resumen-item">
                  <strong>Giro:</strong>
                  <span>{{ formData.id_giro }}</span>
                </div>
                <div class="resumen-item">
                  <strong>Propietario:</strong>
                  <span>{{ formData.propietario }}</span>
                </div>
                <div class="resumen-item">
                  <strong>Teléfono:</strong>
                  <span>{{ formData.telefono }}</span>
                </div>
                <div class="resumen-item">
                  <strong>Ubicación:</strong>
                  <span>{{ formData.calle }}, {{ formData.colonia }}</span>
                </div>
                <div class="resumen-item">
                  <strong>Actividad:</strong>
                  <span class="text-truncate">{{ formData.actividad }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Botones de navegación del wizard -->
          <div class="wizard-navigation">
            <button
              v-if="currentStep > 1"
              type="button"
              class="btn-municipal-secondary"
              @click="previousStep"
            >
              <font-awesome-icon icon="arrow-left" />
              Anterior
            </button>

            <button
              type="button"
              class="btn-municipal-secondary"
              @click="cancelarWizard"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>

            <button
              v-if="currentStep < steps.length"
              type="button"
              class="btn-municipal-primary"
              @click="handleNextStep"
            >
              Siguiente
              <font-awesome-icon icon="arrow-right" />
            </button>

            <button
              v-if="currentStep === steps.length"
              type="button"
              class="btn-municipal-success"
              @click="registrarSolicitud"
            >
              <font-awesome-icon icon="check" />
              Registrar Solicitud
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Información de la última solicitud registrada -->
    <div class="municipal-card" v-if="ultimaSolicitud">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" class="text-success" />
          Última Solicitud Registrada
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="solicitud-info">
          <div class="info-item">
            <strong>ID Trámite:</strong>
            <span class="badge-primary">{{ ultimaSolicitud.id_tramite }}</span>
          </div>
          <div class="info-item">
            <strong>Folio:</strong>
            <span class="badge-success">{{ ultimaSolicitud.folio }}</span>
          </div>
          <div class="info-item">
            <strong>Mensaje:</strong>
            <span>{{ ultimaSolicitud.mensaje }}</span>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-info"
            @click="verDetalleTramite(ultimaSolicitud.id_tramite)"
          >
            <font-awesome-icon icon="eye" />
            Ver Detalles del Trámite
          </button>
          <button
            class="btn-municipal-primary"
            @click="agregarDocumento"
          >
            <font-awesome-icon icon="file-upload" />
            Agregar Documentos
          </button>
        </div>
      </div>
    </div>

    <!-- Modal para agregar documentos -->
    <Modal
      :show="showDocumentoModal"
      title="Agregar Documento al Trámite"
      size="lg"
      @close="showDocumentoModal = false"
      @confirm="guardarDocumento"
      :loading="agregandoDocumento"
      confirmText="Agregar Documento"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="guardarDocumento">
        <div class="form-group full-width">
          <label class="municipal-form-label">ID Trámite:</label>
          <input
            type="number"
            class="municipal-form-control"
            :value="ultimaSolicitud?.id_tramite"
            disabled
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Nombre del Documento: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="documentoForm.nombre"
            maxlength="200"
            required
            placeholder="Ej: Identificación Oficial, Comprobante de Domicilio"
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Ruta del Archivo: <span class="required">*</span></label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="documentoForm.ruta"
            maxlength="500"
            required
            placeholder="/documentos/tramite_xxx/archivo.pdf"
          >
          <small class="form-text">Ruta donde se almacenó el archivo en el servidor</small>
        </div>
      </form>
    </Modal>

    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ toast.duration }}
        </span>
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
      :componentName="'RegistroSolicitud'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const router = useRouter()

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Wizard steps
const currentStep = ref(1)
const steps = [
  {
    title: 'Información del Trámite',
    subtitle: 'Tipo y actividad',
    icon: 'clipboard-list'
  },
  {
    title: 'Datos del Propietario',
    subtitle: 'Información de contacto',
    icon: 'user'
  },
  {
    title: 'Ubicación',
    subtitle: 'Dirección del establecimiento',
    icon: 'map-marker-alt'
  },
  {
    title: 'Datos Técnicos',
    subtitle: 'Especificaciones y confirmación',
    icon: 'tools'
  }
]

// Estado
const agregandoDocumento = ref(false)
const ultimaSolicitud = ref(null)
const showDocumentoModal = ref(false)

// Formularios
const formData = ref({
  tipo_tramite: '',
  id_giro: null,
  actividad: '',
  propietario: '',
  telefono: '',
  email: '',
  calle: '',
  colonia: '',
  cp: '',
  numext: '',
  numint: '',
  letraext: '',
  letraint: '',
  zona: null,
  subzona: null,
  sup_const: null,
  sup_autorizada: null,
  num_cajones: null,
  num_empleados: null,
  inversion: null,
  rfc: '',
  curp: '',
  especificaciones: ''
})

const documentoForm = ref({
  nombre: '',
  ruta: ''
})

// Métodos de navegación del wizard
const goToStep = (step) => {
  if (step <= currentStep.value || step === currentStep.value + 1) {
    currentStep.value = step
  }
}

const nextStep = () => {
  if (currentStep.value < steps.length) {
    currentStep.value++
  }
}

const previousStep = () => {
  if (currentStep.value > 1) {
    currentStep.value--
  }
}

const handleNextStep = (event) => {
  // Prevenir el submit por defecto
  if (event) {
    event.preventDefault()
  }

  // Validar el paso actual antes de continuar
  if (validateCurrentStep()) {
    nextStep()
  }
}

const validateCurrentStep = () => {
  switch (currentStep.value) {
    case 1:
      if (!formData.value.tipo_tramite || !formData.value.id_giro || !formData.value.actividad?.trim()) {
        showToast('warning', 'Por favor complete todos los campos requeridos: Tipo de Trámite, Giro y Actividad')
        return false
      }
      break
    case 2:
      if (!formData.value.propietario?.trim() || !formData.value.telefono?.trim()) {
        showToast('warning', 'Por favor complete todos los campos requeridos: Nombre Completo y Teléfono')
        return false
      }
      break
    case 3:
      if (!formData.value.calle?.trim() || !formData.value.colonia?.trim()) {
        showToast('warning', 'Por favor complete todos los campos requeridos: Calle y Colonia')
        return false
      }
      break
  }
  return true
}

const cancelarWizard = async () => {
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Cancelar registro?',
    text: 'Se perderán todos los datos capturados',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No, continuar'
  })

  if (result.isConfirmed) {
    limpiarFormulario()
    currentStep.value = 1
    showToast('info', 'Registro cancelado')
  }
}

const getTipoTramiteLabel = (tipo) => {
  const tipos = {
    '1': 'Licencia de Funcionamiento',
    '2': 'Licencia de Anuncio',
    '3': 'Constancia de Uso de Suelo',
    '4': 'Renovación de Licencia'
  }
  return tipos[tipo] || 'No especificado'
}

// Métodos
const registrarSolicitud = async () => {
  if (!formData.value.tipo_tramite || !formData.value.id_giro || !formData.value.actividad ||
      !formData.value.propietario || !formData.value.telefono || !formData.value.calle || !formData.value.colonia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios marcados con *',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar registro de solicitud?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se registrará una nueva solicitud con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${getTipoTramiteLabel(formData.value.tipo_tramite)}</li>
          <li style="margin: 5px 0;"><strong>Propietario:</strong> ${formData.value.propietario}</li>
          <li style="margin: 5px 0;"><strong>Actividad:</strong> ${formData.value.actividad.substring(0, 50)}...</li>
          <li style="margin: 5px 0;"><strong>Ubicación:</strong> ${formData.value.calle}, ${formData.value.colonia}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, registrar solicitud',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = performance.now()
  showLoading('Registrando solicitud...', 'Procesando datos del trámite')

  try {
    const response = await execute(
      'sp_registro_solicitud',
      'padron_licencias',
      [
        { nombre: 'p_tipo_tramite', valor: parseInt(formData.value.tipo_tramite), tipo: 'integer' },
        { nombre: 'p_id_giro', valor: parseInt(formData.value.id_giro), tipo: 'integer' },
        { nombre: 'p_actividad', valor: formData.value.actividad.trim(), tipo: 'string' },
        { nombre: 'p_propietario', valor: formData.value.propietario.trim(), tipo: 'string' },
        { nombre: 'p_telefono', valor: formData.value.telefono.trim(), tipo: 'string' },
        { nombre: 'p_email', valor: formData.value.email?.trim() || null, tipo: 'string' },
        { nombre: 'p_calle', valor: formData.value.calle.trim(), tipo: 'string' },
        { nombre: 'p_colonia', valor: formData.value.colonia.trim(), tipo: 'string' },
        { nombre: 'p_cp', valor: formData.value.cp?.trim() || null, tipo: 'string' },
        { nombre: 'p_numext', valor: formData.value.numext?.trim() || null, tipo: 'string' },
        { nombre: 'p_numint', valor: formData.value.numint?.trim() || null, tipo: 'string' },
        { nombre: 'p_letraext', valor: formData.value.letraext?.trim() || null, tipo: 'string' },
        { nombre: 'p_letraint', valor: formData.value.letraint?.trim() || null, tipo: 'string' },
        { nombre: 'p_zona', valor: formData.value.zona || null, tipo: 'integer' },
        { nombre: 'p_subzona', valor: formData.value.subzona || null, tipo: 'integer' },
        { nombre: 'p_sup_const', valor: formData.value.sup_const || null, tipo: 'numeric' },
        { nombre: 'p_sup_autorizada', valor: formData.value.sup_autorizada || null, tipo: 'numeric' },
        { nombre: 'p_num_cajones', valor: formData.value.num_cajones || null, tipo: 'integer' },
        { nombre: 'p_num_empleados', valor: formData.value.num_empleados || null, tipo: 'integer' },
        { nombre: 'p_inversion', valor: formData.value.inversion || null, tipo: 'numeric' },
        { nombre: 'p_rfc', valor: formData.value.rfc?.trim() || null, tipo: 'string' },
        { nombre: 'p_curp', valor: formData.value.curp?.trim() || null, tipo: 'string' },
        { nombre: 'p_especificaciones', valor: formData.value.especificaciones?.trim() || null, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      '', // tenant
      null, // pagination
      'comun' // esquema correcto
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result[0]) {
      ultimaSolicitud.value = response.result[0]

      // Cerrar loading ANTES de mostrar el mensaje de éxito
      hideLoading()

      await Swal.fire({
        icon: 'success',
        title: 'Solicitud Registrada!',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p><strong>ID Trámite:</strong> ${ultimaSolicitud.value.id_tramite}</p>
            <p><strong>Folio:</strong> ${ultimaSolicitud.value.folio}</p>
            <p>${ultimaSolicitud.value.mensaje}</p>
          </div>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('success', 'Solicitud registrada exitosamente', timeMessage)
      limpiarFormulario()
      currentStep.value = 1
    } else {
      // Cerrar loading también en caso de respuesta sin datos
      hideLoading()

      await Swal.fire({
        icon: 'error',
        title: 'Error al registrar solicitud',
        text: 'No se pudo completar el registro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    console.error('Error al registrar solicitud:', error)

    // Cerrar loading ANTES de mostrar el mensaje
    hideLoading()

    // Determinar el mensaje de error
    let errorMessage = 'No se pudo registrar la solicitud'
    let errorTitle = 'Error de conexión'

    if (error.response?.data?.eResponse?.message) {
      const apiMessage = error.response.data.eResponse.message

      // Detectar si es error de SP no existente
      if (apiMessage.includes('no existe')) {
        errorTitle = 'Stored Procedure no encontrado'
        errorMessage = 'El sistema aún no tiene configurado el procedimiento de registro. Por favor contacte al administrador del sistema.'
      } else {
        errorMessage = apiMessage
      }
    }

    handleApiError(error, 'Error al registrar solicitud')

    await Swal.fire({
      icon: 'error',
      title: errorTitle,
      text: errorMessage,
      confirmButtonColor: '#ea8215'
    })
  }
}

const limpiarFormulario = () => {
  formData.value = {
    tipo_tramite: '',
    id_giro: null,
    actividad: '',
    propietario: '',
    telefono: '',
    email: '',
    calle: '',
    colonia: '',
    cp: '',
    numext: '',
    numint: '',
    letraext: '',
    letraint: '',
    zona: null,
    subzona: null,
    sup_const: null,
    sup_autorizada: null,
    num_cajones: null,
    num_empleados: null,
    inversion: null,
    rfc: '',
    curp: '',
    especificaciones: ''
  }
}

const agregarDocumento = () => {
  documentoForm.value = {
    nombre: '',
    ruta: ''
  }
  showDocumentoModal.value = true
}

const guardarDocumento = async () => {
  if (!documentoForm.value.nombre || !documentoForm.value.ruta) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  agregandoDocumento.value = true

  try {
    const response = await execute(
      'sp_agregar_documento',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: ultimaSolicitud.value.id_tramite, tipo: 'integer' },
        { nombre: 'p_nombre', valor: documentoForm.value.nombre.trim(), tipo: 'string' },
        { nombre: 'p_ruta', valor: documentoForm.value.ruta.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      ''
    )

    if (response && response.result && response.result[0]) {
      showDocumentoModal.value = false

      await Swal.fire({
        icon: 'success',
        title: 'Documento agregado!',
        text: response.result[0].mensaje,
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Documento agregado exitosamente')
    }
  } catch (error) {
    handleApiError(error, 'Error al agregar documento')
  } finally {
    agregandoDocumento.value = false
  }
}

const verDetalleTramite = async (id_tramite) => {
  await Swal.fire({
    icon: 'info',
    title: 'Ver Trámite',
    text: `Funcionalidad para ver detalles del trámite ${id_tramite}`,
    confirmButtonColor: '#ea8215'
  })
}

const regresarConsulta = () => {
  router.push('/padron-licencias/consulta-tramites')
}

// Lifecycle
onBeforeUnmount(() => {
  showDocumentoModal.value = false
})
</script>
