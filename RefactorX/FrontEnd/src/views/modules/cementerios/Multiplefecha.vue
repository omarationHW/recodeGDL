<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="calendar-check" />
        Consulta de Pagos por Fecha
      </h1>
      <DocumentationModal
        title="Ayuda - Consulta por Fecha"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Criterios de Búsqueda
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha de Ingreso</label>
            <input
              v-model="filtros.fecha"
              type="date"
              class="municipal-form-control"
              @keyup.enter="buscarPagos"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Recibo</label>
            <input
              v-model.number="filtros.recibo"
              type="number"
              class="municipal-form-control"
              min="1"
              @keyup.enter="buscarPagos"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Caja</label>
            <input
              v-model="filtros.caja"
              type="text"
              class="municipal-form-control"
              maxlength="1"
              @keyup.enter="buscarPagos"
            />
          </div>
        </div>
        <div class="form-actions">
          <button @click="buscarPagos" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar Pagos
          </button>
          <button @click="limpiarFiltros" class="btn-municipal-secondary">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="pagos.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Pagos Encontrados ({{ pagos.length }})
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Folio</th>
                <th>Ubicación</th>
                <th>Fecha Ingreso</th>
                <th>Recibo</th>
                <th>Caja</th>
                <th>Años Pago</th>
                <th>Importe Anual</th>
                <th>Recargos</th>
                <th>Vigencia</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagos" :key="`${pago.control_id}-${pago.control_rcm}`">
                <td>{{ pago.control_rcm }}</td>
                <td>{{ formatearUbicacion(pago) }}</td>
                <td>{{ formatearFecha(pago.fecing) }}</td>
                <td>{{ pago.recing }}</td>
                <td>{{ pago.cajing }}</td>
                <td>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</td>
                <td>{{ formatearMoneda(pago.importe_anual) }}</td>
                <td>{{ formatearMoneda(pago.importe_recargos) }}</td>
                <td>
                  <span :class="getBadgeVigencia(pago.vigencia)">
                    {{ getTextoVigencia(pago.vigencia) }}
                  </span>
                </td>
                <td>
                  <button
                    @click="verDetalleFolio(pago.control_rcm)"
                    class="btn-municipal-secondary btn-sm"
                    title="Ver detalle del folio"
                  >
                    <font-awesome-icon icon="eye" />
                    Ver Detalle
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Resumen -->
        <div class="summary-box mt-3">
          <div class="summary-item">
            <span class="summary-label">Total de Pagos:</span>
            <span class="summary-value">{{ pagos.length }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Total Anual:</span>
            <span class="summary-value">{{ formatearMoneda(totalAnual) }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Total Recargos:</span>
            <span class="summary-value">{{ formatearMoneda(totalRecargos) }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Total General:</span>
            <span class="summary-value highlight">{{ formatearMoneda(totalGeneral) }}</span>
          </div>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron pagos con los criterios especificados
    </div>

    <!-- Modal de detalle (placeholder) -->
    <div v-if="folioSeleccionado" class="modal-overlay" @click="cerrarDetalle">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>
            <font-awesome-icon icon="file-alt" />
            Detalle del Folio {{ folioSeleccionado }}
          </h3>
          <button @click="cerrarDetalle" class="btn-close">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="alert-info">
            <font-awesome-icon icon="info-circle" />
            El detalle completo del folio se implementará en el componente ConIndividual
          </div>
          <p><strong>Folio:</strong> {{ folioSeleccionado }}</p>
          <p>Aquí se mostrará la información detallada del folio, incluyendo datos del titular, ubicación completa y todos los pagos asociados.</p>
        </div>
        <div class="modal-footer">
          <button @click="cerrarDetalle" class="btn-municipal-secondary">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </div>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Multiplefecha'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const filtros = reactive({
  fecha: '',
  recibo: 1,
  caja: 'A'
})

const pagos = ref([])
const busquedaRealizada = ref(false)
const folioSeleccionado = ref(null)

const helpSections = [
  {
    title: 'Consulta de Pagos por Fecha',
    content: `
      <p>Este módulo permite consultar todos los pagos registrados en una fecha específica, con un número de recibo y caja determinados.</p>
      <h4>Uso:</h4>
      <ol>
        <li><strong>Fecha:</strong> Seleccione la fecha de ingreso del pago</li>
        <li><strong>Recibo:</strong> Ingrese el número de recibo</li>
        <li><strong>Caja:</strong> Ingrese la caja (A, B, C, etc.)</li>
        <li><strong>Buscar:</strong> El sistema mostrará todos los pagos que coincidan</li>
        <li><strong>Ver Detalle:</strong> Puede ver la información completa de cada folio</li>
      </ol>
    `
  },
  {
    title: 'Casos de Uso',
    content: `
      <p>Esta consulta es útil para:</p>
      <ul>
        <li>Verificar todos los pagos de una operación de caja específica</li>
        <li>Revisar pagos múltiples del mismo recibo</li>
        <li>Auditar operaciones por fecha y caja</li>
        <li>Identificar folios relacionados con una transacción</li>
      </ul>
    `
  }
]

const totalAnual = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (pago.importe_anual || 0), 0)
})

