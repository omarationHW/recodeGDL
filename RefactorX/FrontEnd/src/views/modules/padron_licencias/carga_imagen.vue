<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="images" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Imágenes</h1>
        <p>Padrón de Licencias - Gestión de Imágenes y Documentos Digitalizados</p>
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
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openUploadModal"
          :disabled="!tramiteInfo"
        >
          <font-awesome-icon icon="upload" />
          Cargar Imagen
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de trámite -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Trámite/Licencia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="searchTramite"
              placeholder="Ingrese número de trámite o licencia"
              @keyup.enter="loadTramiteInfo"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="loadTramiteInfo"
            :disabled="!searchTramite"
          >
            <font-awesome-icon icon="search" />
            Buscar Trámite
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearSearch"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información del trámite -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Información del Trámite
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="tramite-info-grid">
          <div class="info-item">
            <label>Número de Trámite:</label>
            <strong>{{ tramiteInfo.numero_tramite || 'N/A' }}</strong>
          </div>
          <div class="info-item">
            <label>Licencia:</label>
            <strong>{{ tramiteInfo.numero_licencia || 'N/A' }}</strong>
          </div>
          <div class="info-item">
            <label>Propietario:</label>
            <strong>{{ tramiteInfo.propietario || 'N/A' }}</strong>
          </div>
          <div class="info-item">
            <label>Giro:</label>
            <strong>{{ tramiteInfo.giro || 'N/A' }}</strong>
          </div>
          <div class="info-item">
            <label>Estado:</label>
            <span class="badge badge-purple">{{ tramiteInfo.estado || 'N/A' }}</span>
          </div>
          <div class="info-item">
            <label>Fecha:</label>
            <strong>{{ formatDate(tramiteInfo.fecha) }}</strong>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de documentos/imágenes -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="images" />
          Documentos Digitalizados
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="documentos.length > 0">{{ documentos.length }} documentos</span>
        </div>
      </div>

      <div class="municipal-card-body">
        <div class="documents-grid">
          <div v-for="doc in documentos" :key="doc.id" class="document-card">
            <div class="document-thumbnail">
              <div v-if="doc.tipo_archivo === 'pdf'" class="pdf-icon">
                <font-awesome-icon icon="file-pdf" size="3x" />
              </div>
              <img v-else :src="doc.url_thumbnail" :alt="doc.tipo_documento" @error="handleImageError">
            </div>
            <div class="document-info">
              <h6>{{ doc.tipo_documento }}</h6>
              <p class="document-meta">
                <small>
                  <font-awesome-icon icon="calendar" />
                  {{ formatDate(doc.fecha_carga) }}
                </small>
                <small>
                  <font-awesome-icon icon="file" />
                  {{ formatFileSize(doc.tamano) }}
                </small>
              </p>
            </div>
            <div class="document-actions">
              <button
                class="btn-municipal-info btn-sm"
                @click.stop="viewImage(doc)"
                title="Ver documento"
              >
                <font-awesome-icon icon="eye" />
              </button>
              <button
                class="btn-municipal-primary btn-sm"
                @click.stop="downloadImage(doc)"
                title="Descargar"
              >
                <font-awesome-icon icon="download" />
              </button>
              <button
                class="btn-municipal-danger btn-sm"
                @click.stop="confirmDeleteImage(doc)"
                title="Eliminar"
              >
                <font-awesome-icon icon="trash" />
              </button>
            </div>
          </div>
          <div v-if="documentos.length === 0" class="no-documents">
            <font-awesome-icon icon="images" size="3x" class="empty-icon" />
            <p>No hay documentos digitalizados para este trámite</p>
            <button class="btn-municipal-primary" @click="openUploadModal">
              <font-awesome-icon icon="upload" />
              Cargar primer documento
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de carga de imagen -->
    <Modal
      :show="showUploadModal"
      title="Cargar Imagen/Documento"
      size="lg"
      @close="showUploadModal = false"
      @confirm="uploadImage"
      :loading="uploading"
      confirmText="Subir Documento"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="uploadImage">
        <div class="form-group">
          <label class="municipal-form-label">Tipo de Documento: <span class="required">*</span></label>
          <select class="municipal-form-control" v-model="uploadForm.tipoDocumento" required>
            <option value="">Seleccionar tipo...</option>
            <option v-for="tipo in documentTypes" :key="tipo.id" :value="tipo.id">
              {{ tipo.nombre }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label class="municipal-form-label">Archivo: <span class="required">*</span></label>
          <div
            class="file-drop-zone"
            :class="{ 'drag-over': isDragging, 'has-file': uploadForm.file }"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleDrop"
            @click="triggerFileInput"
          >
            <input
              ref="fileInput"
              type="file"
              accept="image/*,application/pdf"
              @change="handleFileSelect"
              style="display: none"
            >
            <div v-if="!uploadForm.file" class="drop-zone-content">
              <font-awesome-icon icon="cloud-upload-alt" size="3x" class="upload-icon" />
              <p><strong>Arrastra un archivo aquí</strong></p>
              <p>o haz clic para seleccionar</p>
              <p class="text-muted"><small>Formatos aceptados: JPG, PNG, PDF (máx. 5MB)</small></p>
            </div>
            <div v-else class="file-preview">
              <font-awesome-icon
                :icon="uploadForm.file.type === 'application/pdf' ? 'file-pdf' : 'file-image'"
                size="3x"
                :class="uploadForm.file.type === 'application/pdf' ? 'text-danger' : 'text-primary'"
              />
              <p><strong>{{ uploadForm.file.name }}</strong></p>
              <p class="text-muted">{{ formatFileSize(uploadForm.file.size) }}</p>
              <button
                type="button"
                class="btn-municipal-secondary btn-sm"
                @click.stop="clearFile"
              >
                <font-awesome-icon icon="times" />
                Cambiar archivo
              </button>
            </div>
          </div>
          <div v-if="uploadError" class="alert alert-danger mt-2">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ uploadError }}
          </div>
        </div>

        <div v-if="uploadProgress > 0 && uploadProgress < 100" class="form-group">
          <label class="municipal-form-label">Progreso de carga:</label>
          <div class="upload-progress-bar">
            <div class="upload-progress-fill" :style="{ width: `${uploadProgress}%` }">
              {{ uploadProgress }}%
            </div>
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización de imagen -->
    <Modal
      :show="showViewModal"
      :title="`${selectedDoc?.tipo_documento || 'Documento'}`"
      size="xl"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedDoc" class="image-viewer">
        <div v-if="selectedDoc.tipo_archivo === 'pdf'" class="pdf-viewer">
          <font-awesome-icon icon="file-pdf" size="5x" class="text-danger" />
          <p class="mt-3">Vista previa de PDF no disponible</p>
          <button class="btn-municipal-primary mt-2" @click="downloadImage(selectedDoc)">
            <font-awesome-icon icon="download" />
            Descargar PDF
          </button>
        </div>
        <img v-else :src="selectedDoc.url_full" :alt="selectedDoc.tipo_documento" class="full-image">
        <div class="modal-actions mt-3">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="downloadImage(selectedDoc)">
            <font-awesome-icon icon="download" />
            Descargar
          </button>
        </div>
      </div>
    </Modal>

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
      :componentName="'carga_imagen'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Carga de Imágenes'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

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

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const selectedRow = ref(null)
const hasSearched = ref(false)
const searchTramite = ref('')
const tramiteInfo = ref(null)
const documentos = ref([])
const documentTypes = ref([])
const selectedDoc = ref(null)
const showUploadModal = ref(false)
const showViewModal = ref(false)
const uploading = ref(false)
const uploadProgress = ref(0)
const uploadError = ref('')
const isDragging = ref(false)
const fileInput = ref(null)

