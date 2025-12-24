<template>
  <div class="export-buttons d-flex gap-2" :class="containerClass">
    <!-- Botón Excel -->
    <button
      v-if="showExcel"
      type="button"
      class="btn btn-success btn-sm"
      :class="buttonClass"
      :disabled="disabled || !hasData"
      @click="handleExportExcel"
      :title="excelTitle"
    >
      <i class="fas fa-file-excel me-1"></i>
      <span v-if="showLabels">{{ excelLabel }}</span>
    </button>

    <!-- Botón PDF -->
    <button
      v-if="showPdf"
      type="button"
      class="btn btn-danger btn-sm"
      :class="buttonClass"
      :disabled="disabled || !hasData"
      @click="handleExportPdf"
      :title="pdfTitle"
    >
      <i class="fas fa-file-pdf me-1"></i>
      <span v-if="showLabels">{{ pdfLabel }}</span>
    </button>

    <!-- Botón Imprimir -->
    <button
      v-if="showPrint"
      type="button"
      class="btn btn-secondary btn-sm"
      :class="buttonClass"
      :disabled="disabled || !hasData"
      @click="handlePrint"
      :title="printTitle"
    >
      <i class="fas fa-print me-1"></i>
      <span v-if="showLabels">{{ printLabel }}</span>
    </button>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useExcelExport } from '@/composables/useExcelExport'
import { usePdfExport } from '@/composables/usePdfExport'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from 'vue-toastification'

// Props
const props = defineProps({
  // Datos a exportar
  data: {
    type: Array,
    required: true
  },
  // Definición de columnas [{header, key, type?, width?}]
  columns: {
    type: Array,
    required: true
  },
  // Nombre base del archivo (sin extensión)
  filename: {
    type: String,
    default: 'export'
  },
  // Título para el reporte PDF
  reportTitle: {
    type: String,
    default: 'Reporte'
  },
  // Subtítulo opcional para PDF
  reportSubtitle: {
    type: String,
    default: ''
  },
  // Mostrar botón Excel
  showExcel: {
    type: Boolean,
    default: true
  },
  // Mostrar botón PDF
  showPdf: {
    type: Boolean,
    default: true
  },
  // Mostrar botón Imprimir
  showPrint: {
    type: Boolean,
    default: false
  },
  // Mostrar etiquetas en botones
  showLabels: {
    type: Boolean,
    default: true
  },
  // Deshabilitado
  disabled: {
    type: Boolean,
    default: false
  },
  // Clase CSS adicional para contenedor
  containerClass: {
    type: String,
    default: ''
  },
  // Clase CSS adicional para botones
  buttonClass: {
    type: String,
    default: ''
  },
  // Orientación PDF: portrait | landscape
  orientation: {
    type: String,
    default: 'portrait'
  },
  // Mostrar totales en PDF
  showTotals: {
    type: Boolean,
    default: false
  },
  // Columnas a totalizar (array de keys)
  totalColumns: {
    type: Array,
    default: () => []
  },
  // Labels personalizados
  excelLabel: {
    type: String,
    default: 'Excel'
  },
  pdfLabel: {
    type: String,
    default: 'PDF'
  },
  printLabel: {
    type: String,
    default: 'Imprimir'
  },
  // Tooltips
  excelTitle: {
    type: String,
    default: 'Exportar a Excel'
  },
  pdfTitle: {
    type: String,
    default: 'Exportar a PDF'
  },
  printTitle: {
    type: String,
    default: 'Imprimir reporte'
  }
})

// Emits
const emit = defineEmits(['export-excel', 'export-pdf', 'print', 'error'])

// Composables
const { exportToExcel } = useExcelExport()
const { exportToPdf, printDirect } = usePdfExport()
const { showLoading, hideLoading } = useGlobalLoading()
const toast = useToast()

// Computed
const hasData = computed(() => {
  return props.data && props.data.length > 0
})

// Methods
const handleExportExcel = async () => {
  if (!hasData.value) {
    toast.warning('No hay datos para exportar')
    return
  }

  showLoading('Generando Excel...', 'Por favor espere')

  try {
    // Pequeño delay para que se muestre el loading
    await new Promise(resolve => setTimeout(resolve, 100))

    const success = exportToExcel(props.data, props.columns, props.filename)

    if (success) {
      toast.success('Excel generado correctamente')
      emit('export-excel', { success: true, count: props.data.length })
    } else {
      toast.error('Error al generar Excel')
      emit('error', { type: 'excel', message: 'Error al generar Excel' })
    }
  } catch (error) {
    console.error('ExportButtons: Error Excel', error)
    toast.error('Error al generar Excel')
    emit('error', { type: 'excel', message: error.message })
  } finally {
    hideLoading()
  }
}

const handleExportPdf = async () => {
  if (!hasData.value) {
    toast.warning('No hay datos para exportar')
    return
  }

  showLoading('Generando PDF...', 'Por favor espere')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    const success = exportToPdf(props.data, props.columns, {
      title: props.reportTitle,
      subtitle: props.reportSubtitle,
      orientation: props.orientation,
      showTotal: props.showTotals,
      totalColumns: props.totalColumns
    })

    if (success) {
      toast.success('PDF generado correctamente')
      emit('export-pdf', { success: true, count: props.data.length })
    } else {
      toast.error('Error al generar PDF. Verifique que no tenga bloqueador de popups.')
      emit('error', { type: 'pdf', message: 'Error al generar PDF' })
    }
  } catch (error) {
    console.error('ExportButtons: Error PDF', error)
    toast.error('Error al generar PDF')
    emit('error', { type: 'pdf', message: error.message })
  } finally {
    hideLoading()
  }
}

const handlePrint = async () => {
  if (!hasData.value) {
    toast.warning('No hay datos para imprimir')
    return
  }

  try {
    printDirect(props.data, props.columns, {
      title: props.reportTitle,
      subtitle: props.reportSubtitle,
      orientation: props.orientation,
      showTotal: props.showTotals,
      totalColumns: props.totalColumns
    })

    emit('print', { success: true, count: props.data.length })
  } catch (error) {
    console.error('ExportButtons: Error Print', error)
    toast.error('Error al imprimir')
    emit('error', { type: 'print', message: error.message })
  }
}
</script>

<style scoped>
.export-buttons {
  flex-wrap: wrap;
}

.export-buttons .btn {
  white-space: nowrap;
}

.export-buttons .btn:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}
</style>
