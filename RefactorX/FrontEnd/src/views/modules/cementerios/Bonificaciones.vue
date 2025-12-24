<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-usd" />
      </div>
      <div class="module-view-info">
        <h1>Bonificaciones de Cementerios</h1>
        <p>Cementerios - Gestión de bonificaciones y descuentos por oficio</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
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

    <div class="module-view-content">
      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'Bonificaciones'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Bonificaciones de Cementerios'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Estado
const pasoActual = ref(1)
const modoModificacion = ref(false)
const currentYear = new Date().getFullYear()
const selectedRow = ref(null)
const hasSearched = ref(false)

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
    showToast('warning', 'Complete correctamente los datos del oficio')
    return
  }

  showLoading('Procesando...', 'Buscando oficio de bonificación')
  hasSearched.value = true
  selectedRow.value = null
  try {
    // Usar SP: sp_bonificaciones_buscar_oficio
    // Base: cementerio.publico (según 18_SP_CEMENTERIOS_BONIFICACIONES_BUSQUEDA_all_procedures.sql)
    const response = await execute(
      'sp_bonificaciones_buscar_oficio',
      'cementerio',
      [
        { nombre: 'p_oficio', valor: datosOficio.value.oficio, tipo: 'integer' },
        { nombre: 'p_axo', valor: datosOficio.value.axo, tipo: 'integer' },
        { nombre: 'p_doble', valor: datosOficio.value.doble, tipo: 'string' }
      ],
      '',
      null,
      'publico'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT *
    FROM cementerio.publico.ta_13_bonifrcm
    WHERE oficio = [oficio]
      AND axo = [axo]
      AND doble = [doble]
    */

    if (response?.result?.length > 0) {
      // Bonificación existe - modo modificación
      const bonif = response.result[0]
      modoModificacion.value = true
      pasoActual.value = 3
      folioBuscar.value = bonif.control_rcm

      // Cargar datos del RCM
      datosRCM.value = {
        control_rcm: bonif.control_rcm,
        nombre: '', // Se cargará al buscar el folio
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

      // // Buscar nombre del propietario
      // const responseFolio = await execute(
      //   'SELECT',
      //   'padron_licencias',
      //   {
      //     table: 'ta_13_datosrcm',
      //     fields: ['nombre'],
      //     where: { control_rcm: bonif.control_rcm }
      //   },
      //   '',
      //   null,
      //   'publico'
      // )
      // if (responseFolio?.result?.length > 0) {
      //   datosRCM.value.nombre = responseFolio.result[0].nombre
      // }

      // Cargar datos de bonificación
      formBonificacion.value = {
        fecha_ofic: bonif.fecha_ofic ? new Date(bonif.fecha_ofic).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
        importe_bonificar: parseFloat(bonif.importe_bonificar) || 0,
        importe_bonificado: parseFloat(bonif.importe_bonificado) || 0,
        importe_resto: parseFloat(bonif.importe_resto) || 0
      }

      showToast('success', 'Bonificación encontrada - Modo modificación')
    } else {
      // No existe - modo alta
      modoModificacion.value = false
      pasoActual.value = 2
      showToast('success', 'Oficio no encontrado - Ingrese el folio a bonificar')
    }
  } catch (error) {
    console.error('Error al buscar oficio:', error)
    // Si no existe, pasar a paso 2 para crear nuevo
    modoModificacion.value = false
    pasoActual.value = 2
    showToast('success', 'Oficio nuevo - Ingrese el folio a bonificar')
  } finally {
    hideLoading()
  }
}

// Buscar folio
const buscarFolio = async () => {
  if (!folioBuscar.value) {
    showToast('warning', 'Ingrese un número de folio')
    return
  }

  showLoading('Procesando...', 'Buscando folio en el registro')
  hasSearched.value = true
  selectedRow.value = null
  try {
    // Usar SP: sp_bonificaciones_buscar_folio
    // Base: cementerio.publico (según 18_SP_CEMENTERIOS_BONIFICACIONES_BUSQUEDA_all_procedures.sql)
    const response = await execute(
      'sp_bonificaciones_buscar_folio',
      'cementerio',
      [
        { nombre: 'p_folio', valor: folioBuscar.value, tipo: 'integer' }
      ],
      '',
      null,
      'publico'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT *
    FROM padron_licencias.comun.ta_13_datosrcm
    WHERE control_rcm = [folioBuscar]
      AND vigencia = 'A'
    */

    if (response?.result?.length > 0) {
      const folio = response.result[0]

      if (folio.vigencia === 'B') {
        showToast('warning', 'Este folio está dado de baja')
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
      showToast('success', 'Folio encontrado')
    } else {
      showToast('error', 'Folio no encontrado')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar el folio')
  } finally {
    hideLoading()
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
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }

  showLoading('Procesando...', modoModificacion.value ? 'Modificando bonificación' : 'Registrando bonificación')
  hasSearched.value = true
  selectedRow.value = null
  try {
    // Usar SP existentes: sp_bonificaciones_create o sp_bonificaciones_update
    // Base: cementerio.publico (según postgreok.csv: ta_13_bonifrcm → cementerio.publico)
    // SP en: RefactorX/Base/cementerios/database/ok/04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql

    if (modoModificacion.value) {
      // Modificación usando sp_bonificaciones_update (Pascal línea 201-205)
      const response = await execute(
        'sp_bonificaciones_update',
        'cementerio',
        [
          { nombre: 'p_oficio', valor: datosOficio.value.oficio, tipo: 'integer' },
          { nombre: 'p_axo', valor: datosOficio.value.axo, tipo: 'integer' },
          { nombre: 'p_doble', valor: datosOficio.value.doble, tipo: 'string' },
          { nombre: 'p_fecha_ofic', valor: formBonificacion.value.fecha_ofic, tipo: 'string' },
          { nombre: 'p_importe_bonificar', valor: formBonificacion.value.importe_bonificar, tipo: 'numeric' },
          { nombre: 'p_importe_bonificado', valor: formBonificacion.value.importe_bonificado, tipo: 'numeric' },
          { nombre: 'p_importe_resto', valor: formBonificacion.value.importe_resto, tipo: 'numeric' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' } // TODO: Obtener del contexto de usuario
        ],
        '',
        null,
        'publico'
      )

      showToast('success', 'Bonificación modificada exitosamente')
      nuevoOficio()
    } else {
      // Alta usando sp_bonificaciones_create (Pascal línea 167-174)
      const response = await execute(
        'sp_bonificaciones_create',
        'cementerio',
        [
          { nombre: 'p_oficio', valor: datosOficio.value.oficio, tipo: 'integer' },
          { nombre: 'p_axo', valor: datosOficio.value.axo, tipo: 'integer' },
          { nombre: 'p_doble', valor: datosOficio.value.doble, tipo: 'string' },
          { nombre: 'p_control_rcm', valor: datosRCM.value.control_rcm, tipo: 'integer' },
          { nombre: 'p_cementerio', valor: datosRCM.value.cementerio, tipo: 'string' },
          { nombre: 'p_clase', valor: datosRCM.value.clase, tipo: 'integer' },
          { nombre: 'p_clase_alfa', valor: datosRCM.value.clase_alfa, tipo: 'string' },
          { nombre: 'p_seccion', valor: datosRCM.value.seccion, tipo: 'integer' },
          { nombre: 'p_seccion_alfa', valor: datosRCM.value.seccion_alfa, tipo: 'string' },
          { nombre: 'p_linea', valor: datosRCM.value.linea, tipo: 'integer' },
          { nombre: 'p_linea_alfa', valor: datosRCM.value.linea_alfa, tipo: 'string' },
          { nombre: 'p_fosa', valor: datosRCM.value.fosa, tipo: 'integer' },
          { nombre: 'p_fosa_alfa', valor: datosRCM.value.fosa_alfa, tipo: 'string' },
          { nombre: 'p_fecha_ofic', valor: formBonificacion.value.fecha_ofic, tipo: 'string' },
          { nombre: 'p_importe_bonificar', valor: formBonificacion.value.importe_bonificar, tipo: 'numeric' },
          { nombre: 'p_importe_bonificado', valor: formBonificacion.value.importe_bonificado, tipo: 'numeric' },
          { nombre: 'p_importe_resto', valor: formBonificacion.value.importe_resto, tipo: 'numeric' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' }, // TODO: Obtener del contexto de usuario
          { nombre: 'p_fecha_mov', valor: new Date().toISOString(), tipo: 'string' }
        ],
        '',
        null,
        'publico'
      )

      // Verificar si hay error (p_error OUT parameter)
      if (response?.result?.[0]?.p_error) {
        showToast('error', 'Error al guardar: ' + response.result[0].p_error)
        return
      }

      showToast('success', 'Bonificación registrada exitosamente')
      nuevoOficio()
    }
  } catch (error) {
    console.error('Error al guardar bonificación:', error)
    showToast('error', 'Error al guardar la bonificación')
  } finally {
    hideLoading()
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
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    await eliminarBonificacion()
  }
}

// Eliminar bonificación
const eliminarBonificacion = async () => {
  showLoading('Procesando...', 'Eliminando bonificación')
  hasSearched.value = true
  selectedRow.value = null
  try {
    // Usar SP existente: sp_bonificaciones_delete
    // Base: cementerio.publico (según postgreok.csv: ta_13_bonifrcm → cementerio.publico)
    // SP en: RefactorX/Base/cementerios/database/ok/04_SP_CEMENTERIOS_BONIFICACIONES_EXACTO_all_procedures.sql
    // Pascal original línea 230-231
    const response = await execute(
      'sp_bonificaciones_delete',
      'cementerio',
      [
        { nombre: 'p_oficio', valor: datosOficio.value.oficio, tipo: 'integer' },
        { nombre: 'p_axo', valor: datosOficio.value.axo, tipo: 'integer' },
        { nombre: 'p_doble', valor: datosOficio.value.doble, tipo: 'string' },
        { nombre: 'p_usuario', valor: 1, tipo: 'integer' } // TODO: Obtener del contexto de usuario
      ],
      '',
      null,
      'publico'
    )

    showToast('success', 'Bonificación eliminada exitosamente')
    nuevoOficio()
  } catch (error) {
    console.error('Error al eliminar bonificación:', error)
    showToast('error', 'Error al eliminar la bonificación')
  } finally {
    hideLoading()
  }
}

// Nuevo oficio (reiniciar)
const nuevoOficio = () => {
  pasoActual.value = 1
  modoModificacion.value = false
  hasSearched.value = false
  selectedRow.value = null
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
</script>
