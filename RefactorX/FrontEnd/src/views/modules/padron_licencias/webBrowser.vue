<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="globe" />
      </div>
      <div class="module-view-info">
        <h1>Navegador Web</h1>
        <p>Padrón de Licencias - Navegador Web Integrado</p>
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
          @click="openBookmarksModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="bookmark" />
          Marcadores
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Barra de navegación -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="browser-toolbar">
          <div class="nav-buttons">
            <button
              class="btn-municipal-secondary btn-sm"
              @click="goBack"
              :disabled="!canGoBack"
              title="Atrás"
            >
              <font-awesome-icon icon="arrow-left" />
            </button>
            <button
              class="btn-municipal-secondary btn-sm"
              @click="goForward"
              :disabled="!canGoForward"
              title="Adelante"
            >
              <font-awesome-icon icon="arrow-right" />
            </button>
            <button
              class="btn-municipal-secondary btn-sm"
              @click="reload"
              :disabled="loading"
              title="Recargar"
            >
              <font-awesome-icon icon="sync-alt" :spin="loading" />
            </button>
          </div>

          <div class="url-bar">
            <div class="url-input-wrapper">
              <font-awesome-icon icon="lock" class="url-icon" v-if="isSecure" />
              <font-awesome-icon icon="globe" class="url-icon" v-else />
              <input
                type="text"
                class="municipal-form-control url-input"
                v-model="currentUrl"
                @keyup.enter="navigateTo"
                placeholder="Ingrese una URL (ejemplo: https://tramites.gob.mx)"
              >
              <button
                class="btn-municipal-primary btn-sm go-button"
                @click="navigateTo"
                :disabled="!currentUrl"
              >
                <font-awesome-icon icon="arrow-right" />
                Ir
              </button>
            </div>
          </div>

          <div class="action-buttons">
            <button
              class="btn-municipal-secondary btn-sm"
              @click="addBookmark"
              :disabled="!currentUrl"
              title="Agregar a marcadores"
            >
              <font-awesome-icon icon="bookmark" />
            </button>
            <button
              class="btn-municipal-secondary btn-sm"
              @click="openInNewTab"
              :disabled="!currentUrl"
              title="Abrir en nueva pestaña"
            >
              <font-awesome-icon icon="external-link-alt" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Advertencia de seguridad -->
    <div class="municipal-card" v-if="showSecurityWarning">
      <div class="municipal-card-body security-warning">
        <div class="warning-content">
          <font-awesome-icon icon="exclamation-triangle" class="warning-icon" />
          <div class="warning-text">
            <h6>Advertencia de Seguridad</h6>
            <p>
              Está a punto de acceder a un sitio web externo. Por favor, asegúrese de que la URL sea confiable
              antes de continuar. No ingrese información sensible en sitios no verificados.
            </p>
          </div>
        </div>
        <div class="warning-actions">
          <button class="btn-municipal-secondary" @click="showSecurityWarning = false">
            Entendido
          </button>
        </div>
      </div>
    </div>

    <!-- Iframe del navegador -->
    <div class="municipal-card browser-container">
      <div class="municipal-card-body browser-card-body">
        <div v-if="!loadedUrl" class="browser-placeholder">
          <font-awesome-icon icon="globe" size="4x" class="placeholder-icon" />
          <h3>Bienvenido al Navegador Web</h3>
          <p>Ingrese una URL en la barra superior para comenzar a navegar</p>
          <div class="quick-links">
            <h6>Enlaces Rápidos:</h6>
            <div class="quick-link-buttons">
              <button
                v-for="link in quickLinks"
                :key="link.url"
                class="btn-municipal-primary btn-sm"
                @click="navigateToUrl(link.url)"
              >
                <font-awesome-icon :icon="link.icon" />
                {{ link.name }}
              </button>
            </div>
          </div>
        </div>

        <div v-if="loading && loadedUrl" class="loading-overlay">
          <div class="loading-spinner">
            <div class="spinner"></div>
            <p>Cargando página...</p>
          </div>
        </div>

        <iframe
          v-if="loadedUrl"
          :src="loadedUrl"
          class="browser-iframe"
          @load="onIframeLoad"
          sandbox="allow-scripts allow-same-origin allow-forms allow-popups"
        ></iframe>
      </div>
    </div>

    <!-- Modal de marcadores -->
    <Modal
      :show="showBookmarksModal"
      title="Marcadores Guardados"
      size="lg"
      @close="showBookmarksModal = false"
      :showDefaultFooter="false"
    >
      <div class="bookmarks-list">
        <div v-if="bookmarks.length === 0" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="bookmark" size="3x" />
          </div>
          <h4>Sin Marcadores</h4>
          <p>No hay marcadores guardados</p>
        </div>

        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Nombre</th>
                <th>URL</th>
                <th>Fecha Guardado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="bookmark in bookmarks"
                :key="bookmark.id"
                @click="selectedRow = bookmark"
                :class="{ 'table-row-selected': selectedRow === bookmark }"
                class="row-hover"
              >
                <td>
                  <font-awesome-icon icon="bookmark" class="text-primary" />
                  {{ bookmark.nombre }}
                </td>
                <td>
                  <code class="bookmark-url">{{ bookmark.url }}</code>
                </td>
                <td>
                  <small class="text-muted">
                    {{ formatDate(bookmark.fecha_guardado) }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="navigateToUrl(bookmark.url); showBookmarksModal = false"
                      title="Ir a este sitio"
                    >
                      <font-awesome-icon icon="arrow-right" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click.stop="deleteBookmark(bookmark)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="showBookmarksModal = false">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
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
      :componentName="'webBrowser'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Navegador Web'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
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
const currentUrl = ref('')
const loadedUrl = ref('')
const bookmarks = ref([])
const showBookmarksModal = ref(false)
const showSecurityWarning = ref(true)
const navigationHistory = ref([])
const currentHistoryIndex = ref(-1)
const selectedRow = ref(null)
const hasSearched = ref(false)
const loading = ref(false)

// Enlaces rápidos
const quickLinks = ref([
  { name: 'Trámites Digitales', url: 'https://www.gob.mx/tramites', icon: 'file-alt' },
  { name: 'Guadalajara', url: 'https://guadalajara.gob.mx', icon: 'landmark' },
  { name: 'SAT', url: 'https://www.sat.gob.mx', icon: 'money-bill' }
])

// Computed
const canGoBack = computed(() => currentHistoryIndex.value > 0)
const canGoForward = computed(() => currentHistoryIndex.value < navigationHistory.value.length - 1)
const isSecure = computed(() => currentUrl.value.startsWith('https://'))

// Métodos
const loadBookmarks = async () => {
  const startTime = performance.now()
  try {
    const response = await execute(
      'webbrowser_sp_get_bookmarks',
      'padron_licencias',
      [],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      bookmarks.value = response.result
      toast.value.duration = durationText
    }
  } catch (error) {
    handleApiError(error)
  }
}

const navigateTo = () => {
  if (!currentUrl.value) return

  let url = currentUrl.value.trim()

  // Añadir https:// si no tiene protocolo
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://' + url
    currentUrl.value = url
  }

  // Validar URL
  try {
    new URL(url)
  } catch (error) {
    showToast('error', 'URL inválida')
    return
  }

  navigateToUrl(url)
}

