<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="check-circle" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagados</h1>
        <p>Otras Obligaciones - Historial de pagos por local</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Control:</label>
              <div class="control-inputs">
                <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" />
                <span class="separator">-</span>
                <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" />
              </div>
            </div>
            <div class="form-group">
              <button class="btn-municipal-primary" @click="handleBuscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="pagos.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Historial de Pagos ({{ pagos.length }})</h5>
          <div class="button-group">
            <button class="btn-municipal-success" @click="handleImprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table table-municipal">
              <thead class="municipal-table-header">
                <tr>
                  <th>Periodo</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargo</th>
                  <th>Fecha Pago</th>
                  <th>Folio</th>
                  <th>Usuario</th>
                  <th>Caja</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(pago, index) in pagos" :key="index">
                  <td>{{ pago.periodo }}</td>
                  <td class="text-right">{{ formatCurrency(pago.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(pago.recargo) }}</td>
                  <td>{{ pago.fecha_hora_pago }}</td>
                  <td>{{ pago.folio_recibo }}</td>
                  <td>{{ pago.usuario }}</td>
                  <td>{{ pago.caja }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="totales-container">
            <strong>Total Pagado: {{ formatCurrency(totalPagado) }}</strong>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de Ayuda y Documentacion -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'RPagados'"
      :moduleName="'otras_obligaciones'"
      :docType="docType"
      :title="'Reporte de Pagados'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const { handleApiError, showToast } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

// Documentacion y Ayuda
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
const pagos = ref([])
const datosLocal = ref({})

const formData = reactive({
  numero: '',
  letra: ''
})

const totalPagado = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (pago.importe || 0) + (pago.recargo || 0), 0)
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  const startTime = performance.now()
  showLoading('Buscando pagos del local...')

  try {
    const control = formData.letra ? `${formData.numero}-${formData.letra}` : formData.numero
    const localResponse = await execute(
      'gconsulta2_sp_busca_cont',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' }
      ],
      'guadalajara'
    )

    if (!localResponse?.result || localResponse.result.length === 0 || localResponse.result[0].status === -1) {
      hideLoading()
      showToast('warning', 'No se encontró el local')
      return
    }

    datosLocal.value = localResponse.result[0]

    const pagosResponse = await execute(
      'sp_rpagados_get_pagados_by_control',
      BASE_DB,
      [{ nombre: 'p_control', valor: datosLocal.value.id_datos, tipo: 'integer' }],
      'guadalajara'
    )

    pagos.value = pagosResponse?.result || []
    hideLoading()

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    if (pagos.value.length === 0) {
      showToast('info', 'No hay pagos registrados para este local', timeMessage)
    } else {
      showToast('success', `Se encontraron ${pagos.value.length} pagos`, timeMessage)
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const handleExportar = () => {
  const startTime = performance.now()

  const dataExport = pagos.value.map(pago => ({
    'Periodo': pago.periodo,
    'Importe': pago.importe,
    'Recargo': pago.recargo,
    'Total': pago.importe + pago.recargo,
    'Fecha Pago': pago.fecha_hora_pago,
    'Folio': pago.folio_recibo,
    'Usuario': pago.usuario,
    'Caja': pago.caja
  }))

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Pagos')
  XLSX.writeFile(wb, `Pagos_${Date.now()}.xlsx`)

  const endTime = performance.now()
  const duration = ((endTime - startTime) / 1000).toFixed(2)
  const timeMessage = duration < 1
    ? `${(duration * 1000).toFixed(0)}ms`
    : `${duration}s`

  showToast('success', 'Exportación exitosa', timeMessage)
}

const handleImprimir = () => {
  if (pagos.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const columns = [
    { header: 'Periodo', key: 'periodo', type: 'string' },
    { header: 'Importe', key: 'importe', type: 'currency' },
    { header: 'Recargo', key: 'recargo', type: 'currency' },
    { header: 'Total', key: 'total', type: 'currency' },
    { header: 'Fecha Pago', key: 'fecha_hora_pago', type: 'string' },
    { header: 'Folio', key: 'folio_recibo', type: 'string' },
    { header: 'Caja', key: 'caja', type: 'string' }
  ]

  const data = pagos.value.map(p => ({
    ...p,
    total: (p.importe || 0) + (p.recargo || 0)
  }))

  const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`

  exportToPdf(data, columns, {
    title: 'Reporte de Pagados - Rastro',
    subtitle: `Control: ${control} - Total: ${formatCurrency(totalPagado.value)}`,
    orientation: 'landscape'
  })
}

const goBack = () => {
  router.push('/otras-obligaciones/menu')
}
</script>

<style>
/* Estilos en municipal-theme.css */
</style>
