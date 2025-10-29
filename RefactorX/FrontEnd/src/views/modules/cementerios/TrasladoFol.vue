<template>
  <div class="module-container">
    <!-- Header -->
    <div class="module-header">
      <div class="module-title-section">
        <i class="fas fa-exchange-alt module-icon"></i>
        <div>
          <h1 class="module-title">Traslado de Folios</h1>
          <p class="module-subtitle">Traslado de pagos entre folios</p>
        </div>
      </div>
      <div class="module-actions">
        <button class="btn-help" @click="mostrarAyuda = true">
          <i class="fas fa-question-circle"></i>
          Ayuda
        </button>
      </div>
    </div>

    <!-- Búsqueda de Folios -->
    <div class="card">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Selección de Folios
      </div>
      <div class="card-body">
        <div class="alert-info mb-3">
          <i class="fas fa-info-circle"></i>
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
              <i class="fas fa-search"></i>
              Verificar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información de Folios -->
    <div v-if="datosOrigen && datosDestino" class="card mt-3">
      <div class="card-header">
        <i class="fas fa-info-circle"></i>
        Información de Folios
      </div>
      <div class="card-body">
        <div class="folio-comparison">
          <!-- Folio Origen -->
          <div class="folio-info">
            <h3 class="folio-title origin">
              <i class="fas fa-arrow-right"></i>
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
            <i class="fas fa-arrow-circle-right"></i>
          </div>

          <!-- Folio Destino -->
          <div class="folio-info">
            <h3 class="folio-title destination">
              <i class="fas fa-arrow-left"></i>
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
    <div v-if="pagosOrigen.length > 0" class="card mt-3">
      <div class="card-header">
        <i class="fas fa-list-check"></i>
        Pagos a Trasladar ({{ pagosSeleccionados.length }} seleccionados)
      </div>
      <div class="card-body">
        <div class="alert-warning mb-3">
          <i class="fas fa-exclamation-triangle"></i>
          <span>Seleccione los pagos que desea trasladar del folio {{ folioOrigen }} al folio {{ folioDestino }}</span>
        </div>

        <div class="table-actions mb-3">
          <button class="btn-municipal-secondary" @click="seleccionarTodos">
            <i class="fas fa-check-square"></i>
            Seleccionar Todos
          </button>
          <button class="btn-municipal-secondary" @click="deseleccionarTodos">
            <i class="fas fa-square"></i>
            Deseleccionar Todos
          </button>
        </div>

        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>
                  <input
                    type="checkbox"
                    @change="toggleTodos"
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
              <tr v-for="pago in pagosOrigen" :key="pago.control_id">
                <td>
                  <input
                    type="checkbox"
                    :value="pago.control_id"
                    v-model="pagosSeleccionados"
                  />
                </td>
                <td>{{ formatDate(pago.fecing) }}</td>
                <td>{{ pago.recing }}</td>
                <td>{{ pago.control_id }}</td>
                <td>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</td>
                <td>{{ formatCurrency(pago.importe_anual) }}</td>
                <td>{{ formatCurrency(pago.importe_recargos) }}</td>
                <td class="text-bold">
                  {{ formatCurrency(pago.importe_anual + pago.importe_recargos) }}
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
            <i class="fas fa-times"></i>
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="confirmarTraslado"
            :disabled="pagosSeleccionados.length === 0"
          >
            <i class="fas fa-exchange-alt"></i>
            Trasladar Pagos ({{ pagosSeleccionados.length }})
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="mostrarAyuda"
      title="Ayuda - Traslado de Folios"
      @close="mostrarAyuda = false"
    >
      <div class="help-content">
        <section class="help-section">
          <h3><i class="fas fa-info-circle"></i> Descripción</h3>
          <p>
            Este módulo permite trasladar pagos de un folio a otro. Es útil cuando se necesita
            corregir errores en la asignación de pagos o cuando se fusionan folios.
          </p>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-list-ol"></i> Proceso</h3>
          <ol>
            <li>Ingrese el <strong>Folio Origen</strong> (desde donde se trasladarán los pagos)</li>
            <li>Ingrese el <strong>Folio Destino</strong> (hacia donde se trasladarán los pagos)</li>
            <li>Presione "Verificar" para cargar los datos de ambos folios</li>
            <li>El sistema mostrará los pagos del folio origen</li>
            <li>Seleccione los pagos que desea trasladar (puede usar "Seleccionar Todos")</li>
            <li>Presione "Trasladar Pagos" para confirmar</li>
            <li>El sistema actualizará los pagos al nuevo folio</li>
          </ol>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-exclamation-triangle"></i> Importante</h3>
          <ul>
            <li>Ambos folios deben existir en el sistema</li>
            <li>Solo se trasladarán los pagos seleccionados</li>
            <li>Los pagos mantendrán su información original de fechas e importes</li>
            <li>La ubicación (cementerio, clase, sección, etc.) se actualizará al folio destino</li>
            <li>El año pagado de ambos folios se recalculará automáticamente</li>
            <li>Esta operación no se puede deshacer fácilmente</li>
          </ul>
        </section>

        <section class="help-section">
          <h3><i class="fas fa-shield-alt"></i> Seguridad</h3>
          <p>
            Se recomienda verificar cuidadosamente los folios antes de realizar el traslado,
            ya que esta operación afecta el historial de pagos y puede tener implicaciones
            en la contabilidad.
          </p>
        </section>
      </div>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { callProcedure } = useApi()