const navigateToUrl = (url) => {
  loading.value = true
  loadedUrl.value = url
  currentUrl.value = url

  // Agregar a historial
  navigationHistory.value.splice(currentHistoryIndex.value + 1)
  navigationHistory.value.push(url)
  currentHistoryIndex.value = navigationHistory.value.length - 1
}

const goBack = () => {
  if (canGoBack.value) {
    currentHistoryIndex.value--
    const url = navigationHistory.value[currentHistoryIndex.value]
    loadedUrl.value = url
    currentUrl.value = url
  }
}

const goForward = () => {
  if (canGoForward.value) {
    currentHistoryIndex.value++
    const url = navigationHistory.value[currentHistoryIndex.value]
    loadedUrl.value = url
    currentUrl.value = url
  }
}

const reload = () => {
  if (loadedUrl.value) {
    loading.value = true
    const temp = loadedUrl.value
    loadedUrl.value = ''
    setTimeout(() => {
      loadedUrl.value = temp
    }, 100)
  }
}

const onIframeLoad = () => {
  loading.value = false
}

const addBookmark = async () => {
  if (!currentUrl.value) return

  const { value: bookmarkName } = await Swal.fire({
    title: 'Guardar Marcador',
    input: 'text',
    inputLabel: 'Nombre del marcador',
    inputValue: currentUrl.value,
    inputPlaceholder: 'Ingrese un nombre para este marcador',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Guardar',
    cancelButtonText: 'Cancelar',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar un nombre'
      }
    }
  })

  if (bookmarkName) {
    const startTime = performance.now()
    try {
      const usuario = localStorage.getItem('usuario') || 'sistema'
      const response = await execute(
        'webbrowser_sp_save_bookmark',
        'padron_licencias',
        [
          { nombre: 'p_nombre', valor: bookmarkName, tipo: 'string' },
          { nombre: 'p_url', valor: currentUrl.value, tipo: 'string' },
          { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
        ],
        'guadalajara'
      )

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

      if (response && response.result && response.result[0]?.success) {
        showToast('success', 'Marcador guardado exitosamente')
        toast.value.duration = durationText
        loadBookmarks()
      } else {
        showToast('error', 'Error al guardar marcador')
      }
    } catch (error) {
      handleApiError(error)
    }
  }
}