// Formulario de carga
const uploadForm = ref({
  tipoDocumento: '',
  file: null
})

// Métodos
const loadTramiteInfo = async () => {
  if (!searchTramite.value.trim()) {
    showToast('warning', 'Ingrese un número de trámite o licencia')
    return
  }

  showLoading('Buscando trámite...', 'Consultando información del sistema')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const response = await execute(
      'carga_imagen_sp_get_tramite_info',
      'padron_licencias',
      [
        { nombre: 'p_numero', valor: searchTramite.value.trim(), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      tramiteInfo.value = response.result[0]
      await loadDocumentos()
      await loadDocumentTypes()
      showToast('success', 'Trámite encontrado')
    } else {
      tramiteInfo.value = null
      documentos.value = []
      showToast('warning', 'No se encontró el trámite')
    }
  } catch (error) {
    handleApiError(error)
    tramiteInfo.value = null
    documentos.value = []
  } finally {
    hideLoading()
  }
}

const loadDocumentos = async () => {
  if (!tramiteInfo.value) return

  try {
    const response = await execute(
      'carga_imagen_sp_get_tramite_documents',
      'padron_licencias',
      [
        { nombre: 'p_tramite_id', valor: tramiteInfo.value.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      documentos.value = response.result
    } else {
      documentos.value = []
    }
  } catch (error) {
    handleApiError(error)
    documentos.value = []
  }
}

const loadDocumentTypes = async () => {
  try {
    const response = await execute(
      'carga_imagen_sp_get_document_types',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      documentTypes.value = response.result
    } else {
      documentTypes.value = []
    }
  } catch (error) {
    handleApiError(error)
    documentTypes.value = []
  }
}

const clearSearch = () => {
  searchTramite.value = ''
  tramiteInfo.value = null
  documentos.value = []
  documentTypes.value = []
  hasSearched.value = false
  selectedRow.value = null
}

const openUploadModal = () => {
  uploadForm.value = {
    tipoDocumento: '',
    file: null
  }
  uploadError.value = ''
  uploadProgress.value = 0
  showUploadModal.value = true
}

const triggerFileInput = () => {
  fileInput.value?.click()
}

const handleFileSelect = (event) => {
  const file = event.target.files[0]
  validateAndSetFile(file)
}

const handleDrop = (event) => {
  isDragging.value = false
  const file = event.dataTransfer.files[0]
  validateAndSetFile(file)
}

const validateAndSetFile = (file) => {
  uploadError.value = ''

  if (!file) return

  // Validar tipo de archivo
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf']
  if (!allowedTypes.includes(file.type)) {
    uploadError.value = 'Formato de archivo no permitido. Use JPG, PNG o PDF.'
    return
  }

  // Validar tamaño (5MB máximo)
  const maxSize = 5 * 1024 * 1024 // 5MB en bytes
  if (file.size > maxSize) {
    uploadError.value = 'El archivo excede el tamaño máximo de 5MB.'
    return
  }

  uploadForm.value.file = file
}

const clearFile = () => {
  uploadForm.value.file = null
  uploadError.value = ''
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const uploadImage = async () => {
  if (!uploadForm.value.tipoDocumento || !uploadForm.value.file) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Seleccione el tipo de documento y el archivo',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  uploading.value = true
  uploadProgress.value = 0

  try {
    // Simular progreso de carga
    const progressInterval = setInterval(() => {
      if (uploadProgress.value < 90) {
        uploadProgress.value += 10
      }
    }, 200)

    // Convertir archivo a base64
    const base64 = await fileToBase64(uploadForm.value.file)

    const response = await execute(
      'carga_imagen_sp_upload_document_image',
      'padron_licencias',
      [
        { nombre: 'p_tramite_id', valor: tramiteInfo.value.id, tipo: 'integer' },
        { nombre: 'p_tipo_documento', valor: uploadForm.value.tipoDocumento, tipo: 'string' },
        { nombre: 'p_nombre_archivo', valor: uploadForm.value.file.name, tipo: 'string' },
        { nombre: 'p_tipo_archivo', valor: uploadForm.value.file.type, tipo: 'string' },
        { nombre: 'p_tamano', valor: uploadForm.value.file.size, tipo: 'integer' },
        { nombre: 'p_contenido_base64', valor: base64, tipo: 'string' }
      ],
      'guadalajara'
    )

    clearInterval(progressInterval)
    uploadProgress.value = 100

    if (response && response.result && response.result[0]?.success) {
      showUploadModal.value = false
      await loadDocumentos()

      await Swal.fire({
        icon: 'success',
        title: 'Documento cargado',
        text: 'El documento ha sido cargado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Documento cargado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al cargar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    uploading.value = false
    uploadProgress.value = 0
  }
}

const fileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => {
      const base64 = reader.result.split(',')[1]
      resolve(base64)
    }
    reader.onerror = reject
    reader.readAsDataURL(file)
  })
}

const viewImage = async (doc) => {
  showLoading('Cargando documento...', 'Preparando visualización')

  try {
    const response = await execute(
      'carga_imagen_sp_get_document_image',
      'padron_licencias',
      [
        { nombre: 'p_document_id', valor: doc.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      selectedDoc.value = {
        ...doc,
        url_full: response.result[0].url || doc.url_thumbnail
      }
      showViewModal.value = true
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const downloadImage = async (doc) => {
  showToast('info', 'Descargando documento...')

  try {
    const response = await execute(
      'carga_imagen_sp_get_document_image',
      'padron_licencias',
      [
        { nombre: 'p_document_id', valor: doc.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      // Aquí iría la lógica real de descarga
      showToast('success', 'Documento descargado')
    }
  } catch (error) {
    handleApiError(error)
  }
}

const confirmDeleteImage = async (doc) => {
  const result = await Swal.fire({
    title: 'Eliminar documento',
    text: `¿Está seguro de eliminar el documento "${doc.tipo_documento}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteImage(doc)
  }
}

const deleteImage = async (doc) => {
  showLoading('Eliminando documento...', 'Procesando solicitud')

  try {
    const response = await execute(
      'carga_imagen_sp_delete_document_image',
      'padron_licencias',
      [
        { nombre: 'p_document_id', valor: doc.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await loadDocumentos()

      await Swal.fire({
        icon: 'success',
        title: 'Documento eliminado',
        text: 'El documento ha sido eliminado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Documento eliminado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatFileSize = (bytes) => {
  if (!bytes) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

const handleImageError = (event) => {
  event.target.src = '/placeholder-image.png'
}

// Lifecycle
onMounted(() => {
  // Inicialización si es necesaria
})

onBeforeUnmount(() => {
  showUploadModal.value = false
  showViewModal.value = false
})
</script>

<style scoped>
.tramite-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 600;
}

.info-item strong {
  font-size: 1rem;
  color: #2c3e50;
}

.documents-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 1.5rem;
}

.document-card {
  border: 1px solid #dee2e6;
  border-radius: 0.5rem;
  overflow: hidden;
  transition: all 0.3s ease;
}

.document-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.document-thumbnail {
  width: 100%;
  height: 200px;
  background: #f8f9fa;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.document-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.pdf-icon {
  color: #dc3545;
}

.document-info {
  padding: 1rem;
}

.document-info h6 {
  margin: 0 0 0.5rem 0;
  color: #2c3e50;
  font-size: 0.95rem;
  font-weight: 600;
}

.document-meta {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin: 0;
}

.document-meta small {
  color: #6c757d;
  font-size: 0.75rem;
}

.document-actions {
  display: flex;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-top: 1px solid #dee2e6;
  background: #f8f9fa;
}

.no-documents {
  grid-column: 1 / -1;
  text-align: center;
  padding: 3rem 1rem;
  color: #6c757d;
}

.file-drop-zone {
  border: 2px dashed #dee2e6;
  border-radius: 0.5rem;
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #f8f9fa;
}

.file-drop-zone:hover {
  border-color: #ea8215;
  background: #fff;
}

.file-drop-zone.drag-over {
  border-color: #ea8215;
  background: #fff5e6;
}

.file-drop-zone.has-file {
  border-color: #28a745;
  background: #f0f9f4;
}

.upload-icon {
  color: #ea8215;
  margin-bottom: 1rem;
}

.drop-zone-content p {
  margin: 0.5rem 0;
}

.file-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}

.upload-progress-bar {
  width: 100%;
  height: 30px;
  background: #e9ecef;
  border-radius: 0.25rem;
  overflow: hidden;
}

.upload-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #ea8215 0%, #c46e12 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  transition: width 0.3s ease;
}

.image-viewer {
  text-align: center;
}

.pdf-viewer {
  padding: 3rem;
}

.full-image {
  max-width: 100%;
  height: auto;
  border-radius: 0.5rem;
}

.alert {
  padding: 0.75rem 1rem;
  border-radius: 0.25rem;
  margin-top: 0.5rem;
}

.alert-danger {
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}
</style>
