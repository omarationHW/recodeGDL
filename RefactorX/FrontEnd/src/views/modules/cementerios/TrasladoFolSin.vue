<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-title-section">
        <font-awesome-icon icon="exchange-alt" class="module-icon" />
        <div>
          <h1 class="module-view-info">Traslado de Folios Sin Adeudos</h1>
          <p class="module-subtitle">Traslado de pagos entre folios sin afectar adeudos</p>
        </div>
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

    <!-- Búsqueda de Folios -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Selección de Folios
      </div>
      <div class="municipal-card-body">
        <div class="alert-info mb-3">
          <font-awesome-icon icon="info-circle" />
          <span>Ingrese el folio origen (de donde se trasladarán los pagos) y el folio destino</span>
        </div>

        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Folio Origen (DE)</label>
            <input
              type="number"
              v-model.number="folioOrigen"
              class="form-input"
              placeholder="Folio de traslado"
              @keyup.enter="verificarFolios"
            />
            <small class="form-help">Folio desde el cual se trasladarán los pagos</small>
          </div>
          <div class="form-group">
            <label class="form-label required">Folio Destino (A)</label>
            <input
              type="number"
              v-model.number="folioDestino"
              class="form-input"
              placeholder="Folio a trasladar"
              @keyup.enter="verificarFolios"
            />
            <small class="form-help">Folio hacia el cual se trasladarán los pagos</small>
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="verificarFolios"
              :disabled="!foliosValidos"
            >
              <font-awesome-icon icon="search" />
              Verificar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información de Folios -->
    <div v-if="datosOrigen && datosDestino" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="info-circle" />
        Información de Folios
      </div>
      <div class="municipal-card-body">
        <div class="folio-comparison">
          <!-- Folio Origen -->
          <div class="folio-info">
            <h3 class="folio-title origin">
              <font-awesome-icon icon="arrow-right" />
              Folio Origen
            </h3>
            <div class="info-section">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Folio:</span>
                  <span class="info-value">{{ datosOrigen.control_rcm }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Cementerio:</span>
                  <span class="info-value">{{ datosOrigen.cementerio }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Ubicación:</span>
                  <span class="info-value">
                    {{ datosOrigen.clase_alfa }}-{{ datosOrigen.seccion_alfa }}-{{ datosOrigen.linea_alfa }}-{{ datosOrigen.fosa_alfa }}
                  </span>
                </div>
                <div class="info-item full-width">
                  <span class="info-label">Nombre:</span>
                  <span class="info-value">{{ datosOrigen.nombre }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Flecha de traslado -->
          <div class="transfer-arrow">
            <font-awesome-icon icon="arrow-circle-right" />
          </div>

          <!-- Folio Destino -->
          <div class="folio-info">
            <h3 class="folio-title destination">
              <font-awesome-icon icon="arrow-left" />
              Folio Destino
            </h3>
            <div class="info-section">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Folio:</span>
                  <span class="info-value">{{ datosDestino.control_rcm }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Cementerio:</span>
                  <span class="info-value">{{ datosDestino.cementerio }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Ubicación:</span>
                  <span class="info-value">
                    {{ datosDestino.clase_alfa }}-{{ datosDestino.seccion_alfa }}-{{ datosDestino.linea_alfa }}-{{ datosDestino.fosa_alfa }}
                  </span>
                </div>
                <div class="info-item full-width">
                  <span class="info-label">Nombre:</span>
                  <span class="info-value">{{ datosDestino.nombre }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Pagos para Trasladar -->
    <div v-if="pagosOrigen.length > 0" class="municipal-card mt-3">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list-check" />
          Pagos a Trasladar
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="pagosSeleccionados.length > 0">
            {{ pagosSeleccionados.length }} seleccionados
          </span>
        </div>
      </div>
      <div class="municipal-card-body">
        <div class="alert-warning mb-3">
          <font-awesome-icon icon="exclamation-triangle" />
          <span>Seleccione los pagos que desea trasladar del folio {{ folioOrigen }} al folio {{ folioDestino }}</span>
        </div>

        <div class="table-actions mb-3">
          <button class="btn-municipal-secondary" @click="seleccionarTodos">
            <font-awesome-icon icon="check-square" />
            Seleccionar Todos
          </button>
          <button class="btn-municipal-secondary" @click="deseleccionarTodos">
            <font-awesome-icon icon="square" />
            Deseleccionar Todos
          </button>
        </div>

        <div class="table-container">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>
                  <input
                    type="checkbox"
                    @change.stop="toggleTodos"
                    :checked="todosMarcados"
                  />
                </th>
                <th>Fecha Ingreso</th>
                <th>Recibo</th>
                <th>Control ID</th>
                <th>Años</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="pago in pagosOrigen"
                :key="pago.control_id"
                @click="selectedRow = pago"
                :class="{ 'table-row-selected': selectedRow === pago }"
                class="row-hover"
              >
                <td>
                  <input
                    type="checkbox"
                    :value="pago.control_id"
                    v-model="pagosSeleccionados"
                    @click.stop
                  />
                </td>
                <td>{{ formatDate(pago.fecing) }}</td>
                <td>{{ pago.recing }}</td>
                <td>{{ pago.control_id }}</td>
                <td>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</td>
                <td>{{ formatCurrency(pago.importe_anual) }}</td>
                <td>{{ formatCurrency(pago.importe_recargos) }}</td>
                <td class="text-bold">
                  {{ formatCurrency(parseFloat(pago.importe_anual || 0) + parseFloat(pago.importe_recargos || 0)) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="summary-box mt-3">
          <div class="summary-item">
            <span class="summary-label">Total Pagos:</span>
            <span class="summary-value">{{ pagosOrigen.length }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Seleccionados:</span>
            <span class="summary-value primary">{{ pagosSeleccionados.length }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Total a Trasladar:</span>
            <span class="summary-value success">
              {{ formatCurrency(totalSeleccionado) }}
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button
            class="btn-municipal-secondary"
            @click="cancelar"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="confirmarTraslado"
            :disabled="pagosSeleccionados.length === 0"
          >
            <font-awesome-icon icon="exchange-alt" />
            Trasladar Pagos ({{ pagosSeleccionados.length }})
          </button>
        </div>
      </div>
    </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="!datosOrigen && !datosDestino && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="exchange-alt" size="3x" />
        </div>
        <h4>Traslado de Folios Sin Adeudos</h4>
        <p>Ingrese el folio origen y destino para comenzar el proceso de traslado</p>
      </div>

      <!-- Empty State - Sin pagos -->
      <div v-else-if="datosOrigen && datosDestino && pagosOrigen.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin pagos disponibles</h4>
        <p>El folio origen no tiene pagos para trasladar</p>
      </div>

      <!-- Modal de Ayuda -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'TrasladoFolSin'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Traslado de Folios Sin Adeudos'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showSuccess, showError } = useToast()

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
const folioOrigen = ref(null)
const folioDestino = ref(null)
const datosOrigen = ref(null)
const datosDestino = ref(null)
const pagosOrigen = ref([])
const pagosSeleccionados = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)

// Validaciones
const foliosValidos = computed(() => {
  return folioOrigen.value > 0 && folioDestino.value > 0 && folioOrigen.value !== folioDestino.value
})

const todosMarcados = computed(() => {
  return pagosOrigen.value.length > 0 &&
         pagosSeleccionados.value.length === pagosOrigen.value.length
})

const totalSeleccionado = computed(() => {
  return pagosOrigen.value
    .filter(p => pagosSeleccionados.value.includes(p.control_id))
    .reduce((sum, p) => {
      const importe = parseFloat(p.importe_anual || 0)
      const recargos = parseFloat(p.importe_recargos || 0)
      return sum + importe + recargos
    }, 0)
})

// Verificar folios
const verificarFolios = async () => {
  if (!foliosValidos.value) {
    showError('Por favor ingrese dos folios diferentes válidos')
    return
  }

  showLoading('Verificando folios...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null

  try {
    // Buscar folio origen
    const response = await execute(
      'sp_abcf_get_folio',
      'cementerio',
      [
        { nombre: 'p_folio', valor: folioOrigen.value, tipo: 'integer' }
      ],
      '',
      null,
      'public')

    if(response?.result?.length > 0 ) {
      datosOrigen.value = response.result[0]
    } else {
      showError('El folio origen no existe')
      return
    }

    // Buscar folio destino
    const resultDestino = await execute(
      'sp_abcf_get_folio',
      'cementerio',
      [
        { nombre: 'p_folio', valor: folioDestino.value, tipo: 'integer' }
      ],
      '',
      null,
      'public')

    if(resultDestino?.result?.length > 0 ) {
      datosDestino.value = resultDestino.result[0]
    } else {
      showError('El folio destino no existe')
      return
    }

    // Cargar pagos del folio origen
    await cargarPagosOrigen()

  } catch (error) {
    console.error('Error al verificar folios:', error)
    showError('Error al verificar los folios')
  } finally {
    hideLoading()
  }
}

// Cargar pagos del folio origen
const cargarPagosOrigen = async () => {
  try {
    const response = await execute(
      'sp_trasladofol_listar_pagos_folio',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioOrigen.value, tipo: 'integer' }
      ],
      'cementerio',
      null,
      'public')

    if(response?.result?.length > 0 ) {
      pagosOrigen.value = response.result
    } else {
      showError('El folio origen no tiene pagos para trasladar')
      return
    }
    pagosSeleccionados.value = []

  } catch (error) {
    console.error('Error al cargar pagos:', error)
    showError('Error al cargar los pagos')
  }
}

// Seleccionar todos los pagos
const seleccionarTodos = () => {
  pagosSeleccionados.value = pagosOrigen.value.map(p => p.control_id)
}

// Deseleccionar todos los pagos
const deseleccionarTodos = () => {
  pagosSeleccionados.value = []
}

// Toggle todos
const toggleTodos = () => {
  if (todosMarcados.value) {
    deseleccionarTodos()
  } else {
    seleccionarTodos()
  }
}

// Confirmar traslado
const confirmarTraslado = async () => {
  if (pagosSeleccionados.value.length === 0) {
    showError('Debe seleccionar al menos un pago')
    return
  }

  const result = await Swal.fire({
    title: '¿Confirmar traslado?',
    html: `
      Se trasladarán <strong>${pagosSeleccionados.value.length}</strong> pago(s)<br>
      Del folio <strong>${folioOrigen.value}</strong><br>
      Al folio <strong>${folioDestino.value}</strong><br><br>
      Total: <strong>${formatCurrency(totalSeleccionado.value)}</strong><br><br>
      <strong>Nota:</strong> Los adeudos NO se verán afectados
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, trasladar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33'
  })

  if (!result.isConfirmed) return

  showLoading('Trasladando pagos...', 'Por favor espere')
  selectedRow.value = null

  try {
    // Trasladar pagos sin afectar adeudos usando el SP correcto
    const controlIds = pagosSeleccionados.value.join(',')

    const response = await execute(
      'sp_traslado_folios_sin_adeudo',
      'cementerio',
      [
        { nombre: 'p_folio_de', valor: folioOrigen.value, tipo: 'integer' },
        { nombre: 'p_folio_a', valor: folioDestino.value, tipo: 'integer' },
        { nombre: 'p_pagos_ids', valor: controlIds, tipo: 'varchar' },
        { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
      ],
      'cementerio',
      null,
      'public')

    let trasladoData = null
    if(response?.result?.length > 0 ){
      trasladoData = response.result[0]
    }

    if (trasladoData && trasladoData.resultado === 'S') {
    showSuccess(trasladoData.mensaje || 'Traslado realizado exitosamente')

      // Limpiar y recargar
      await verificarFolios()
    } else {
      showError(trasladoData?.mensaje || 'Error al trasladar pagos')
    }
  } catch (error) {
    console.error('Error al trasladar pagos:', error)
    showError('Error al trasladar los pagos')
  } finally {
    hideLoading()
  }
}

// Cancelar
const cancelar = () => {
  folioOrigen.value = null
  folioDestino.value = null
  datosOrigen.value = null
  datosDestino.value = null
  pagosOrigen.value = []
  pagosSeleccionados.value = []
  hasSearched.value = false
  selectedRow.value = null
}

// Formatear moneda
const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  const numValue = parseFloat(value)
  if (isNaN(numValue)) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(numValue)
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}
</script>

<style scoped>
/* Layout único de comparación de folios - Justificado mantener scoped */
.folio-comparison {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 2rem;
  align-items: center;
}

.folio-info {
  background: var(--color-bg-secondary);
  border-radius: 8px;
  padding: 1.5rem;
}

.folio-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
}

.folio-title.origin {
  color: var(--color-warning);
}

.folio-title.destination {
  color: var(--color-success);
}

.transfer-arrow {
  font-size: 3rem;
  color: var(--color-primary);
}

.table-actions {
  display: flex;
  gap: 0.5rem;
}

@media (max-width: 768px) {
  .folio-comparison {
    grid-template-columns: 1fr;
    gap: 1rem;
  }

  .transfer-arrow {
    transform: rotate(90deg);
    font-size: 2rem;
  }
}
</style>
