<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-title-section">
        <font-awesome-icon icon="hand-holding-usd module-icon" />
        <div>
          <h1 class="module-view-info">Bonificaciones de Cementerios</h1>
          <p class="module-subtitle">Gestión de bonificaciones y descuentos por oficio</p>
        </div>
      </div>
      <div class="module-actions">
        <button @click="showHelp = true" class="btn-icon" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
        </button>
      </div>
    </div>

    <div class="module-content">
      <!-- Paso 1: Datos del Oficio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="file-signature" />
          Paso 1: Datos del Oficio
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-three">
            <div class="form-group">
              <label for="oficio" class="form-label required">Número de Oficio</label>
              <input
                id="oficio"
                v-model.number="datosOficio.oficio"
                type="number"
                min="1"
                class="municipal-form-control"
                :disabled="pasoActual > 1"
              />
            </div>

            <div class="form-group">
              <label for="axo" class="form-label required">Año</label>
              <input
                id="axo"
                v-model.number="datosOficio.axo"
                type="number"
                :min="currentYear - 10"
                :max="currentYear"
                class="municipal-form-control"
                :disabled="pasoActual > 1"
              />
            </div>

            <div class="form-group">
              <label for="doble" class="form-label required">Recibido</label>
              <input
                id="doble"
                v-model="datosOficio.doble"
                type="text"
                maxlength="1"
                class="municipal-form-control"
                placeholder="0-9"
                :disabled="pasoActual > 1"
              />
            </div>
          </div>

          <div class="form-actions">
            <button
              v-if="pasoActual === 1"
              @click="buscarOficio"
              class="btn-municipal-primary"
              :disabled="!oficioValid"
            >
              <font-awesome-icon icon="search" />
              Buscar Oficio
            </button>
            <button
              v-if="pasoActual > 1"
              @click="nuevoOficio"
              class="btn-municipal-secondary"
            >
              <font-awesome-icon icon="redo" />
              Nuevo Oficio
            </button>
          </div>
        </div>
      </div>

      <!-- Paso 2: Datos del Folio (solo si se encontró o es nuevo oficio) -->
      <div v-if="pasoActual >= 2" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="folder" />
          Paso 2: Folio a Bonificar
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-two">
            <div class="form-group">
              <label for="folio" class="form-label required">Folio (Control RCM)</label>
              <input
                id="folio"
                v-model.number="folioBuscar"
                type="number"
                class="municipal-form-control"
                :disabled="pasoActual === 3 || modoModificacion"
                @keyup.enter="buscarFolio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <button
                v-if="!modoModificacion && pasoActual === 2"
                @click="buscarFolio"
                class="btn-municipal-primary"
                :disabled="!folioBuscar"
              >
                <font-awesome-icon icon="search" />
                Buscar Folio
              </button>
            </div>
          </div>

          <!-- Datos del folio encontrado -->
          <div v-if="pasoActual === 3 && datosRCM.control_rcm" class="info-section mt-3">
            <h3 class="section-title">Datos del Folio</h3>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Control RCM:</span>
                <span class="info-value">{{ datosRCM.control_rcm }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Propietario:</span>
                <span class="info-value">{{ datosRCM.nombre }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Ubicación:</span>
                <span class="info-value">
                  {{ formatUbicacion() }}
                </span>
              </div>
              <div class="info-item">
                <span class="info-label">Cementerio:</span>
                <span class="info-value">{{ datosRCM.cementerio }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Paso 3: Datos de la Bonificación -->
      <div v-if="pasoActual === 3" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="calculator" />
          Datos de la Bonificación
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-two">
            <div class="form-group">
              <label for="fechaOficio" class="form-label required">Fecha del Oficio</label>
              <input
                id="fechaOficio"
                v-model="formBonificacion.fecha_ofic"
                type="date"
                class="municipal-form-control"
              />
            </div>

            <div class="form-group">
              <label for="importeBonificar" class="form-label required">Importe a Bonificar</label>
              <input
                id="importeBonificar"
                v-model.number="formBonificacion.importe_bonificar"
                type="number"
                step="0.01"
                min="0"
                class="municipal-form-control"
                @blur="calcularPendiente"
              />
            </div>
          </div>

          <div class="form-grid-two">
            <div class="form-group">
              <label for="importeBonificado" class="municipal-form-label">Importe Bonificado</label>
              <input
                id="importeBonificado"
                v-model.number="formBonificacion.importe_bonificado"
                type="number"
                step="0.01"
                min="0"
                class="municipal-form-control"
                @blur="calcularPendiente"
              />
            </div>

            <div class="form-group">
              <label for="importePendiente" class="municipal-form-label">Pendiente por Bonificar</label>
              <input
                id="importePendiente"
                v-model.number="formBonificacion.importe_resto"
                type="number"
                step="0.01"
                class="municipal-form-control"
                disabled
              />
            </div>
          </div>

          <!-- Resumen visual -->
          <div class="summary-box mt-3">
            <div class="summary-item">
              <span class="summary-label">Total a Bonificar:</span>
              <span class="summary-value primary">{{ formatCurrency(formBonificacion.importe_bonificar) }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">Bonificado:</span>
              <span class="summary-value success">{{ formatCurrency(formBonificacion.importe_bonificado) }}</span>
            </div>
            <div class="summary-item">
              <span class="summary-label">Pendiente:</span>
              <span class="summary-value warning">{{ formatCurrency(formBonificacion.importe_resto) }}</span>
            </div>
          </div>

          <!-- Acciones -->
          <div class="form-actions mt-3">
            <button
              @click="guardarBonificacion"
              class="btn-municipal-primary"
              :disabled="!bonificacionValid"
            >
              <font-awesome-icon icon="save" />
              {{ modoModificacion ? 'Guardar Cambios' : 'Registrar Bonificación' }}
            </button>
            <button
              v-if="modoModificacion"
              @click="confirmarEliminacion"
              class="btn-danger"
            >
              <font-awesome-icon icon="trash" />
              Eliminar
            </button>
            <button
              @click="cancelar"
              class="btn-municipal-secondary"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="showHelp"
      title="Bonificaciones de Cementerios"
      @close="showHelp = false"
    >
      <div class="help-content">
        <h3>Descripción</h3>
        <p>
          Este módulo permite gestionar bonificaciones y descuentos aplicados a folios de cementerios
          mediante oficios autorizados.
        </p>

        <h3>Proceso de Registro</h3>
        <ol>
          <li><strong>Paso 1:</strong> Ingrese los datos del oficio (número, año y recibido)</li>
          <li><strong>Paso 2:</strong> Si el oficio no existe, ingrese el folio a bonificar</li>
          <li><strong>Paso 3:</strong> Capture los importes y guarde la bonificación</li>
        </ol>

        <h3>Instrucciones de Uso</h3>
        <ul>
          <li>Para crear nueva bonificación: ingrese oficio que no exista</li>
          <li>Para modificar: ingrese oficio existente y modifique los importes</li>
          <li>El importe pendiente se calcula automáticamente</li>
          <li>Puede eliminar bonificaciones existentes con el botón "Eliminar"</li>
        </ul>

        <h3>Campos Requeridos</h3>
        <ul>
          <li><strong>Número de Oficio:</strong> Número del oficio que autoriza la bonificación</li>
          <li><strong>Año:</strong> Año del oficio (no puede ser mayor al actual)</li>
          <li><strong>Recibido:</strong> Duplicado del oficio (0-9)</li>
          <li><strong>Folio:</strong> Control RCM a bonificar</li>
          <li><strong>Fecha del Oficio:</strong> Fecha de emisión del oficio</li>
          <li><strong>Importe a Bonificar:</strong> Total autorizado para bonificar</li>
        </ul>

        <h3>Cálculo Automático</h3>
        <p>
          <strong>Pendiente = Total a Bonificar - Bonificado</strong><br>
          El sistema calcula automáticamente el importe pendiente al modificar los valores.
        </p>
      </div>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Bonificaciones'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showSuccess, showError, showWarning } = useToast()

// Estado
const showHelp = ref(false)
const pasoActual = ref(1)
const modoModificacion = ref(false)
const currentYear = new Date().getFullYear()

// Datos del oficio
const datosOficio = ref({
  oficio: null,
  axo: currentYear,
  doble: '0'
})

// Folio a buscar
const folioBuscar = ref(null)

// Datos del RCM
const datosRCM = ref({
  control_rcm: null,
  nombre: '',
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

// Formulario de bonificación
const formBonificacion = ref({
  fecha_ofic: new Date().toISOString().split('T')[0],
  importe_bonificar: 0,
  importe_bonificado: 0,
  importe_resto: 0
})

// Validaciones
const oficioValid = computed(() => {
  return (
    datosOficio.value.oficio > 0 &&
    datosOficio.value.axo > 0 &&
    datosOficio.value.axo <= currentYear &&
    datosOficio.value.doble &&
    datosOficio.value.doble.length === 1 &&
    /^[0-9]$/.test(datosOficio.value.doble)
  )
})

const bonificacionValid = computed(() => {
  return (
    formBonificacion.value.fecha_ofic &&
    formBonificacion.value.importe_bonificar > 0
  )
})

// Buscar oficio
const buscarOficio = async () => {
  if (!oficioValid.value) {
    showWarning('Complete correctamente los datos del oficio')
    return
  }

  try {
    const response = await execute(
      'sp_cem_buscar_bonificacion',
      'cementerios',
      {
        p_oficio: datosOficio.value.oficio,
        p_axo: datosOficio.value.axo,
        p_doble: datosOficio.value.doble
      },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S' && response.result && response.result.length > 0) {
      // Bonificación existe - modo modificación
      const bonif = response.result[0]
      modoModificacion.value = true
      pasoActual.value = 3
      folioBuscar.value = bonif.control_rcm

      // Cargar datos del RCM
      datosRCM.value = {
        control_rcm: bonif.control_rcm,
        nombre: bonif.nombre_propietario || '',
        cementerio: bonif.cementerio,
        clase: bonif.clase,
        clase_alfa: bonif.clase_alfa,
        seccion: bonif.seccion,
        seccion_alfa: bonif.seccion_alfa,
        linea: bonif.linea,
        linea_alfa: bonif.linea_alfa,
        fosa: bonif.fosa,
        fosa_alfa: bonif.fosa_alfa
      }

      // Cargar datos de bonificación
      formBonificacion.value = {
        fecha_ofic: bonif.fecha_ofic ? new Date(bonif.fecha_ofic).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
        importe_bonificar: bonif.importe_bonificar || 0,
        importe_bonificado: bonif.importe_bonificado || 0,
        importe_resto: bonif.importe_resto || 0
      }

      showSuccess('Bonificación encontrada - Modo modificación')
    } else {
      // No existe - modo alta
      modoModificacion.value = false
      pasoActual.value = 2
      showSuccess('Oficio no encontrado - Ingrese el folio a bonificar')
    }
  } catch (error) {
    // Si no existe, pasar a paso 2 para crear nuevo
    modoModificacion.value = false
    pasoActual.value = 2
    showSuccess('Oficio nuevo - Ingrese el folio a bonificar')
  }
}

// Buscar folio
const buscarFolio = async () => {
  if (!folioBuscar.value) {
    showWarning('Ingrese un número de folio')
    return
  }

  try {
    const response = await execute(
      'sp_cem_buscar_folio',
      'cementerios',
      { p_control_rcm: folioBuscar.value },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S' && response.result && response.result.length > 0) {
      const folio = response.result[0]

      if (folio.vigencia === 'B') {
        showWarning('Este folio está dado de baja')
        return
      }

      datosRCM.value = {
        control_rcm: folio.control_rcm,
        nombre: folio.nombre || '',
        cementerio: folio.cementerio,
        clase: folio.clase,
        clase_alfa: folio.clase_alfa,
        seccion: folio.seccion,
        seccion_alfa: folio.seccion_alfa,
        linea: folio.linea,
        linea_alfa: folio.linea_alfa,
        fosa: folio.fosa,
        fosa_alfa: folio.fosa_alfa
      }

      pasoActual.value = 3
      showSuccess('Folio encontrado')
    } else {
      showError('Folio no encontrado')
    }
  } catch (error) {
    showError('Error al buscar el folio')
  }
}

// Calcular pendiente
const calcularPendiente = () => {
  const total = formBonificacion.value.importe_bonificar || 0
  const bonificado = formBonificacion.value.importe_bonificado || 0
  formBonificacion.value.importe_resto = total - bonificado
}

// Guardar bonificación
const guardarBonificacion = async () => {
  if (!bonificacionValid.value) {
    showWarning('Complete todos los campos requeridos')
    return
  }

  try {
    const response = await execute(
      'sp_cem_registrar_bonificacion',
      'cementerios',
      {
        p_operacion: modoModificacion.value ? 2 : 1,
        p_oficio: datosOficio.value.oficio,
        p_axo: datosOficio.value.axo,
        p_doble: datosOficio.value.doble,
        p_control_rcm: datosRCM.value.control_rcm,
        p_fecha_ofic: formBonificacion.value.fecha_ofic,
        p_importe_bonificar: formBonificacion.value.importe_bonificar,
        p_importe_bonificado: formBonificacion.value.importe_bonificado,
        p_importe_resto: formBonificacion.value.importe_resto,
        p_usuario: 1 // TODO: Obtener del contexto de usuario
      },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S') {
      showSuccess(modoModificacion.value ? 'Bonificación modificada exitosamente' : 'Bonificación registrada exitosamente')
      nuevoOficio()
    } else {
      showError(response?.mensaje || 'Error al guardar la bonificación')
    }
  } catch (error) {
    showError('Error al guardar la bonificación')
  }
}

// Confirmar eliminación
const confirmarEliminacion = async () => {
  const result = await Swal.fire({
    title: '¿Eliminar bonificación?',
    html: `
      <p>Está a punto de eliminar la bonificación:</p>
      <p><strong>Oficio ${datosOficio.value.oficio}/${datosOficio.value.axo}</strong></p>
      <p>Folio: ${datosRCM.value.control_rcm}</p>
      <p>Importe: ${formatCurrency(formBonificacion.value.importe_bonificar)}</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6'
  })

  if (result.isConfirmed) {
    await eliminarBonificacion()
  }
}

// Eliminar bonificación
const eliminarBonificacion = async () => {
  try {
    const response = await execute(
      'sp_cem_eliminar_bonificacion',
      'cementerios',
      {
        p_oficio: datosOficio.value.oficio,
        p_axo: datosOficio.value.axo,
        p_doble: datosOficio.value.doble
      },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S') {
      showSuccess('Bonificación eliminada exitosamente')
      nuevoOficio()
    } else {
      showError(response?.mensaje || 'Error al eliminar la bonificación')
    }
  } catch (error) {
    showError('Error al eliminar la bonificación')
  }
}

// Nuevo oficio (reiniciar)
const nuevoOficio = () => {
  pasoActual.value = 1
  modoModificacion.value = false
  datosOficio.value = {
    oficio: null,
    axo: currentYear,
    doble: '0'
  }
  folioBuscar.value = null
  datosRCM.value = {
    control_rcm: null,
    nombre: '',
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
  formBonificacion.value = {
    fecha_ofic: new Date().toISOString().split('T')[0],
    importe_bonificar: 0,
    importe_bonificado: 0,
    importe_resto: 0
  }
}

// Cancelar
const cancelar = () => {
  if (pasoActual.value === 3) {
    nuevoOficio()
  } else {
    pasoActual.value = Math.max(1, pasoActual.value - 1)
  }
}

// Formatear ubicación
const formatUbicacion = () => {
  const parts = []
  if (datosRCM.value.clase) parts.push(`Clase: ${datosRCM.value.clase}${datosRCM.value.clase_alfa || ''}`)
  if (datosRCM.value.seccion) parts.push(`Sec: ${datosRCM.value.seccion}${datosRCM.value.seccion_alfa || ''}`)
  if (datosRCM.value.linea) parts.push(`Línea: ${datosRCM.value.linea}${datosRCM.value.linea_alfa || ''}`)
  if (datosRCM.value.fosa) parts.push(`Fosa: ${datosRCM.value.fosa}${datosRCM.value.fosa_alfa || ''}`)
  return parts.join(' - ')
}

// Formatear moneda
const formatCurrency = (value) => {
  if (value === null || value === undefined) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