const { showSuccess, showError } = useToast()

// Estado
const mostrarAyuda = ref(false)
const folioOrigen = ref(null)
const folioDestino = ref(null)
const datosOrigen = ref(null)
const datosDestino = ref(null)
const pagosOrigen = ref([])
const pagosSeleccionados = ref([])

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
    .reduce((sum, p) => sum + p.importe_anual + p.importe_recargos, 0)
})

// Verificar folios
const verificarFolios = async () => {
  if (!foliosValidos.value) {
    showError('Por favor ingrese dos folios diferentes válidos')
    return
  }

  try {
    // Buscar folio origen
    const resultOrigen = await callProcedure('SP_CEM_BUSCAR_FOLIO', {
      p_control_rcm: folioOrigen.value
    })

    if (resultOrigen.resultado !== 'S' || !resultOrigen.data) {
      showError('El folio origen no existe')
      return
    }

    datosOrigen.value = resultOrigen.data

    // Buscar folio destino
    const resultDestino = await callProcedure('SP_CEM_BUSCAR_FOLIO', {
      p_control_rcm: folioDestino.value
    })

    if (resultDestino.resultado !== 'S' || !resultDestino.data) {
      showError('El folio destino no existe')
      return
    }

    datosDestino.value = resultDestino.data

    // Cargar pagos del folio origen
    await cargarPagosOrigen()

  } catch (error) {
    console.error('Error al verificar folios:', error)
    showError('Error al verificar los folios')
  }
}

// Cargar pagos del folio origen
const cargarPagosOrigen = async () => {
  try {
    const result = await callProcedure('SP_CEM_LISTAR_PAGOS_FOLIO', {
      p_control_rcm: folioOrigen.value
    })

    pagosOrigen.value = result.data || []
    pagosSeleccionados.value = []

    if (pagosOrigen.value.length === 0) {
      showError('El folio origen no tiene pagos para trasladar')
    }
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
      Total: <strong>${formatCurrency(totalSeleccionado.value)}</strong>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, trasladar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33'
  })

  if (!result.isConfirmed) return

  try {
    // Trasladar pagos
    const controlIds = pagosSeleccionados.value.join(',')
    const resultTraslado = await callProcedure('SP_CEM_TRASLADAR_PAGOS', {
      p_control_ids: controlIds,
      p_folio_destino: folioDestino.value,
      p_usuario: 1 // TODO: Obtener de sesión
    })

    if (resultTraslado.resultado === 'S') {
      // Actualizar año pagado del folio origen
      await callProcedure('SP_CEM_ACTUALIZAR_AXO_PAGADO', {
        p_control_rcm: folioOrigen.value,
        p_usuario: 1
      })

      showSuccess(`${pagosSeleccionados.value.length} pago(s) trasladado(s) exitosamente`)

      // Limpiar y recargar
      await verificarFolios()
    } else {
      showError(resultTraslado.mensaje || 'Error al trasladar pagos')
    }
  } catch (error) {
    console.error('Error al trasladar pagos:', error)
    showError('Error al trasladar los pagos')
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
}

// Formatear moneda
const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}
</script>

<style scoped>
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

.align-end {
  align-self: flex-end;
}

.text-bold {
  font-weight: 600;
}

.primary {
  color: var(--color-primary);
}

.success {
  color: var(--color-success);
}

.mt-3 {
  margin-top: 1rem;
}

.mb-3 {
  margin-bottom: 1rem;
}

.full-width {
  grid-column: 1 / -1;
}

.form-help {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  color: var(--color-text-secondary);
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
