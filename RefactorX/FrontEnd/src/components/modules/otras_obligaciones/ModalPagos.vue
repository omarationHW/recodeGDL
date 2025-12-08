<template>
  <div class="modal-overlay" @click.self="close">
    <div class="modal-container modal-lg">
      <div class="modal-header">
        <h5>
          <font-awesome-icon icon="file-invoice-dollar" />
          Historial de Pagos Realizados
        </h5>
        <button class="modal-close-btn" @click="close">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <div class="modal-body">
        <div v-if="loading" class="text-center">
          <div class="spinner"></div>
          <p>Cargando pagos...</p>
        </div>

        <div v-else>
          <div class="table-responsive" v-if="pagos.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Pago</th>
                  <th>Período</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargo</th>
                  <th>Fecha/Hora Pago</th>
                  <th>Recaudadora</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Folio Recibo</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_34_pagos" class="row-hover">
                  <td>{{ pago.id_34_pagos }}</td>
                  <td>{{ formatDate(pago.periodo) }}</td>
                  <td class="text-right">{{ formatCurrency(pago.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(pago.recargo) }}</td>
                  <td>{{ formatDateTime(pago.fecha_hora_pago) }}</td>
                  <td>{{ pago.id_recaudadora }}</td>
                  <td>{{ pago.caja }}</td>
                  <td>{{ pago.operacion }}</td>
                  <td>{{ pago.folio_recibo }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="municipal-table-footer">
                  <td colspan="2" class="text-right"><strong>Total Pagado:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalRecargo) }}</strong></td>
                  <td colspan="6"></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <div v-else class="text-center text-muted">
            <p>No se encontraron pagos para este registro</p>
          </div>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-municipal-secondary" @click="close">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'otras_obligaciones'

const props = defineProps({
  idDatos: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['close'])

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()

const loading = ref(false)
const pagos = ref([])

const totalImporte = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (parseFloat(pago.importe) || 0), 0)
})

const totalRecargo = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (parseFloat(pago.recargo) || 0), 0)
})

const formatDate = (dateString) => {
  if (!dateString) return '-'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX')
  } catch (error) {
    return dateString
  }
}

const formatDateTime = (dateTimeString) => {
  if (!dateTimeString) return '-'
  try {
    const date = new Date(dateTimeString)
    return date.toLocaleString('es-MX')
  } catch (error) {
    return dateTimeString
  }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const loadPagos = async () => {
  loading.value = true
  try {
    const response = await execute(
      'spcob34_gpagados',
      BASE_DB,
      [{ nombre: 'p_Control', valor: props.idDatos, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      pagos.value = response.result
    } else {
      pagos.value = []
    }
  } catch (error) {
    handleApiError(error)
    pagos.value = []
  } finally {
    loading.value = false
  }
}

const close = () => {
  emit('close')
}

onMounted(() => {
  loadPagos()
})
</script>
