<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Salvadas</h1>
        <p>Inicio > Mercados > Reporte de Salvadas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="fetchReport">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Inicio <span class="required">*</span></label>
                <input type="date" v-model="filters.start_date" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Fin <span class="required">*</span></label>
                <input type="date" v-model="filters.end_date" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Oficina</label>
                <input type="number" v-model="filters.oficina" class="municipal-form-control" placeholder="1" />
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-12 text-end">
                <button type="submit" class="btn-municipal-primary" :disabled="!filters.start_date || !filters.end_date || loading">
                  <font-awesome-icon icon="file-chart-line" /> Generar Reporte
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <div v-if="report.length" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="table" /> Resultados del Reporte</h5>
          <div class="header-right"><span class="badge-purple">{{ report.length }} registros</span></div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th>#</th><th>Fecha</th><th>Descripcion</th><th class="text-end">Valor</th></tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in report" :key="idx" class="row-hover">
                  <td>{{ idx + 1 }}</td>
                  <td>{{ row.fecha || row.fecha_pago }}</td>
                  <td>{{ row.descripcion || row.mercado || 'Pago' }}</td>
                  <td class="text-end"><strong class="text-info">{{ row.valor || row.importe || 0 }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="reportRequested && !loading" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No se encontraron resultados para el rango seleccionado</p>
      </div>
    </div>
  </div>
  <DocumentationModal :show="showAyuda" :component-name="'RprtSalvadas'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RprtSalvadas'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RprtSalvadas'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RprtSalvadas'" @close="showDocumentacion = false" />
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)

const BASE_DB = 'mercados'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { showToast } = useToast()

const filters = ref({ start_date: '', end_date: '', oficina: 1 })
const report = ref([])
const reportRequested = ref(false)

const fetchReport = async () => {
  reportRequested.value = true
  report.value = []
  try {
    const params = [
      { nombre: 'p_fecha_desde', tipo: 'date', valor: filters.value.start_date },
      { nombre: 'p_fecha_hasta', tipo: 'date', valor: filters.value.end_date },
      { nombre: 'p_oficina', tipo: 'integer', valor: parseInt(filters.value.oficina) || 1 }
    ]
    const response = await execute('sp_rpt_pagos_locales', BASE_DB, params, '', null, SCHEMA)
    const data = response?.result || response || []
    report.value = Array.isArray(data) ? data : []
    showToast('Reporte generado: ' + report.value.length + ' registros', 'success')
  } catch (err) {
    showToast('Error: ' + err.message, 'error')
    console.error('Error en fetchReport:', err)
  }
}
</script>
