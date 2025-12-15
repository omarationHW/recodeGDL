<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="globe" />
      </div>
      <div class="module-view-info">
        <h1>Navegador Web</h1>
        <p>Padrón de Licencias - Navegador Web Integrado</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
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
          <font-awesome-icon icon="bookmark" size="2x" class="empty-icon" />
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
              <tr v-for="bookmark in bookmarks" :key="bookmark.id" class="clickable-row">
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
                      @click="navigateToUrl(bookmark.url); showBookmarksModal = false"
                      title="Ir a este sitio"
                    >
                      <font-awesome-icon icon="arrow-right" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="deleteBookmark(bookmark)"
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

    <!-- Toast Notification -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'webBrowser'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const currentUrl = ref('')
const loadedUrl = ref('')
const bookmarks = ref([])
const showBookmarksModal = ref(false)
const showSecurityWarning = ref(true)
const navigationHistory = ref([])
const currentHistoryIndex = ref(-1)

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
      'guadalajara',
      null,
      'publico'
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
  setLoading(true)
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
    setLoading(true)
    const temp = loadedUrl.value
    loadedUrl.value = ''
    setTimeout(() => {
      loadedUrl.value = temp
    }, 100)
  }
}

const onIframeLoad = () => {
  setLoading(false)
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
        'guadalajara',
      null,
      'publico'
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
        'guadalajara',
      null,
      'publico'
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

