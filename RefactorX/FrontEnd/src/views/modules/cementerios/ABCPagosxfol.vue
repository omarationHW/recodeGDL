<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-check-alt" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Pagos por Folio</h1>
        <p>Cementerios - ABC de Pagos Individual</p>
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

    <div class="module-view-content">
      <!-- Sección 1: Datos de Pago (Fecha, Recibo, Caja, Operación) -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" />
            Datos del Pago
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Fecha de Pago</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="datosPago.fecha"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Recibo</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="datosPago.recibo"
                placeholder="Número de recibo..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Caja</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="datosPago.caja"
                placeholder="Caja..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Operación</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="datosPago.operacion"
                placeholder="Número de operación..."
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="verificarPago"
            >
              <font-awesome-icon icon="search" />
              Verificar Pago
            </button>
          </div>
        </div>
      </div>

      <!-- Sección 2: Buscar Folio (solo visible si no existe el pago) -->
      <div class="municipal-card" v-if="mostrarBusquedaFolio">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Folio</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="folioABuscar"
                @keyup.enter="buscarFolio"
                :disabled="folioEncontrado"
                placeholder="Ingrese el folio..."
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarFolio"
              :disabled="folioEncontrado"
            >
              <font-awesome-icon icon="search" />
              Buscar Folio
            </button>
          </div>

          <!-- Info del folio encontrado -->
          <div v-if="folioEncontrado" class="info-section">
            <h6>Información del Folio</h6>
            <div class="info-grid">
              <div class="info-item">
                <span class="label">Titular:</span>
                <span class="value">{{ datosFolio.nombre }}</span>
              </div>
              <div class="info-item">
                <span class="label">Cementerio:</span>
                <span class="value">{{ datosFolio.nombre_cementerio }}</span>
              </div>
              <div class="info-item">
                <span class="label">Ubicación:</span>
                <span class="value">{{ formatearUbicacion(datosFolio) }}</span>
              </div>
              <div class="info-item">
                <span class="label">Último Año Pagado:</span>
                <span class="value">{{ datosFolio.axo_pagado }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sección 3: Formulario de Alta/Modificación (solo visible si hay folio) -->
      <div class="municipal-card" v-if="folioEncontrado">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            {{ pagoExistente ? 'Modificar Pago' : 'Registrar Pago' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Año Desde</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formPago.axo_desde"
                :min="2000"
                placeholder="Año desde..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Año Hasta</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formPago.axo_hasta"
                :min="2000"
                placeholder="Año hasta..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Importe Mantenimiento</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formPago.importe_anual"
                step="0.01"
                min="0"
                placeholder="0.00"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Importe Recargos</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formPago.importe_recargos"
                step="0.01"
                min="0"
                placeholder="0.00"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="guardarPago"
            >
              <font-awesome-icon icon="save" />
              {{ pagoExistente ? 'Modificar' : 'Registrar' }}
            </button>
            <button
              v-if="pagoExistente"
              class="btn-municipal-danger"
              @click="confirmarEliminarPago"
            >
              <font-awesome-icon icon="trash" />
              Eliminar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFormulario"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>
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

      <!-- Modal de Ayuda/Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ABCPagosxfol'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Gestión de Pagos por Folio'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de Toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => {
    hideToast()
  }, 4000)
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
const selectedRow = ref(null)
const hasSearched = ref(false)
const mostrarBusquedaFolio = ref(false)
const folioEncontrado = ref(false)
const pagoExistente = ref(false)
const folioABuscar = ref(null)

const datosPago = reactive({
  fecha: new Date().toISOString().split('T')[0],
  recibo: 0,
  caja: '',
  operacion: 0
})

const datosFolio = ref({})
const pagoActual = ref({})

const formPago = reactive({
  axo_desde: new Date().getFullYear(),
  axo_hasta: new Date().getFullYear(),
  importe_anual: 0,
  importe_recargos: 0
})

// Métodos
const verificarPago = async () => {
  if (!datosPago.fecha || !datosPago.recibo || !datosPago.caja || !datosPago.operacion) {
    showToast('warning', 'Complete todos los datos del pago')
    return
  }

  showLoading('Verificando pago...', 'Consultando datos del pago')
  hasSearched.value = true
  selectedRow.value = null

  try {
    /* TODO FUTURO: Query SQL original (ABCPagosxfol.pas DFM):
    -- SQL: 'select * from ta_13_pagosrcm where fecing=:fecha and recing=:rec
    --       and cajing=:caja and opcaja=:operac'
    */

    const response = await execute(
      'sp_pagosxfol_verificar_pago',
      'cementerio',
      [
        { nombre: 'p_fecha', valor: datosPago.fecha, tipo: 'date' },
        { nombre: 'p_recibo', valor: datosPago.recibo, tipo: 'smallint' },
        { nombre: 'p_caja', valor: datosPago.caja, tipo: 'varchar' },
        { nombre: 'p_operacion', valor: datosPago.operacion, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    if (response?.result?.length > 0) {
      // Pago existe - modo modificación
      pagoExistente.value = true
      pagoActual.value = response.result[0]
      folioABuscar.value = pagoActual.value.control_rcm

      // Buscar datos del folio
      await buscarFolio()

      // Cargar datos del pago existente
      formPago.axo_desde = pagoActual.value.axo_pago_desde
      formPago.axo_hasta = pagoActual.value.axo_pago_hasta
      formPago.importe_anual = parseFloat(pagoActual.value.importe_anual || 0)
      formPago.importe_recargos = parseFloat(pagoActual.value.importe_recargos || 0)

      showToast('info', 'Pago encontrado - Modo modificación')
    } else {
      // Pago no existe - modo alta
      pagoExistente.value = false
      mostrarBusquedaFolio.value = true
      showToast('info', 'No existe un pago con estos datos. Busque el folio para registrarlo.')
    }
  } catch (error) {
    console.error('Error al verificar pago:', error)
    showToast('error', 'Error al verificar pago: ' + error.message)
  } finally {
    hideLoading()
  }
}

const buscarFolio = async () => {
  if (!folioABuscar.value) {
    showToast('warning', 'Ingrese un número de folio')
    return
  }

  showLoading('Buscando folio...', 'Consultando información del folio')
  hasSearched.value = true
  selectedRow.value = null

  try {
    /* TODO FUTURO: Query SQL original (ABCPagosxfol.pas DFM):
    -- SQL: 'select a.*,b.* from ta_13_datosrcm a, tc_13_cementerios b
    --       where control_rcm=:control and a.cementerio=b.cementerio'
    */

    const response = await execute(
      'sp_pagosxfol_buscar_folio',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    if (response?.result?.length > 0) {
      datosFolio.value = response.result[0]
      folioEncontrado.value = true

      // Inicializar años con el año actual
      const anioActual = new Date().getFullYear()
      formPago.axo_desde = anioActual
      formPago.axo_hasta = anioActual

      showToast('success', 'Folio encontrado')
    } else {
      showToast('error', 'No se encontró el folio especificado')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar folio: ' + error.message)
  } finally {
    hideLoading()
  }
}

const guardarPago = async () => {
  // Validaciones
  if (formPago.axo_desde === 0) {
    showToast('warning', 'El año desde es obligatorio')
    return
  }
  if (formPago.axo_hasta === 0) {
    showToast('warning', 'El año hasta es obligatorio')
    return
  }
  if (formPago.importe_anual === 0) {
    showToast('warning', 'El importe de mantenimiento es obligatorio')
    return
  }
  if (formPago.axo_desde > formPago.axo_hasta) {
    showToast('warning', 'El año desde no puede ser mayor que el año hasta')
    return
  }

  showLoading('Guardando pago...', pagoExistente.value ? 'Actualizando registro' : 'Registrando nuevo pago')
  selectedRow.value = null

  try {
    let response

    if (pagoExistente.value) {
      // Modificar pago existente
      /* TODO FUTURO: Query SQL original (ABCPagosxfol.pas línea 212-216):
      -- UPDATE ta_13_pagosrcm SET axo_pago_desde=:desde, axo_pago_hasta=:hasta,
      --   importe_anual=:importeman, importe_recargos=:importerec,
      --   usuario=:user, fecha_mov=today WHERE control_id=:id
      */

      response = await execute(
        'sp_pagosxfol_modificar',
        'cementerio',
        [
          { nombre: 'p_control_id', valor: pagoActual.value.control_id, tipo: 'integer' },
          { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
          { nombre: 'p_axo_desde', valor: formPago.axo_desde, tipo: 'integer' },
          { nombre: 'p_axo_hasta', valor: formPago.axo_hasta, tipo: 'integer' },
          { nombre: 'p_importe_anual', valor: formPago.importe_anual, tipo: 'numeric' },
          { nombre: 'p_importe_recargos', valor: formPago.importe_recargos, tipo: 'numeric' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
        ],
        'function',
        null,
        'publico'
      )
    } else {
      // Registrar nuevo pago
      /* TODO FUTURO: Query SQL original (ABCPagosxfol.pas línea 178-186):
      -- INSERT INTO ta_13_pagosrcm VALUES(fecha, recibo, caja, operacion, 0, control_rcm,
      --   cementerio, clase, clase_alfa, seccion, seccion_alfa, linea, linea_alfa,
      --   fosa, fosa_alfa, axo_desde, axo_hasta, importe_anual, importe_recargos, 'A', usuario, today)
      */

      response = await execute(
        'sp_pagosxfol_registrar',
        'cementerio',
        [
          { nombre: 'p_fecha', valor: datosPago.fecha, tipo: 'date' },
          { nombre: 'p_recibo', valor: datosPago.recibo, tipo: 'smallint' },
          { nombre: 'p_caja', valor: datosPago.caja, tipo: 'varchar' },
          { nombre: 'p_operacion', valor: datosPago.operacion, tipo: 'integer' },
          { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
          { nombre: 'p_cementerio', valor: datosFolio.value.cementerio, tipo: 'varchar' },
          { nombre: 'p_clase', valor: datosFolio.value.clase, tipo: 'smallint' },
          { nombre: 'p_clase_alfa', valor: datosFolio.value.clase_alfa || '', tipo: 'varchar' },
          { nombre: 'p_seccion', valor: datosFolio.value.seccion, tipo: 'smallint' },
          { nombre: 'p_seccion_alfa', valor: datosFolio.value.seccion_alfa || '', tipo: 'varchar' },
          { nombre: 'p_linea', valor: datosFolio.value.linea, tipo: 'smallint' },
          { nombre: 'p_linea_alfa', valor: datosFolio.value.linea_alfa || '', tipo: 'varchar' },
          { nombre: 'p_fosa', valor: datosFolio.value.fosa, tipo: 'smallint' },
          { nombre: 'p_fosa_alfa', valor: datosFolio.value.fosa_alfa || '', tipo: 'varchar' },
          { nombre: 'p_axo_desde', valor: formPago.axo_desde, tipo: 'integer' },
          { nombre: 'p_axo_hasta', valor: formPago.axo_hasta, tipo: 'integer' },
          { nombre: 'p_importe_anual', valor: formPago.importe_anual, tipo: 'numeric' },
          { nombre: 'p_importe_recargos', valor: formPago.importe_recargos, tipo: 'numeric' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
        ],
        'function',
        null,
        'publico'
      )
    }

    if (response && response.length > 0 && response[0].resultado === 'S') {
      showToast('success', response[0].mensaje)
      limpiarFormulario()
    } else {
      showToast('error', response[0]?.mensaje || 'Error al guardar pago')
    }
  } catch (error) {
    console.error('Error al guardar pago:', error)
    showToast('error', 'Error al guardar pago: ' + error.message)
  } finally {
    hideLoading()
  }
}

const confirmarEliminarPago = async () => {
  const result = await Swal.fire({
    title: '¿Eliminar pago?',
    text: '¿Está seguro de eliminar este pago? Esta acción no se puede deshacer.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    await eliminarPago()
  }
}

const eliminarPago = async () => {
  showLoading('Eliminando pago...', 'Procesando solicitud')
  selectedRow.value = null

  try {
    /* TODO FUTURO: Query SQL original (ABCPagosxfol.pas línea 241-242):
    -- DELETE FROM ta_13_pagosrcm WHERE control_id=:id
    */

    const response = await execute(
      'sp_pagosxfol_eliminar',
      'cementerio',
      [
        { nombre: 'p_control_id', valor: pagoActual.value.control_id, tipo: 'integer' },
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    if (response && response.length > 0 && response[0].resultado === 'S') {
      showToast('success', response[0].mensaje)
      limpiarFormulario()
    } else {
      showToast('error', response[0]?.mensaje || 'Error al eliminar pago')
    }
  } catch (error) {
    console.error('Error al eliminar pago:', error)
    showToast('error', 'Error al eliminar pago: ' + error.message)
  } finally {
    hideLoading()
  }
}

const limpiarFormulario = () => {
  folioABuscar.value = null
  datosFolio.value = {}
  pagoActual.value = {}
  folioEncontrado.value = false
  pagoExistente.value = false
  mostrarBusquedaFolio.value = false
  hasSearched.value = false
  selectedRow.value = null

  formPago.axo_desde = new Date().getFullYear()
  formPago.axo_hasta = new Date().getFullYear()
  formPago.importe_anual = 0
  formPago.importe_recargos = 0
}

const formatearUbicacion = (folio) => {
  if (!folio) return ''
  const partes = []
  partes.push(`Cl:${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec:${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin:${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa:${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' ')
}
</script>
