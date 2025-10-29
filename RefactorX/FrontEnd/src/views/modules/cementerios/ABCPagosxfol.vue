<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-money-check-alt"></i>
        Gestión de Pagos por Folio
      </h1>
      <DocumentationModal
        title="Ayuda - ABC Pagos"
        :sections="helpSections"
      />
    </div>

    <!-- Búsqueda de Folio -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-search"></i>
        Buscar Folio
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="form-control"
              @keyup.enter="buscarPagos"
            />
          </div>
          <div class="form-actions">
            <button @click="buscarPagos" class="btn-municipal-primary">
              <i class="fas fa-search"></i>
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Pagos -->
    <div v-if="pagos.length > 0" class="card mb-3">
      <div class="card-header">
        <i class="fas fa-list"></i>
        Pagos del Folio {{ folioABuscar }}
        <button @click="mostrarFormAlta = true" class="btn-municipal-primary btn-sm float-right">
          <i class="fas fa-plus"></i>
          Nuevo Pago
        </button>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Formulario Alta de Pago -->
    <div v-if="mostrarFormAlta" class="card">
      <div class="card-header">
        <i class="fas fa-plus-circle"></i>
        Registrar Nuevo Pago
      </div>
      <div class="card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Año</label>
            <input v-model.number="nuevoPago.anio" type="number" class="form-control" :min="2000" />
          </div>
          <div class="form-group">
            <label class="form-label required">Importe</label>
            <input v-model.number="nuevoPago.importe" type="number" class="form-control" step="0.01" min="0" />
          </div>
          <div class="form-group">
            <label class="form-label">Recibo</label>
            <input v-model.number="nuevoPago.recibo" type="number" class="form-control" />
          </div>
        </div>
        <div class="form-actions">
          <button @click="registrarPago" class="btn-municipal-primary">
            <i class="fas fa-save"></i>
            Registrar Pago
          </button>
          <button @click="cancelarAlta" class="btn-municipal-secondary">
            <i class="fas fa-times"></i>
            Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

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
    const response = await api.callStoredProcedure('SP_CEM_ABC_PAGOS_POR_FOLIO', {
      p_operacion: 3,
      p_id_pago: 0,
      p_control_rcm: folioABuscar.value,
      p_anio: 0,
      p_importe: 0,
      p_recibo: 0,
      p_usuario: 1
    })

    pagos.value = response.data || []

    if (pagos.value.length > 0) {
      toast.success(`Se encontraron ${pagos.value.length} pago(s)`)
    } else {
      toast.info('No hay pagos registrados para este folio')
    }
  } catch (error) {
    console.error('Error al buscar pagos:', error)
    toast.error('Error al buscar pagos')
  }
}

const registrarPago = async () => {
  if (!nuevoPago.anio || nuevoPago.importe <= 0) {
    toast.warning('Complete todos los campos requeridos')
    return
  }

  try {
    const response = await api.callStoredProcedure('SP_CEM_ABC_PAGOS_POR_FOLIO', {
      p_operacion: 1,
      p_id_pago: 0,
      p_control_rcm: folioABuscar.value,
      p_anio: nuevoPago.anio,
      p_importe: nuevoPago.importe,
      p_recibo: nuevoPago.recibo || 0,
      p_usuario: 1
    })

    if (response.data && response.data[0]?.resultado === 'S') {
      toast.success('Pago registrado exitosamente')
      cancelarAlta()
      await buscarPagos()
    } else {
      toast.error(response.data[0]?.mensaje || 'Error al registrar pago')
    }
  } catch (error) {
    console.error('Error al registrar pago:', error)
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
      const response = await api.callStoredProcedure('SP_CEM_ABC_PAGOS_POR_FOLIO', {
        p_operacion: 2,
        p_id_pago: 0,
        p_control_rcm: folioABuscar.value,
        p_anio: anio,
        p_importe: 0,
        p_recibo: 0,
        p_usuario: 1
      })

      if (response.data && response.data[0]?.resultado === 'S') {
        toast.success('Pago eliminado exitosamente')
        await buscarPagos()
      } else {
        toast.error(response.data[0]?.mensaje || 'Error al eliminar pago')
      }
    } catch (error) {
      console.error('Error al eliminar pago:', error)
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
.float-right {
  float: right;
}

.total-amount {
  font-weight: bold;
  color: var(--color-primary);
}

.form-grid-three {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}
</style>
