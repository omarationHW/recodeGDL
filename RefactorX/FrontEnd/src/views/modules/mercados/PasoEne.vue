<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-upload" />
      </div>
      <div class="module-view-info">
        <h1>Paso de Pagos de Energía</h1>
        <p>Inicio > Operaciones > Paso Pagos Energía</p>
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
        
        <button class="btn-municipal-primary" @click="triggerFileInput" :disabled="loading">
          <font-awesome-icon icon="folder-open" /> Seleccionar Archivo
        </button>
        <button class="btn-municipal-primary" @click="ejecutarCarga" :disabled="loading || rows.length === 0">
          <font-awesome-icon icon="play" /> Ejecutar Carga
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-alt" /> Carga de Archivo TXT</h5>
        </div>
        <div class="municipal-card-body">
          <div class="file-upload-area" @click="triggerFileInput" @dragover.prevent @drop.prevent="handleDrop">
            <input type="file" ref="fileInput" @change="handleFileSelect" accept=".txt" style="display: none;" />
            <div class="file-upload-icon">
              <font-awesome-icon icon="cloud-upload-alt" size="3x" />
            </div>
            <p class="file-upload-text">
              <strong>Haga clic o arrastre un archivo aquí</strong><br />
              <span class="text-muted">Formato: Archivo de texto (.txt) con pagos de energía</span>
            </p>
            <div v-if="fileName" class="file-selected">
              <font-awesome-icon icon="file-alt" class="text-success" />
              <strong>{{ fileName }}</strong> ({{ fileSize }})
            </div>
          </div>

          <div v-if="parseErrors.length > 0" class="alert alert-danger mt-3">
            <strong><font-awesome-icon icon="exclamation-triangle" /> Errores de Formato:</strong>
            <ul class="mb-0 mt-2">
              <li v-for="(err, idx) in parseErrors" :key="idx">{{ err }}</li>
            </ul>
          </div>

          <div v-if="fileName && rows.length === 0 && parseErrors.length === 0 && !loading" class="alert alert-warning mt-3">
            <font-awesome-icon icon="info-circle" /> El archivo está vacío o no contiene registros válidos
          </div>
        </div>
      </div>

      <div v-if="rows.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Previsualización de Pagos</h5>
          <div class="header-right">
            <span class="badge-purple">{{ rows.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" style="max-height: 500px;">
            <table class="municipal-table">
              <thead class="municipal-table-header sticky-header">
                <tr>
                  <th>#</th>
                  <th>ID Energía</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th class="text-end">Importe</th>
                  <th>Consumo</th>
                  <th class="text-end">Cantidad</th>
                  <th>Folio</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in rows" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td><strong class="text-primary">{{ row.id_energia }}</strong></td>
                  <td class="text-center">{{ row.axo }}</td>
                  <td class="text-center">{{ row.periodo }}</td>
                  <td class="text-center">{{ row.fecha_pago }}</td>
                  <td class="text-center">{{ row.oficina_pago }}</td>
                  <td class="text-center">{{ row.caja_pago }}</td>
                  <td class="text-center">{{ row.operacion_pago }}</td>
                  <td class="text-end">{{ formatCurrency(row.importe_pago) }}</td>
                  <td class="text-center">{{ row.consumo }}</td>
                  <td class="text-end">{{ formatNumber(row.cantidad) }}</td>
                  <td class="text-center">{{ row.folio }}</td>
                  <td class="text-center">{{ row.id_usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="processResult.show" class="municipal-card mt-3">
        <div class="municipal-card-header" :class="processResult.type === 'success' ? 'bg-success' : 'bg-danger'">
          <h5 class="text-white">
            <font-awesome-icon :icon="processResult.type === 'success' ? 'check-circle' : 'times-circle'" />
            Resultado de la Carga
          </h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="processResult.type === 'success'">
            <div class="alert alert-success mb-3">
              <strong><font-awesome-icon icon="check-circle" /> Proceso completado</strong><br />
              <span class="fs-4">{{ processResult.inserted }} de {{ rows.length }} registros insertados correctamente</span>
            </div>
            <div v-if="processResult.errors.length > 0" class="alert alert-warning">
              <strong><font-awesome-icon icon="exclamation-triangle" /> Errores encontrados ({{ processResult.errors.length }}):</strong>
              <ul class="mb-0 mt-2" style="max-height: 200px; overflow-y: auto;">
                <li v-for="(err, idx) in processResult.errors" :key="idx">{{ err }}</li>
              </ul>
            </div>
          </div>
          <div v-else>
            <div class="alert alert-danger">
              <strong><font-awesome-icon icon="times-circle" /> Error en el proceso:</strong>
              <ul class="mb-0 mt-2">
                <li v-for="(err, idx) in processResult.errors" :key="idx">{{ err }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Progress Modal -->
    <div v-if="showProgressModal" class="modal-overlay">
      <div class="municipal-modal progress-modal">
        <div class="municipal-modal-header">
          <h5>
            <font-awesome-icon icon="spinner" spin />
            Procesando Pagos de Energía
          </h5>
        </div>
        <div class="municipal-modal-body">
          <p class="text-center mb-3">Insertando registros en la base de datos...</p>
          <div class="progress-bar-container">
            <div class="progress-bar-fill" :style="{ width: progressPercent + '%' }"></div>
          </div>
          <p class="text-center mt-2 text-muted">
            {{ processedCount }} de {{ rows.length }} registros ({{ progressPercent }}%)
          </p>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'PasoEne'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - PasoEne'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'PasoEne'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - PasoEne'" @close="showDocumentacion = false" />
</template>

<script setup>
import Swal from 'sweetalert2'

// Helpers de confirmación SweetAlert
const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, computed } from 'vue'
import axios from 'axios'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const fileInput = ref(null)
const fileName = ref('')
const fileSize = ref('')
const rows = ref([])
const parseErrors = ref([])
const loading = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })
const processResult = ref({ show: false, type: 'success', inserted: 0, errors: [] })
const showProgressModal = ref(false)
const processedCount = ref(0)

const totalImporte = computed(() => {
  return rows.value.reduce((sum, row) => sum + parseFloat(row.importe_pago || 0), 0)
})

const progressPercent = computed(() => {
  if (rows.value.length === 0) return 0
  return Math.round((processedCount.value / rows.value.length) * 100)
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('Seleccione un archivo .txt con pagos de energía. El formato debe ser: ID_ENERGIA|AXO|PERIODO|FECHA_PAGO|OFICINA|CAJA|OPERACION|IMPORTE|CONSUMO|CANTIDAD|FOLIO|FECHA_ACT|USUARIO', 'info')
}

const triggerFileInput = () => {
  if (!loading.value) {
    fileInput.value.click()
  }
}

const handleDrop = (e) => {
  if (loading.value) return
  const file = e.dataTransfer.files[0]
  if (file && file.name.endsWith('.txt')) {
    processFile(file)
  } else {
    showToast('Por favor seleccione un archivo .txt', 'error')
  }
}

const handleFileSelect = (e) => {
  const file = e.target.files[0]
  if (file) {
    processFile(file)
  }
}

const processFile = (file) => {
  fileName.value = file.name
  fileSize.value = formatFileSize(file.size)
  rows.value = []
  parseErrors.value = []
  processResult.value.show = false
  loading.value = true

  const reader = new FileReader()
  reader.onload = (evt) => {
    try {
      const content = evt.target.result
      parseFileContent(content)
    } catch (err) {
      parseErrors.value.push('Error al leer el archivo: ' + err.message)
    } finally {
      loading.value = false
    }
  }
  reader.onerror = () => {
    parseErrors.value.push('Error al leer el archivo')
    loading.value = false
  }
  reader.readAsText(file, 'UTF-8')
}

const parseFileContent = (content) => {
  const lines = content.split(/\r?\n/).filter(line => line.trim().length > 0)
  const parsed = []
  const errors = []

  lines.forEach((line, idx) => {
    const lineNum = idx + 1
    const parts = line.split('|')

    if (parts.length < 13) {
      errors.push(`Línea ${lineNum}: Formato inválido - se esperan 13 campos separados por |`)
      return
    }

    const [id_energia, axo, periodo, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, consumo, cantidad, folio, fecha_actualizacion, id_usuario] = parts

    // Validaciones básicas
    if (!id_energia || isNaN(parseInt(id_energia))) {
      errors.push(`Línea ${lineNum}: ID Energía inválido`)
      return
    }
    if (!axo || isNaN(parseInt(axo))) {
      errors.push(`Línea ${lineNum}: Año inválido`)
      return
    }
    if (!periodo || isNaN(parseInt(periodo))) {
      errors.push(`Línea ${lineNum}: Periodo inválido`)
      return
    }
    if (!importe_pago || isNaN(parseFloat(importe_pago))) {
      errors.push(`Línea ${lineNum}: Importe inválido`)
      return
    }

    parsed.push({
      id_energia: parseInt(id_energia),
      axo: parseInt(axo),
      periodo: parseInt(periodo),
      fecha_pago: fecha_pago.trim(),
      oficina_pago: parseInt(oficina_pago) || 0,
      caja_pago: caja_pago.trim(),
      operacion_pago: parseInt(operacion_pago) || 0,
      importe_pago: parseFloat(importe_pago),
      consumo: consumo.trim(),
      cantidad: parseFloat(cantidad) || 0,
      folio: folio.trim(),
      fecha_actualizacion: fecha_actualizacion.trim(),
      id_usuario: parseInt(id_usuario) || 1
    })
  })

  rows.value = parsed
  parseErrors.value = errors

  if (parsed.length > 0) {
    showToast(`${parsed.length} registros cargados correctamente`, 'success')
  }
  if (errors.length > 0) {
    showToast(`${errors.length} líneas con errores fueron omitidas`, 'warning')
  }
}

const ejecutarCarga = async () => {
  if (rows.value.length === 0) {
    showToast('No hay registros para procesar', 'warning')
    return
  }

  if (!confirm(`¿Está seguro de insertar ${rows.value.length} pagos de energía? Esta acción no se puede deshacer.`)) {
    return
  }

  showProgressModal.value = true
  processedCount.value = 0
  const insertedIds = []
  const errors = []

  for (let i = 0; i < rows.value.length; i++) {
    const row = rows.value[i]
    try {
      const res = await apiService.execute(
          'sp_pasoene_insert_pagoenergia',
          'mercados',
          [
            { nombre: 'p_id_energia', valor: parseInt(row.id_energia) },
            { nombre: 'p_axo', valor: parseInt(row.axo) },
            { nombre: 'p_periodo', valor: parseInt(row.periodo) },
            { nombre: 'p_fecha_pago', valor: row.fecha_pago },
            { nombre: 'p_oficina_pago', valor: parseInt(row.oficina_pago) },
            { nombre: 'p_caja_pago', valor: row.caja_pago },
            { nombre: 'p_operacion_pago', valor: parseInt(row.operacion_pago) },
            { nombre: 'p_importe_pago', valor: parseFloat(row.importe_pago) },
            { nombre: 'p_consumo', valor: row.consumo },
            { nombre: 'p_cantidad', valor: parseFloat(row.cantidad) },
            { nombre: 'p_folio', valor: row.folio },
            { nombre: 'p_fecha_actualizacion', valor: row.fecha_actualizacion },
            { nombre: 'p_id_usuario', valor: parseInt(row.id_usuario) }
          ],
          '',
          null,
          'publico'
        )

      if (res.success) {
        const result = res.data.result[0]
        if (result.success) {
          insertedIds.push(result.id_pago_energia)
        } else {
          errors.push(`Registro ${i + 1}: ${result.message}`)
        }
      } else {
        errors.push(`Registro ${i + 1}: ${res.message}`)
      }
    } catch (err) {
      errors.push(`Registro ${i + 1}: Error de conexión`)
    }
    processedCount.value = i + 1
  }

  showProgressModal.value = false
  processResult.value = {
    show: true,
    type: insertedIds.length > 0 ? 'success' : 'error',
    inserted: insertedIds.length,
    errors: errors
  }

  if (insertedIds.length === rows.value.length) {
    showToast(`¡Proceso completado! ${insertedIds.length} registros insertados`, 'success')
    // Limpiar después de inserción exitosa completa
    setTimeout(() => {
      rows.value = []
      fileName.value = ''
      fileSize.value = ''
      fileInput.value.value = ''
    }, 3000)
  } else if (insertedIds.length > 0) {
    showToast(`Proceso completado con errores: ${insertedIds.length} insertados, ${errors.length} fallidos`, 'warning')
  } else {
    showToast('No se pudieron insertar registros', 'error')
  }
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (val) => {
  if (val === null || val === undefined) return '0'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatFileSize = (bytes) => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}
</script>
