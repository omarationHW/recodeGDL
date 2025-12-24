<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="palette" /></div>
      <div class="module-view-info">
        <h1>Aspecto del Sistema — Estacionamientos Públicos</h1>
        <p>Configuración visual del sistema</p>
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
        <button
          class="btn-municipal-secondary"
          :disabled="loading"
          @click="cargar"
        >
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Aspecto Actual -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="check-circle" /> Aspecto Actual
        </div>
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-3">
            <div class="spinner-border text-primary"></div>
          </div>
          <div v-else-if="actual" class="d-flex align-items-center gap-3">
            <div class="aspecto-preview" :style="{ backgroundColor: actual.color || '#ea8215' }">
              <font-awesome-icon icon="palette" size="2x" />
            </div>
            <div>
              <h4 class="mb-1">{{ actual.nombre || 'Sin nombre' }}</h4>
              <p class="text-muted mb-0">{{ actual.descripcion || 'Aspecto activo del sistema' }}</p>
            </div>
          </div>
          <div v-else class="text-muted">
            <font-awesome-icon icon="info-circle" /> No hay aspecto configurado
          </div>
        </div>
      </div>

      <!-- Catálogo de Aspectos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge d-flex justify-content-between">
          <span><font-awesome-icon icon="list" /> Catálogo de Aspectos</span>
          <span class="badge bg-secondary">{{ aspectos.length }} disponibles</span>
        </div>
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-3">
            <div class="spinner-border text-primary"></div>
          </div>

          <div v-else-if="aspectos.length === 0" class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon mb-2" />
            <p>No hay aspectos disponibles</p>
          </div>

          <div v-else class="table-responsive">
            <table class="table table-striped table-hover">
              <thead class="table-dark">
                <tr>
                  <th>ID</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th>Color</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="a in paginatedAspectos" :key="a.id || a.nombre">
                  <td>{{ a.id }}</td>
                  <td>{{ a.nombre }}</td>
                  <td>{{ a.descripcion || '-' }}</td>
                  <td>
                    <span
                      class="color-badge"
                      :style="{ backgroundColor: a.color || '#ccc' }"
                    ></span>
                    {{ a.color || '-' }}
                  </td>
                  <td>
                    <span :class="a.activo ? 'badge bg-success' : 'badge bg-secondary'">
                      {{ a.activo ? 'Activo' : 'Inactivo' }}
                    </span>
                  </td>
                  <td>
                    <button
                      v-if="!a.activo"
                      class="btn-municipal-primary btn-sm"
                      @click="seleccionarAspecto(a)"
                      :disabled="loading"
                    >
                      <font-awesome-icon icon="check" /> Activar
                    </button>
                    <span v-else class="text-success">
                      <font-awesome-icon icon="check-circle" /> Actual
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Paginación -->
            <div v-if="aspectos.length > itemsPerPage" class="d-flex justify-content-between align-items-center mt-3">
              <div class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, aspectos.length) }} de {{ aspectos.length }} registros
              </div>
              <nav>
                <ul class="pagination pagination-sm mb-0">
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="currentPage = 1" :disabled="currentPage === 1">
                      <font-awesome-icon icon="angles-left" />
                    </button>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="currentPage--" :disabled="currentPage === 1">
                      <font-awesome-icon icon="angle-left" />
                    </button>
                  </li>
                  <li v-for="page in visiblePages" :key="page" class="page-item" :class="{ active: currentPage === page }">
                    <button class="page-link" @click="currentPage = page">{{ page }}</button>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <button class="page-link" @click="currentPage++" :disabled="currentPage === totalPages">
                      <font-awesome-icon icon="angle-right" />
                    </button>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <button class="page-link" @click="currentPage = totalPages" :disabled="currentPage === totalPages">
                      <font-awesome-icon icon="angles-right" />
                    </button>
                  </li>
                </ul>
              </nav>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'AspectoPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Aspecto del Sistema'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const aspectos = ref([])
const actual = ref(null)

// Paginación
const itemsPerPage = 10
const currentPage = ref(1)

const totalPages = computed(() => Math.ceil(aspectos.value.length / itemsPerPage))

const paginatedAspectos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return aspectos.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value
  const delta = 2

  let start = Math.max(1, current - delta)
  let end = Math.min(total, current + delta)

  if (current - delta <= 1) {
    end = Math.min(total, 1 + delta * 2)
  }
  if (current + delta >= total) {
    start = Math.max(1, total - delta * 2)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

async function cargar() {
  showLoading('Cargando...', 'Obteniendo aspectos')
  aspectos.value = []
  actual.value = null

  try {
    // Cargar lista de aspectos
    const respAspectos = await execute('sp_get_aspectos', BASE_DB, [], '', null, SCHEMA)
    const dataAspectos = respAspectos?.result || respAspectos?.data?.result || respAspectos?.data || []
    aspectos.value = Array.isArray(dataAspectos) ? dataAspectos : []

    // Cargar aspecto actual
    const respActual = await execute('sp_get_current_aspecto', BASE_DB, [], '', null, SCHEMA)
    const dataActual = respActual?.result || respActual?.data?.result || respActual?.data || []
    actual.value = Array.isArray(dataActual) ? dataActual[0] : dataActual

    hideLoading()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  }
}

async function seleccionarAspecto(aspecto) {
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Cambiar Aspecto',
    text: `¿Activar el aspecto "${aspecto.nombre}"?`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, activar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Aplicando...', 'Cambiando aspecto del sistema')
  try {
    const params = [
      { nombre: 'p_aspecto_id', valor: aspecto.id, tipo: 'integer' }
    ]

    const resp = await execute('sp_set_aspecto', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Aspecto Actualizado',
        text: `Se activó el aspecto "${aspecto.nombre}"`,
        timer: 2000,
        timerProgressBar: true,
        showConfirmButton: false
      })
      cargar()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo cambiar el aspecto'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
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

onMounted(() => {
  cargar()
})
</script>

<style>
.color-badge {
  display: inline-block;
  width: 24px;
  height: 24px;
  border-radius: 4px;
  border: 1px solid #ddd;
  margin-right: 8px;
  vertical-align: middle;
}

.aspecto-preview {
  width: 80px;
  height: 80px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>