const totalRecargos = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (pago.importe_recargos || 0), 0)
})

const totalGeneral = computed(() => {
  return totalAnual.value + totalRecargos.value
})

const buscarPagos = async () => {
  if (!filtros.fecha) {
    toast.warning('Seleccione una fecha')
    return
  }
  if (!filtros.recibo || filtros.recibo < 1) {
    toast.warning('Ingrese un número de recibo válido')
    return
  }
  if (!filtros.caja || filtros.caja.trim() === '') {
    toast.warning('Ingrese una caja')
    return
  }

  try {
    const params = [
      {
        nombre: 'p_fecha',
        valor: filtros.fecha,
        tipo: 'date'
      },
      {
        nombre: 'p_recibo',
        valor: filtros.recibo,
        tipo: 'string'
      },
      {
        nombre: 'p_caja',
        valor: filtros.caja.toUpperCase(),
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_consultar_pagos_por_fecha', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    pagos.value = response.result || []
    busquedaRealizada.value = true

    if (pagos.value.length === 0) {
      toast.info('No existe Registro con esos Datos')
    } else {
      toast.success(`Se encontraron ${pagos.value.length} pago(s)`)
    }
  } catch (error) {
    toast.error('Error al buscar pagos')
  }
}

const limpiarFiltros = () => {
  filtros.fecha = new Date().toISOString().split('T')[0]
  filtros.recibo = 1
  filtros.caja = 'A'
  pagos.value = []
  busquedaRealizada.value = false
  folioSeleccionado.value = null
}

const verDetalleFolio = (controlRcm) => {
  folioSeleccionado.value = controlRcm
  // TODO: Integrar con componente ConIndividual cuando esté disponible
}

const cerrarDetalle = () => {
  folioSeleccionado.value = null
}

const formatearUbicacion = (pago) => {
  const partes = []
  partes.push(`Cl:${pago.clase}${pago.clase_alfa || ''}`)
  partes.push(`Sec:${pago.seccion}${pago.seccion_alfa || ''}`)
  partes.push(`Lin:${pago.linea}${pago.linea_alfa || ''}`)
  partes.push(`Fosa:${pago.fosa}${pago.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (valor == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(valor)
}

const getBadgeVigencia = (vigencia) => {
  switch (vigencia) {
    case 'V':
    case 'A':
      return 'badge-success'
    case 'C':
      return 'badge-danger'
    default:
      return 'badge-secondary'
  }
}

const getTextoVigencia = (vigencia) => {
  switch (vigencia) {
    case 'V':
      return 'Vigente'
    case 'A':
      return 'Activo'
    case 'C':
      return 'Cancelado'
    default:
      return vigencia || 'N/A'
  }
}

onMounted(() => {
  // Inicializar con fecha actual
  filtros.fecha = new Date().toISOString().split('T')[0]
})
</script>

<style scoped>
.btn-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
}

.badge-success {
  background-color: var(--color-success);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
}

.badge-danger {
  background-color: var(--color-danger);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
}

.badge-secondary {
  background-color: var(--color-secondary);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
}

.summary-value.highlight {
  font-weight: 700;
  color: var(--color-primary);
  font-size: 1.125rem;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 0.5rem;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--color-border);
}

.modal-header h3 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  color: var(--color-text-secondary);
  padding: 0.25rem;
  line-height: 1;
}

.btn-close:hover {
  color: var(--color-danger);
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  padding: 1rem 1.5rem;
  border-top: 1px solid var(--color-border);
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}
</style>
