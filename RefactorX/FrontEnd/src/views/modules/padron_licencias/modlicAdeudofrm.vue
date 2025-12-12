<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" >
      <div class="module-view-icon">
        <font-awesome-icon icon="calculator" />
      </div>
      <div class="module-view-info">
        <h1>Modificación de Adeudos</h1>
        <p>Padrón de Licencias - Cálculo y Ajuste de Saldos de Licencias</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de Licencia -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar Licencia
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.id_licencia"
              placeholder="Ingrese ID de licencia"
              @keyup.enter="searchLicencia"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencia"
            :disabled="loading || !searchForm.id_licencia"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearSearch"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información de Licencia -->
    <div class="municipal-card" v-if="licenciaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-invoice-dollar" />
          Información de Licencia: {{ licenciaData.licencia || 'N/A' }}
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Datos Generales
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Licencia:</td>
                <td><strong>{{ licenciaData.id_licencia }}</strong></td>
              </tr>
              <tr>
                <td class="label">Número Licencia:</td>
                <td><code>{{ licenciaData.licencia || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ licenciaData.propietario || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Detalle de Adeudos -->
    <div class="municipal-card" v-if="licenciaData">
      <div class="municipal-card-header header-with-actions">
        <h5>
          <font-awesome-icon icon="list-alt" />
          Detalle de Adeudos
          <span class="badge-purple" v-if="adeudos.length > 0">{{ adeudos.length }} registros</span>
        </h5>
        <div class="header-actions">
          <button
            class="btn-municipal-success btn-sm"
            @click="abrirModalNuevoAdeudo"
            :disabled="loading"
          >
            <font-awesome-icon icon="plus" />
            Agregar
          </button>
          <button
            class="btn-municipal-primary btn-sm"
            @click="recalcularSaldos"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Recalcular
          </button>
        </div>
      </div>
      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Concepto</th>
                <th>Forma</th>
                <th>Derechos</th>
                <th>Derechos 2</th>
                <th>Recargos</th>
                <th>Desc. Derechos</th>
                <th>Desc. Recargos</th>
                <th>Total</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(adeudo, index) in adeudos" :key="index" class="clickable-row">
                <td>{{ adeudo.concepto || 'Concepto General' }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.forma) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.derechos) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.derechos2) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.desc_derechos) }}</td>
                <td class="text-end">${{ formatCurrency(adeudo.desc_recargos) }}</td>
                <td class="text-end">
                  <strong>${{ formatCurrency(calcularTotal(adeudo)) }}</strong>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-warning btn-sm"
                      @click="abrirModalEditarAdeudo(adeudo, index)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmarEliminarAdeudo(adeudo, index)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="adeudos.length === 0 && !loading">
                <td colspan="9" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No se encontraron adeudos para esta licencia</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Saldos Consolidados -->
    <div class="municipal-card" v-if="saldosData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="calculator" />
          Saldos Consolidados
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="saldos-grid">
          <div class="saldo-item">
            <label>Derechos:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.derechos) }}</span>
          </div>
          <div class="saldo-item">
            <label>Anuncios:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.anuncios) }}</span>
          </div>
          <div class="saldo-item">
            <label>Recargos:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.recargos) }}</span>
          </div>
          <div class="saldo-item">
            <label>Gastos:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.gastos) }}</span>
          </div>
          <div class="saldo-item">
            <label>Multas:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.multas) }}</span>
          </div>
          <div class="saldo-item">
            <label>Formas:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.formas) }}</span>
          </div>
          <div class="saldo-item saldo-total">
            <label>Total:</label>
            <span class="saldo-value">${{ formatCurrency(saldosData.total) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando información...</p>
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

    <!-- Modal de Adeudo (Agregar/Editar) -->
    <Modal
      :show="showAdeudoModal"
      :title="modoEdicion ? 'Editar Adeudo' : 'Agregar Adeudo'"
      size="lg"
      @close="cerrarModalAdeudo"
      :showDefaultFooter="false"
    >
      <div class="adeudo-form">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Concepto: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="adeudoForm.concepto"
              placeholder="Descripción del concepto"
            >
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Forma:</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="adeudoForm.forma"
              placeholder="0.00"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Derechos:</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="adeudoForm.derechos"
              placeholder="0.00"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Derechos 2:</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="adeudoForm.derechos2"
              placeholder="0.00"
            >
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Recargos:</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="adeudoForm.recargos"
              placeholder="0.00"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Desc. Derechos:</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="adeudoForm.desc_derechos"
              placeholder="0.00"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Desc. Recargos:</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="adeudoForm.desc_recargos"
              placeholder="0.00"
            >
          </div>
        </div>

        <div class="form-row total-preview">
          <div class="form-group">
            <label class="municipal-form-label">Total Calculado:</label>
            <div class="total-value">
              ${{ formatCurrency(calcularTotalForm()) }}
            </div>
          </div>
        </div>

        <div class="modal-actions">
          <button
            class="btn-municipal-primary"
            @click="guardarAdeudo"
            :disabled="!adeudoForm.concepto || guardandoAdeudo"
          >
            <font-awesome-icon :icon="guardandoAdeudo ? 'spinner' : 'save'" :spin="guardandoAdeudo" />
            {{ guardandoAdeudo ? 'Guardando...' : 'Guardar' }}
          </button>
          <button
            class="btn-municipal-secondary"
            @click="cerrarModalAdeudo"
            :disabled="guardandoAdeudo"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>
      </div>
    </Modal>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'modlicAdeudofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

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
const searchForm = ref({
  id_licencia: null
})

const licenciaData = ref(null)
const adeudos = ref([])
const saldosData = ref(null)

// Estado para CRUD de adeudos
const showAdeudoModal = ref(false)
const modoEdicion = ref(false)
const adeudoEditIndex = ref(null)
const guardandoAdeudo = ref(false)
const adeudoForm = ref({
  id: null,
  concepto: '',
  forma: 0,
  derechos: 0,
  derechos2: 0,
  recargos: 0,
  desc_derechos: 0,
  desc_recargos: 0
})

// Métodos
const searchLicencia = async () => {
  if (!searchForm.value.id_licencia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el ID de la licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando licencia...')

  try {
    // Buscar información de licencia
    const responseLic = await execute(
      'SP_GET_LICENCIA_BY_ID',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchForm.value.id_licencia, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (responseLic && responseLic.result && responseLic.result.length > 0) {
      licenciaData.value = responseLic.result[0]
      await loadAdeudos()
      await loadSaldos()
      showToast('success', 'Licencia encontrada correctamente')
    } else {
      licenciaData.value = null
      adeudos.value = []
      saldosData.value = null
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No se encontró la licencia especificada',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    licenciaData.value = null
    adeudos.value = []
    saldosData.value = null
  } finally {
    setLoading(false)
  }
}

const loadAdeudos = async () => {
  try {
    const response = await execute(
      'SP_GET_DETSAL_LIC',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchForm.value.id_licencia, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      adeudos.value = response.result
    } else {
      adeudos.value = []
    }
  } catch (error) {
    adeudos.value = []
  }
}

const loadSaldos = async () => {
  try {
    const response = await execute(
      'SP_GET_SALDOS_LIC',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchForm.value.id_licencia, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      saldosData.value = response.result[0]
    } else {
      saldosData.value = null
    }
  } catch (error) {
    saldosData.value = null
  }
}

const recalcularSaldos = async () => {
  const result = await Swal.fire({
    title: 'Recalcular Saldos',
    text: '¿Está seguro de recalcular los saldos de esta licencia?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, recalcular',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    setLoading(true, 'Recalculando saldos...')

    try {
      const response = await execute(
        'calc_sdoslsr',
        'padron_licencias',
        [
          { nombre: 'p_id_licencia', valor: searchForm.value.id_licencia, tipo: 'integer' }
        ],
        'guadalajara',
      null,
      'publico'
      )

      await loadSaldos()

      await Swal.fire({
        icon: 'success',
        title: 'Saldos Recalculados',
        text: 'Los saldos han sido recalculados correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Saldos recalculados exitosamente')
    } catch (error) {
      handleApiError(error)
      await Swal.fire({
        icon: 'error',
        title: 'Error al recalcular',
        text: 'No se pudieron recalcular los saldos',
        confirmButtonColor: '#ea8215'
      })
    } finally {
      setLoading(false)
    }
  }
}

const clearSearch = () => {
  searchForm.value = {
    id_licencia: null
  }
  licenciaData.value = null
  adeudos.value = []
  saldosData.value = null
  showToast('info', 'Búsqueda limpiada')
}

// Utilidades
const formatCurrency = (value) => {
  if (value === null || value === undefined) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')
}

const calcularTotal = (adeudo) => {
  const forma = parseFloat(adeudo.forma || 0)
  const derechos = parseFloat(adeudo.derechos || 0)
  const derechos2 = parseFloat(adeudo.derechos2 || 0)
  const recargos = parseFloat(adeudo.recargos || 0)
  const descDerechos = parseFloat(adeudo.desc_derechos || 0)
  const descRecargos = parseFloat(adeudo.desc_recargos || 0)

  return forma + derechos + derechos2 + recargos - descDerechos - descRecargos
}

const calcularTotalForm = () => {
  return calcularTotal(adeudoForm.value)
}

// Funciones CRUD de adeudos
const resetAdeudoForm = () => {
  adeudoForm.value = {
    id: null,
    concepto: '',
    forma: 0,
    derechos: 0,
    derechos2: 0,
    recargos: 0,
    desc_derechos: 0,
    desc_recargos: 0
  }
}

const abrirModalNuevoAdeudo = () => {
  resetAdeudoForm()
  modoEdicion.value = false
  adeudoEditIndex.value = null
  showAdeudoModal.value = true
}

const abrirModalEditarAdeudo = (adeudo, index) => {
  adeudoForm.value = {
    id: adeudo.id || null,
    concepto: adeudo.concepto || '',
    forma: parseFloat(adeudo.forma || 0),
    derechos: parseFloat(adeudo.derechos || 0),
    derechos2: parseFloat(adeudo.derechos2 || 0),
    recargos: parseFloat(adeudo.recargos || 0),
    desc_derechos: parseFloat(adeudo.desc_derechos || 0),
    desc_recargos: parseFloat(adeudo.desc_recargos || 0)
  }
  modoEdicion.value = true
  adeudoEditIndex.value = index
  showAdeudoModal.value = true
}

const cerrarModalAdeudo = () => {
  showAdeudoModal.value = false
  resetAdeudoForm()
}

const guardarAdeudo = async () => {
  if (!adeudoForm.value.concepto.trim()) {
    showToast('warning', 'El concepto es requerido')
    return
  }

  guardandoAdeudo.value = true

  try {
    const spName = modoEdicion.value
      ? 'modlicAdeudofrm_sp_update_adeudo'
      : 'modlicAdeudofrm_sp_insert_adeudo'

    const params = [
      { nombre: 'p_id_licencia', valor: searchForm.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_concepto', valor: adeudoForm.value.concepto.trim(), tipo: 'string' },
      { nombre: 'p_forma', valor: adeudoForm.value.forma || 0, tipo: 'decimal' },
      { nombre: 'p_derechos', valor: adeudoForm.value.derechos || 0, tipo: 'decimal' },
      { nombre: 'p_derechos2', valor: adeudoForm.value.derechos2 || 0, tipo: 'decimal' },
      { nombre: 'p_recargos', valor: adeudoForm.value.recargos || 0, tipo: 'decimal' },
      { nombre: 'p_desc_derechos', valor: adeudoForm.value.desc_derechos || 0, tipo: 'decimal' },
      { nombre: 'p_desc_recargos', valor: adeudoForm.value.desc_recargos || 0, tipo: 'decimal' }
    ]

    if (modoEdicion.value && adeudoForm.value.id) {
      params.unshift({ nombre: 'p_id_adeudo', valor: adeudoForm.value.id, tipo: 'integer' })
    }

    const response = await execute(
      spName,
      'padron_licencias',
      params,
      'guadalajara',
      null,
      'publico'
    )

    if (response) {
      await Swal.fire({
        icon: 'success',
        title: modoEdicion.value ? 'Adeudo Actualizado' : 'Adeudo Agregado',
        text: modoEdicion.value
          ? 'El adeudo ha sido actualizado correctamente'
          : 'El adeudo ha sido agregado correctamente',
        confirmButtonColor: '#28a745',
        timer: 2000
      })

      showToast('success', modoEdicion.value ? 'Adeudo actualizado' : 'Adeudo agregado')
      cerrarModalAdeudo()
      await loadAdeudos()
      await loadSaldos()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    guardandoAdeudo.value = false
  }
}

const confirmarEliminarAdeudo = async (adeudo, index) => {
  const result = await Swal.fire({
    title: '¿Eliminar Adeudo?',
    html: `
      <p>Está a punto de eliminar el adeudo:</p>
      <p><strong>${adeudo.concepto || 'Sin concepto'}</strong></p>
      <p>Por un total de: <strong>$${formatCurrency(calcularTotal(adeudo))}</strong></p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await eliminarAdeudo(adeudo, index)
  }
}

const eliminarAdeudo = async (adeudo, index) => {
  setLoading(true, 'Eliminando adeudo...')

  try {
    const response = await execute(
      'modlicAdeudofrm_sp_delete_adeudo',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchForm.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_id_adeudo', valor: adeudo.id, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response) {
      await Swal.fire({
        icon: 'success',
        title: 'Adeudo Eliminado',
        text: 'El adeudo ha sido eliminado correctamente',
        confirmButtonColor: '#28a745',
        timer: 2000
      })

      showToast('success', 'Adeudo eliminado')
      await loadAdeudos()
      await loadSaldos()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}
</script>

<style scoped>
.saldos-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  padding: 1rem 0;
}

.saldo-item {
  display: flex;
  flex-direction: column;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #ea8215;
}

.saldo-item label {
  font-weight: 600;
  color: #495057;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
}

.saldo-value {
  font-size: 1.25rem;
  font-weight: 700;
  color: #ea8215;
}

.saldo-total {
  border-left-color: #28a745;
  background: #e8f5e9;
}

.saldo-total .saldo-value {
  color: #28a745;
  font-size: 1.5rem;
}

.text-end {
  text-align: right;
}

/* Header con acciones */
.header-with-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
}

/* Formulario de adeudo */
.adeudo-form .form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.adeudo-form .form-group {
  display: flex;
  flex-direction: column;
}

.adeudo-form input[type="number"] {
  text-align: right;
}

.total-preview {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 0.375rem;
  margin-top: 1rem;
}

.total-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #28a745;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--municipal-border, #dee2e6);
}

/* Botones de acción en tabla */
.button-group-sm {
  display: flex;
  gap: 0.25rem;
}

.button-group-sm .btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.75rem;
}
</style>
