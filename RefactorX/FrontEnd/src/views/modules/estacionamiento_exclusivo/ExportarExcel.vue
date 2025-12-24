<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-excel" />
      </div>
      <div class="module-view-info">
        <h1>Exportar a Excel</h1>
        <p>Exportación de datos de apremios a formato Excel</p>
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
      <!-- Tarjeta de exportación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="download" />
            Exportación de Datos
          </h5>
        </div>
        <div class="municipal-card-body">
          <p class="text-muted mb-3">
            Exportar datos de folios de pago de apremios a formato Excel (CSV)
          </p>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="exportar">
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ExportarExcel'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Exportar a Excel'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

// Configuración del módulo
const BASE_DB = 'estacionamiento_exclusivo'
const OP_EXPORT = 'spd_15_foliospag'

// Composables
const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Función de exportación
const exportar = async () => {
  showLoading('Exportando a Excel...', 'Generando archivo CSV')
  const startTime = performance.now()

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

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      toast.value.duration = durationText
      showToast('success', `Exportación completada - ${exportData.length} registros`)
    } else {
      showToast('warning', 'No hay datos para exportar')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

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

</script>
