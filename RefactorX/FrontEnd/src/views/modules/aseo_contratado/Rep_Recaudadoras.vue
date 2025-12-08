<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building-columns" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Recaudadoras</h1>
        <p>Aseo Contratado - Resumen de actividad por recaudadora</p>
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
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Período del Reporte</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Desde</label>
            <input type="date" class="municipal-form-control" v-model="parametros.fechaDesde" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha Hasta</label>
            <input type="date" class="municipal-form-control" v-model="parametros.fechaHasta" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Recaudadora</label>
            <select class="municipal-form-control" v-model="parametros.recaudadora">
              <option value="">Todas</option>
              <option v-for="rec in recaudadoras" :key="rec.num_recaudadora" :value="rec.num_recaudadora">
                {{ rec.nombre_recaudadora }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-info w-100" @click="generarReporte" :disabled="cargando">
              <font-awesome-icon icon="chart-bar" /> Generar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="datosReporte.length > 0">
      <div class="row mb-3">
        <div class="col-md-3">
          <div class="municipal-card bg-info text-white">
            <div class="municipal-card-body">
              <h6>Recaudadoras Activas</h6>
              <h2>{{ datosReporte.length }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-success text-white">
            <div class="municipal-card-body">
              <h6>Total Pagos</h6>
              <h2>{{ totalPagos }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-primary text-white">
            <div class="municipal-card-body">
              <h6>Monto Total</h6>
              <h2>${{ formatCurrency(montoTotal) }}</h2>
            </div>
          </div>
        </div>
        <div class="col-md-3">
          <div class="municipal-card bg-warning text-dark">
            <div class="municipal-card-body">
              <h6>Promedio por Recaudadora</h6>
              <h2>${{ formatCurrency(promedioPorRecaudadora) }}</h2>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Detalle por Recaudadora</h6>
          <div>
            <button class="btn btn-sm btn-success me-2" @click="exportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <button class="btn btn-sm btn-danger" @click="imprimir">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table-sm table-bordered">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Recaudadora</th>
                  <th class="text-end">Núm. Pagos</th>
                  <th class="text-end">Monto Total</th>
                  <th class="text-end">Promedio por Pago</th>
                  <th class="text-end">% del Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in datosReporte" :key="item.num_recaudadora">
                  <td>{{ index + 1 }}</td>
                  <td>{{ item.nombre_recaudadora }}</td>
                  <td class="text-end">{{ item.num_pagos }}</td>
                  <td class="text-end">${{ formatCurrency(item.monto_total) }}</td>
                  <td class="text-end">${{ formatCurrency(item.promedio) }}</td>
                  <td class="text-end">
                    <span class="badge badge-primary">{{ calcularPorcentaje(item.monto_total) }}%</span>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <th colspan="2">TOTALES</th>
                  <th class="text-end">{{ totalPagos }}</th>
                  <th class="text-end">${{ formatCurrency(montoTotal) }}</th>
                  <th class="text-end">${{ formatCurrency(promedioGeneral) }}</th>
                  <th class="text-end">100%</th>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Reporte de Recaudadoras">
      <h6>Descripción</h6>
      <p>Genera un resumen de la actividad de recaudación por entidad recaudadora.</p>
      <h6>Información Incluida</h6>
      <ul>
        <li>Número de pagos procesados</li>
        <li>Monto total recaudado</li>
        <li>Promedio por pago</li>
        <li>Porcentaje de participación</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rep_Recaudadoras'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const datosReporte = ref([])
const recaudadoras = ref([])

const parametros = ref({
  fechaDesde: '',
  fechaHasta: new Date().toISOString().split('T')[0],
  recaudadora: ''
})

const totalPagos = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseInt(item.num_pagos || 0), 0)
})

const montoTotal = computed(() => {
  return datosReporte.value.reduce((sum, item) => sum + parseFloat(item.monto_total || 0), 0)
})

const promedioPorRecaudadora = computed(() => {
  return datosReporte.value.length > 0 ? montoTotal.value / datosReporte.value.length : 0
})

const promedioGeneral = computed(() => {
  return totalPagos.value > 0 ? montoTotal.value / totalPagos.value : 0
})

const calcularPorcentaje = (monto) => {
  return montoTotal.value > 0 ? ((monto / montoTotal.value) * 100).toFixed(2) : 0
}

const generarReporte = async () => {
  if (!parametros.value.fechaHasta) {
    return showToast('Seleccione al menos la fecha hasta', 'warning')
  }

  cargando.value = true
  try {
    const params = {
      p_fecha_desde: parametros.value.fechaDesde || null,
      p_fecha_hasta: parametros.value.fechaHasta,
      p_recaudadora: parametros.value.recaudadora || null
    }
    const response = await execute('SP_ASEO_REPORTE_RECAUDADORAS', 'aseo_contratado', params)
    datosReporte.value = response || []
    showToast(`Reporte generado: ${datosReporte.value.length} recaudadoras`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al generar reporte')
  } finally {
    cargando.value = false
  }
}

const exportar = () => showToast('Exportando a Excel...', 'info')
const imprimir = () => showToast('Preparando impresión...', 'info')

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_RECAUDADORAS_LIST', 'aseo_contratado', {})
    recaudadoras.value = response || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
