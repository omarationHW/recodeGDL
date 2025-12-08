<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-excel" /></div><div class="module-view-info"><h1>Exportar a Excel</h1><p>Exportación de datos a formato Excel</p></div>
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
    </div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="download" /> Exportación</h5></div><div class="municipal-card-body"><p class="text-muted mb-3">Exportar datos de apremios a formato Excel</p><div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="exportar"><font-awesome-icon icon="file-excel" /> Exportar a Excel</button></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ExportarExcel"
    >
      <h3>Exportar Excel</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ExportarExcel'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_EXPORT = 'spd_15_foliospag'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const exportar = async () => {
  showLoading('Exportando a Excel...', 'Generando archivo')
  const t0 = performance.now()
  try {
    const response = await execute(OP_EXPORT, BASE_DB, {
      prec: 0,
      pmod: 0,
      pfold: 0,
      pfolh: 999999,
      pfemi: new Date('2020-01-01'),
      pfpagd: new Date('2020-01-01'),
      pfpagh: new Date()
    })

    // Convertir resultado a CSV/Excel
    let exportData = []
    if (response && response.data) {
      exportData = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      exportData = Array.isArray(response.result) ? response.result : []
    }

    if (exportData.length > 0) {
      // Crear CSV
      const headers = Object.keys(exportData[0]).join(',')
      const csvRows = exportData.map(row => Object.values(row).join(',')).join('\n')
      const csv = headers + '\n' + csvRows

      // Descargar archivo
      const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')
      const url = URL.createObjectURL(blob)
      link.setAttribute('href', url)
      link.setAttribute('download', `folios_pagos_${new Date().toISOString().split('T')[0]}.csv`)
      link.style.visibility = 'hidden'
      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
    }

    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    showToast('success', `Exportación completada en ${txt}`)
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
