<template>
  <div class="module-view">
    <div class="module-view-header">
      <h1 class="module-view-info">
        <font-awesome-icon icon="money-check-alt" />
        Gestión de Pagos por Folio
      </h1>
      <DocumentationModal
        title="Ayuda - ABC Pagos"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda de Folio -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Buscar Folio
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="municipal-form-control"
              @keyup.enter="buscarPagos"
            />
          </div>
          <div class="form-actions">
            <button @click="buscarPagos" class="btn-municipal-primary">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Pagos -->
    <div v-if="pagos.length > 0" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Pagos del Folio {{ folioABuscar }}
        <button @click="mostrarFormAlta = true" class="btn-municipal-primary btn-sm float-right">
          <font-awesome-icon icon="plus" />
          Nuevo Pago
        </button>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Año</th>
                <th>Fecha</th>
                <th>Recibo</th>
                <th>Importe</th>
                <th>Descuento</th>
                <th>Bonificación</th>
                <th>Recargo</th>
                <th>Total</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagos" :key="pago.anio">
                <td><strong>{{ pago.anio }}</strong></td>
                <td>{{ formatearFecha(pago.fecha_mov) }}</td>
                <td>{{ pago.recibo }}</td>
                <td>${{ formatearMoneda(pago.importe) }}</td>
                <td>${{ formatearMoneda(pago.descuento) }}</td>
                <td>${{ formatearMoneda(pago.bonificacion) }}</td>
                <td>${{ formatearMoneda(pago.recargo) }}</td>
                <td class="total-amount">${{ formatearMoneda(calcularTotal(pago)) }}</td>
                <td>
                  <button @click="eliminarPago(pago.anio)" class="btn-municipal-danger btn-sm">
                    <font-awesome-icon icon="trash" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Formulario Alta de Pago -->
    <div v-if="mostrarFormAlta" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="plus-circle" />
        Registrar Nuevo Pago
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Año</label>
            <input v-model.number="nuevoPago.anio" type="number" class="municipal-form-control" :min="2000" />
          </div>
          <div class="form-group">
            <label class="form-label required">Importe</label>
            <input v-model.number="nuevoPago.importe" type="number" class="municipal-form-control" step="0.01" min="0" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Recibo</label>
            <input v-model.number="nuevoPago.recibo" type="number" class="municipal-form-control" />
          </div>
        </div>
        <div class="form-actions">
          <button @click="registrarPago" class="btn-municipal-primary">
            <font-awesome-icon icon="save" />
            Registrar Pago
          </button>
          <button @click="cancelarAlta" class="btn-municipal-secondary">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>
      </div>
    </div>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ABCPagosxfol'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Modal de documentación
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const folioABuscar = ref(null)
const pagos = ref([])
const mostrarFormAlta = ref(false)

const nuevoPago = reactive({
  anio: new Date().getFullYear(),
  importe: 0,
  recibo: 0
})

const helpSections = [
  {
    title: 'Gestión de Pagos por Folio',
    content: `
      <p>Administración completa de pagos asociados a un folio.</p>
      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Consultar:</strong> Ver todos los pagos de un folio</li>
        <li><strong>Registrar:</strong> Agregar nuevos pagos</li>
        <li><strong>Eliminar:</strong> Borrar pagos registrados</li>
      </ul>
    `
  }
]

const buscarPagos = async () => {
  if (!folioABuscar.value) {
    toast.warning('Ingrese un número de folio')
    return
  }

  try {
    const params = [
      {
        nombre: 'p_operacion',
        valor: 3,
        tipo: 'string'
      },
      {
        nombre: 'p_id_pago',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'string'
      },
      {
        nombre: 'p_anio',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_importe',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_recibo',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_usuario',
        valor: 1,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    pagos.value = response.result || []

    if (pagos.value.length > 0) {
      toast.success(`Se encontraron ${pagos.value.length} pago(s)`)
    } else {
      toast.info('No hay pagos registrados para este folio')
    }
  } catch (error) {
    toast.error('Error al buscar pagos')
  }
}

const registrarPago = async () => {
  if (!nuevoPago.anio || nuevoPago.importe <= 0) {
    toast.warning('Complete todos los campos requeridos')
    return
  }

  try {
    const params = [
      {
        nombre: 'p_operacion',
        valor: 1,
        tipo: 'string'
      },
      {
        nombre: 'p_id_pago',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'string'
      },
      {
        nombre: 'p_anio',
        valor: nuevoPago.anio,
        tipo: 'integer'
      },
      {
        nombre: 'p_importe',
        valor: nuevoPago.importe,
        tipo: 'string'
      },
      {
        nombre: 'p_recibo',
        valor: nuevoPago.recibo || 0,
        tipo: 'string'
      },
      {
        nombre: 'p_usuario',
        valor: 1,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

    if (response.result && response.result[0]?.resultado === 'S') {
      toast.success('Pago registrado exitosamente')
      cancelarAlta()
      await buscarPagos()
    } else {
      toast.error(response.result[0]?.mensaje || 'Error al registrar pago')
    }
  } catch (error) {
    toast.error('Error al registrar pago')
  }
}

const eliminarPago = async (anio) => {
  const result = await Swal.fire({
    title: '¿Eliminar pago?',
    text: `¿Está seguro de eliminar el pago del año ${anio}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    try {
      const params = [
      {
        nombre: 'p_operacion',
        valor: 2,
        tipo: 'string'
      },
      {
        nombre: 'p_id_pago',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_control_rcm',
        valor: folioABuscar.value,
        tipo: 'string'
      },
      {
        nombre: 'p_anio',
        valor: anio,
        tipo: 'string'
      },
      {
        nombre: 'p_importe',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_recibo',
        valor: 0,
        tipo: 'string'
      },
      {
        nombre: 'p_usuario',
        valor: 1,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_abc_pagos_por_folio', 'cementerios', params,
      'cementerios',
      null,
      'public'
    , '', null, 'comun')

      if (response.result && response.result[0]?.resultado === 'S') {
        toast.success('Pago eliminado exitosamente')
        await buscarPagos()
      } else {
        toast.error(response.result[0]?.mensaje || 'Error al eliminar pago')
      }
    } catch (error) {
      toast.error('Error al eliminar pago')
    }
  }
}

const cancelarAlta = () => {
  mostrarFormAlta.value = false
  nuevoPago.anio = new Date().getFullYear()
  nuevoPago.importe = 0
  nuevoPago.recibo = 0
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

const calcularTotal = (pago) => {
  return parseFloat(pago.importe || 0) - parseFloat(pago.descuento || 0) -
         parseFloat(pago.bonificacion || 0) + parseFloat(pago.recargo || 0)
}
</script>

<style scoped>
/* Estilo único de monto total - Justificado mantener scoped */
.total-amount {
  font-weight: bold;
  color: var(--color-primary);
}
</style>