const deleteBookmark = async (bookmark) => {
  const result = await Swal.fire({
    title: '¿Eliminar marcador?',
    text: `¿Está seguro de eliminar el marcador "${bookmark.nombre}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    const startTime = performance.now()
    try {
      const response = await execute(
        'webbrowser_sp_delete_bookmark',
        'padron_licencias',
        [
          { nombre: 'p_id', valor: bookmark.id, tipo: 'integer' }
        ],
        'guadalajara'
      )

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

      if (response && response.result && response.result[0]?.success) {
        showToast('success', 'Marcador eliminado')
        toast.value.duration = durationText
        loadBookmarks()
      }
    } catch (error) {
      handleApiError(error)
    }
  }
}

const openBookmarksModal = () => {
  loadBookmarks()
  showBookmarksModal.value = true
}

const openInNewTab = () => {
  if (currentUrl.value) {
    window.open(currentUrl.value, '_blank')
  }
}

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

// Lifecycle
onMounted(() => {
  loadBookmarks()
})

onBeforeUnmount(() => {
  showBookmarksModal.value = false
})
</script>

<style scoped>
.browser-toolbar {
  display: flex;
  gap: 1rem;
  align-items: center;
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 0.5rem;
}

.nav-buttons {
  display: flex;
  gap: 0.5rem;
}

.url-bar {
  flex: 1;
}

.url-input-wrapper {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: white;
  padding: 0.5rem;
  border-radius: 0.375rem;
  border: 1px solid #dee2e6;
}

.url-icon {
  color: #6c757d;
  margin-left: 0.25rem;
}

.url-input {
  flex: 1;
  border: none;
  outline: none;
  padding: 0;
}

.go-button {
  white-space: nowrap;
}

.action-buttons {
  display: flex;
  gap: 0.5rem;
}

.security-warning {
  background: #fff3cd;
  border-left: 4px solid #ffc107;
}

.warning-content {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.warning-icon {
  color: #ffc107;
  font-size: 2rem;
  flex-shrink: 0;
}

.warning-text h6 {
  margin: 0 0 0.5rem 0;
  color: #856404;
  font-weight: 600;
}

.warning-text p {
  margin: 0;
  color: #856404;
}

.warning-actions {
  text-align: right;
}

.browser-container {
  min-height: 600px;
  height: calc(100vh - 400px);
}

.browser-card-body {
  position: relative;
  height: 100%;
  padding: 0;
}

.browser-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 3rem;
  text-align: center;
  color: #6c757d;
}

.placeholder-icon {
  color: #dee2e6;
  margin-bottom: 1.5rem;
}

.browser-placeholder h3 {
  margin-bottom: 0.5rem;
  color: #495057;
}

.quick-links {
  margin-top: 2rem;
  width: 100%;
  max-width: 600px;
}

.quick-links h6 {
  margin-bottom: 1rem;
  color: #495057;
}

.quick-link-buttons {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
  justify-content: center;
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.loading-spinner {
  text-align: center;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #ea8215;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem auto;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.browser-iframe {
  width: 100%;
  height: 100%;
  border: none;
  min-height: 500px;
}

.bookmarks-list {
  min-height: 300px;
}

.bookmark-url {
  font-size: 0.875rem;
  color: #6c757d;
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  display: inline-block;
  max-width: 400px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.modal-actions {
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
  text-align: right;
}
</style>
