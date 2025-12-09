<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-upload" />
      </div>
      <div class="module-view-info">
        <h1>Paso de Tianguis al Padrón</h1>
        <p>Inicio > Operaciones > Paso de Mercados (Tianguis)</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="triggerFileInput" :disabled="loading">
          <font-awesome-icon icon="folder-open" /> Seleccionar Archivo
        </button>
        <button class="btn-municipal-success" @click="ejecutarCarga" :disabled="loading || rows.length === 0">
          <font-awesome-icon icon="play" /> Ejecutar Carga
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
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
              <span class="text-muted">Formato: Archivo de texto (.txt) con datos de Tianguis</span>
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
          <h5><font-awesome-icon icon="list" /> Previsualización de Locales</h5>
          <div class="header-right">
            <span class="badge-purple">{{ rows.length }} registros</span>
            <span class="badge-success ms-2">Total Superficie: {{ formatNumber(totalSuperficie) }} m²</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" style="max-height: 500px;">
            <table class="municipal-table">
              <thead class="municipal-table-header sticky-header">
                <tr>
                  <th>#</th>
                  <th>Folio</th>
                  <th>Nombre</th>
                  <th>Domicilio</th>
                  <th>Superficie</th>
                  <th>Descuento</th>
                  <th>Motivo Descuento</th>
                  <th>Vigencia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in rows" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td><strong class="text-primary">{{ row.folio }}</strong></td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.domicilio }}</td>
                  <td class="text-end">{{ formatNumber(row.superficie) }} m²</td>
                  <td class="text-end">{{ formatNumber(row.descuento) }}%</td>
                  <td>{{ row.motivo_descuento }}</td>
                  <td class="text-center">
                    <span :class="row.vigencia === 'A' ? 'badge-success' : 'badge-secondary'">
                      {{ row.vigencia === 'A' ? 'Activo' : 'Baja' }}
                    </span>
                  </td>
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
            Insertando Locales de Tianguis
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
</template>

<script setup>
import { ref, computed } from 'vue'
import axios from 'axios'

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

const totalSuperficie = computed(() => {
  return rows.value.reduce((sum, row) => sum + parseFloat(row.superficie || 0), 0)
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
  showToast('Seleccione un archivo .txt con datos de Tianguis. El formato debe ser: FOLIO|NOMBRE|DOMICILIO|SUPERFICIE|DESCUENTO|MOTIVO_DESCUENTO|VIGENCIA (Vigencia: A=Activo, B=Baja)', 'info')
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

    if (parts.length < 7) {
      errors.push(`Línea ${lineNum}: Formato inválido - se esperan 7 campos separados por |`)
      return
    }

    const [folio, nombre, domicilio, superficie, descuento, motivo_descuento, vigencia] = parts

    // Validaciones básicas
    if (!folio || isNaN(parseInt(folio))) {
      errors.push(`Línea ${lineNum}: Folio inválido`)
      return
    }
    if (!nombre || nombre.trim().length === 0) {
      errors.push(`Línea ${lineNum}: Nombre requerido`)
      return
    }
    if (!superficie || isNaN(parseFloat(superficie))) {
      errors.push(`Línea ${lineNum}: Superficie inválida`)
      return
    }
    if (!vigencia || !['A', 'B'].includes(vigencia.trim().toUpperCase())) {
      errors.push(`Línea ${lineNum}: Vigencia inválida (debe ser A o B)`)
      return
    }

    parsed.push({
      folio: parseInt(folio),
      nombre: nombre.trim(),
      domicilio: domicilio.trim(),
      superficie: parseFloat(superficie),
      descuento: parseFloat(descuento) || 0,
      motivo_descuento: motivo_descuento.trim(),
      vigencia: vigencia.trim().toUpperCase()
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

  if (!confirm(`¿Está seguro de insertar ${rows.value.length} locales de Tianguis al padrón? Esta acción no se puede deshacer.`)) {
    return
  }

  showProgressModal.value = true
  processedCount.value = 0
  const insertedIds = []
  const errors = []

  for (let i = 0; i < rows.value.length; i++) {
    const row = rows.value[i]
    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_pasomdos_insert_tianguis',
          Base: 'padron_licencias',
          Parametros: [
            { Nombre: 'p_folio', Valor: parseInt(row.folio) },
            { Nombre: 'p_nombre', Valor: row.nombre },
            { Nombre: 'p_domicilio', Valor: row.domicilio },
            { Nombre: 'p_superficie', Valor: parseFloat(row.superficie) },
            { Nombre: 'p_descuento', Valor: parseFloat(row.descuento) },
            { Nombre: 'p_motivo_descuento', Valor: row.motivo_descuento },
            { Nombre: 'p_vigencia', Valor: row.vigencia },
            { Nombre: 'p_id_usuario', Valor: 1 }
          ]
        }
      })

      if (res.data.eResponse.success) {
        const result = res.data.eResponse.data.result[0]
        if (result.success) {
          insertedIds.push(result.id_local)
        } else {
          errors.push(`Folio ${row.folio}: ${result.message}`)
        }
      } else {
        errors.push(`Folio ${row.folio}: ${res.data.eResponse.message}`)
      }
    } catch (err) {
      errors.push(`Folio ${row.folio}: Error de conexión - ${err.message}`)
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
    showToast(`¡Proceso completado! ${insertedIds.length} locales insertados`, 'success')
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

<style scoped>
.file-upload-area {
  border: 2px dashed #ccc;
  border-radius: 8px;
  padding: 3rem 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #fafafa;
}

.file-upload-area:hover {
  border-color: var(--municipal-blue);
  background: #f0f7ff;
}

.file-upload-icon {
  color: #6c757d;
  margin-bottom: 1rem;
}

.file-upload-text {
  margin: 0;
  color: #495057;
}

.file-selected {
  margin-top: 1.5rem;
  padding: 1rem;
  background: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 4px;
  color: #155724;
}

.sticky-header {
  position: sticky;
  top: 0;
  z-index: 10;
  background: var(--municipal-blue);
}

.progress-modal {
  max-width: 500px;
}

.progress-bar-container {
  width: 100%;
  height: 30px;
  background: #e9ecef;
  border-radius: 15px;
  overflow: hidden;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
}

.progress-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--municipal-blue) 0%, #0056b3 100%);
  transition: width 0.3s ease;
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
}

.bg-success {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%) !important;
}

.bg-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%) !important;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
}

.municipal-modal {
  background: white;
  border-radius: 8px;
  max-width: 600px;
  width: 90%;
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.2);
}

.municipal-modal-header {
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, var(--municipal-blue) 0%, var(--municipal-blue-dark) 100%);
  color: white;
  border-radius: 8px 8px 0 0;
}

.municipal-modal-header h5 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.municipal-modal-body {
  padding: 1.5rem;
}
</style>
