<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="dollar-sign" />
      </div>
      <div class="module-view-info">
        <h1>Registro de Pagos</h1>
        <p>Aseo Contratado - Registro y aplicación de pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato con Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <input type="number" v-model="numContrato" class="municipal-form-control"
                placeholder="Ingrese número de contrato" @keyup.enter="buscarAdeudos" />
            </div>
          </div>
          <button class="btn-municipal-primary" @click="buscarAdeudos" :disabled="loading">
            <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar Adeudos
          </button>
        </div>
      </div>

      <!-- Adeudos Pendientes -->
      <div v-if="adeudosPendientes.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Adeudos Pendientes</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>
                    <input type="checkbox" @change="seleccionarTodos" v-model="todosSeleccionados" />
                  </th>
                  <th>Periodo</th>
                  <th>Concepto</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-right">Recargo</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudosPendientes" :key="adeudo.periodo">
                  <td>
                    <input type="checkbox" v-model="adeudo.seleccionado" />
                  </td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ adeudo.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_adeudo) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_recargo) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="5" class="text-right"><strong>TOTAL A PAGAR:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalSeleccionado) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Formulario de Pago -->
      <div v-if="adeudosPendientes.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cash-register" /> Datos del Pago</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Importe a Pagar</label>
              <div class="input-group">
                <span class="input-group-text">$</span>
                <input type="number" v-model="formPago.importe" class="municipal-form-control"
                  :max="totalSeleccionado" step="0.01" min="0" required />
              </div>
              <small class="form-text">Máximo: {{ formatCurrency(totalSeleccionado) }}</small>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <select v-model="formPago.id_rec" class="municipal-form-control">
                <option value="1">Recaudadora Principal</option>
                <option value="2">Recaudadora 2</option>
                <option value="3">Recaudadora 3</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Caja</label>
              <input type="text" v-model="formPago.caja" class="municipal-form-control"
                placeholder="001" maxlength="10" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio de Recibo</label>
              <input type="number" v-model="formPago.folio" class="municipal-form-control"
                placeholder="Dejar vacío para auto-generar" />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="registrarPago"
              :disabled="loading || !formPago.importe || formPago.importe <= 0">
              <font-awesome-icon :icon="loading ? 'spinner' : 'check'" :spin="loading" />
              {{ loading ? 'Procesando...' : 'Registrar Pago' }}
            </button>
            <button class="btn-municipal-secondary" @click="cancelarPago" :disabled="loading">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Historial de Pagos -->
      <div v-if="historialPagos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="history" /> Pagos Registrados (Sesión Actual)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Contrato</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Saldo Pendiente</th>
                  <th>Fecha</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in historialPagos" :key="pago.folio">
                  <td><strong>{{ pago.folio }}</strong></td>
                  <td>{{ pago.num_contrato }}</td>
                  <td class="text-right">{{ formatCurrency(pago.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(pago.saldo_pendiente) }}</td>
                  <td>{{ formatDateTime(pago.fecha) }}</td>
                  <td>
                    <span :class="['badge', pago.success ? 'badge-success' : 'badge-danger']">
                      {{ pago.success ? 'Aplicado' : 'Error' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Registro de Pagos">
      <h3>Registro de Pagos</h3>
      <p>Este módulo permite registrar pagos de adeudos y aplicarlos a los periodos correspondientes.</p>
      <h4>Procedimiento:</h4>
      <ol>
        <li>Busque el contrato por número</li>
        <li>Revise los adeudos pendientes</li>
        <li>Seleccione los periodos a pagar (checkbox)</li>
        <li>Ingrese el importe del pago</li>
        <li>Complete los datos adicionales (recaudadora, caja, folio)</li>
        <li>Registre el pago</li>
      </ol>
      <h4>Notas:</h4>
      <ul>
        <li>El importe no puede exceder el total de adeudos seleccionados</li>
        <li>Si no se proporciona folio, se genera automáticamente</li>
        <li>El pago se aplica primero a los periodos más antiguos</li>
        <li>El saldo pendiente se actualiza automáticamente</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Adeudos_Pag'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showDocumentation = ref(false)
const numContrato = ref(null)
const adeudosPendientes = ref([])
const todosSeleccionados = ref(false)
const historialPagos = ref([])

const formPago = ref({
  importe: null,
  id_rec: 1,
  caja: '001',
  folio: null
})

const totalSeleccionado = computed(() => {
  return adeudosPendientes.value
    .filter(a => a.seleccionado)
    .reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const buscarAdeudos = async () => {
  if (!numContrato.value) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  showLoading()
  try {
    // Primero buscar el contrato (Delphi líneas 174-186)
    const contrato = await execute('sp_aseo_contratos_buscar', 'aseo_contratado', {
      p_num_contrato: numContrato.value,
      p_num_empresa: null,
      p_nombre_empresa: null,
      p_ctrol_aseo: null
    })

    if (!contrato || !contrato || contrato.length === 0) {
      showToast('Contrato no encontrado', 'warning')
      return
    }

    const contratoData = contrato.data[0]

    // Buscar CUOTA NORMAL (operación 6) y EXEDENCIAS (operación 7) por separado
    // como hace Delphi en líneas 189-221
    const [respCN, respExe] = await Promise.all([
      // Cuota Normal (Ctrol_operacion = 6)
      execute('sp_aseo_adeudos_por_tipo', 'aseo_contratado', {
        p_control_contrato: contratoData.control_contrato,
        p_ctrol_operacion: 6, // Cuota Normal
        p_status_vigencia: 'V' // Solo vigentes
      }),
      // Exedencias (Ctrol_operacion = 7)
      execute('sp_aseo_adeudos_por_tipo', 'aseo_contratado', {
        p_control_contrato: contratoData.control_contrato,
        p_ctrol_operacion: 7, // Exedencias
        p_status_vigencia: 'V'
      })
    ])

    adeudosPendientes.value = []

    // Procesar cuota normal
    if (respCN && respCN.length > 0) {
      adeudosPendientes.value.push(...respCN.map(a => ({
        ...a,
        seleccionado: false,
        tipo_operacion: 'CN', // Cuota Normal
        editable: true // Permitir editar importe como en Delphi
      })))
    }

    // Procesar exedencias
    if (respExe && respExe.length > 0) {
      adeudosPendientes.value.push(...respExe.map(a => ({
        ...a,
        seleccionado: false,
        tipo_operacion: 'EXE', // Exedencias
        editable: true
      })))
    }

    if (adeudosPendientes.value.length === 0) {
      showToast('No hay adeudos pendientes para este contrato', 'info')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al buscar adeudos', 'error')
  } finally {
    hideLoading()
  }
}

const seleccionarTodos = () => {
  adeudosPendientes.value.forEach(a => a.seleccionado = todosSeleccionados.value)
}

const registrarPago = async () => {
  if (!formPago.value.importe || formPago.value.importe <= 0) {
    showToast('Ingrese un importe válido', 'warning')
    return
  }

  if (formPago.value.importe > totalSeleccionado.value) {
    showToast('El importe excede el total de adeudos seleccionados', 'warning')
    return
  }

  const adeudosSeleccionados = adeudosPendientes.value.filter(a => a.seleccionado)
  if (adeudosSeleccionados.length === 0) {
    showToast('Seleccione al menos un periodo para pagar', 'warning')
    return
  }

  const result = await Swal.fire({
    title: '¿Registrar Pago?',
    html: `<p>Importe: <strong>${formatCurrency(formPago.value.importe)}</strong></p>
           <p>Total adeudo: <strong>${formatCurrency(totalSeleccionado.value)}</strong></p>
           <p>Periodos seleccionados: <strong>${adeudosSeleccionados.length}</strong></p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, registrar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading()
  try {
    // Registrar pago para cada periodo seleccionado
    // Delphi procesa CN y EXE por separado (líneas 426-494)
    const pagosExitosos = []
    const pagosError = []

    for (const adeudo of adeudosSeleccionados) {
      try {
        // Formato de fecha como en Delphi línea 438: 'yyyy-mm-dd hh:nn'
        const fechaHoy = new Date()
        const fechaPagoStr = fechaHoy.toISOString().slice(0, 16).replace('T', ' ')

        const response = await execute('sp_aseo_actualizar_pago', 'aseo_contratado', {
          p_control_contrato: adeudo.control_contrato,
          p_aso_mes_pago: adeudo.aso_mes_pago,
          p_ctrol_operacion: adeudo.ctrol_operacion,
          p_importe: adeudo.importe_editable || adeudo.importe, // Permitir edición como Delphi línea 430
          p_status_vigencia: 'P', // Pagado
          p_fecha_hora_pago: fechaPagoStr,
          p_id_rec: formPago.value.id_rec,
          p_caja: formPago.value.caja || '01',
          p_consec_operacion: formPago.value.consecutivo || 0,
          p_folio_rcbo: formPago.value.folio || '0', // Delphi usa '0' si está vacío
          p_usuario: 1
        })

        if (response?.[0]?.success) {
          pagosExitosos.push({
            periodo: adeudo.periodo,
            folio: response[0].folio_pago || formPago.value.folio
          })
        } else {
          pagosError.push({ periodo: adeudo.periodo, error: response?.[0]?.message || 'Error desconocido' })
        }
      } catch (err) {
        hideLoading()
        pagosError.push({ periodo: adeudo.periodo, error: err.message })
      }
    }

    // Actualizar historial
    if (pagosExitosos.length > 0) {
      historialPagos.value.unshift({
        folio: pagosExitosos[0].folio,
        num_contrato: numContrato.value,
        importe: formPago.value.importe,
        periodos_pagados: pagosExitosos.length,
        fecha: new Date(),
        success: true
      })

      showToast(`Pago registrado: ${pagosExitosos.length} periodo(s) pagado(s)`, 'success')
      cancelarPago()
      buscarAdeudos() // Recargar adeudos
    }

    if (pagosError.length > 0) {
      showToast(`Advertencia: ${pagosError.length} periodo(s) no se pudo(ieron) procesar`, 'warning')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    showToast('Error al registrar el pago', 'error')
  } finally {
    hideLoading()
  }
}

const cancelarPago = () => {
  formPago.value = {
    importe: null,
    id_rec: 1,
    caja: '001',
    folio: null
  }
  todosSeleccionados.value = false
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatDateTime = (date) => {
  return new Date(date).toLocaleString('es-MX')
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>
