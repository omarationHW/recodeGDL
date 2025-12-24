<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-excel" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Contratos</h1>
        <p>Aseo Contratado - Dar de baja contratos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <div class="input-group">
                <input type="number" v-model="numContratoBuscar" class="municipal-form-control"
                  placeholder="Ingrese número de contrato" @keyup.enter="buscarContrato" />
                <button class="btn-municipal-secondary" @click="buscarContrato" :disabled="loading" type="button">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Información del Contrato -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-header bg-warning">
          <h5 class="text-white">
            <font-awesome-icon icon="exclamation-triangle" /> Información del Contrato a Dar de Baja
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Advertencia:</strong> Esta operación marcará el contrato como "Baja". Verifique que no existan adeudos pendientes.
          </div>

          <h6 class="section-title"><font-awesome-icon icon="file-contract" /> Datos del Contrato</h6>
          <div class="detail-grid">
            <div class="detail-item">
              <label class="detail-label">Número de Contrato</label>
              <p class="detail-value"><strong>{{ contratoSeleccionado.num_contrato }}</strong></p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Empresa</label>
              <p class="detail-value">{{ contratoSeleccionado.nombre_empresa }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Representante</label>
              <p class="detail-value">{{ contratoSeleccionado.representante_empresa }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Tipo de Aseo</label>
              <p class="detail-value">{{ contratoSeleccionado.tipo_aseo_descripcion }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Unidades</label>
              <p class="detail-value">{{ contratoSeleccionado.cantidad_recoleccion }} - {{ contratoSeleccionado.unidad_recoleccion }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Status Actual</label>
              <p class="detail-value">
                <span :class="['badge', getStatusClass(contratoSeleccionado.status_contrato)]">
                  {{ getStatusLabel(contratoSeleccionado.status_contrato) }}
                </span>
              </p>
            </div>
          </div>

          <h6 class="section-title mt-4"><font-awesome-icon icon="map-marker-alt" /> Domicilio</h6>
          <div class="detail-grid">
            <div class="detail-item full-width">
              <label class="detail-label">Dirección Completa</label>
              <p class="detail-value">{{ getDomicilioCompleto(contratoSeleccionado) }}</p>
            </div>
          </div>

          <!-- Verificación de Adeudos -->
          <div v-if="adeudosPendientes !== null" class="mt-4">
            <div v-if="adeudosPendientes > 0" class="alert alert-danger">
              <font-awesome-icon icon="exclamation-circle" />
              <strong>Atención:</strong> Este contrato tiene <strong>{{ adeudosPendientes }} adeudos pendientes</strong>.
              Se recomienda resolver los adeudos antes de dar de baja el contrato.
            </div>
            <div v-else class="alert alert-success">
              <font-awesome-icon icon="check-circle" />
              Este contrato no tiene adeudos pendientes. Puede proceder con la baja.
            </div>
          </div>

          <!-- Formulario de Baja -->
          <div class="mt-4">
            <h6 class="section-title"><font-awesome-icon icon="edit" /> Motivo de Baja</h6>
            <div class="form-group">
              <label class="municipal-form-label required">Motivo de la Baja</label>
              <select v-model="motivoBaja" class="municipal-form-control" required>
                <option value="">Seleccione un motivo...</option>
                <option value="SOLICITUD_CLIENTE">Solicitud del Cliente</option>
                <option value="FALTA_PAGO">Falta de Pago</option>
                <option value="INCUMPLIMIENTO">Incumplimiento de Contrato</option>
                <option value="CIERRE_NEGOCIO">Cierre de Negocio</option>
                <option value="OTRO">Otro</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Observaciones</label>
              <textarea v-model="observaciones" class="municipal-form-control" rows="4"
                placeholder="Describa el motivo de la baja" required maxlength="500"></textarea>
              <small class="form-text">{{ observaciones.length }}/500 caracteres</small>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Fecha de Baja</label>
              <input type="date" v-model="fechaBaja" class="municipal-form-control" required :max="maxDate" />
            </div>
          </div>

          <!-- Botones de Acción -->
          <div class="button-group mt-4">
            <button class="btn-municipal-secondary" @click="confirmarBaja"
              :disabled="loading || !motivoBaja || !observaciones || !fechaBaja">
              <font-awesome-icon :icon="loading ? 'spinner' : 'ban'" :spin="loading" />
              {{ loading ? 'Procesando...' : 'Dar de Baja Contrato' }}
            </button>
            <button class="btn-municipal-secondary" @click="cancelar" :disabled="loading">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontró el contrato especificado</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Baja de Contratos">
      <h3>Baja de Contratos</h3>
      <p>Este módulo permite dar de baja contratos de aseo contratado.</p>

      <h4>Procedimiento:</h4>
      <ol>
        <li>Busque el contrato por su número</li>
        <li>Verifique la información del contrato</li>
        <li>Revise si hay adeudos pendientes</li>
        <li>Seleccione el motivo de la baja</li>
        <li>Ingrese observaciones detalladas</li>
        <li>Especifique la fecha de baja</li>
        <li>Confirme la operación</li>
      </ol>

      <h4>Motivos de Baja:</h4>
      <ul>
        <li><strong>Solicitud del Cliente:</strong> El cliente solicita dar de baja el servicio</li>
        <li><strong>Falta de Pago:</strong> Adeudos no pagados</li>
        <li><strong>Incumplimiento:</strong> Incumplimiento de los términos del contrato</li>
        <li><strong>Cierre de Negocio:</strong> El negocio cierra operaciones</li>
        <li><strong>Otro:</strong> Otro motivo (especificar en observaciones)</li>
      </ul>

      <h4>Consideraciones Importantes:</h4>
      <ul>
        <li>Verifique que no existan adeudos pendientes antes de dar de baja</li>
        <li>Si hay adeudos, se recomienda resolver primero o registrarlos como incobrables</li>
        <li>La baja es reversible mediante la modificación del status</li>
        <li>Se debe proporcionar un motivo claro y detallado</li>
        <li>La fecha de baja no debe ser futura</li>
      </ul>

      <h4>Efectos de la Baja:</h4>
      <ul>
        <li>El contrato cambia a status "Baja" (B)</li>
        <li>No se generarán nuevos adeudos automáticamente</li>
        <li>Los adeudos existentes permanecen activos</li>
        <li>El contrato permanece en el sistema para consultas históricas</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const numContratoBuscar = ref(null)
const contratoEncontrado = ref(false)
const busquedaRealizada = ref(false)
const contratoSeleccionado = ref(null)
const adeudosPendientes = ref(null)
const motivoBaja = ref('')
const observaciones = ref('')
const fechaBaja = ref('')

const maxDate = computed(() => {
  return new Date().toISOString().split('T')[0]
})

const buscarContrato = async () => {
  if (!numContratoBuscar.value) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  loading.value = true
  busquedaRealizada.value = true
  contratoEncontrado.value = false
  adeudosPendientes.value = null

  try {
    const response = await execute('sp16_contratos_buscar', 'aseo_contratado', {
      parContrato: numContratoBuscar.value,
      parTipo: 'T',
      parVigencia: 'T'
    })

    if (response && response.data && response.data.length > 0) {
      contratoSeleccionado.value = response.data[0]
      contratoEncontrado.value = true

      // Verificar si el contrato ya está dado de baja
      if (contratoSeleccionado.value.status_contrato === 'B') {
        showToast('Este contrato ya está dado de baja', 'warning')
      }

      // Verificar adeudos pendientes
      await verificarAdeudos()
    } else {
      showToast('Contrato no encontrado', 'warning')
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al buscar el contrato', 'error')
  } finally {
    loading.value = false
  }
}

const verificarAdeudos = async () => {
  try {
    const response = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_status_vigencia: 'D',
      p_fecha_hasta: null
    })

    if (response && response.data) {
      adeudosPendientes.value = response.data.length
    }
  } catch (error) {
    console.error('Error al verificar adeudos:', error)
    adeudosPendientes.value = 0
  }
}

const confirmarBaja = async () => {
  if (!motivoBaja.value || !observaciones.value || !fechaBaja.value) {
    showToast('Complete todos los campos requeridos', 'warning')
    return
  }

  let confirmText = `<p>Contrato: <strong>${contratoSeleccionado.value.num_contrato}</strong></p>
                     <p>Empresa: <strong>${contratoSeleccionado.value.nombre_empresa}</strong></p>
                     <p>Fecha de baja: <strong>${fechaBaja.value}</strong></p>`

  if (adeudosPendientes.value > 0) {
    confirmText += `<p class="text-danger"><strong>Atención:</strong> Existen ${adeudosPendientes.value} adeudos pendientes</p>`
  }

  const result = await Swal.fire({
    title: '¿Dar de Baja el Contrato?',
    html: confirmText,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545'
  })

  if (!result.isConfirmed) return

  loading.value = true

  try {
    // Nota: Este SP debe ser creado
    const response = await execute('SP_ASEO_CONTRATOS_BAJA', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_motivo: motivoBaja.value,
      p_observaciones: observaciones.value,
      p_fecha_baja: fechaBaja.value,
      p_usuario_id: 1
    })

    if (response && response.data && response.data[0]) {
      const result = response.data[0]

      if (result.success) {
        await Swal.fire({
          title: '¡Éxito!',
          text: 'El contrato ha sido dado de baja exitosamente',
          icon: 'success',
          confirmButtonText: 'Aceptar'
        })

        cancelar()
      } else {
        showToast(result.message || 'Error al dar de baja el contrato', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al dar de baja el contrato', 'error')
  } finally {
    loading.value = false
  }
}

const cancelar = () => {
  contratoEncontrado.value = false
  busquedaRealizada.value = false
  numContratoBuscar.value = null
  contratoSeleccionado.value = null
  adeudosPendientes.value = null
  motivoBaja.value = ''
  observaciones.value = ''
  fechaBaja.value = ''
}

const getDomicilioCompleto = (contrato) => {
  const partes = [
    contrato.calle,
    contrato.numext,
    contrato.numint,
    contrato.colonia,
    contrato.cp,
    contrato.municipio,
    contrato.estado
  ].filter(Boolean)

  return partes.join(', ')
}

const getStatusLabel = (status) => {
  const labels = {
    V: 'Vigente',
    N: 'Nuevo',
    B: 'Baja',
    C: 'Cancelado'
  }
  return labels[status] || status
}

const getStatusClass = (status) => {
  const classes = {
    V: 'badge-success',
    N: 'badge-info',
    B: 'badge-warning',
    C: 'badge-danger'
  }
  return classes[status] || 'badge-secondary'
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

